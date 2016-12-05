`timescale 1ns / 1ps
`default_nettype none

  // CREATED		"Tue Mar  8 16:23:03 2016"
  // single channel digitizer

  module digi
    #(parameter SIZE=8, WIDTH=16)
   (
    input wire	RST,
    input wire	CK50,
    input wire	DAVAIL,
    input wire	TRIGGER,
    input wire [WIDTH-1:0] adcdata_p,
    input wire [SIZE-1:0]  howmany,
    input wire [SIZE-1:0]  offset,
    output wire [WIDTH-1:0] dout,
    input wire 	      rd_request
    );
   



   wire 	      CLK;
   wire [SIZE-1:0]    RD_ADDR;
   wire 	      RESET;
   wire 	      RO_ENABLE;
   wire 	      WR_ENABLE;
   wire [SIZE-1:0]    SYNTHESIZED_WIRE_0;
   wire 	      SYNTHESIZED_WIRE_1;



   // single channel 

   ringbuffer	ringbuffer_inst0(
				 .clk(CLK),
				 .wr_en(WR_ENABLE),
				 .rd_en(RO_ENABLE),
				 .rst(RESET),
				 .ain(SYNTHESIZED_WIRE_0),
				 .din(adcdata_p),
				 .aout(RD_ADDR),
				 .dout(dout));
   defparam	ringbuffer_inst0.SIZE = SIZE;
   defparam	ringbuffer_inst0.WIDTH = WIDTH;

   wire 	      RO_DONE_n;

   SM1	channel_sm(
		   .DAVAIL(DAVAIL),
		   .ROREQUEST(rd_request),
		   .TRIGGER(TRIGGER),
		   .clk(CLK),
		   .rst(RESET),
		   .RO_ENABLE(RO_ENABLE),
		   .WR_ENABLE(WR_ENABLE),
		   .RODONE_n(RO_DONE_n));
   defparam	channel_sm.ADC_RUNNING = 3'b010;
   defparam	channel_sm.IDLE = 3'b000;
   defparam	channel_sm.READOUT = 3'b001;
   defparam	channel_sm.TRIGGERED = 3'b100;


   addr_cntrl	ch_addrctrl(
			    .rd_request(RO_ENABLE),
			    .clk(CLK),
			    .rst(RESET),
			    .ain(RD_ADDR),
			    .howmany_i(howmany),
			    .offset_i(offset),
			    .address(SYNTHESIZED_WIRE_0),
			    .ro_done_n(RO_DONE_n));
   defparam	ch_addrctrl.SIZE = SIZE;

   assign	CLK = CK50;
   assign	RESET = RST;

endmodule
