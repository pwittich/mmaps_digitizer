`timescale 1ns / 1ps
`default_nettype none

module handle_diff_io(

			output wire ADCCLK1_p, ADCCLK1_n,
			input wire ADCCLK1,

			output wire ADCCLK2_p, ADCCLK2_n,
			input wire ADCCLK2,

			input wire SPI_MOSI_p, SPI_MOSI_n,
			output wire SPI_MOSI,

			input wire SPI_SCLK_p, SPI_SCLK_n,
			output wire SPI_SCLK,

			input wire SPI_SS_p, SPI_SS_n,
			output wire SPI_SS,

			output wire SPI_MISO_p, SPI_MISO_n,
			input wire SPI_MISO,

			input wire [15:0] adcdata_p, input wire [15:0] adcdata_n,
			output wire [15:0] adcdata,

			input wire adcfastclk_p, adcfastclk_n,
			output wire adcfastclk,

			input wire adcframe_p, adcframe_n,
			output wire adcframe,
			
			input wire PMT_trigger_p, PMT_trigger_n,
			output wire PMT_trigger
);


	ALT_OUTBUF_DIFF outbuf_adcclk1(
		.i(ADCCLK1),
		.obar(ADCCLK1_n),
		.o(ADCCLK1_p)
	);

	ALT_OUTBUF_DIFF outbuf_adcclk2(
		.i(ADCCLK2),
		.obar(ADCCLK2_n),
		.o(ADCCLK2_p)
	);

	ALT_INBUF_DIFF inbuf_spimosi(
		.i(SPI_MOSI_p),
		.ibar(SPI_MOSI_n),
		.o(SPI_MOSI)
	);

	ALT_INBUF_DIFF inbuf_spisclk(
		.i(SPI_SCLK_p),
		.ibar(SPI_SCLK_n),
		.o(SPI_SCLK)
	);

	ALT_INBUF_DIFF inbuf_spiss(
		.i(SPI_SS_p),
		.ibar(SPI_SS_n),
		.o(SPI_SS)
	);

	ALT_OUTBUF_DIFF outbuf_spimiso(
		.i(SPI_MISO),
		.o(SPI_MISO_p),
		.obar(SPI_MISO_n)
	);


	ALT_INBUF_DIFF inbuf_adcdata0(
		.i(adcdata_p[0]),
		.ibar(adcdata_n[0]),
		.o(adcdata[0])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata1(
		.i(adcdata_p[1]),
		.ibar(adcdata_n[1]),
		.o(adcdata[1])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata2(
		.i(adcdata_p[2]),
		.ibar(adcdata_n[2]),
		.o(adcdata[2])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata3(
		.i(adcdata_p[3]),
		.ibar(adcdata_n[3]),
		.o(adcdata[3])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata4(
		.i(adcdata_p[4]),
		.ibar(adcdata_n[4]),
		.o(adcdata[4])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata5(
		.i(adcdata_p[5]),
		.ibar(adcdata_n[5]),
		.o(adcdata[5])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata6(
		.i(adcdata_p[6]),
		.ibar(adcdata_n[6]),
		.o(adcdata[6])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata7(
		.i(adcdata_p[7]),
		.ibar(adcdata_n[7]),
		.o(adcdata[7])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata8(
		.i(adcdata_p[8]),
		.ibar(adcdata_n[8]),
		.o(adcdata[8])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata9(
		.i(adcdata_p[9]),
		.ibar(adcdata_n[9]),
		.o(adcdata[9])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata10(
		.i(adcdata_p[10]),
		.ibar(adcdata_n[10]),
		.o(adcdata[10])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata11(
		.i(adcdata_p[11]),
		.ibar(adcdata_n[11]),
		.o(adcdata[11])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata12(
		.i(adcdata_p[12]),
		.ibar(adcdata_n[12]),
		.o(adcdata[12])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata13(
		.i(adcdata_p[13]),
		.ibar(adcdata_n[13]),
		.o(adcdata[13])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata14(
		.i(adcdata_p[14]),
		.ibar(adcdata_n[14]),
		.o(adcdata[14])
	);
	
	ALT_INBUF_DIFF inbuf_adcdata15(
		.i(adcdata_p[15]),
		.ibar(adcdata_n[15]),
		.o(adcdata[15])
	);

	ALT_INBUF_DIFF inbuf_adcfastclk(
		.i(adcfastclk_p),
		.ibar(adcfastclk_n),
		.o(adcfastclk)
	);

	ALT_INBUF_DIFF inbuf_adcframe(
		.i(adcframe_p),
		.ibar(adcframe_n),
		.o(adcframe)
	);
	
	ALT_INBUF_DIFF inbuf_pmttrigger(
		.i(PMT_trigger_p),
		.ibar(PMT_trigger_n),
		.o(PMT_trigger)
	);

endmodule