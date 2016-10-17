// test bench for spi_master, spi_slave, with state machine

// single master, two slaves

// format of command
// bottom byte
// bottom nybble: CMD
// top nybble: command-specific

`include "spi_defines.v"

`timescale 1ns/1ns
`default_nettype none
  module spi_demo_sm(
                     input wire rst,
                     input wire sysclk, // input clock
                     input wire start,
                     input wire [7:0] master_data_i ,
                     output wire [7:0] master_data_o ,
                     output wire busy,
                     output wire new_data
                     );
   localparam NSLAVE = 1;



   wire                          MISO; // master in, slave out
   wire                          MOSI; // mster out, slave in
   wire                          SCLK; // output from master
   wire                          sel ; // active high
   wire                          SPI_done;
   
   
   wire [7:0]                    s_m;
   reg [7:0] 			 reg_master_data_o;
   assign master_data_o = reg_master_data_o;

   


   //assign sel = busy;
   assign sel = 1;

   // SPI master
   spi my_spi_master (
                      .clk(sysclk),
                      .sck(SCLK),
                      .rst(rst),
                      .miso(MISO),
                      .mosi(MOSI),
                      .data_in(master_data_i),
                      .data_out(s_m),
                      .start(start),
                      .busy(busy),
                      .new_data(new_data)
                      );
   // latch the data the master has received
   always_ff @( negedge sysclk )
     if ( new_data )
       reg_master_data_o <= s_m;
   

   wire [7:0] 			 s ;
   reg [7:0] 			 registers [15:0];
   
   reg [7:0] 			 SPI_tx_reg; // to be transmitted
   reg [7:0] 			 SPI_rx_reg; // most recent received
   reg [3:0] 			 addr;
   reg [3:0] 			 cmd;

   // Tilde infront of the SCLK takes care of the fact
   // that the slave and master have different CPOL/CPHA settings.
   spi_slave slave
     (
      .clk(sysclk),
      .rst(rst),
      .ss(~sel), // active low
      .mosi(MOSI),
      .miso(MISO),
      .sck(~SCLK),
      .din(SPI_tx_reg),
      .dout(s),
      .done(SPI_done)
      );

   // store slave's data
   always @(posedge sysclk) begin
      if ( SPI_done ) begin
         SPI_rx_reg <= s;
      end
   end
   
   
   wire rd_select, wr_select, fifo_select, fifo_rd_one;
   always @(posedge sysclk ) begin
      //if ( SPI_done && rd_select) begin
      if ( rd_select) begin
         SPI_tx_reg <= registers[addr];
      end 
      else if ( SPI_done && wr_select ) begin
         registers[addr] <= SPI_rx_reg;
      end
   end

   reg [7:0] FIFO_PK_SZ;
   wire       latch_cmd;
   
   always @(posedge sysclk ) begin
      if ( latch_cmd ) begin
         addr <= SPI_rx_reg[7:4]; 
	 cmd <= SPI_rx_reg[3:0];
      end
   end
   
   SPI_SM sm( // State machine for SPI slave on CycloneIII
              .rd_select(rd_select),
              .wr_select(wr_select),
	      //.led(led_hack),
              .fifo_select(fifo_select),
              .latch_cmd(latch_cmd),
	      .fifo_rd_enable(fifo_rd_one),
              .CMD(SPI_rx_reg[3:0]), // before they are latched
              .DONE(SPI_done),
              .FIFO_PK_SZ(FIFO_PK_SZ),   // number of words to send
              .clk(sysclk),
              .rst(rst) 
              );
   
   
   // synthesis translate_off
   reg        reg_start;
   reg 	      reg_RST, reg_CLK;
   reg [7:0]  reg_master_data_i;
   assign start = reg_start;
   assign sysclk = reg_CLK;
   assign rst = reg_RST;
   assign master_data_i = reg_master_data_i;
   // test bench - initialzation
   initial #0  begin
      SPI_tx_reg = 8'h00;
      SPI_rx_reg = 8'h00;
      reg_RST = 0;
      reg_CLK= 0;
      reg_start = 0;
      reg_master_data_i = 8'h00;
      FIFO_PK_SZ = 8'd10;

      //registers = {16{16{1b'0}}};
      
      // reset
      // toggle reset at t=10
      #10;
      reg_RST = 1;
      #44;
      reg_RST = 0;
      #44;
      // send a write command
      // concat goes from MSB to LSB
      // command is bottom 4 bits
      reg_master_data_i = { 4'hf, `WR  };
   #1;
      $display("%t: sending 0x%h", $time, reg_master_data_i);
   #4;
      reg_start = 1;
   @(posedge busy) ;
      reg_master_data_i = 8'ha5;
   
      @(posedge new_data ); // wait for the done
   //reg_start = 0;
      @(posedge sysclk);
     // reg_start = 1;
      // send the data to write
      @(posedge new_data ); // wait for the done
      reg_start = 0;
      $display("%t: register write: %h", $time, registers[addr]);
   #25;
     // now do a read
   $display("%t: starting read", $time);
   reg_master_data_i = { 4'hf, `RD};
   reg_start = 1;
   @(posedge new_data);
   reg_start = 0;
   reg_master_data_i =  8'hff; // nonsense data
   #250;
   @(posedge sysclk);
   // now get the data
   $display("%t: second command", $time);
   reg_start = 1;
   @(posedge new_data);
   $display("%t: register read: %h", $time, master_data_o);
   reg_start = 0;
   
   end
   // clock
   always 
     #10 reg_CLK = ~reg_CLK;
   // synthesis translate_on 



endmodule
