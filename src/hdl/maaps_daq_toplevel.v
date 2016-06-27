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

module maaps_daq_toplevel(
	CK50,
	adcfastclk_p,
	adcframe_p,
	spi_cs,
	spi_sclk,
	spi_data_in,
	PMT_trigger,
	adcdata_p,
	TDC,
	ADC_SCLK1,
	ADC_nCS1,
	ADCCLK1_p,
	ADCCLK2_p,
	L1,
	L0,
	spi_data_out,
	ADC_SDIO1
);


input wire	CK50;
input wire	adcfastclk_p;
input wire	adcframe_p;
input wire	spi_cs;
input wire	spi_sclk;
input wire	spi_data_in;
input wire	PMT_trigger;
input wire	[15:0] adcdata_p; // 16 serial lines
input wire	[31:0] TDC; // unused
output wire	ADC_SCLK1;
output wire	ADC_nCS1;
output wire	ADCCLK1_p;
output wire	ADCCLK2_p;
output wire	L1;
output wire	L0;
output wire	spi_data_out;
inout wire	ADC_SDIO1;

wire	sysclk;
assign	sysclk = CK50;

assign ADCCLK1_p = CK50;
assign ADCCLK2_p = CK50;

wire [15:0] dout;
wire adc_ready; // output

wire adc_flag;
reg [7:0] adc_mode;

initial adc_mode = 8'h09;

	adc_spimaster adc_spimaster_inst(
		.sys_clk(sysclk),
		.reset_n(1),
		
		.adc_sclk(ADC_SCLK1),
		.adc_sdio(ADC_SDIO1),
		.adc_cs(ADC_nCS1),
		
		.adc_flag(adc_flag),
		.adc_mode(adc_mode),
		.adc_ready(adc_ready)
		);
		
	
	

	digi_many digi_many_inst(
		.RST(0), .CK50(CK50), 
		.adc_clk(adcfastclk_p), 
		.adc_frame(adcframe_p),
		.adcdata_p(adcdata_p), 
		.DOUT(dout) // output to remote
	);

	

	
	
	endmodule

