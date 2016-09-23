// NB SS is active low!!!!!

// https://embeddedmicro.com/tutorials/mojo/serial-peripheral-interface-spi
// Quote: "This module assumes CPOL = 0 and CPHA = 0.  It waits for SS
// to go low. Once SS is low, it starts shifting data into the
// data_d/_q register. Once eight bits have been shifted in it signals
// that it has new data on dout. On the falling edges of the clock, it
// shifts out the data that was provided by din at the beginning of
// the transmission."

// adapted to have variable width wordsize set by a parameter
module spi_slave
#(parameter WORDSIZE=8)
(
    input clk,
    input rst,
    input ss, // ACTIVE LOW
    input mosi,
    output miso,
    input sck,
    output done,
    input [WORDSIZE-1:0] din,
    output [WORDSIZE-1:0] dout
  );
   
  localparam log2_WORDSIZE = $clog2(WORDSIZE);
  reg mosi_d, mosi_q;
  reg ss_d, ss_q;
  reg sck_d, sck_q;
  reg sck_old_d, sck_old_q;
  reg [WORDSIZE-1:0] data_d, data_q;
  reg done_d, done_q;
  reg [2:0] bit_ct_d, bit_ct_q;
  reg [WORDSIZE-1:0] dout_d, dout_q;
  reg miso_d, miso_q;
   
  assign miso = miso_q;
  assign done = done_q;
  assign dout = dout_q;
   
  always @(*) begin
    ss_d = ss;
    mosi_d = mosi;
    miso_d = miso_q;
    sck_d = sck;
    sck_old_d = sck_q;
    data_d = data_q;
    done_d = 1'b0;
    bit_ct_d = bit_ct_q;
    dout_d = dout_q;
     
    if (ss_q) begin                           // if slave select is high (deselcted)
      bit_ct_d = {log2_WORDSIZE{1'b0}};       // reset bit counter
      data_d = din;                           // read in data
      miso_d = data_q[WORDSIZE-1];                     // output MSB
    end else begin                            // else slave select is low (selected)
      if (!sck_old_q && sck_q) begin          // rising edge
        data_d = {data_q[WORDSIZE-2:0], mosi_q};       // read data in and shift
        bit_ct_d = bit_ct_q + 1'b1;           // increment the bit counter
        if (bit_ct_q == {log2_WORDSIZE{1'b1}}) begin         // if we are on the last bit
          dout_d = {data_q[WORDSIZE-2:0], mosi_q};     // output the data
          done_d = 1'b1;                      // set transfer done flag
          data_d = din;                       // read in new data
        end
      end else if (sck_old_q && !sck_q) begin // falling edge
        miso_d = data_q[WORDSIZE-1];                   // output MSB
      end
    end
  end
   
  always @(posedge clk) begin
    if (rst) begin
      done_q <= 1'b0;
      bit_ct_q <= {log2_WORDSIZE{1'b0}};
      dout_q <= {WORDSIZE{1'b0}};
      miso_q <= 1'b1;
    end else begin
      done_q <= done_d;
      bit_ct_q <= bit_ct_d;
      dout_q <= dout_d;
      miso_q <= miso_d;
    end
     
    sck_q <= sck_d;
    mosi_q <= mosi_d;
    ss_q <= ss_d;
    data_q <= data_d;
    sck_old_q <= sck_old_d;
     
  end
   
endmodule
