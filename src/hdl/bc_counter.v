`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2016 02:16:31 PM
// Design Name: 
// Module Name: bc_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Bunch counter 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bc_counter(
    input wire CLK,
    input wire RST,
    output wire [11:0] BC
    );
    
    reg [11:0] BC_reg;
    
    always @(posedge CLK) begin
        if ( RST ) begin
            BC_reg <= 12'h000;
        end else begin
            BC_reg <= BC_reg + 12'h001;
        end 
    end
    assign BC = BC_reg;
endmodule
