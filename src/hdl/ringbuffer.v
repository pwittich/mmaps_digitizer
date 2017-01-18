// ring buffer for storing the PMT data as it comes off the ADC
// synchronous, with a synchronous reset
`timescale 1ns / 1ps
`default_nettype none
 
// Module to contain the ADC data. It stores the data
// sequentially, outputting the last address that has been
// filled via aout, to addr_ctrl. It wraps around if it fills
// up. When it's readout time it gets the address of the data
// to read out via ain from addr_ctrl, and outputs the word in
// that register.
module ringbuffer #(parameter SIZE=12, WIDTH=14) (
	input wire sysclk,
	input wire fastclk,
	input wire wr_en, 
	input wire rd_en, 
	input wire rst,
	input wire [SIZE-1:0] ain,
	input wire [WIDTH-1:0] din, 
	output wire [WIDTH-1:0] dout,
	output wire [SIZE-1:0] aout
);

reg [SIZE-1:0] address;
//localparam NUMWORDS=2**SIZE;
localparam NUMWORDS=2**10;
reg [WIDTH-1:0] data[0:NUMWORDS-1];

reg [WIDTH-1:0] dout_reg;
// Quartus likes the input address to be latched
reg [SIZE-1:0] ain_reg; 

initial address <= {SIZE{1'b0}};

always @(posedge sysclk) begin
	ain_reg <= ain;
	if ( rst == 1 ) begin
		address <= {SIZE{1'b0}};
		dout_reg <= {WIDTH{1'b0}};
	end
	else begin 
		if ( wr_en == 1 ) begin
			address <= address + 1'b1;
			data[address] <= din;
		end
		if ( rd_en == 1) begin
			dout_reg <= data[ain_reg];
		end
	end
end

assign aout = address;
assign dout = dout_reg;
	
endmodule