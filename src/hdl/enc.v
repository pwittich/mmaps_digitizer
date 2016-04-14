`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2016 04:23:45 PM
// Design Name: 
// Module Name: enc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module enc #(parameter SIZE = 3)
  (
    input wire [2**SIZE-1:0] in,
    output reg [SIZE-1:0] out
  );
  integer i;
  always @* begin
    out = 0; // default value if 'in' is all 0's
    for (i=2**SIZE-1; i>=0; i=i-1)
        if (in[i]) out = i;
  end
endmodule