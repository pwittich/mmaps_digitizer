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
    #(parameter SIZE=12, WIDTH=12)
   (
    input wire 	clk,
    input wire 	reset,
    input wire 	adc_data_ready,
    input wire 	trigger,
    input wire 	adc_fast_clk,
    input wire 	adc_frame,
    input wire 	adc_data_p, // single channel serial input
    output wire 	[WIDTH-1:0] data_out,
	 //output wire	sc_wr_enable,
    input wire		[SIZE-1:0]  how_many,
    input wire    read_request,
	 input wire		SPI_done,
	 input wire    [11:0] read_address,
	 output wire RO_ENABLE_out,
	 output wire RODONE_n_out
    );
   
   wire 		 				RO_ENABLE;
   wire 		 				WR_ENABLE_LVDS;
	wire 		 				WR_ENABLE_SM;
   wire 	[SIZE-1:0] 	 	SYNTHESIZED_WIRE_0;
   //wire 		 				SYNTHESIZED_WIRE_1;
   wire 	[SIZE-1:0] 	 	RD_ADDR;

   wire 	[WIDTH-1:0] 	cbdata;
	
	assign RO_ENABLE_out = RO_ENABLE;
	assign RODONE_n_out = RO_DONE_n;
	
	//initial cbdata = 12'haaa;
	
	//assign sc_wr_enable = WR_ENABLE_SM;
   
//	reg self_trigger_d, self_trigger_q;
//	always @(*) begin
//		self_trigger_d = 1'b0;
//		if (cbdata == 12'h9ff && !RO_ENABLE) begin
//			self_trigger_d = 1'b1;
//		end
//	end
//	always @(posedge clk) begin
//		self_trigger_q <= self_trigger_d;
//	end
	
	reg WR_ENABLE_LATCH_d, WR_ENABLE_LATCH_q;
	reg [2:0] wr_enable_timer_d, wr_enable_timer_q;
	
	always @ (*) begin
		if (WR_ENABLE_LVDS == 1'b1) begin
			WR_ENABLE_LATCH_d = 1'b1;
			wr_enable_timer_d = 3'b100;
		end else if (wr_enable_timer_q > 3'b000) begin
			wr_enable_timer_d = wr_enable_timer_q - 3'b001;
			WR_ENABLE_LATCH_d = WR_ENABLE_LATCH_q;
		end else begin
			WR_ENABLE_LATCH_d = 1'b0;
			wr_enable_timer_d = wr_enable_timer_q;
		end
	end
	
	always @ (posedge adc_fast_clk) begin
		if (reset) begin
			wr_enable_timer_q <= 3'b000;
			WR_ENABLE_LATCH_q <= 1'b0;
		end else begin
			wr_enable_timer_q <= wr_enable_timer_d;
			WR_ENABLE_LATCH_q <= WR_ENABLE_LATCH_d;
		end
	end
		

   lvdsreceiver receiver_inst(
			      .sysclk(clk),
			      .DATA(adc_data_p),
			      .FRAME(adc_frame),
			      .FASTCLK(adc_fast_clk),
			      .CBDATA(cbdata),
			      //.CBADDRESS(), // not used right now
			      .WENABLE(WR_ENABLE_LVDS),
			      .RESET_n(~reset)
			      );
   
	wire [WIDTH-1:0] data_out_rb;
   assign data_out = read_request ? data_out_rb : 12'hccc;
	
   ringbuffer	ringbuffer_inst0(
				 .sysclk(clk),
				 .fastclk(adc_fast_clk),
				 .wr_en(WR_ENABLE_LATCH_q&WR_ENABLE_SM),
				 .rd_en(RO_ENABLE),
				 .rst(reset),
				 .ain(SYNTHESIZED_WIRE_0),
				 .din(cbdata),
				 .aout(RD_ADDR),
				 .dout(data_out_rb));
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
	
	reg [11:0] offset_temp = 12'h000;
	
   addr_cntrl    ch_addrctrl(
			     .rd_request(RO_ENABLE),
			     .sysclk(clk),
			     .rst(reset),
			     .ain(RD_ADDR),
			     .howmany_i(how_many),
			     .offset_i(offset_temp),
				  .SPI_done(SPI_done),
			     .address(SYNTHESIZED_WIRE_0),
			     .ro_done_n(RO_DONE_n));
				  //.debug(debug));
   defparam    ch_addrctrl.SIZE = SIZE;
   
   
endmodule
