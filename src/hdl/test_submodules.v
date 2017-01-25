`timescale 1ns / 1ps
`default_nettype none

module test_submodules(
	input wire sysclk,
	input wire adcfastclk,
	input wire adcframe,
	input wire [15:0] adcdata,
	input wire rst,
	output wire [11:0] adc_data_out_vhdl,
	input wire adc_ready1,
	input wire trigger_out,
	output wire [11:0] adc_data_out_singlechannel,
	input wire [11:0] howmany,
	input wire read_request,
	input wire SPI_done,
	input wire SPI_SS,
	input wire [15:0] ZYNQ_word_num
);


// Test of the receivers is not enabled right now.
// Uncomment lines below to enable (this will probably
// require other modifications in the rest of the code
// as well)

wire [11:0] adc_data_out_verilog;

// lvdsreceiver lvdsrec_inst_test(
// 	.sysclk(sysclk),
// 	.FASTCLK(adcfastclk),
// 	.FRAME(adcframe),
// 	.DATA(adcdata[channelUnderTest]),
// 	.RESET_n(~rst),
// 	.CBDATA(adc_data_out_vhdl)
// );

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


// This block is used for a test readout of a single
// channel. It iterates over the readout register 
// address and iterates every time an SPI word is
// transferred to the zynq.

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

localparam channelUnderTest = 0;

single_channel single_channel_inst(
	.clk(sysclk),
	.reset(rst),
	.adc_data_ready(adc_ready1),
	.trigger(trigger_out),
	.adc_fast_clk(adcfastclk),
	.adc_frame(adcframe),
	.adc_data(adcdata[channelUnderTest]),
	.data_out(adc_data_out_singlechannel),
	//.sc_wr_enable(sc_wr_enable),
	.how_many(howmany[9:0]),
	.read_request(read_request),
	.SPI_done(SPI_done),
	.read_address(RD_ADDR_q[9:0])
);

endmodule