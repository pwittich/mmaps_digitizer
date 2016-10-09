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

   wire [15:0] 	     dout;
	
   wire              adc_ready1, adc_ready2; // output
   reg              adc_flag1, adc_flag2;
   reg [7:0]         adc_mode1, adc_mode2;
	
	reg [31:0] ticks;
	always @(posedge sysclk) begin
		if (rst) begin
			ticks <= 32'h00000000;
		end else begin
			ticks <= ticks + 1;
		end
	end
	
	always @ (*) begin
		adc_mode1 = 8'h09;
		adc_mode2 = 8'h09;
		adc_flag1 = 1'b0;
		adc_flag2 = 1'b0;
		if (ticks > 100000) begin
			adc_flag1 = 1'b1;
			adc_flag2 = 1'b1;
			if (ticks > 100100) begin
				adc_flag1 = 1'b0;
				adc_flag2 = 1'b0;
			end
		end
	end

   // ugh

   // SPI controller to configure the external ADCs
   // one each for each octal ADC

   adc_spimaster adc_spimaster_inst_1(
                                      .sys_clk(sysclk),
                                      .reset_n(~rst),
                                      .adc_sclk(ADC_SCLK1),
                                      .adc_sdio(ADC_SDIO1),
                                      .adc_cs(ADC_nCS1),
                                      .adc_flag(adc_flag1),
                                      .adc_mode(adc_mode1),
                                      .adc_ready(adc_ready1)
                                      );
   adc_spimaster adc_spimaster_inst_2(
                                      .sys_clk(sysclk),
                                      .reset_n(~rst),
                                      .adc_sclk(ADC_SCLK2),
                                      .adc_sdio(ADC_SDIO2),
                                      .adc_cs(ADC_nCS2),
                                      .adc_flag(adc_flag2),
                                      .adc_mode(adc_mode2),
                                      .adc_ready(adc_ready2)
                                      );
     

   wire              fifo_empty;
   wire [7:0]        offset;
   wire [7:0]        howmany;
	reg					trigger;
	reg					read_request;
	
   // module to contain the input from the digitizer channels.
   // configurable how many it controls by the CHAN variable.
   // howmany, offset should be made configurable - hardwired for now
   // DAVAIL and TRIGGER should also not be hardwired to their current widths.
//   digi_many #(.CHAN(8)) digi_many_inst(
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
	
	//single_channel_tb single_channel_tb_inst ();
	
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
	
	// Test: single_channel.v
	single_channel single_channel_inst(
							.clk(sysclk),
							.reset(rst),
							.adc_data_ready(adc_ready1),
							.trigger(trigger),
							.adc_fast_clk(adcfastclk_p),
							.adc_frame(adcframe_p),
							.adc_data_p(adcdata_p[1]),
							.data_out(adc_data_out),
							//.sc_wr_enable(sc_wr_enable),
							.how_many(howmany),
							.offset(offset),
							.read_request(read_request)
	);
	
	//lvds_receiver_tb lvds_receiver_tb_inst();
	lvds_receiver lvds_rec_inst_test(
	 					.sysclk(sysclk),
	 					.FASTCLK(adcfastclk_p),
							.FRAME(adcframe_p),
	 					.DATA(adcdata_p[1]),
							.RESET_n(~rst),
							.CBDATA(adc_data_out2),
							.CBADDRESS(adc_addr_out_test),
							.WENABLE(adc_wenable_test)
	);
	// Test: lvdsreceiver.vhd
	// Trying to read single channel
	// synthesis read_comments_as_HDL off
	//      lvdsreceiver lvds_rec_inst_test(
	// 					.sysclk(sysclk),
	// 					.FASTCLK(adcfastclk_p),
	//						.FRAME(adcframe_p),
	// 					.DATA(adcdata_p[1]),
	//						.RESET_n(~rst),
	//						.CBDATA(adc_data_out),
	//						.CBADDRESS(adc_addr_out),
	//						.WENABLE(adc_wenable)
	//		);
	//	synthesis read_comments_as_HDL off

