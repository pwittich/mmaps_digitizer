`timescale 1ns / 1ps
`default_nettype none

// CREATED            "Tue Mar  8 16:23:03 2016"
// module to hold several channels of digitized ADC input.
// contains the ADC input, a circular buffer, and logic to
// send the data out to the ZYNQ
module digi_many #(parameter DATA_WIDTH=12, CHAN=8) (
	input wire  RST,
	input wire 	SYSCLK,
	input wire	DAVAIL,
	input wire	EOS,
	input wire	[CHAN-1:0] adcdata, // serial data: 1 / channel
	input wire	adc_clk,
	input wire	adc_frame,
	input wire	[11:0] ADC_sample_num,
	input wire	[15:0] trigger_delay,
	output wire	[DATA_WIDTH-1:0] DOUT,
	input wire	SPI_done,
	output wire	ZYNQ_RD_EN
);

localparam ADC_WIDTH = 12;
	 
wire [CHAN-1:0] RODONE_n;
reg  [CHAN-1:0] TRIGGER;
reg 			EOS_ALLOWED;

reg [15:0] delay_counter;

// This block waits for an EOS signal (which is really
// the original trigger signal) in the form of ZYNQ_RD_EN 
// (see the multi-channel readout SM) and then triggers all
// the channels at once. When triggered each channel stops
// recording data and waits for its turn in the readout chain.
// If there is a trigger delay offset then the code waits until
// the delay is finished to issue the channel triggers.
always @ (posedge SYSCLK) begin
	if (RST) begin
		EOS_ALLOWED <= 1'b1;
		TRIGGER <= {CHAN{1'b0}};
		delay_counter <= trigger_delay;
	end
	else if (ZYNQ_RD_EN) begin
		if (EOS_ALLOWED) begin
			if (trigger_delay == 16'h0000) begin
				EOS_ALLOWED <= 1'b0;
				TRIGGER <= {CHAN{1'b1}};
			end else if (delay_counter == 16'h0001) begin
				EOS_ALLOWED <= 1'b0;
				TRIGGER <= {CHAN{1'b1}};
				delay_counter <= delay_counter - 1'b1;
			end else begin
				delay_counter <= delay_counter - 1'b1;
			end
		end
		else begin
			if (!RODONE_n[SEL]) begin
				TRIGGER[SEL] <= 1'b0;
			end
		end
	end
	else begin
		EOS_ALLOWED <= 1'b1;
		delay_counter <= trigger_delay;
	end
end
	
wire SPI_complete;

// SPI transfer of data is finished when all trigger flags are
// back to 0 and trigger delay is either finished or 0.
assign SPI_complete = ~(|TRIGGER) & ~(|delay_counter);
	
// Generate channels for output.
wire [ADC_WIDTH*CHAN-1:0] DOUT_F; // output from each channel
wire [CHAN-1:0] 	 RD_REQUEST; // readout request to each channel

// Generates instances of all singlechannels. Each outputs its data
// via the DOUT_F variable.
genvar 		 i;
generate
	for (i=0;i<CHAN;i=i+1) 
	begin : channel_gen
		single_channel sc(
			.clk(SYSCLK),
			.reset(RST),
			.adc_data_ready(DAVAIL),
			.adc_data(adcdata[i]),
			.adc_fast_clk(adc_clk),
			.adc_frame(adc_frame),
			.how_many(ADC_sample_num),
			.read_request(RD_REQUEST[i]),
			.trigger(TRIGGER[i]),
			.data_out(DOUT_F[(i+1)*ADC_WIDTH-1 -: ADC_WIDTH]),
			.RODONE_n_out(RODONE_n[i]),
			.SPI_done(SPI_done)
		);
	end
endgenerate

// Make fake data to test multiple channels, instead
// of using real data from single_channel. To use uncomment
// below and comment out output .data_out from single_channel;
// also change type of DOUT_F from wire to reg.
//
//	integer k;
//	always @ (posedge SYSCLK) begin
//		for (k = 0; k < CHAN; k = k + 1)
//			DOUT_F[(k+1)*ADC_WIDTH-1 -: ADC_WIDTH] <= {(ADC_WIDTH/4){k[3:0]}};
//	end


// Calculates the number of bits in input n.
function integer clog2 (input integer n); 
integer j; 
begin 
	n = n - 1;
	for (j = 0; n > 0; j = j + 1)        
		n = n >> 1;
	clog2 = j;
end
endfunction


wire [clog2(CHAN)-1:0] SEL;
	
// Priority encoder. Select numerically lowest channel that's
// still triggered.
enc #(.SIZE(clog2(CHAN))) enc1(.in(TRIGGER), .out(SEL));
	

// Multiplexer for the data from the channels
// Last 4 bits are up for grabs (maybe channel id?)

//	integer j;
//	always @ (*) begin
//		for (j = 0; j < CHAN; j = j + 1)
//			if (SEL == j)
//				DOUT = {DOUT_F[(j+1)*ADC_WIDTH-1 -: ADC_WIDTH], 4'h0};
//	end
	
// More concise version of multiplexer. Takes all 16 singlechannel
// outputs and puts into one big register, padding the extra 4 bits
// with 0's (12-bit ADC + 4 0's = 16 bits).
assign DOUT = {DOUT_F[(SEL+1)*ADC_WIDTH-1 -: ADC_WIDTH], 4'h0};
	

// Demux to choose rd_request line for active channel (SEL).
// If we are still in the state ZYNQ_RD_EN (i.e. reading out data),
// then SEL gives which channel we want to read out next, which we
// do by asserting the RD_REQUEST line.
demux #(.N(CHAN)) dm1(.in(ZYNQ_RD_EN), .sel(SEL), .out(RD_REQUEST));


// Simple state machine to handle overall zynq readout. Basic idea
// is that EOS (End-Of-Spill) changes state from acquiring data
// continuously to triggered, where all channels stop acquisition.
// Then we read out channel by channel until all are done, at which
// point we revert back to the running state.
multi_chn_readout_SM multi_chn_SM (
	.clk(SYSCLK),
	.reset(RST),
	.SPI_complete(SPI_complete),
	.EOS(EOS),
	.ZYNQ_RD_EN(ZYNQ_RD_EN)
);
   

// NOT USED RIGHT NOW - AF 12/14/16
// Bunch counter - to tag the data for timing and later identification.
// not clear if this is the right number of bits. Needs to fit into fifo?
// localparam BC_BITS=12;
// localparam BC_BITS=5;
// wire [BC_BITS-1:0] 	    BC;
// bc_counter #(.BITS(BC_BITS)) bc_counter_inst(.CLK(SYSCLK), .RST(RST), .BC(BC) );
   

endmodule