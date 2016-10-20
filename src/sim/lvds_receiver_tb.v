`timescale 1ns / 1ns
`default_nettype none

module lvds_receiver_tb ();

reg 	clk;
reg 	reset;
reg 	adc_data_ready;
reg 	trigger;
reg 	adc_fast_clk;
reg 	adc_frame;
reg 	adc_data_p; // single channel serial input
wire 	[11:0] data_out;
wire	[7:0] address_out;
wire	wenable;


lvds_receiver receiver_inst(
			      .sysclk(clk),
			      .DATA(adc_data_p),
			      .FRAME(adc_frame),
			      .FASTCLK(adc_fast_clk),
			      .CBDATA(data_out),
			      .CBADDRESS(address_out), // not used right now
			      .WENABLE(wenable),
			      .RESET_n(~reset)
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
	#40
	reset = 1;
	#40
	reset = 0;
end


initial begin
	wait (reset == 1);
	adc_data_ready = 1;
	trigger = 1;
end

endmodule
