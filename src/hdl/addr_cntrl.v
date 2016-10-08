// address control for the ring buffer
`timescale 1ns / 1ps
`default_nettype none

module addr_cntrl #(parameter SIZE=8) (
	input wire [SIZE-1:0] offset_i,
	input wire [SIZE-1:0] howmany_i,
	input wire [SIZE-1:0] ain,
	input wire rd_request,
	input wire clk,
	input wire rst,
	output wire [SIZE-1:0] address,
	output wire ro_done_n);
	
	reg [SIZE-1:0] reg_addr;
	reg [SIZE-1:0] offset;
	reg [SIZE-1:0] howmany;
	
	// where to start readout. only updated if 
	// not during a ro cycle.
	always @(posedge clk) begin
		if ( rst ) begin 
			howmany <= {SIZE{1'b0}};
			offset <= {SIZE{1'b0}};
		end
		else if ( ! rd_request) begin
			reg_addr <= ain - offset - 1'b1; 
			howmany <= howmany_i -1'b1; // without the -1 leads to an off-by-one error
			offset <= offset_i;
		end
		else if ( rd_request) begin 	// readout block
			reg_addr <= reg_addr - 1'b1;
			howmany <= howmany - 1'b1;
		end

	end
	assign address = rd_request?reg_addr:{SIZE{1'b0}};
	assign ro_done_n = |howmany; // enable readout as long as howmany is non-zero
	
	endmodule
	