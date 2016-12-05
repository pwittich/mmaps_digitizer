`timescale 1ns / 1ps
`default_nettype none

  // CREATED            07.10.2016
  // module to hold several channels of digitized ADC input.
  // contains the ADC input, a circular buffer, and logic to
  // send the data out to the ZYNQ
  module digi_many_stream
    #(parameter SIZE=8, WIDTH=12, CHAN=8)
   (
    input wire  RST,
    input wire  CLK,
    input wire [CHAN-1:0] DAVAIL,
    input wire EOS, // end of spill
    input wire [CHAN-1:0] adcdata_p, // serial data - one per channel
    input wire adc_clk,
    input wire adc_frame,
    input wire [SIZE-1:0]  howmany,
    input wire [SIZE-1:0]  offset,
    output wire [WIDTH-1:0] DOUT,
    input wire rd_request,
    input wire [$clog2(CHAN)-1:0] rd_ch_sel
    );
   



   
   // generate channels for output
   wire [WIDTH*CHAN-1:0] DOUT_F; // output from each channel

   
   // channels
   genvar 		 i;
   generate
      for (i=0;i<CHAN;i=i+1) 
        begin : channel_gen
           single_channel sc(
			     .clk(CLK),
			     .reset(RST),
			     .adc_data_ready(DAVAIL[i]),
			     .adc_data_p(adcdata_p[i]),
			     .adc_fast_clk(adc_clk),
			     .adc_frame(adc_frame),
			     .how_many(howmany),
			     .offset(offset),
			     .read_request(RD_REQUEST[i]),
			     .trigger(EOS), // signals end of spill to all channels
			     .data_out(DOUT_F[(i*WIDTH+(WIDTH-1)):i*WIDTH])
			     );
        end // for (i=0;i<CHAN;i=i+1)
   endgenerate

   reg [15:0] DOUT_i;
   // priority encoder. Select numerically highest channel that fired.
   enc enc1(.in(TRIGGER), .out(rd_ch_sel));
   // multiplexer for the data from the channels
   // HARDWIRED TO EIGHT HERE - SHOULD BE CHAN instead
   always @(SEL, DOUT_F)
     case (SEL)
       3'b000: DOUT_i = DOUT_F[11:0];
       3'b001: DOUT_i = DOUT_F[23:12];
       3'b010: DOUT_i = DOUT_F[35:24];
       3'b011: DOUT_i = DOUT_F[47:36];
       3'b100: DOUT_i = DOUT_F[59:48];
       3'b101: DOUT_i = DOUT_F[71:60];
       3'b110: DOUT_i = DOUT_F[83:72];
       3'b111: DOUT_i = DOUT_F[95:84];
     endcase
   
   wire       WR_EN;
   wire       SEL_ONE;
   demux #(.N(8)) dm1(.in(SEL_ONE), .sel(SEL),.out(RD_REQUEST));
   
   
   wire [SIZE-1:0]  LOCL_ADDR;

   

endmodule
