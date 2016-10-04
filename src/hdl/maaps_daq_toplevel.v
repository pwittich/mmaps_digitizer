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


   input wire   CK50;
   input wire   adcfastclk_p;
   input wire   adcframe_p;
        input wire      SPI_MOSI;
        input wire      SPI_SCLK;
        input wire      SPI_SS;
   input wire   PMT_trigger;
   input wire [15:0] adcdata_p; // 16 serial lines
   input wire [31:0] TDC; // unused
   output wire       ADC_SCLK1;
   output wire       ADC_nCS1;
   output wire       ADCCLK1_p;
   output wire       ADCCLK2_p;
   output wire       L1;
   output wire       L0;
        output wire                       SPI_MISO;
   inout wire        ADC_SDIO1;

   
   reg               rst;

   // input clock - 50 MHz 
   wire              sysclk;
   assign       sysclk = CK50;

   // output clocks to the two octal ADCs
   assign ADCCLK1_p = sysclk;
   assign ADCCLK2_p = sysclk;

   wire [15:0]       dout;
   wire              adc_ready; // output

   wire              adc_flag;
   reg [7:0]         adc_mode;

   // ugh

   // // hard-wired for now
   //   // SPI controller to configure the external ADCs
   // synthesis read_comments_as_HDL on
   //   initial adc_mode = 8'h09;
   //   adc_spimaster adc_spimaster_inst(
   //                               .sys_clk(sysclk),
   //                               .reset_n(~rst),
   //      
   //                               .adc_sclk(ADC_SCLK1),
   //                               .adc_sdio(ADC_SDIO1),
   //                               .adc_cs(ADC_nCS1),
   //      
   //                               .adc_flag(adc_flag),
   //                               .adc_mode(adc_mode),
   //                               .adc_ready(adc_ready)
   //                               );
   //
   //   
   // synthesis read_comments_as_HDL off

   wire              fifo_empty;
   wire [7:0]        offset;
   wire [7:0]        howmany;
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
   wire [31:0]       dcount;
   bc_counter #(.BITS(32)) counter_inst0(
                                         .CLK(sysclk),
                                         .RST(rst), 
                                         .BC(dcount)
                                         );
/* -----\/----- EXCLUDED -----\/-----
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
                                                .dout(SPI_s)
                                                );

   // store slave's data
   always @(posedge sysclk) begin
      if ( SPI_done ) begin
         SPI_rx_reg <= SPI_s;
      end
   end

   // state machine outputs
   wire       rd_select, wr_select, fifo_select, latch_cmd;

   // handle the read and write 
   always @(posedge sysclk ) begin
      if ( rd_select) begin
         SPI_tx_reg <= ctrl_regs[SPI_addr];
      end 
      else if ( SPI_done && wr_select ) begin
         ctrl_regs[SPI_addr] <= SPI_rx_reg;
      end
      else if ( SPI_done && fifo_select ) begin
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
   assign L0 = rd_select;
   assign L1 = wr_select;
   
   SPI_SM sm( // State machine for SPI slave on CycloneIII
              .rd_select(rd_select),
              .wr_select(wr_select),
              .fifo_select(fifo_select),
              .latch_cmd(latch_cmd),
              .CMD(SPI_rx_reg[3:0]), // before they are latched
              .DONE(SPI_done),
              .FIFO_PK_SZ(FIFO_PK_SZ),   // number of words to send
              .clk(sysclk),
              .rst(rst) 
              );
   
   
   // 16 control registers
   reg [ZSPI_WORDSIZE-1:0]  ctrl_regs [15:0];
   wire                     FIFO_PK_SZ;

   assign howmany = ctrl_regs[1] ;
   assign offset = ctrl_regs[2] ;
   assign FIFO_PK_SZ = ctrl_regs[3];


   

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

