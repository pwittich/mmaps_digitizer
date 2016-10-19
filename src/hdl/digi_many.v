`timescale 1ns / 1ps
`default_nettype none

  // CREATED            "Tue Mar  8 16:23:03 2016"
  // module to hold several channels of digitized ADC input.
  // contains the ADC input, a circular buffer, and logic to
  // send the data out to the ZYNQ
  module digi_many
    #(parameter SIZE=8, WIDTH=12, CHAN=8)
   (
    input wire  RST,
    input wire  CK50,
	 input wire DAVAIL,
	 input wire EOS,
    input wire [CHAN-1:0] adcdata_p, // serial data - one per channel
    input wire adc_clk,
    input wire adc_frame,
	 input wire	[11:0] ADC_sample_num,
    input wire [SIZE-1:0]  offset,
    output wire [WIDTH-1:0] DOUT,
	 input wire SPI_done,
	 output wire ZYNQ_RD_EN_out,
	 output wire debug
    );
	 
	 
   wire 	CLK;
   wire 	RESET; 
	 
	// mappings to outside
   assign       CLK = CK50;
   assign       RESET = RST;
	 
	assign DOUT = DOUT_i;
	assign ZYNQ_RD_EN_out = ZYNQ_RD_EN;
	
	
	wire [CHAN-1:0] RODONE_n;
	reg [CHAN-1:0] TRIGGER;
	reg EOS_ALLOWED;
	
		
	always @ (posedge CLK) begin
		if (RST) begin
			EOS_ALLOWED <= 1'b1;
			TRIGGER <= {CHAN{1'b0}};
		end
		else if (ZYNQ_RD_EN) begin
			if (EOS && EOS_ALLOWED) begin
				EOS_ALLOWED <= 1'b0;
				TRIGGER <= {CHAN{1'b1}};
			end
			else begin
				if (!RODONE_n[SEL]) begin
					TRIGGER[SEL] <= 1'b0;
				end
			end
		end
		else begin
			EOS_ALLOWED <= 1'b1;
		end
	end
	
	wire SPI_complete;
	wire ZYNQ_RD_EN;
	
	wire [CHAN-1:0] debugs;
	assign debug = debugs[0];
	
	assign SPI_complete = ~(|TRIGGER);
   
   // generate channels for output
   wire [12*CHAN-1:0] DOUT_F; // output from each channel
   wire [CHAN-1:0] 	 RD_REQUEST; // readout  request to each channel
   // channels
   genvar 		 i;
   generate
      for (i=0;i<CHAN;i=i+1) 
        begin : channel_gen
           single_channel sc(
			     .clk(CLK),
			     .reset(RESET),
			     .adc_data_ready(DAVAIL),
			     .adc_data_p(adcdata_p[i]),
			     .adc_fast_clk(adc_clk),
			     .adc_frame(adc_frame),
			     .how_many(ADC_sample_num),
			     .offset(offset),
			     .read_request(RD_REQUEST[i]),
			     .trigger(TRIGGER[i]),
			     .data_out(DOUT_F[(i*12+(12-1)):i*12]),
				  .RODONE_n_out(RODONE_n[i]),
				  .SPI_done(SPI_done),
				  .debug(debugs[i])
			     );
        end // for (i=0;i<CHAN;i=i+1)
   endgenerate
	
// 	always @ (posedge CLK) begin
//		DOUT_F[11:0] <= 12'h111;
//		DOUT_F[23:12] <= 12'h222;
//		DOUT_F[35:24] <= 12'h333;
//		DOUT_F[47:36] <= 12'h444;
//		DOUT_F[59:48] <= 12'h555;
//		DOUT_F[71:60] <= 12'h666;
//		DOUT_F[83:72] <= 12'h777;
//		DOUT_F[95:84] <= 12'h888;
//	end

   reg [15:0] DOUT_i;
   wire [2:0] SEL;
	
   // priority encoder. Select numerically highest channel that fired.
   enc enc1(.in(TRIGGER), .out(SEL));
	
   // multiplexer for the data from the channels
   // HARDWIRED TO EIGHT HERE - SHOULD BE CHAN instead
   always @(SEL, DOUT_F)
     case (SEL)
       3'b000: DOUT_i = {DOUT_F[11:0], 4'h0};
       3'b001: DOUT_i = {DOUT_F[23:12], 4'h0};
       3'b010: DOUT_i = {DOUT_F[35:24], 4'h0};
       3'b011: DOUT_i = {DOUT_F[47:36], 4'h0};
       3'b100: DOUT_i = {DOUT_F[59:48], 4'h0};
       3'b101: DOUT_i = {DOUT_F[71:60], 4'h0};
       3'b110: DOUT_i = {DOUT_F[83:72], 4'h0};
       3'b111: DOUT_i = {DOUT_F[95:84], 4'h0};
     endcase
	
	demux #(.N(8)) dm1(.in(ZYNQ_RD_EN), .sel(SEL), .out(RD_REQUEST));
	
	// Simple state machine to handle overall zynq readout
	multi_chn_readout multi_chn_rd_inst (
				.clk(CLK),
				.reset(RST),
				.SPI_complete(SPI_complete),
				.EOS(EOS),
				.ZYNQ_RD_EN(ZYNQ_RD_EN)
	);
   

   // Bunch counter - to tag the data for timing and later identification.
   // not clear if this is the right number of bits. Needs to fit into fifo?
   //localparam BC_BITS=12;
//	localparam BC_BITS=5;
//   wire [BC_BITS-1:0] 	    BC;
//   bc_counter #(.BITS(BC_BITS)) bc_counter_inst(.CLK(CLK), .RST(RESET), .BC(BC) );
   
	
//   wire 	    BCSEL; 
//   assign BCSEL = WR_EN & ~SEL_ONE; 
//   always @(BCSEL,SEL,BC,DOUT_i) 
//     case (BCSEL)
//       1'b0: FIFO_DIN = DOUT_i; // width needs to be checked
//       //1'b1: FIFO_DIN = {1'b0,SEL, BC};
//		 1'b1: FIFO_DIN = {SEL, BC};
//     endcase
   

endmodule
