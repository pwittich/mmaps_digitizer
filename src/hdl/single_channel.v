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


// This module manages the operation of a single channel, and
// is instanced several times in digi_many to handle all channels.
// It contains an lvdsreceiver module which acquires the data from
// the adc via lvds lines, a ring_buffer module to store said data
// and read out upon demand, and an address_control module to
// manage the ring_buffer memory and tell it which address to 
// store in next, and which address to start readout from.
module single_channel #(parameter SIZE=12, WIDTH=12) (
	input wire 	clk,
	input wire 	reset,
	input wire 	adc_data_ready,
	input wire 	trigger,
	input wire 	adc_fast_clk,
	input wire 	adc_frame,
	input wire 	adc_data, // single channel serial input
	input wire	[SIZE-1:0]  how_many,
	input wire 	read_request,
	input wire	SPI_done,
	input wire  [11:0] read_address,
	output wire RODONE_n_out,
	output wire [WIDTH-1:0] data_out
);
   
wire 		 			RO_ENABLE;
wire 		 			WR_ENABLE_LVDS;
wire 		 			WR_ENABLE_SM;
wire 	[SIZE-1:0] 	 	rb_addr_in;
wire 	[SIZE-1:0] 	 	RD_ADDR;

wire 	[WIDTH-1:0] 	cbdata;
	
assign RODONE_n_out = RO_DONE_n;

// This block extends the duration of the WR_ENABLE_LVDS
// signal, because the latter comes from the lvdsreceiver
// module which works on the adc_fast_clk, so its write
// enable signal is too short for the regular CK50 clock.
// Right now we are extending by 3 extra adc_fast_clk
// cycles, which is why wr_enable_timer_d is set to 3'b100.

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
		
// This module receives data from the ADC, and sends out
// a write enable signal (WR_ENABLE_LVDS) when a word is 
// ready to be stored.
lvdsreceiver receiver_inst(
	.sysclk(clk),
	.DATA(adc_data),
	.FRAME(adc_frame),
	.FASTCLK(adc_fast_clk),
	.CBDATA(cbdata),
	//.CBADDRESS(), // not used right now
	.WENABLE(WR_ENABLE_LVDS),
	.RESET_n(~reset)
);
   
wire [WIDTH-1:0] rb_data_out;
assign data_out = read_request ? rb_data_out : 12'hccc;

// The ringbuffer stores the data received from lvdsreceiver.
// It's basically an array of registers, and takes the address
// to store the next word from the addr_cntrl module, via ain 
// and din. When it's readout time it outputs the word via dout
// and its corresponding address via aout.
ringbuffer		ringbuffer_inst0(
	.sysclk(clk),
	.fastclk(adc_fast_clk),
	.wr_en(WR_ENABLE_LATCH_q&WR_ENABLE_SM),
	.rd_en(RO_ENABLE),
	.rst(reset),
	.ain(rb_addr_in),
	.din(cbdata),
	.aout(RD_ADDR),
	.dout(rb_data_out)
);
defparam    ringbuffer_inst0.SIZE = SIZE; // 2^SIZE ringbuffer size
defparam    ringbuffer_inst0.WIDTH = WIDTH;
   
wire 		 RO_DONE_n;
   
// State machine to control the writing 
// and reading of the single_channel module.
// When the ADC is ready it goes into ADC_RUNNING
// mode, and waits for a trigger to go into TRIGGERED
// mode, when it stops recording data. Then it waits
// for a readout flag to go into READOUT mode, and when
// readout is complete it returns to ADC_RUNNING mode, and
// so on.
single_channel_SM   channel_sm(
	.DAVAIL(adc_data_ready),
	.ROREQUEST(read_request),
	.TRIGGER(trigger),
	.clk(clk),
	.rst(reset),
	.RO_ENABLE(RO_ENABLE),
	.WR_ENABLE(WR_ENABLE_SM),
	.RODONE_n(RO_DONE_n)
);
defparam    channel_sm.ADC_RUNNING = 3'b010;
defparam    channel_sm.IDLE = 3'b000;
defparam    channel_sm.READOUT = 3'b001;
defparam    channel_sm.TRIGGERED = 3'b100;
	
reg [11:0] rb_addr_offset = 12'h000; // no address offset
	
// Address control module to keep track of which index in
// the buffer we are currently working at. An offset can
// also be specified, although we don't currently use it.
// The howmany_i register tells how many words we want to 
// read out from the buffer to the external world.
addr_cntrl    ch_addrctrl(
	.rd_request(RO_ENABLE),
	.sysclk(clk),
	.rst(reset),
	.ain(RD_ADDR),
	.howmany_in(how_many),
	.offset_in(rb_addr_offset),
	.SPI_done(SPI_done),
	.address(rb_addr_in),
	.ro_done_n(RO_DONE_n)
);
defparam    ch_addrctrl.SIZE = SIZE;
   
   
endmodule