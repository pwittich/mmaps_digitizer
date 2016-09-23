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
`timescale 1ns / 1ps
`default_nettype none
  // Top level HDL module
  module maaps_daq_toplevel(
			    CK50,
			    adcfastclk_p,
			    adcframe_p,
			    spi_cs,
			    spi_sclk,
			    spi_data_in,
			    spi_data_out,
			    PMT_trigger, // external trigger - how to input? not in the SDC file now
			    adcdata_p,
			    TDC,
			    ADC_SCLK1,
			    ADC_nCS1,
			    ADCCLK1_p,
			    ADCCLK2_p,
			    L1,
			    L0,
			    ADC_SDIO1,
			    Z0,
			    Z0_FRAME,
			    Z0_CLK
			    );


   input wire	CK50;
   input wire	adcfastclk_p;
   input wire	adcframe_p;
   input wire	spi_cs;
   input wire	spi_sclk;
   input wire	spi_data_in;
   input wire	PMT_trigger;
   input wire [15:0] adcdata_p; // 16 serial lines
   input wire [31:0] TDC; // unused
   output wire 	     ADC_SCLK1;
   output wire 	     ADC_nCS1;
   output wire 	     ADCCLK1_p;
   output wire 	     ADCCLK2_p;
   output wire 	     L1;
   output wire 	     L0;
   output wire 	     spi_data_out;
   inout wire 	     ADC_SDIO1;
	reg rst;

   // input clock - 50 MHz 
   wire 	     sysclk;
   assign	sysclk = CK50;

   // output clocks to the two octal ADCs
   assign ADCCLK1_p = sysclk;
   assign ADCCLK2_p = sysclk;

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
					.CK50(sysclk), 
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
   
   output wire [1:0] Z0;
   output wire 	     Z0_FRAME;
   output wire 	     Z0_CLK;

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



	// spi slave for ZYNQ communications
	localparam ZSPI_WORDSIZE = 8;
	wire SPI_done;
	wire [ZSPI_WORDSIZE-1:0] SPI_DIN;
	wire [ZSPI_WORDSIZE-1:0] SPI_DOUT;
	
	// hack for now
	wire done;
	
	reg [ZSPI_WORDSIZE-1:0] spi_q;

	spi_slave #(.WORDSIZE(ZSPI_WORDSIZE)) spi_slave_inst(
		  .clk(sysclk),
        .rst(rst),
        .ss(spi_cs), // ACTIVE LOW, input from master
        .mosi(spi_data_in), // MOSi
        .miso(spi_data_out), // MISO
        .sck(spi_sclk),  // 
        .done(done),
        .din(SPI_DIN),
        .dout(SPI_DOUT)
		);
	always @(posedge sysclk) begin
		if (done) begin
			spi_q <= SPI_DOUT;
		end
	end
	assign SPI_DIN = spi_q;	
	

   
	// self-reset on startup for now. This is a hack.
	reg [4:0] rst_cnt; 
	initial rst_cnt = 0;
	always @(posedge sysclk ) begin
		if ( rst_cnt < 5'd31 )
			rst_cnt <= rst_cnt + 5'b1;
		if ( rst_cnt < 5'd25) 
			rst = 1;
		else
			rst = 0;
			
	end
	
endmodule

