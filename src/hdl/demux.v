`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
  // 
  // Create Date: 03/13/2016 05:19:23 PM
  // Design Name: 
  // Module Name: demux
  // Project Name: 
  // Target Devices: 
  // Tool Versions: 
  // Description: Demultiplexer
  // 
  // Dependencies: 
  // 
  // Revision:
  // Revision 0.01 - File Created
  // Additional Comments:
  // 
////////////////////////////////////////////////////////////////////////////////

  module demux #(parameter N=4) ( input wire in,
				  input wire [clog2(N)-1:0] sel, 
				  output wire [N-1:0] out );

   genvar 					      i;
   generate 
      for (i = 0; i < N; i = i + 1)  begin : dm_out 
	 assign out[i] = sel==i ? in : 1'b0;
      end
   endgenerate

   function integer clog2 (input integer n); 
      integer j; 
      begin 
	 n = n - 1;
	 for (j = 0; n > 0; j = j + 1)        
           n = n >> 1;
	 clog2 = j;
      end
   endfunction

endmodule
