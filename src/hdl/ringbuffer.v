// ring buffer for storing the PMT data as it comes off the ADC
// synchronous, with a synchronous reset
`timescale 1ns / 1ps
`default_nettype none
 
module ringbuffer #(parameter SIZE=12, WIDTH=14)(
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

	reg [WIDTH-1:0] dout_reg;
	// Quartus likes the input address to be latched
	reg [SIZE-1:0] ain_reg; 
	
	initial address <= {SIZE{1'b0}};
	
//	always @(*) begin
//		if (rst) begin
//			dout_reg_d = {SIZE{1'b0}};
//		end
//		else begin
//			if (wr_en) begin
//				data[address] = din;
//				address = address + 1'b1;
//			end
//			if (rd_en) begin
//				dout_reg_d = data[ain_reg];
//			end
//			else begin
//				dout_reg_
	
	always @(posedge clk) begin
		ain_reg <= ain;
		if ( rst == 1 ) begin
			address <= {SIZE{1'b0}};
			dout_reg <= {SIZE{1'b0}};
		end
		else begin 
			if ( wr_en == 1 ) begin
				address <= address + 1'b1;
				data[address] <= din;
			end
			if ( rd_en == 1) begin
				dout_reg <= data[ain_reg];
			end
//			else
//				//dout_reg <= {SIZE{1'b0}};
		end
	end
	
	assign aout = address;
	assign dout = dout_reg;
	
	endmodule