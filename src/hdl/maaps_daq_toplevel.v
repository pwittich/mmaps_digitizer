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
                            TDC,
                            ADC_SCLK1,
                            ADC_nCS1,
                            ADC_SDIO1,
                            ADC_SCLK2,
                            ADC_nCS2,
                            ADC_SDIO2,
                            ADCCLK1_p,
                            ADCCLK2_p,
                            L1,
                            L0,
                            );


   input wire   CK50;
   input wire   adcfastclk_p;
   input wire   adcframe_p;
   input wire 	SPI_MOSI;
   input wire 	SPI_SCLK;
   input wire 	SPI_SS;
   input wire   PMT_trigger;
   input wire [15:0] adcdata_p; // 16 serial lines
   input wire [31:0] TDC; // unused
   output wire       ADC_SCLK1;
   output wire       ADC_nCS1;
   inout wire        ADC_SDIO1;
   output wire       ADC_SCLK2;
   output wire       ADC_nCS2;
   inout wire        ADC_SDIO2;
   output wire       ADCCLK1_p;
   output wire       ADCCLK2_p;
   output wire       L1;
   output wire       L0;
   output wire 	     SPI_MISO;
   
   
   reg               rst;

   // input clock - 50 MHz 
   wire              sysclk;
   assign       sysclk = CK50;

   // output clocks to the two octal ADCs
   assign ADCCLK1_p = sysclk;
   assign ADCCLK2_p = sysclk;
	
	reg [ZSPI_WORDSIZE-1:0]  ctrl_regs [15:0];

   wire [15:0] 	     dout;
	
   wire              adc_ready1, adc_ready2; // output
   reg              adc_flag1, adc_flag2;
   //reg [7:0]         adc_mode1, adc_mode2;
	wire [7:0]			adc_mode1_d, adc_mode2_d;
	reg  [7:0]			adc_mode1_q, adc_mode2_q;
	
	reg [31:0] ticks;
	always @(posedge sysclk) begin
		if (rst) begin
			ticks <= 32'h00000000;
		end else begin
			ticks <= ticks + 1;
		end
	end
	
	// ADC_mode_config
	// -------------------------------------------------------------
	//
	// Detects if user has changed the ADC mode
	// and sets each adc flag to signal
	// to adc_spimaster that a new adc
	// spi transaction must occur to update
	// the ADC mode
	
	always @(*) begin
		if (adc_mode1_q != adc_mode1_d) begin
			adc_flag1 = 1'b1;
		end else begin
			adc_flag1 = 1'b0;
		end
		if (adc_mode2_q != adc_mode2_d) begin
			adc_flag2 = 1'b1;
		end else begin
			adc_flag2 = 1'b0;
		end
	end
	
	always @(posedge sysclk) begin
		adc_mode1_q <= adc_mode1_d;
		adc_mode2_q <= adc_mode2_d;
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
     

   wire              fifo_empty;
   wire [7:0]        offset;
   //wire [7:0]        howmany;
	reg [11:0]			howmany;
	wire					trigger;
	wire					read_request;
	
   // module to contain the input from the digitizer channels.
   // configurable how many it controls by the CHAN variable.
   // howmany, offset should be made configurable - hardwired for now
   // DAVAIL and TRIGGER should also not be hardwired to their current widths.
	//   digi_many #(.CHAN(8),.WIDTH(8)) digi_many_inst(
	//                                        .RST(rst&adc_ready1&adc_ready2), 
	//                                        .CK50(sysclk), 
	//                                        .adc_clk(adcfastclk_p), 
	//                                        .adc_frame(adcframe_p),
	//                                        .adcdata_p(adcdata_p), 
	//                                        .DOUT(dout), // output to remote
	//                                        .ZYNQ_RD_REQUEST(fifo_rd_one),
	//                                        .GLBL_EMPTY(fifo_empty),
	//                                        .howmany(howmany), // configuration
	//                                        .offset(offset), // configuration
	//                                        .DAVAIL(TDC[7:0]), // FIXME
	//                                        .TRIGGER(TDC[16:8]) // FIXME -- replace with PMT_trigger?
	//                                        );

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
 

	wire [11:0] adc_data_out, adc_data_out2;
	reg [7:0] adc_addr_out;
	reg adc_wenable;
	wire adc_wenable_test;
	wire adc_addr_out_test;
	
	wire sc_wr_enable;
	reg [11:0] adc_data_out_reg_q;
	reg [11:0] adc_data_out_reg_d;
	always @(*) begin
		adc_data_out_reg_d = adc_data_out_reg_q;
		if (sc_wr_enable) begin
			adc_data_out_reg_d = adc_data_out;
		end
	end
	always @(negedge sysclk) begin
		if (rst) begin	
			adc_data_out_reg_q = 12'hfff;
		end
		adc_data_out_reg_q = adc_data_out_reg_d;
	end
	
	reg [11:0] RD_ADDR_d, RD_ADDR_q;
	
	always @ (*) begin
		if (!SPI_SS) begin
			if (SPI_done && RD_ADDR_q < 12'h400) begin
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
	
	reg [11:0] staging_register [1023:0];
	wire [11:0] howmany_left;
	wire RO_ENABLE_out;
	wire [11:0] rd_index;
	
	assign rd_index = 12'h3ff - howmany_left;
	
	always @(posedge sysclk) begin
		if (RO_ENABLE_out) begin
			staging_register[rd_index] <= adc_data_out_singlechannel;
		end
	end
	
	single_channel single_channel_inst(
							.clk(sysclk),
							.reset(rst),
							.adc_data_ready(adc_ready1),
							.trigger(trigger),
							.adc_fast_clk(adcfastclk_p),
							.adc_frame(adcframe_p),
							.adc_data_p(adcdata_p[channelUnderTest]),
							.data_out(adc_data_out_singlechannel),
							//.sc_wr_enable(sc_wr_enable),
							.how_many(howmany),
							.offset(offset),
							.read_request(read_request),
							.SPI_done(SPI_done),
							.read_address(RD_ADDR_q),
							.debug1(L0),
							.debug2(L1),
							.howmany_left(howmany_left),
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
						.CBDATA(adc_data_out_vhdl),
						//.CBADDRESS(adc_addr_out_test),
						.WENABLE(adc_wenable_test)
	);
	
	// Check ctrl_regs[7] for which module to test
	always @(*) begin
		adc_data_out_test = 12'hccc;
		if (ctrl_regs[7] == 8'h00) begin
			adc_data_out_test = adc_data_out_verilog;
		end else if (ctrl_regs[7] == 8'h01) begin
			adc_data_out_test = adc_data_out_vhdl;
		end else if (ctrl_regs[7] == 8'h02) begin
			adc_data_out_test = adc_data_out_singlechannel;
		end else if (ctrl_regs[7] == 8'h03) begin
			adc_data_out_test = staging_register[RD_ADDR_q];
		end
	end
	
	// Check ctrl_regs[8] for which 8 bits to send,
	// lowest 8 or highest 8
	always @(*) begin
		if (ctrl_regs[8] == 8'h00) begin
			adc_data_out_word = adc_data_out_test[11:4];
		end else if (ctrl_regs[8] == 8'h01) begin
			adc_data_out_word = adc_data_out_test[7:0];
		end else begin
			adc_data_out_word = 8'hcc;
		end
	end
	
	// END Test_Modules
	// -------------------------------------------------------------
	
	
	
	// SPI_Interface for ZYNQ communications
	// -------------------------------------------------------------
	// Receives commands from the zynq and sends
	// back ADC samples to be stored
	
   localparam ZSPI_WORDSIZE = 8;
	
   wire              SPI_done;

   // TEST: initialize data to send to master

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
                                                //.din(SPI_tx_reg),
																.din(adc_data_out_word),
                                                //.din(hack),
                                                .dout(SPI_s)
                                                );
   wire       led_hack;

   //wire [7:0] hack;
   //assign hack = SPI_rx_reg;

   // L0: blue LED
   // L1: green LED
   //assign L0 = (SPI_addr == 4'h0)&(SPI_cmd == `WR); // blue LED
	//assign L0 = trigger;
   //assign L1 = ctrl_regs[0][7]; // green LED
   //assign L1 = SPI_tx_reg[7]; // green LED
	//assign L1 = read_request;

   // store slave's data
   always @(posedge sysclk) begin
      if ( SPI_done ) begin
         SPI_rx_reg <= SPI_s;
      end
   end

   // 16 control registers

   wire [7:0] 		    FIFO_PK_SZ;

	initial howmany = 12'h400;
   //assign howmany = (ctrl_regs[1] << 16) | (ctrl_regs[0]);
   assign offset = ctrl_regs[2] ;
   assign FIFO_PK_SZ = ctrl_regs[3];
	//assign trigger = ctrl_regs[4];
	//assign read_request = ctrl_regs[5];
	assign adc_mode1_d  = ctrl_regs[6];
	assign adc_mode2_d  = ctrl_regs[6];
	
	//assign trigger = ~SPI_SS;
	assign trigger = ctrl_regs[10][0];
	//assign read_request = ~SPI_SS;
	assign read_request = ctrl_regs[11][0];
	
//	always @(*) begin
//		trigger = 1'b0;
//		//read_request = 1'b0;
//		if (ticks > 32'h0EE6B280) begin
//			trigger = 1'b1;
//			//read_request = 1'b1;
//		end
//		if (ticks > 32'h0EE6B290) begin
//			trigger = 1'b0;
//			//read_request = 1'b0;
//		end
//	end
				

   // preload some registers
   initial begin
      ctrl_regs[0] = 8'h00; // lowest 8 bits of howmany
      ctrl_regs[1] = 8'h04; // highest 8 bits of howmany
      //ctrl_regs[2] = 8'ha5;
      //ctrl_regs[3] = 8'h5a;
		ctrl_regs[6] = 8'h09; // ADC mode
		ctrl_regs[7] = 8'h00; // Which module to test, lvds_rec.v, lvdsrec.vhd, or sc
		ctrl_regs[8] = 8'h00; // Use highest 8 bits or lowest 8 bits
		ctrl_regs[9] = 8'h00; // Which channel to test
		ctrl_regs[10] = 8'h00; // trigger
		ctrl_regs[11] = 8'h00; // read_request
   end

   // state machine outputs
   wire       rd_select, wr_select, fifo_select, latch_cmd, fifo_rd_one;

   // handle the read and write 
   always @(posedge sysclk ) begin
      if ( rd_select) begin
         SPI_tx_reg <= ctrl_regs[SPI_addr];
      end 
      else if ( wr_select ) begin
         ctrl_regs[SPI_addr] <= SPI_rx_reg;
      end
      else if ( SPI_done & fifo_select & fifo_rd_one ) begin
	 // needs to set ZYNQ_RD_REQUEST for one clock cycle
	 // BROKEN. Update SPI state machine to handle this.
	 SPI_tx_reg <= dout[7:0];
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
	      .led(led_hack),
              .fifo_select(fifo_select),
              .latch_cmd(latch_cmd),
	      //.fifo_rd_enable(fifo_rd_one),
              .cmd(SPI_rx_reg[3:0]), // before they are latched
              .done(SPI_done),
              //.FIFO_PK_SZ(FIFO_PK_SZ),   // number of words to send
              .clk(sysclk),
              .rst(rst) 
              );
				  
				  
   // END SPI_Interface
	// ------------------------------------------------------------
   

	
   //-------------------------------------------------------------
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

