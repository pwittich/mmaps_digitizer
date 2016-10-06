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

   wire [15:0]       dout;

   // ugh

   // SPI controller to configure the external ADCs
   // one each for each octal ADC
   wire              adc_ready1, adc_ready2; // output
   wire              adc_flag1, adc_flag2;
   reg [7:0]         adc_mode1, adc_mode2;
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
   // module to contain the input from the digitizer channels.
   // configurable how many it controls by the CHAN variable.
   // howmany, offset should be made configurable - hardwired for now
   // DAVAIL and TRIGGER should also not be hardwired to their current widths.
   digi_many #(.CHAN(8)) digi_many_inst(
                                        .RST(rst&adc_ready1&adc_ready2), 
                                        .CK50(sysclk), 
                                        .adc_clk(adcfastclk_p), 
                                        .adc_frame(adcframe_p),
                                        .adcdata_p(adcdata_p), 
                                        .DOUT(dout), // output to remote
                                        .ZYNQ_RD_REQUEST(fifo_rd_one),
                                        .GLBL_EMPTY(fifo_empty),
                                        .howmany(howmany), // configuration
                                        .offset(offset), // configuration
                                        .DAVAIL(TDC[7:0]), // FIXME
                                        .TRIGGER(TDC[16:8]) // FIXME -- replace with PMT_trigger?
                                        );

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
                                                .din(SPI_tx_reg),
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
   assign L1 = SPI_tx_reg[7]; // green LED

   // store slave's data
   always @(posedge sysclk) begin
      if ( SPI_done ) begin
         SPI_rx_reg <= SPI_s;
      end
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
   
   // 16 control registers
   reg [ZSPI_WORDSIZE-1:0]  ctrl_regs [15:0];
   wire [7:0] 		    FIFO_PK_SZ;

   assign howmany = ctrl_regs[1] ;
   assign offset = ctrl_regs[2] ;
   assign FIFO_PK_SZ = ctrl_regs[3];

   // preload some registers
   initial begin
      ctrl_regs[0] = 8'haa;
      ctrl_regs[1] = 8'h55;
      ctrl_regs[2] = 8'ha5;
      ctrl_regs[3] = 8'h5a;
   end

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

