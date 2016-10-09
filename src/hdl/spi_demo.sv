// test bench for spi_master, spi_slave

// single master, two slaves
`timescale 1ns/1ns
`default_nettype none
  module spi_demo;
   localparam NSLAVE = 1;

   reg CLK; // input clock
   reg RST;
   wire MISO; // master in, slave out
   wire MISO_i[NSLAVE-1:0]; // master in, slave out per slave
   wire MOSI; // mster out, slave in
   
   wire SCLK; // output from master
   wire busy;
   wire new_data;
   reg  sel [NSLAVE-1:0]; // active high
   wire [NSLAVE-1:0] done;
   

   // route the right MISO signal to the master
   mux_l #(.inputs(NSLAVE), .width(1)) miso_to_master(
                                                      .out(MISO),
                                                      .sel(sel),
                                                      .in(MISO_i)
                                                      );
   
   // store data from the master, slaves here.
   // dummy. would be peripherals in the real version.
   reg [7:0]         slave_data_o [NSLAVE-1:0];
   reg [7:0]         slave_data_i [NSLAVE-1:0];
   reg [7:0]         master_data_o ;
   reg [7:0]         master_data_i ;
   
   
   wire [7:0]        s_m;
   logic             start;

   //assign start = sel[0] | sel[1];
   

   // logical OR of the selects
   always_comb
     begin
        start = 1'b0;
        for ( int unsigned j = 0; j < NSLAVE; j++ )
          begin
             start |= sel[j];
          end
     end

   // SPI master
   spi my_spi_master (
                      .clk(CLK),
                      .sck(SCLK),
                      .rst(RST),
                      .miso(MISO),
                      .mosi(MOSI),
                      .data_in(master_data_i),
                      .data_out(s_m),
                      .start(start),
                      .busy(busy),
                      .new_data(new_data)
                      );
   // latch the data the master has received
   always_ff @( negedge CLK )
     if ( new_data )
       master_data_o <= s_m;
   

   wire [7:0] s [NSLAVE-1:0];

   // generate the NSLAVE slaves
   genvar     i;

   generate
      for ( i =0; i < NSLAVE; i = i + 1 )
        begin: slave_gen
           spi_slave slave
             (
              .clk(CLK),
              .rst(RST),
              .ss(~sel[i]), // active low
              .mosi(MOSI),
              .miso(MISO_i[i]),
              .sck(SCLK),
              .din(slave_data_i[i]),
              .dout(s[i]),
              .done(done[i])
              );
           // store slave i's data
           always @(negedge CLK) begin
              if ( done[i] ) 
                slave_data_o[i] <= s[i];
           end
        end // block: slave_gen
   endgenerate
   
   
   // test bench - initialzation
   initial #0  begin
      RST = 0;
      CLK= 0;
      sel = '{0,0};
      slave_data_i[0] = 8'haa;
      slave_data_i[1] = 8'h55;
      master_data_i = 8'ha5;

      // reset
      slave_data_o[0] = 8'h00;
      slave_data_o[1] = 8'h00;
      master_data_o = 8'h00;
      
      
      // toggle reset at t=0
      #10;
      RST = 1;
      #44;
      RST = 0;
      #44;
      sel = '{1,0};
      #900 sel = '{0,0};
      
      
   end
   // clock
   always 
     #10 CLK = ~CLK;



endmodule
