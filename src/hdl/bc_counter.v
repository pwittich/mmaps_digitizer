`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: pw
// 
// Create Date: 03/15/2016 02:16:31 PM
// Design Name: 
// Module Name: bc_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Bunch counter . Simple counter with a synchronous reset.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////


module bc_counter
	#(parameter BITS=12)
	(
    input wire CLK,
    input wire RST,
    output wire [BITS-1:0] BC
    );
    
    reg [BITS-1:0] BC_reg;
    
    always @(posedge CLK) begin
        if ( RST ) begin
            BC_reg <= 0;
        end else begin
            BC_reg <= BC_reg + 1;
        end 
    end
    assign BC = BC_reg;
endmodule
