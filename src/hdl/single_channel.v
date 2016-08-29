`timescale 1ns / 1ps
`default_nettype none
  //////////////////////////////////////////////////////////////////////////////////
// Company: 
  // Engineer: 
  // 
  // Create Date: 03/11/2016 11:31:57 AM
  // Design Name: 
  // Module Name: single_channel
  // Project Name: 
  // Target Devices: 
  // Tool Versions: 
  // Description: test module to develop single channel. Obsolete.
  //              Actually not obsolete - Used by digi_many
  // 
  // Dependencies: 
  // 
  // Revision:
  // Revision 0.01 - File Created
  // Revision 1 - Katherine Ding - Aug 24 2016
  // Additional Comments:
  // 
  //////////////////////////////////////////////////////////////////////////////////


  module single_channel
    #(parameter SIZE=8, WIDTH=12)
   (
    input wire 	clk,
    input wire 	reset,
    input wire 	adc_data_ready,
    input wire 	trigger,
    input wire 	adc_fast_clk,
    input wire 	adc_frame,
    input wire 	adc_data_p, // single channel serial input
    output wire 	[WIDTH-1:0] data_out,
    input wire		[SIZE-1:0]  how_many,
    input wire 	[SIZE-1:0]  offset,
    input wire    read_request
    );
   
   wire 		 				RO_ENABLE;
   wire 		 				WR_ENABLE_LVDS;
	wire 		 				WR_ENABLE_SM;
   wire 	[SIZE-1:0] 	 	SYNTHESIZED_WIRE_0;
   //wire 		 				SYNTHESIZED_WIRE_1;
   wire 	[SIZE-1:0] 	 	RD_ADDR;

   wire 	[WIDTH-1:0] 	cbdata;
   

   lvds_receiver receiver_inst(
			      .sysclk(clk),
			      .DATA(adc_data_p),
			      .FRAME(adc_frame),
			      .FASTCLK(adc_fast_clk),
			      .CBDATA(cbdata),
			      //.CBADDRESS(), // not used right now
			      .WENABLE(WR_ENABLE_LVDS),
			      .RESET_n(~reset)
			      );
   
   
   ringbuffer	ringbuffer_inst0(
				 .clk(clk),
				 .wr_en(WR_ENABLE_LVDS&WR_ENABLE_SM),
				 .rd_en(RO_ENABLE),
				 .rst(reset),
				 .ain(SYNTHESIZED_WIRE_0),
				 .din(cbdata),
				 .aout(RD_ADDR),
				 .dout(data_out));
   defparam    ringbuffer_inst0.SIZE = SIZE; // 2^SIZE ringbuffer size
   defparam    ringbuffer_inst0.WIDTH = WIDTH;
   
   wire 		 RO_DONE_n;
   
   SM1    channel_sm(
		     .DAVAIL(adc_data_ready),
		     .ROREQUEST(read_request),
		     .TRIGGER(trigger),
		     .clk(clk),
		     .rst(reset),
		     .RO_ENABLE(RO_ENABLE),
		     .WR_ENABLE(WR_ENABLE_SM),
		     .RODONE_n(RO_DONE_n));
   defparam    channel_sm.ADC_RUNNING = 3'b010;
   defparam    channel_sm.IDLE = 3'b000;
   defparam    channel_sm.READOUT = 3'b001;
   defparam    channel_sm.TRIGGERED = 3'b100;
   
   
   addr_cntrl    ch_addrctrl(
			     .rd_request(RO_ENABLE),
			     .clk(clk),
			     .rst(reset),
			     .ain(RD_ADDR),
			     .howmany_i(how_many),
			     .offset_i(offset),
			     .address(SYNTHESIZED_WIRE_0),
			     .ro_done_n(RO_DONE_n));
   defparam    ch_addrctrl.SIZE = SIZE;
   
   
endmodule
