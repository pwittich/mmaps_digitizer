`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2016 05:06:00 PM
// Design Name: 
// Module Name: digi_bench
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


module digi_bench(

    );

// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "03/09/2016 14:25:05"
                                                                                
// Verilog Test Bench template for design : digi
// 
// Simulation tool : ModelSim-Altera (Verilog)
// 

// constants                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg [15:0] adcdata_p;
reg CK50;
reg DAVAIL;
reg [7:0] howmany;
reg [7:0] offset;
reg RST;
reg TRIGGER;
reg rd_request;
// wires                                               
wire [15:0]  dout;

// assign statements (if any)                          
digi i1 (
// port map - connection between master ports and signals/registers   
	.adcdata_p(adcdata_p),
	.CK50(CK50),
	.DAVAIL(DAVAIL),
	.dout(dout),
	.howmany(howmany),
	.offset(offset),
	.RST(RST),
	.TRIGGER(TRIGGER),
	.rd_request(rd_request)
);
initial                                                
begin                                                  
// code that executes only once                        
// insert code here --> begin                          
   CK50 = 0;
   DAVAIL = 0;
   TRIGGER = 0;
   howmany = 8'd10;
   offset = 8'd10;
   rd_request = 0;
   #10;
   RST = 1;
   #20;
   RST = 0;
   #10;
   DAVAIL = 1;
   #320 TRIGGER = 1;
   #10 rd_request = 1;
   #100 TRIGGER = 0;
                                                       
// --> end                                             
$display("Running testbench");                       
end // initial begin

// clock
   always
     #10 CK50 = ~CK50;
   // generate random input data
   always @(posedge CK50) begin
      adcdata_p = $random;
   end

endmodule

