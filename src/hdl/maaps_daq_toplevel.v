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

// PROGRAM              "Quartus II 64-Bit"
// VERSION              "Version 13.1.0 Build 162 10/23/2013 SJ Full Version"
// CREATED              "Fri Jun 24 17:07:43 2016"
`timescale 1ns / 1ps
`default_nettype none

`include "spi_defines.v"
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
                            //TDC,
                            ADC_SCLK1,
                            ADC_nCS1,
                            ADC_SDIO1,
                            ADC_SCLK2,
                            ADC_nCS2,
                            ADC_SDIO2,
                            ADCCLK1_p,
                            ADCCLK2_p,
                            L1,
                            L0
                            );

	
	// IO Initialization
	// -------------------------------------------------------------
									 
	// System clock IO
   input  wire			CK50;
	
	// External trigger IO
	input  wire			PMT_trigger;
	
	// ZYNQ SPI IO
   input  wire			SPI_MOSI;
   input  wire			SPI_SCLK;
   input  wire			SPI_SS;
	output wire			SPI_MISO;
	
	// ADC SPI config IO
   output wire       ADC_SCLK1;
   output wire       ADC_nCS1;
   inout  wire       ADC_SDIO1;
	
   output wire       ADC_SCLK2;
   output wire       ADC_nCS2;
   inout  wire       ADC_SDIO2;
	
	// ADC data IO
	input  wire [15:0] adcdata_p; // 16 serial lines
	//input  wire [31:0] TDC; // unused
	input  wire	 		adcfastclk_p;
	input  wire			adcframe_p;
   output wire       ADCCLK1_p;
   output wire       ADCCLK2_p;
	
	// LED IO
   output wire       L1;
   output wire       L0;
   
   // END IO Initialization
	// -------------------------------------------------------------
	
	
	// L0: blue LED
   // L1: green LED
	
	assign L0 = ZYNQ_RD_EN;
	//assign L1 = adc_ready1 & adc_ready2;
	//assign L1 = ctrl_regs[6][0];
	//assign L1 = PMT_trigger;
	assign L1 = trigger_out;
	

   // input clock - 50 MHz 
   wire              sysclk;
   assign       		sysclk = CK50;

   // output clocks to the two octal ADCs
   assign ADCCLK1_p = sysclk;
   assign ADCCLK2_p = sysclk;
	
	
	
	// ADC_mode_config
	// -------------------------------------------------------------
	//
	// Detects if user has changed the ADC mode
	// and sets each adc flag to signal
	// to adc_spimaster that a new adc
	// spi transaction must occur to update
	// the ADC mode
	
	wire              adc_ready1, adc_ready2; // output
   reg             	adc_flag1, adc_flag2;
	wire [7:0]			adc_mode1_d, adc_mode2_d;
	reg  [7:0]			adc_mode1_q, adc_mode2_q;
	
	always @ (posedge sysclk) begin
		if (adc_flag1 == 1'b1)
			adc_flag1 <= 1'b0;
		else
			if (adc_mode1_q != adc_mode1_d)
				adc_flag1 <= 1'b1;
				
		if (adc_flag2 == 1'b1)
			adc_flag2 <= 1'b0;
		else
			if (adc_mode2_q != adc_mode2_d)
				adc_flag2 <= 1'b1;
	end
		
	
//	always @(*) begin
//		if (adc_mode1_q != adc_mode1_d) begin
//			adc_flag1 = 1'b1;
//		end else begin
//			adc_flag1 = 1'b0;
//		end
//		if (adc_mode2_q != adc_mode2_d) begin
//			adc_flag2 = 1'b1;
//		end else begin
//			adc_flag2 = 1'b0;
//		end
//	end
	
	always @(posedge sysclk) begin
		if (rst) begin
			adc_mode1_q <= 8'h39;
			adc_mode2_q <= 8'h39;
		end else begin
			adc_mode1_q <= adc_mode1_d;
			adc_mode2_q <= adc_mode2_d;
		end
	end
	
	// End ADC_mode_config
	// -------------------------------------------------------------
	
	
   // ADC_SPI_controller to configure the external ADCs
   // one each for each octal ADC
	// -------------------------------------------------------------

   adc_spimaster adc_spimaster_inst_1(
                                      .sys_clk(sysclk),
                                      .reset_n(~rst),
                                      .adc_sclk(ADC_SCLK1),
                                      .adc_sdio(ADC_SDIO1),
                                      .adc_cs(ADC_nCS1),
                                      .adc_flag(adc_flag1),
                                      .adc_mode(adc_mode1_q),
                                      .adc_ready(adc_ready1)
                                      );
												  
   adc_spimaster adc_spimaster_inst_2(
                                      .sys_clk(sysclk),
                                      .reset_n(~rst),
                                      .adc_sclk(ADC_SCLK2),
                                      .adc_sdio(ADC_SDIO2),
                                      .adc_cs(ADC_nCS2),
                                      .adc_flag(adc_flag2),
                                      .adc_mode(adc_mode2_q),
                                      .adc_ready(adc_ready2)
                                      );
												  
	// End ADC_SPI_controller
	// -------------------------------------------------------------
     
	  
	  
	  
	// -------------------------------------------------------------
	// Digi_many module to read and hold data from all channels,
	// each with its own ringbuffer. The EOS signal is a trigger
	// that stops the data collection and waits until all the data
	// is sent to the ZYNQ before resuming.

   wire [15:0]        offset;
   //wire [7:0]        howmany;
	reg [11:0]			howmany;
	wire					trigger_in;
	wire					read_request;
		
	wire [15:0] adc_data_out_digimany;
	
	wire ZYNQ_RD_EN;
	
   // module to contain the input from the digitizer channels.
   // configurable how many it controls by the CHAN variable.
   // howmany, offset should be made configurable - hardwired for now
   // DAVAIL and TRIGGER should also not be hardwired to their current widths.
	digi_many #(.CHAN(16),.WIDTH(16)) digi_many_inst(
													 .RST(rst), 
													 .CK50(sysclk), 
													 .adc_clk(adcfastclk_p), 
													 .adc_frame(adcframe_p),
													 .adcdata_p(adcdata_p[15:0]), 
													 .DOUT(adc_data_out_digimany), // output to remote
													 .EOS(trigger_out),
													 //.SPI_done(SPI_done),
													 .SPI_done(word_done),
													 .ADC_sample_num(ADC_sample_num),
													 .offset(offset), // configuration
													 .DAVAIL(adc_ready1),
													 .ZYNQ_RD_EN_out(ZYNQ_RD_EN)
													 );
		
	// End ADC_SPI_controller
	// -------------------------------------------------------------

	
	
	/* -----\/----- EXCLUDED -----\/-----
   // counter just to twiddle the LED on the digitzer
   wire [31:0]       dcount;
   bc_counter #(.BITS(32)) counter_inst0(
                                         .CLK(sysclk),
                                         .RST(rst), 
                                         .BC(dcount)
                                         );
   assign L0 = dcount[26]; // should be about 1 Hz
   assign L1 = dcount[25]; // should be 2x as fast as L1
	-----/\----- EXCLUDED -----/\----- */
 
	
	reg [11:0] RD_ADDR_d, RD_ADDR_q;
	
	always @ (*) begin
		if (!SPI_SS) begin
			if (SPI_done && (RD_ADDR_q < ZYNQ_word_num)) begin
				RD_ADDR_d = RD_ADDR_q + 12'h001;
			end else if (SPI_done) begin
				RD_ADDR_d = 12'h000;
			end else begin
				RD_ADDR_d = RD_ADDR_q;
			end
		end else begin
			RD_ADDR_d = 12'h000;
		end
	end
	
	always @ (posedge sysclk) begin
		if (rst) begin
			RD_ADDR_q <= 12'h000;
		end else begin
			RD_ADDR_q <= RD_ADDR_d;
		end
	end
	
	
	
	// Test_Modules:
	// -------------------------------------------------------------
	//
	// Test single_channel, lvds_receiver.v
	// and lvdsreceiver.vhd. Which output goes
	// to the SPI slave to be sent to the zynq
	// is controlled by ctrl_regs[7]
	
	wire [11:0] adc_data_out_verilog;
	wire [11:0] adc_data_out_vhdl;
	wire [11:0] adc_data_out_singlechannel;

	reg [11:0] adc_data_out_test;
	reg [7:0] adc_data_out_word;
	
	localparam channelUnderTest = 0;
	
	wire RO_ENABLE_out;
	
	single_channel single_channel_inst(
							.clk(sysclk),
							.reset(rst),
							.adc_data_ready(adc_ready1),
							.trigger(trigger_out),
							.adc_fast_clk(adcfastclk_p),
							.adc_frame(adcframe_p),
							.adc_data_p(adcdata_p[channelUnderTest]),
							.data_out(adc_data_out_singlechannel),
							//.sc_wr_enable(sc_wr_enable),
							.how_many(howmany),
							.read_request(read_request),
							.SPI_done(SPI_done),
							.read_address(RD_ADDR_q),
							.RO_ENABLE_out(RO_ENABLE_out)
	);
	
	//	lvds_receiver lvds_rec_inst_test(
	//	 					.sysclk(sysclk),
	//	 					.FASTCLK(adcfastclk_p),
	//							.FRAME(adcframe_p),
	//	 					.DATA(adcdata_p[channelUnderTest]),
	//							.RESET_n(~rst),
	//							.CBDATA(adc_data_out_verilog),
	//							.CBADDRESS(adc_addr_out_test),
	//							.WENABLE(adc_wenable_test)
	//	);
	
	lvdsreceiver lvdsrec_inst_test(
	 					.sysclk(sysclk),
	 					.FASTCLK(adcfastclk_p),
						.FRAME(adcframe_p),
	 					.DATA(adcdata_p[channelUnderTest]),
						.RESET_n(~rst),
						.CBDATA(adc_data_out_vhdl)
	);
	
	// Check ctrl_regs[7] for which module to test
	always @(*) begin
		adc_data_out_test = 12'haff;
		if (ctrl_regs[7] == 8'h00) begin
			adc_data_out_test = adc_data_out_digimany[15:4];
		end else if (ctrl_regs[7] == 8'h01) begin
			adc_data_out_test = adc_data_out_vhdl;
		end else if (ctrl_regs[7] == 8'h02) begin
			adc_data_out_test = adc_data_out_singlechannel;
		end
		//		end else if (ctrl_regs[7] == 8'h03) begin
		//			adc_data_out_test = adc_data_out_verilog;
		//		end
	end
	
	reg word_done;
	reg MSB;
	
	always @ (posedge sysclk) begin
		if (rst) begin
			word_done <= 1'b0;
			MSB <= 1'b1;
			adc_data_out_word <= 8'hcc;
		end else if (SPI_done) begin
			if (ctrl_regs[8] == 8'h02) begin
				if (MSB) begin
					MSB <= 1'b0;
					adc_data_out_word <= adc_data_out_test[11:8];
					word_done <= 1'b1;
				end else begin
					MSB <= 1'b1;
					adc_data_out_word <= adc_data_out_test[7:0];
					word_done <= 1'b0;
				end
			end else if (ctrl_regs[8] == 8'h01) begin
				adc_data_out_word <= adc_data_out_test[7:0];
				word_done <= 1'b1;
			end else if (ctrl_regs[8] == 8'h00) begin
				adc_data_out_word <= adc_data_out_test[11:4];
				word_done <= 1'b1;
			end
		end else begin
			word_done <= 1'b0;
		end
	end
	
	
//	// Check ctrl_regs[8] for which 8 bits to send,
//	// lowest 8 or highest 8
//	always @(*) begin
//		if (ctrl_regs[8] == 8'h00) begin
//			adc_data_out_word = adc_data_out_test[11:4];
//		end else if (ctrl_regs[8] == 8'h01) begin
//			adc_data_out_word = adc_data_out_test[7:0];
//		end else begin
//			adc_data_out_word = 8'hcc;
//		end
//	end
	
	// END Test_Modules
	// -------------------------------------------------------------
	
	
	
	
	// SPI_Interface for ZYNQ communications
	// -------------------------------------------------------------
	// Receives commands from the zynq and sends
	// back ADC samples to be stored
	
   localparam ZSPI_WORDSIZE = 8;
	
	reg [ZSPI_WORDSIZE-1:0]  ctrl_regs [15:0];
	
   wire 	SPI_done;

   // RX: most recent received message
   // TX: next word to be sent
   reg [7:0] SPI_tx_reg; // to be transmitted
   reg [7:0] SPI_rx_reg; // most recent received
   reg [3:0] SPI_cmd; // SPI command
   reg [3:0] SPI_addr; // address in SPI command

   wire [7:0] SPI_s; 

   spi_slave 
     #(.WORDSIZE(ZSPI_WORDSIZE)) spi_slave_inst(
                                                .clk(sysclk),
                                                .rst(rst),
                                                .ss(SPI_SS), // ACTIVE LOW
                                                .mosi(SPI_MOSI),
                                                .miso(SPI_MISO),
                                                .sck(SPI_SCLK),
                                                .done(SPI_done),
                                                .din(SPI_tx_reg),
                                                .dout(SPI_s)
                                                );


   // store slave's data
   always @(posedge sysclk) begin
      if ( SPI_done ) begin
         SPI_rx_reg <= SPI_s;
      end
   end

   // 16 control registers
	
	wire [11:0] ADC_sample_num;
	wire [15:0] ZYNQ_word_num;

	assign ADC_sample_num = {ctrl_regs[1][3:0], ctrl_regs[0]};
	assign ZYNQ_word_num = {ctrl_regs[3], ctrl_regs[2]};
	
   assign offset = {ctrl_regs[5], ctrl_regs[4]};
	
	assign adc_mode1_d  = ctrl_regs[6];
	assign adc_mode2_d  = ctrl_regs[6];
	
	//assign trigger = ctrl_regs[10][0];
	assign trigger_in = PMT_trigger | ctrl_regs[10][0];
	wire trigger_out;
	wire trigger_temp;
	
	dff_sync_reset ff1 (
		.data(trigger_in),
		.clk(sysclk),
		.reset(rst),
		.q(trigger_temp)
	);
	
	dff_sync_reset ff2 (
		.data(trigger_temp),
		.clk(sysclk),
		.reset(rst),
		.q(trigger_out)
	);
	
	assign read_request = ctrl_regs[11][0]; // to be used for single_channel test only
	
	wire rst;
	assign rst = reset | ctrl_regs[12][0];

   // state machine outputs
   wire       rd_select, wr_select, latch_cmd;

   // handle the read and write 
   always @(posedge sysclk ) begin
		// preload some registers
		if (rst) begin
			ctrl_regs[0] <= 8'h00; // bottom 8 bits of ADC_sample_num
			ctrl_regs[1] <= 8'h04; // top 8 bits of ADC_sample_num
			ctrl_regs[2] <= 8'h00; // bottom 8 bits of ZYNQ_word_num
			ctrl_regs[3] <= 8'h10; // top 8 bits of ZYNQ_word_num
			
			ctrl_regs[4] <= 8'h00; // bottom 8 bits of trigger delay offset
			ctrl_regs[5] <= 8'h00; // top 8 bits of trigger delay offset
			
			ctrl_regs[6] <= 8'h09; // ADC mode (free-running or test pattern)
			ctrl_regs[7] <= 8'h00; // Which module to test, lvds_rec.v, lvdsrec.vhd, or sc
			ctrl_regs[8] <= 8'h00; // Send out top 8 bits, bototm 8 bits of data out, or both
			
//			ctrl_regs[9] <= 8'h00; // Use trigger as BOS or EOS and offset as increment
//										  // or decrement (default EOS)
			
			ctrl_regs[10] <= 8'h00; // trigger
			ctrl_regs[11] <= 8'h00; // read_request (for single_channel test only)
			ctrl_regs[12] <= 8'h00; // Reset by zynq
		end
		
      else if ( rd_select) begin
         SPI_tx_reg <= ctrl_regs[SPI_addr];
      end 
      else if ( wr_select ) begin
         ctrl_regs[SPI_addr] <= SPI_rx_reg;
      end
		else begin
			SPI_tx_reg <= adc_data_out_word;
		end
   end

   // store the command and associated address data
   always @(posedge sysclk ) begin
      if ( latch_cmd ) begin
         SPI_addr <= SPI_rx_reg[7:4]; 
         SPI_cmd <= SPI_rx_reg[3:0];
      end
   end
   
   SPI_SM sm( // State machine for SPI slave on CycloneIII
              .rd_select(rd_select),
              .wr_select(wr_select),
              .latch_cmd(latch_cmd),
              .cmd(SPI_rx_reg[3:0]), // before they are latched
              .done(SPI_done),
              .clk(sysclk),
              .rst(rst) 
              );
				  
				  
   // END SPI_Interface
	// ------------------------------------------------------------
   

	
	
   //-------------------------------------------------------------
   // self-reset on startup for now. This is a hack.
	
	reg  reset;
   reg [4:0] rst_cnt; 
   initial rst_cnt = 0;
   always @(posedge sysclk ) begin
      if ( rst_cnt < 5'd31 )
        rst_cnt <= rst_cnt + 5'b1;
      if ( rst_cnt < 5'd25) 
        reset <= 1;
      else
        reset <= 0;
   end
	
   
endmodule

