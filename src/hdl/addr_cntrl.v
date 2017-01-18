// address control for the ring buffer
`timescale 1ns / 1ps
`default_nettype none

// This module controls the addressing of the ring
// buffer storage readout. It receives the last 
// address that the rb wrote to, and when there is
// a readout request it starts from that location and
// iterates backwards, outputting which address the rb
// should read out next. It also receives how many words
// are to be read out via howmany_i, and when all requested
// words have been read it flags completion via ro_done_n.
module addr_cntrl #(parameter SIZE=12) (
	input wire [SIZE-1:0] offset_in,
	input wire [SIZE-1:0] howmany_in,
	input wire [SIZE-1:0] ain,
	input wire rd_request,
	input wire sysclk,
	input wire rst,
	input wire SPI_done,
	output wire [SIZE-1:0] address,
	output wire ro_done_n
);
	
reg [SIZE-1:0] reg_addr;
reg [SIZE-1:0] offset;
reg [12-1:0] howmany;
	
// where to start readout. only updated if 
// not during a ro cycle.
always @(posedge sysclk) begin
	if ( rst ) begin 
		howmany <= {SIZE{1'b0}};
		offset <= {SIZE{1'b0}};
	end
	else if ( ! rd_request) begin
		reg_addr <= ain - offset - 1'b1; 
		howmany <= howmany_in; // - 1'b1; // without the -1 leads to an off-by-one error
		offset <= offset_in;
	end
	else if ( rd_request) begin 	// readout block
		// Wait for SPI to finish current word before moving to next
		if (SPI_done) begin
			reg_addr <= reg_addr - 1'b1;
			howmany <= howmany - 1'b1;
		end
	end

end

assign address = rd_request ? reg_addr : {SIZE{1'b0}};
assign ro_done_n = |howmany; // enable readout as long as howmany is non-zero


endmodule