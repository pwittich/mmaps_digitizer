`timescale 1ns / 1ps
`default_nettype none

  // CREATED            "Tue Mar  8 16:23:03 2016"

  module digi_many
    #(parameter SIZE=8, WIDTH=12, CHAN=8)
   (
    input wire  RST,
    input wire  CK50,
    input wire [CHAN-1:0] DAVAIL,
    input wire [CHAN-1:0] TRIGGER,
    input wire [CHAN-1:0] adcdata_p, // serial data - one per channel
    input wire adc_clk,
    input wire adc_frame,
    input wire [SIZE-1:0]  howmany,
    input wire [SIZE-1:0]  offset,
    //input wire [2:0] SEL,
    output wire [WIDTH-1:0] DOUT,
    //input wire  [CHAN-1:0]      RD_REQUEST,
    input wire ZYNQ_RD_REQUEST,
    output wire GLBL_FULL,
    output wire GLBL_EMPTY
    );
   



   wire 		  CLK;
   //wire [SIZE-1:0] 	  RD_ADDR;
   wire 		  RESET;
   //wire 		  RO_ENABLE;
   //wire 		  WR_ENABLE;
   

   wire [WIDTH*CHAN-1:0]  DOUT_F; // output from each channel
   wire [CHAN-1:0] RD_REQUEST; // readout  request to each channel
   // channels
   genvar 		  i;
   generate
      for (i=0;i<CHAN;i=i+1) 
        begin : channel_gen
           single_channel sc(
			     .CLK(CLK),
			     .RESET(RESET),
			     .DAVAIL(DAVAIL[i]),
			     .adcdata_p(adcdata_p[i]),
				  .adc_fastclk(adc_clk),
				  .adc_frame(adc_frame),
			     .howmany(howmany),
			     .offset(offset),
			     .rd_request(RD_REQUEST[i]),
			     .TRIGGER(TRIGGER[i]),
			     .DOUT(DOUT_F[(i*WIDTH+(WIDTH-1)):i*WIDTH])
			     );
        end // for (i=0;i<CHAN;i=i+1)
   endgenerate

   reg [15:0] DOUT_i;
   wire [2:0] SEL;
   // priority encoder. Select numerically highest channel that fired.
   enc enc1(.in(TRIGGER), .out(SEL));
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
   
      
   multi_ro multi_ro_inst(
			  .CHSEL(SEL_ONE),
			  .WR_EN(WR_EN),
			  .CLK(CLK),
			  .RST(RESET),
			  .DAVAIL(|TRIGGER)
			  );
   

   wire       GLBL_RD_REQUEST;
   wire [WIDTH-1:0] GLBL_DOUT;
   
   wire [SIZE-1:0]  LOCL_ADDR;

   reg [WIDTH-1:0] FIFO_DIN; 
   // this is not parameterized either
   fifo fifo_inst(.clock(CLK),
		  .sclr(RESET),
		  .data(FIFO_DIN),
		  .wrreq(WR_EN),
		  .rdreq(GLBL_RD_REQUEST),
		  .q(DOUT),
		  .full(GLBL_FULL),
		  .empty(GLBL_EMPTY)
		  );
   wire [11:0] BC;
   bc_counter bc_counter_inst(.CLK(CLK),
    .RST(RESET),
    .BC(BC)
    );
   wire BCSEL; 
   assign BCSEL = WR_EN & ~SEL_ONE; 
   always @(BCSEL,SEL,BC,DOUT_i) 
     case (BCSEL)
        1'b0: FIFO_DIN = DOUT_i; // width needs to be checked
        1'b1: FIFO_DIN = {1'b0,SEL, BC};
     endcase


   // mappings to outside
   assign GLBL_RD_REQUEST = ZYNQ_RD_REQUEST;
   assign GLBL_DOUT = DOUT;
   assign       CLK = CK50;
   assign       RESET = RST;
   

endmodule
