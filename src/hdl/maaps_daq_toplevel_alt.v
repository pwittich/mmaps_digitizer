// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Full Version"
// CREATED		"Fri Jun 24 17:07:43 2016"

// REVISED Aug 24 2016 by Katherine Ding
`timescale 1ns / 1ps
`default_nettype none

// Top level HDL module
module maaps_daq_toplevel_alt(
	//input: system clock - 50MHz
	input wire sys_clk,
	
	//inputs from ADC
	input wire adc_fastclk_p,
	input wire adc_frame_p,
	input wire [15:0] adc_data_p, //16 serial lines
	
	//input from TDC
	input wire [31:0] tdc, //not used as TDC
	
	//currently unused input ports
	input wire spi_cs,
	input wire spi_sclk,
	input wire spi_data_in,
	input wire pmt_trigger, // external trigger - how to input? not in the SDC file now

	//output/inout from adc_spimaster
	output wire adc_ncs1,
	output wire adc_sclk1,
	inout wire adc_sdio1,
	
	//output from bc_counter
	output wire L1,
	output wire L0,
	
	//two copies of the system clock sent to two ADCs
	output wire adc_clk1_p,
	output wire adc_clk2_p,
	
	//output from lvds_transmitter
	output wire [1:0] z0,
	output wire z0_clk,
	
	//currently unused output ports
	output wire spi_data_out,	
	output wire z0_frame
);
   

	
	reg rst;

   // input clock - 50 MHz 
   wire 	     	sysclk;
   assign		sysclk = sys_clk;

   // output clocks to the two octal ADCs
   assign adc_clk1_p = sysclk;
   assign adc_clk2_p = sysclk;

   wire [15:0] 	     dout;
   wire 	     adc_ready; // output

   wire 	     adc_flag;
   reg [7:0] 	     adc_mode;

   // ugh

// // hard-wired for now
//   // SPI controller to configure the external ADCs
   // synthesis read_comments_as_HDL on
//   initial adc_mode = 8'h09;
//   adc_spimaster adc_spimaster_inst(
//				    .sys_clk(sysclk),
//				    .reset_n(~rst),
//      
//				    .adc_sclk(ADC_SCLK1),
//				    .adc_sdio(ADC_SDIO1),
//				    .adc_cs(ADC_nCS1),
//      
//				    .adc_flag(adc_flag),
//				    .adc_mode(adc_mode),
//				    .adc_ready(adc_ready)
//				    );
//
//   
   // synthesis read_comments_as_HDL off

   
   // module to contain the input from the digitizer channels.
   // configurable how many it controls by the CHAN variable
   // howmany, offset should be made configurable - hardwired for now
   // DAVAIL and TRIGGER should also not be hardwired to their current widths.
   digi_many #(.CHAN(8)) digi_many_inst(
					.RST(rst&adc_ready), 
					.sys_clk(sysclk), 
					.adc_clk(adcfastclk_p), 
					.adc_frame(adcframe_p),
					.adcdata_p(adcdata_p), 
					.DOUT(dout), // output to remote
					.ZYNQ_RD_REQUEST(1),
					.howmany(8'hFF), // configuration
					.offset(8'h00), // configuration
					.DAVAIL(TDC[7:0]), // FIXME
					.TRIGGER(TDC[16:8]) // FIXME -- replace with PMT_trigger?
					);

   // counter just to twiddle the LED on the digitzer
   wire [31:0] 	     dcount;
   bc_counter #(.BITS(32)) counter_inst0(
					 .CLK(sysclk),
					 .RST(rst), 
					 .BC(dcount)
					 );
   assign L0 = dcount[26]; // should be about 1 Hz
   assign L1 = dcount[25]; // should be 2x as fast as L1
   

//
//   // LVDS output to the ZYNQ
//   // the Z0 clock is the slow clock; its leading edge indicates the
//   // MSB of the serial output stream.
   // synthesis read_comments_as_HDL on
//   lvds_transmitter lvds_tx_inst(
//				 .DIN(dout), 
//				 .CLK(sysclk),
//				 .O_D(Z0),
//				 .O_CLK(Z0_CLK)
//				 );
   // synthesis read_comments_as_HDL off
   
	// self-reset on startup for now. This is a hack.
	reg [4:0] rst_cnt; 
	initial rst_cnt = 0;
	always @(posedge sysclk ) begin
		if ( rst_cnt < 31 )
			rst_cnt <= rst_cnt + 5'b1;
		if ( rst_cnt < 31) 
			rst = 1;
		else
			rst = 0;
			
	end
	
endmodule

