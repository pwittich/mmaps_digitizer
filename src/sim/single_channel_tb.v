`timescale 1ns / 1ns
`default_nettype none

module single_channel_tb ();

reg 	clk;
reg 	reset;
reg 	adc_data_ready;
reg 	trigger;
reg 	adc_fast_clk;
reg 	adc_frame;
reg 	adc_data_p; // single channel serial input
wire 	[11:0] data_out;
reg		[11:0]  how_many;
reg 	[11:0]  offset;
reg    read_request;

single_channel single_channel_inst2(
							.clk(clk),
							.reset(reset),
							.adc_data_ready(adc_data_ready),
							.trigger(trigger),
							.adc_fast_clk(adc_fast_clk),
							.adc_frame(adc_frame),
							.adc_data_p(adc_data_p),
							.data_out(data_out),
							.how_many(how_many),
							.offset(offset),
							.read_request(read_request)
	);


initial begin: clock_gen
	clk = 0;
end
always begin
	 #12 clk = ~clk;
end

integer i;
initial begin: fast_clock_gen
	adc_fast_clk = 0;
	for (i = 0; i < 4000; i = i + 1) begin
		#2 adc_fast_clk = ~ adc_fast_clk;
	end
end

integer j;
initial begin: adc_data_p_gen
	adc_data_p = 0;
	#1 adc_data_p = 1;
	for (j = 0; j < 4000; j = j + 1) begin
		#2 adc_data_p = ~ adc_data_p;
	end
end

integer k;
initial begin: adc_frame_gen
	adc_frame = 0;
	#1 adc_frame = 1;
	for (k = 0; k < 4000; k = k + 1) begin
		#12 adc_frame = ~ adc_frame;
	end
end

initial begin: reset_gen
	reset = 0;
	#10
	reset = 1;
	#10
	reset = 0;
end

initial begin
	wait (reset == 1);
	adc_data_ready = 1;
	trigger = 1;
	how_many = 12'h001;
	offset = 12'h000;
	read_request = 1;
end

//always @ (posedge clock) begin
//	if (reset) begin
//		adc_data_ready = 1;
//		trigger = 1;
//		how_many = 12'h00a;
//		offset = 12'h000;
//		read_request <= 1;
//	end
//end

endmodule