// (AF) Pseudo-state machine to handle communication from
// the zynq. This uses a 3-word cycle, where the command
// and register are sent in the first byte, the value to
// write is sent in the second byte if command is a write
// and a dummy byte if command is a read. The third byte
// is always a dummy and is there to allow time for the
// slave to respond. This is being replaced by Peter's
// SPI state machine which has a different structure.
// Keeping this here commented out just in case.
//	
//	
//   wire 	     SPI_done;
//	wire [ZSPI_WORDSIZE-1:0] SPI_datatomaster;
//	wire [ZSPI_WORDSIZE-1:0] SPI_datafrommaster;
//
//   spi_slave #(.WORDSIZE(ZSPI_WORDSIZE)) spi_slave_inst(
//							.clk(sysclk),
//							.rst(rst),
//							.ss(SPI_SS), // ACTIVE LOW, input from master
//							.mosi(SPI_MOSI),
//							.miso(SPI_MISO),
//							.sck(SPI_SCLK),
//							.done(SPI_done),
//							.din(SPI_datatomaster),
//							.dout(SPI_datafrommaster)
//							);
//							
//	// (AF) SPI structure for now:
//	// master request: 3 bytes
//	// - READ:  CCCCRRRR DDDDDDDD DDDDDDDD
//	// - WRITE: CCCCRRRR VVVVVVVV DDDDDDDD
//	// where C = command, R = Register address,
//	// V = value to write, D = dummy data
//	// slave response: 3 bytes
//	// - DDDDDDDD DDDDDDDD VVVVVVVV, V = value to read
//	
//	reg [ZSPI_WORDSIZE-1:0] ctrl_regs [15:0];
//	
//	reg [3:0] command_d;
//	reg [3:0] command_q;
//	reg [3:0] register_d;
//	reg [3:0] register_q;
//	reg [7:0] value;
//	reg SPI_SM_done;
//	wire SPI_SM_rd_select;
//	wire SPI_SM_wr_select;
//	
//	reg [1:0] byte_ct_q;
//	reg [1:0] byte_ct_d;
//	reg [7:0] SPI_datatomaster_q;
//	reg [7:0] SPI_datatomaster_d;
//
//	
//	//assign SPI_datatomaster = SPI_datatomaster_q;
//	assign SPI_datatomaster = adc_data_out[11:4];
//	//assign SPI_datatomaster = adc_data_out_reg_q[11:4];
//	
//	reg [7:0] control_regs_d[15:0];
//	reg [7:0] control_regs_q[15:0];
//	
//	integer i;
//	
//	always @ (*) begin
//		
//		byte_ct_d = byte_ct_q;
//		SPI_datatomaster_d = SPI_datatomaster_q;
//		command_d = command_q;
//		register_d = register_q;
//		for (i = 0; i < 16; i = i + 1) begin
//			control_regs_d[i] = control_regs_q[i];
//		end
//		
//		if (SPI_SS) begin
//			byte_ct_d = 2'b00;
//			SPI_datatomaster_d = 8'h99;
//		end
//		
//		// Handles the communication protocol
//		// by checking which byte we are currently
//		// processing
//		if (SPI_done) begin
//			if (byte_ct_q == 2'b00) begin
//				command_d = SPI_datafrommaster[7:4];
//				register_d = SPI_datafrommaster[3:0];
//				if (command_d == 4'b0001) begin // If CMD == RD
//					SPI_datatomaster_d = control_regs_d[register_d]; // sends value of reg (takes 2 word cycles to show up)
//				end
//				byte_ct_d = 2'b01;
//			end else if (byte_ct_q == 2'b01) begin
//				if (command_q == 4'b0010) begin // IF CMD == WR
//					control_regs_d[register_q] = SPI_datafrommaster; // writes to reg value sent from master
//				end
//				byte_ct_d = 2'b10;
//			end else if (byte_ct_q == 2'b10) begin // Need this extra byte to complete communication
//				SPI_datatomaster_d = 8'haa;
//				byte_ct_d = 2'b00;
//			end
////			end else if (byte_ct_q == 2'b11) begin
////				SPI_datatomaster_d = 8'h88;
////				byte_ct_d = 2'b00;
//		end
//	end
//	
//	always @ (posedge sysclk) begin
//		if (rst) begin
//			byte_ct_q <= 2'b00;
//			SPI_datatomaster_q <= 8'h00;
//			command_q <= 4'h00;
//			register_q <= 4'h00;
//			for (i = 0; i < 16; i = i + 1) begin
//				control_regs_q[i] <= 8'h00;
//			end
//		end else begin
//			byte_ct_q <= byte_ct_d;
//			SPI_datatomaster_q <= SPI_datatomaster_d;
//			command_q <= command_d;
//			register_q <= register_d;
//			for (i = 0; i < 16; i = i + 1) begin
//				control_regs_q[i] = control_regs_d[i];
//			end
//		end
//	end

	// spi slave for ZYNQ communications
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
																.din(adc_data_out[7:0]),
                                                //.din(hack),
                                                .dout(SPI_s)
                                                );
   wire       led_hack;

   //wire [7:0] hack;
   //assign hack = SPI_rx_reg;

   // L0: blue LED
   // L1: green LED
   assign L0 = (SPI_addr == 4'h0)&(SPI_cmd == `WR); // blue LED
   //assign L1 = ctrl_regs[0][7]; // green LED
   //assign L1 = SPI_tx_reg[7]; // green LED
	assign L1 = read_request;

   // store slave's data
   always @(posedge sysclk) begin
      if ( SPI_done ) begin
         SPI_rx_reg <= SPI_s;
      end
   end

   // 16 control registers
   reg [ZSPI_WORDSIZE-1:0]  ctrl_regs [15:0];
   wire [7:0] 		    FIFO_PK_SZ;

   assign howmany = ctrl_regs[1] ;
   assign offset = ctrl_regs[2] ;
   assign FIFO_PK_SZ = ctrl_regs[3];
	//assign trigger = ctrl_regs[4];
	//assign read_request = ctrl_regs[5];
	
	always @(*) begin
		trigger = 1'b0;
		read_request = 1'b0;
		if (ticks > 32'h1dcd6500) begin
			trigger = 1'b1;
			read_request = 1'b1;
		end
//		if (ticks > 32'h1dcd7500) begin
//			trigger = 1'b0;
//			read_request = 1'b0;
//		end
	end
				

   // preload some registers
   initial begin
      ctrl_regs[0] = 8'haa;
      ctrl_regs[1] = 8'hff;
      //ctrl_regs[2] = 8'ha5;
      //ctrl_regs[3] = 8'h5a;
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
   // END SPI INTERFACE
   

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

