`timescale 1ns / 1ps
`default_nettype none

module handle_spi #(parameter ZSPI_WORDSIZE=8) (
	input wire sysclk,
	input wire rst,
	input wire SPI_SS,
	input wire SPI_MOSI,
	input wire SPI_MISO,
	input wire SPI_SCLK,
	output wire SPI_done,

	output wire [8*16-1:0] ctrl_regs_longarray,
	input wire [7:0] adc_data_out_word
);

reg [ZSPI_WORDSIZE-1:0] ctrl_regs [15:0];

genvar i;
generate for (i = 0; i < 16; i = i + 1) begin:convertoarray
	assign ctrl_regs_longarray[ZSPI_WORDSIZE*i +: ZSPI_WORDSIZE] = ctrl_regs[i];
end endgenerate

//wire SPI_done;

// RX: most recent received message
// TX: next word to be sent
reg [7:0] SPI_tx_reg; // to be transmitted
reg [7:0] SPI_rx_reg; // most recent received
//reg [3:0] SPI_cmd; // SPI command
reg [3:0] SPI_addr; // address in SPI command

wire [7:0] SPI_s; 

spi_slave #(.WORDSIZE(ZSPI_WORDSIZE)) spi_slave_inst(
	.clk(sysclk),
	.rst(rst),
	.ss(SPI_SS), // ACTIVE LOW
	.mosi(SPI_MOSI),
	.miso(SPI_MISO),
	.sck(SPI_SCLK),
	.done(SPI_done),
	.din(SPI_tx_reg),
	.dout(SPI_s)
);


// store slave's data
always @(posedge sysclk) begin
if ( SPI_done ) begin
 SPI_rx_reg <= SPI_s;
end
end

// 16 control registers
//reg [ZSPI_WORDSIZE-1:0] ctrl_regs [15:0];


// state machine outputs
wire rd_select, wr_select, latch_cmd;

// handle the read and write 
always @(posedge sysclk ) begin
	//ctrl_regs[9] <= ZYNQ_RD_EN;
	
	// preload some registers
	if (rst) begin
		ctrl_regs[0] <= 8'h00; // bottom 8 bits of ADC_sample_num
		ctrl_regs[1] <= 8'h04; // top 8 bits of ADC_sample_num
		ctrl_regs[2] <= 8'h00; // bottom 8 bits of ZYNQ_word_num
		ctrl_regs[3] <= 8'h10; // top 8 bits of ZYNQ_word_num
		
		ctrl_regs[4] <= 8'h00; // bottom 8 bits of trigger delay offset
		ctrl_regs[5] <= 8'h00; // top 8 bits of trigger delay offset
		
		ctrl_regs[6] <= 8'h09; // ADC mode (free-running or test pattern)
		ctrl_regs[7] <= 8'h00; // Which module to test, lvds_rec.v, lvdsrec.vhd, or sc
		ctrl_regs[8] <= 8'h00; // Send out top 8 bits, bottom 8 bits of data out, or both
				
		ctrl_regs[10] <= 8'h00; // trigger
		ctrl_regs[11] <= 8'h00; // read_request (for single_channel test only)
		ctrl_regs[12] <= 8'h00; // Reset by zynq
	end
	
	else if ( rd_select) begin
    	SPI_tx_reg <= ctrl_regs[SPI_addr];
	end 
	
	else if ( wr_select ) begin
		ctrl_regs[SPI_addr] <= SPI_rx_reg;
	end
	
	else begin
		SPI_tx_reg <= adc_data_out_word;
	end
end

// store the command and associated address data
always @(posedge sysclk ) begin
	if ( latch_cmd ) begin
    	SPI_addr <= SPI_rx_reg[7:4]; 
    	//SPI_cmd <= SPI_rx_reg[3:0];
	end
end
   
SPI_SM sm( // State machine for SPI slave on CycloneIII
	.rd_select(rd_select),
	.wr_select(wr_select),
	.latch_cmd(latch_cmd),
	.cmd(SPI_rx_reg[3:0]), // SPI_cmd, before latched
	.done(SPI_done),
	.clk(sysclk),
	.rst(rst) 
);

endmodule