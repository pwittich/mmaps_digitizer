// address control for the ring buffer
`timescale 1ns / 1ps
`default_nettype none

module addr_cntrl #(parameter SIZE=12) (
	input wire [SIZE-1:0] offset_i,
	input wire [SIZE-1:0] howmany_i,
	input wire [SIZE-1:0] ain,
	input wire rd_request,
	input wire sysclk,
	input wire rst,
	input wire SPI_done,
	output wire [SIZE-1:0] address,
	output wire ro_done_n);
	
//	reg [SIZE-1:0] reg_addr;
//	reg [SIZE-1:0] offset;
//	reg [16-1:0] howmany;
	
	reg rd_request_q;
	reg [SIZE-1:0] howmany_left_d, howmany_left_q;
	reg [SIZE-1:0] current_reg_address_d, current_reg_address_q;
	reg old_rd_request_d, old_rd_request_q;
	
	always @(*) begin
		if (rd_request_q && !old_rd_request_q) begin // begin of rd_request
			howmany_left_d = howmany_i - 12'h0001;
			current_reg_address_d = ain - offset_i - 12'h001;
		end else if (rd_request_q && old_rd_request_q) begin // continuing rd_request
			if (SPI_done) begin // Only iterate to next register if SPI finished with last word
				howmany_left_d = howmany_left_q - 12'h0001;
				current_reg_address_d = current_reg_address_q + 12'h001;
			end else begin
				howmany_left_d = howmany_left_q;
				current_reg_address_d = current_reg_address_q;
			end
		end else begin
			howmany_left_d = 12'hfff;
			current_reg_address_d = 12'hfff;
		end
		old_rd_request_d = rd_request_q;
	end
	
	always @(posedge sysclk) begin
		if (rst) begin
			rd_request_q <= 1'b0;
			old_rd_request_q <= 1'b0;
			current_reg_address_q <= {SIZE{1'b0}};
			howmany_left_q <= {12{1'b1}};
		end else begin
			rd_request_q <= rd_request;
			old_rd_request_q <= old_rd_request_d;
			current_reg_address_q <= current_reg_address_d;
			howmany_left_q <= howmany_left_d;
		end
	end
		
	
//	// where to start readout. only updated if 
//	// not during a ro cycle.
//	always @(posedge sysclk) begin
//		if ( rst ) begin 
//			howmany <= {SIZE{1'b0}};
//			offset <= {SIZE{1'b0}};
//		end
//		else if ( ! rd_request) begin
//			reg_addr <= ain - offset - 1'b1; 
//			howmany <= howmany_i -1'b1; // without the -1 leads to an off-by-one error
//			offset <= offset_i;
//		end
//		else if ( rd_request) begin 	// readout block
//			reg_addr <= reg_addr - 1'b1;
//			howmany <= howmany - 1'b1;
//		end
//
//	end
//	assign address = rd_request ? reg_addr : {SIZE{1'b0}};
//	assign ro_done_n = |howmany; // enable readout as long as howmany is non-zero

	assign address = rd_request ? current_reg_address_q : {SIZE{1'b0}};
	assign ro_done_n = |howmany_left_q;
	
	endmodule
	