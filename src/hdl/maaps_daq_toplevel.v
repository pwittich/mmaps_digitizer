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

`include "all_defines.v"

// Top level HDL module
module maaps_daq_toplevel(
	CK50,

	ADCCLK1_p, ADCCLK1_n,
	ADC_SCLK1,
	ADC_nCS1,
	ADC_SDIO1,

	ADCCLK2_p, ADCCLK2_n,
	ADC_SCLK2,
	ADC_nCS2,
	ADC_SDIO2,

	SPI_MOSI_p, SPI_MOSI_n,
	SPI_SCLK_p, SPI_SCLK_n,
	SPI_SS_p, SPI_SS_n,
	SPI_MISO_p, SPI_MISO_n,

	adcdata_p, adcdata_n,
	adcfastclk_p, adcfastclk_n,
	adcframe_p, adcframe_n,

	PMT_trigger_p, PMT_trigger_n,

	L1,
	L0
);



// IO_INIT
// -------------------------------------------------------------
// Initializes all the IO variables, i.e. pins that connect to
// the outsite world

// ADC SPI CONFIG IO

output wire ADCCLK1_p, ADCCLK1_n;
wire ADCCLK1;

output wire ADC_SCLK1;
output wire ADC_nCS1;
inout wire ADC_SDIO1;

output wire ADCCLK2_p, ADCCLK2_n;
wire ADCCLK2;

output wire ADC_SCLK2;
output wire ADC_nCS2;
inout wire ADC_SDIO2;

// ZYNQ SPI IO

input wire SPI_MOSI_p, SPI_MOSI_n;
wire SPI_MOSI;

input wire SPI_SCLK_p, SPI_SCLK_n;
wire SPI_SCLK;

input wire SPI_SS_p, SPI_SS_n;
wire SPI_SS;

output wire SPI_MISO_p, SPI_MISO_n;
wire SPI_MISO;

// ADC DATA IO

input wire [15:0] adcdata_p;
input wire [15:0] adcdata_n;
wire [15:0] adcdata; // 16 serial lines

input wire adcfastclk_p, adcfastclk_n;
wire adcfastclk;

input wire adcframe_p, adcframe_n;
wire adcframe;

// External trigger IO

input wire PMT_trigger_p, PMT_trigger_n;
wire PMT_trigger;

// System clock IO

input wire CK50;

// input clock - 50 MHz 
wire sysclk;
assign sysclk = CK50;

// output clocks to the two octal ADCs
assign ADCCLK1 = sysclk;
assign ADCCLK2 = sysclk;

// LED IO

output wire L0;
output wire L1;

// L0: blue LED
// L1: green LED

assign L0 = ZYNQ_RD_EN;
assign L1 = trigger_out;

// END IO_INIT
// -------------------------------------------------------------




// DIFF_IO_CONVERT
// -------------------------------------------------------------
// Converts each differential input/output into one logical signal

handle_diff_io handle_diff_io_inst(

	.ADCCLK1_p(ADCCLK1_p), .ADCCLK1_n(ADCCLK1_n),
	.ADCCLK1(ADCCLK1),

	.ADCCLK2_p(ADCCLK2_p), .ADCCLK2_n(ADCCLK2_n),
	.ADCCLK2(ADCCLK2),

	.SPI_MOSI_p(SPI_MOSI_p), .SPI_MOSI_n(SPI_MOSI_n),
	.SPI_MOSI(SPI_MOSI),

	.SPI_SCLK_p(SPI_SCLK_p), .SPI_SCLK_n(SPI_SCLK_n),
	.SPI_SCLK(SPI_SCLK),

	.SPI_SS_p(SPI_SS_p), .SPI_SS_n(SPI_SS_n),
	.SPI_SS(SPI_SS),

	.SPI_MISO_p(SPI_MISO_p), .SPI_MISO_n(SPI_MISO_n),
	.SPI_MISO(SPI_MISO),

	.adcdata_p(adcdata_p), .adcdata_n(adcdata_n),
	.adcdata(adcdata),

	.adcfastclk_p(adcfastclk_p), .adcfastclk_n(adcfastclk_n),
	.adcfastclk(adcfastclk),

	.adcframe_p(adcframe_p), .adcframe_n(adcframe_n),
	.adcframe(adcframe),
	
	.PMT_trigger_p(PMT_trigger_p), .PMT_trigger_n(PMT_trigger_n),
	.PMT_trigger(PMT_trigger)
);

// END DIFF_IO_CONVERT
// -------------------------------------------------------------




// ADC_MODE_CHANGE_DETECT
// -------------------------------------------------------------
// Detects if user has changed the ADC mode and sets each adc 
// flag to signal to adc_spimaster that a new ADC SPI transaction
// must occur to update the ADC mode

wire adc_ready1, adc_ready2; // output
reg adc_flag1, adc_flag2;
reg  [7:0] adc_mode1_q, adc_mode2_q;
	
always @ (posedge sysclk) begin
	// Flag lasts only one sysclk cycle
	if (adc_flag1 == 1'b1)
		adc_flag1 <= 1'b0;
	else
		// Enable flag if mode was changed
		if (adc_mode1_q != adc_mode1_d)
			adc_flag1 <= 1'b1;
			
	if (adc_flag2 == 1'b1)
		adc_flag2 <= 1'b0;
	else
		if (adc_mode2_q != adc_mode2_d)
			adc_flag2 <= 1'b1;
end

always @(posedge sysclk) begin
	if (rst) begin
		adc_mode1_q <= `ADCMODE_CONSTWORD;
		adc_mode2_q <= `ADCMODE_CONSTWORD;
	end else begin
		adc_mode1_q <= adc_mode1_d;
		adc_mode2_q <= adc_mode2_d;
	end
end
	
// END ADC_MODE_CHANGE_DETECT
// -------------------------------------------------------------




// ADC_SPI_CONTROL
// -------------------------------------------------------------
// Configures the two external ADCs (each with 8 channels) with
// the appropriate mode, chosen by the user via ZYNQ_SPI commands
// issued from the zynq (microzed). Note that this is yet another
// SPI communication, but it goes to the ADCs and not the zynq.

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

// END ADC_SPI_CONTROL
// -------------------------------------------------------------




// ALL_CHANNELS_DATA	  
// -------------------------------------------------------------
// Digi_many module to read and hold data from all channels,
// each with its own ringbuffer. The EOS signal is a trigger
// that stops the data collection and waits until all the data
// is sent to the ZYNQ before resuming.

//wire [7:0] howmany;
reg [11:0] howmany;
wire trigger_in;

	
wire [15:0] adc_data_out_digimany;

wire ZYNQ_RD_EN;
	
// Module to contain the input from the digitizer channels.
// configurable how many it controls by the CHAN variable.
digi_many #(.CHAN(16),.DATA_WIDTH(16)) digi_many_inst(
	.RST(rst), 
	.SYSCLK(sysclk), 
	.adc_clk(adcfastclk), 
	.adc_frame(adcframe),
	.adcdata(adcdata[15:0]), 
	.DOUT(adc_data_out_digimany), // output to remote
	.EOS(trigger_out),
	.SPI_done(word_done),
	.ADC_sample_num(ADC_sample_num),
	.trigger_delay(offset), // configuration
	.DAVAIL(adc_ready1),
	.ZYNQ_RD_EN(ZYNQ_RD_EN)
);


reg word_done;
reg MSB;

// Block to determine which bits of ADC data should be sent
// out to the zynq. Options are: top 8 bits, bottom 8 bits, or
// all bits. In the latter case the top 8 and bottom 8 bits are
// sent alternately.
always @ (posedge sysclk) begin
	if (rst) begin
		word_done <= 1'b0;
		MSB <= 1'b1;
		adc_data_out_word <= `DEFAULT_WORD_8BITS;
	end else if (SPI_done) begin
		if (which_bits_out == `ALL12BITS) begin
			// Alternate between sending top 8 bits
			// and bottom 4 bits (MSB vs LSB)
			if (MSB) begin
				MSB <= 1'b0;
				adc_data_out_word <= adc_data_out_test[11:8];
				word_done <= 1'b1;
			end else begin
				MSB <= 1'b1;
				adc_data_out_word <= adc_data_out_test[7:0];
				word_done <= 1'b0;
			end
		end else if (which_bits_out == `BOTTOM8BITS) begin
			adc_data_out_word <= adc_data_out_test[7:0];
			word_done <= 1'b1;
		end else if (which_bits_out == `TOP8BITS) begin
			adc_data_out_word <= adc_data_out_test[11:4];
			word_done <= 1'b1;
		end
	end else begin
		word_done <= 1'b0;
	end
end

// END ALL_CHANNELS_DATA
// -------------------------------------------------------------




// SPI_ZYNQ
// -------------------------------------------------------------
// SPI interface for ZYNQ communication. Receives commands from 
// the zynq and sends back ADC samples to be stored and processes

localparam ZSPI_WORDSIZE = 8;

// 16 control registers
reg [ZSPI_WORDSIZE-1:0] ctrl_regs [15:0];

wire [ZSPI_WORDSIZE*16-1:0] ctrl_regs_longarray;

wire SPI_done;

handle_spi #(.ZSPI_WORDSIZE(ZSPI_WORDSIZE)) handle_spi_inst(
	.sysclk(sysclk),
	.rst(rst),
	.SPI_SS(SPI_SS),
	.SPI_MOSI(SPI_MOSI),
	.SPI_MISO(SPI_MISO),
	.SPI_SCLK(SPI_SCLK),
	.SPI_done(SPI_done),
	.ctrl_regs_longarray(ctrl_regs_longarray),
	.adc_data_out_word(adc_data_out_word)
);

// Modules in Verilog can't pass arrays, so need
// this block to convert a long register into several
// shorter array elements
integer i;
always @ (*) begin
	for (i = 0; i < 16; i = i +1)
		ctrl_regs[i] = ctrl_regs_longarray[8*i +: 8];
end


// END SPI_ZYNQ
// -----------------------------------------------------------




// CTRL_REGS_ASSIGNMENTS
// -------------------------------------------------------------
// Assigns registers from ctrl_regs to their respective
// logical names. Ctrl_regs are configured by user from microzed
// issuing custom commands on ZynqCycloneCommTool (see docs)


wire [11:0] ADC_sample_num;
wire [15:0] ZYNQ_word_num;
wire [15:0] offset;
wire [7:0] adc_mode1_d, adc_mode2_d;
wire [7:0] which_module_to_test;
wire [7:0] which_bits_out;
wire artificial_trigger;
wire read_request;
wire rst;

assign ADC_sample_num = {ctrl_regs[1][3:0], ctrl_regs[0]};
assign ZYNQ_word_num = {ctrl_regs[3], ctrl_regs[2]};
assign offset = {ctrl_regs[5], ctrl_regs[4]};
assign adc_mode1_d  = ctrl_regs[6];
assign adc_mode2_d  = ctrl_regs[6];
assign which_module_to_test = ctrl_regs[7];
assign which_bits_out = ctrl_regs[8];
assign artificial_trigger = ctrl_regs[10][0];
assign read_request = ctrl_regs[11][0]; // used for single_channel test only
assign rst = reset | ctrl_regs[12][0]; // reset can be issued by zynq


// Assigning the trigger is a bit more complex:
// we pass the input trigger (either via the PMT_trigger
// external pin or via the control register) through
// two FF's in sequence to make sure there are no spurious
// effects that would cause the trigger to behave erratically

assign trigger_in = PMT_trigger | artificial_trigger;

wire trigger_temp;

dff_sync_reset ff1 (
.data(trigger_in),
.clk(sysclk),
.reset(rst),
.q(trigger_temp)
);

wire trigger_out;

dff_sync_reset ff2 (
.data(trigger_temp),
.clk(sysclk),
.reset(rst),
.q(trigger_out)
);

// END CTRL_REGS_ASSIGNMENTS
// -----------------------------------------------------------




// TEST_MODULES
// -------------------------------------------------------------
// Test single_channel, lvds_receiver.v and lvdsreceiver.vhd.
// Which output goes to the SPI slave to be sent out to the
// zynq is controlled by ctrl_regs[7]. This is to be used for
// debugging purposes only, and bypasses the digi_many module

wire [11:0] adc_data_out_verilog;
wire [11:0] adc_data_out_vhdl;
wire [11:0] adc_data_out_singlechannel;

test_submodules test_submodules_inst(
	.sysclk(sysclk),
	.adcfastclk(adcfastclk),
	.adcframe(adcframe),
	.adcdata(adcdata),
	.rst(rst),
	.adc_data_out_vhdl(adc_data_out_vhdl),
	.adc_ready1(adc_ready1),
	.trigger_out(trigger_out),
	.adc_data_out_singlechannel(adc_data_out_singlechannel),
	.howmany(howmany),
	.read_request(read_request),
	.SPI_done(SPI_done),
	.SPI_SS(SPI_SS),
	.ZYNQ_word_num(ZYNQ_word_num)
);

reg [11:0] adc_data_out_test;
reg [7:0] adc_data_out_word;

// Check for which module, if any, to test.
// Directs output from corresponding module
always @(*) begin
	adc_data_out_test = `DEFAULT_WORD_12BITS;
	if (which_module_to_test == `DIGIMANY_NOTEST) begin
		adc_data_out_test = adc_data_out_digimany[15:4];
	end else if (which_module_to_test == `VHDL_TEST) begin
		adc_data_out_test = adc_data_out_vhdl;
	end else if (which_module_to_test == `SINGLECHANNEL_TEST) begin
		adc_data_out_test = adc_data_out_singlechannel;
	end
	//		end else if (ctrl_regs[7] == 8'h03) begin
	//			adc_data_out_test = adc_data_out_verilog;
	//		end
end
	
// END TEST_MODULES
// -------------------------------------------------------------




// RESET_LOGIC
// -------------------------------------------------------------
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


// END RESET_LOGIC
// -------------------------------------------------------------
   

endmodule

