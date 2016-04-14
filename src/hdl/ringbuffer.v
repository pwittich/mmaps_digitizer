// ring buffer for storing the PMT data as it comes off the ADC
// synchronous, with a synchronous reset
`timescale 1ns / 1ps
`default_nettype none
 
module ringbuffer #(parameter SIZE=8, WIDTH=14)(
	input wire clk, 
	input wire wr_en, 
	input wire rd_en, 
	input wire rst,
	input wire [SIZE-1:0] ain,
	input wire [WIDTH-1:0] din, 
	output wire [WIDTH-1:0] dout,
	output wire [SIZE-1:0] aout);

	reg [SIZE-1:0] address;
	localparam NUMWORDS=2**SIZE;
	reg [WIDTH-1:0] data[0:NUMWORDS-1];

	initial address <= {SIZE{1'b0}};
	
	always @(posedge clk) begin
		if ( rst == 1 ) begin
			address <= {SIZE{1'b0}};
		end
		else if ( wr_en == 1 ) begin
			address <= address + 1'b1;
			data[address] <= din;
		end
	end
	
	assign aout = address;
	assign dout = rd_en?data[ain]:0;
	
	endmodule