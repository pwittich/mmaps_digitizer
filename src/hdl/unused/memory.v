`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2016 04:29:34 PM
// Design Name: 
// Module Name: memory
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


module memory
  #(parameter RAM_WIDTH=16, RAM_DEPTH=1024)
   (
    input wire CLK,
    input wire RST,
    input wire WEA, // WRITE ENABLE A
    input wire WEB, // WRITE ENABLE B
    input wire ENA, // OUTPUT ENABLE A
    input wire ENB, // OUTPUT ENABLE B
    input wire [RAM_WIDTH-1:0] DINA,
    input wire [RAM_WIDTH-1:0] DINB,
    input wire [clogb2(RAM_DEPTH)-1:0] ADDRA,
    input wire [clogb2(RAM_DEPTH)-1:0] ADDRB,
    output wire [RAM_WIDTH-1:0] DOUTA,
    output wire [RAM_WIDTH-1:0] DOUTB
    );
   
   
   //  Xilinx True Dual Port RAM Write First Single Clock
   //  This code implements a paramitizable true dual port memory (both ports can read and write).
   //  This implements write-first mode where the data being written to the RAM also resides on
   //  the output port.  If the output data is not needed during writes or the last read value is
   //  desired to be retained, it is suggested to use no change as it is more power efficient.
   //  If a reset or enable is not necessary, it may be tied off or removed from the code.
   
   parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE"; // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
   parameter INIT_FILE = "";                       // Specify name/location of RAM initialization file if using one (leave blank if not)
   
  
   reg [RAM_WIDTH-1:0]   RAM [RAM_DEPTH-1:0];
   reg [RAM_WIDTH-1:0]   RAM_A = {RAM_WIDTH{1'b0}};
   reg [RAM_WIDTH-1:0]   RAM_B = {RAM_WIDTH{1'b0}};
   
   // The following code either initializes the memory values to a specified file or to all zeros to match hardware
   generate
      if (INIT_FILE != "") begin: use_init_file
         initial
           $readmemh(INIT_FILE, RAM, 0, RAM_DEPTH-1);
      end else begin: init_bram_to_zero
         integer ram_index;
         initial
           for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
             RAM[ram_index] = {RAM_WIDTH{1'b0}};
      end
   endgenerate
   
   always @(posedge CLK)
     if (WEA) begin
        RAM[ADDRA] <= DINA; 
        RAM_A <= DINA;
     end else
       RAM_A <= RAM[ADDRA];        
   
   always @(posedge CLK)
     if (WEB) begin
        RAM[ADDRB] <= DINB; 
        RAM_B <= DINB;
     end else
       RAM_B <= RAM[ADDRB];        
   
   //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
   generate
      if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register
  
         // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
         assign DOUTA = RAM_A;
         assign DOUTB = RAM_B;
  
      end else begin: output_register
  
         // The following is a 2 clock cycle read latency with improve clock-to-out timing
  
         reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};
         reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};
  
         always @(posedge CLK)
           if (RST)
             douta_reg <= {RAM_WIDTH{1'b0}};
           else if (ENA)
             douta_reg <= RAM_A;
  
         always @(posedge CLK)
           if (RST)
             doutb_reg <= {RAM_WIDTH{1'b0}};
           else if (ENB)
             doutb_reg <= RAM_B;
  
         assign DOUTA = douta_reg;
         assign DOUTB = doutb_reg;
  
      end
   endgenerate
   
   //  The following function calculates the address width based on specified RAM depth
   function integer clogb2;
      input integer       depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
   endfunction
   
   
endmodule
