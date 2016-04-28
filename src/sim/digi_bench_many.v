`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module digi_bench_many(

    );

// constants                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg [16*8-1:0] adcdata_p;
reg CK50;
reg [7:0] DAVAIL;
reg [7:0] howmany;
reg [7:0] offset;
reg RST;
reg [7:0] TRIGGER;
reg rd_request;
// wires                                               
wire [15:0]  dout;

// assign statements (if any)                          
digi_many #(.CHAN(8)) i1 (
// port map - connection between master ports and signals/registers   
	.adcdata_p(adcdata_p),
	.CK50(CK50),
	.DAVAIL(DAVAIL),
	.DOUT(dout),
	.howmany(howmany),
	.offset(offset),
	.RST(RST),
	.TRIGGER(TRIGGER),
	.ZYNQ_RD_REQUEST(rd_request)
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
   RST=0;
   #100;
   RST = 1;
   #100;
   RST = 0;
   #40;
   DAVAIL = 1;
   #320 TRIGGER = 1;
   #10 rd_request = 1;
   #100 TRIGGER = 0;
   #2000 $stop;
   
// --> end                                             
$display("Running testbench");                       
end // initial begin

// clock
   always
     #10 CK50 = ~CK50;
   // generate random input data
   always @(posedge CK50) begin
      adcdata_p[31:0] = $random;
      adcdata_p[63:32] = $random;
      adcdata_p[95:64] = $random;
      adcdata_p[127:96] = $random;
      //std::randomize(adcdata_p ); // needs SystemVerilog which doesn't seem to work
      
   end

endmodule

