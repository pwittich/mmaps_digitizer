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
				 SPI_MOSI,
				 SPI_MISO,
				 SPI_SCLK,
				 SPI_SS,
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
			    );


   input wire	CK50;
   input wire	adcfastclk_p;
   input wire	adcframe_p;
	input wire	SPI_MOSI;
	input wire	SPI_SCLK;
	input wire	SPI_SS;
   input wire	PMT_trigger;
   input wire [15:0] adcdata_p; // 16 serial lines
   input wire [31:0] TDC; // unused
   output wire 	     ADC_SCLK1;
   output wire 	     ADC_nCS1;
   output wire 	     ADCCLK1_p;
   output wire 	     ADCCLK2_p;
   output wire 	     L1;
   output wire 	     L0;
	output wire			  SPI_MISO;
   inout wire 	     ADC_SDIO1;

   
   reg 		     rst;

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

   wire 	     fifo_empty;
   wire [7:0]	     offset;
   wire [7:0] 	     howmany;
   // module to contain the input from the digitizer channels.
   // configurable how many it controls by the CHAN variable.
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
					.GLBL_EMPTY(fifo_empty),
					.howmany(howmany), // configuration
					.offset(offset), // configuration
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
   

//   //
//   //   // LVDS output to the ZYNQ
//   //   // the Z0 clock is the slow clock; its leading edge indicates the
//   //   // MSB of the serial output stream.
//   // synthesis read_comments_as_HDL on
//   //   lvds_transmitter lvds_tx_inst(
//   //				 .DIN(dout), 
//   //				 .CLK(sysclk),
//   //				 .O_D(Z0),
//   //				 .O_CLK(Z0_CLK)
//   //				 );
//   // synthesis read_comments_as_HDL off



   // spi slave for ZYNQ communications
   localparam ZSPI_WORDSIZE = 8;
   wire 	     SPI_done;
	reg [ZSPI_WORDSIZE-1:0] SPI_datatomaster;
	wire [ZSPI_WORDSIZE-1:0] SPI_datafrommaster;
//   wire 		    done;

	// TEST: initialize data to send to master
	initial begin
		SPI_datatomaster <= 8'b01010101;
	end

   // RX: most recent received message
   // TX: next word to be sent
   reg [ZSPI_WORDSIZE-1:0]  spi_rx_q, spi_tx_q;
	
	// TEST: just output to master whatever slave receives
	always @ (SPI_done) begin
		if (SPI_done) begin
			SPI_datatomaster = SPI_datafrommaster;
		end
	end

   spi_slave #(.WORDSIZE(ZSPI_WORDSIZE)) spi_slave_inst(
							.clk(sysclk),
							.rst(rst),
							.ss(SPI_SS), // ACTIVE LOW, input from master
							.mosi(SPI_MOSI),
							.miso(SPI_MISO),
							.sck(SPI_SCLK),
							.done(SPI_done),
							.din(SPI_datatomaster),
							.dout(SPI_datafrommaster)
							);
							
   // store SPI output into spi_rx_q
   always @(posedge sysclk) begin
      if ( rst == 1 ) begin
			spi_rx_q <= {ZSPI_WORDSIZE{1'b0}};
      end
      else if (SPI_done == 1 ) begin
			spi_rx_q <= SPI_datafrommaster;
      end
   end
	
	// 16 control registers
   reg [ZSPI_WORDSIZE-1:0]  ctrl_regs [15:0];

   assign howmany = ctrl_regs[1] ;
   assign offset = ctrl_regs[2] ;

   // if write bit is not set, copy value of ctrl_regs to spi_tx_q
   // should this also look at 'done'?
   // hack: only look at bottom nibble
   always @(posedge sysclk) begin
      if ( spi_rx_q[ZSPI_WORDSIZE-1] == 0 ) begin // read enable
			if ( spi_rx_q[4] == 0 ) begin // control registers
				spi_tx_q <= ctrl_regs[spi_rx_q[3:0]];
			end 
			else begin // FIFO - just read it for now (should check data available)
				if ( fifo_empty != 0 ) begin // fifo is not empty
					spi_tx_q <= dout[ZSPI_WORDSIZE-1:0];
				end else begin
//					spi_tx_q <= 12'haaa; //default empty value
					spi_tx_q <= {ZSPI_WORDSIZE{1'b1}}; // default empty value
				end
			end
      end
      else begin // write-enable
			if ( spi_rx_q[4] == 0 ) begin
				ctrl_regs[spi_rx_q[3:0]] <= SPI_datafrommaster;
			end
		end
	end // always @ (posedge sysclk)

   
   //assign SPI_datatomaster = spi_tx_q;
   

   //--------------------------------------------------
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

