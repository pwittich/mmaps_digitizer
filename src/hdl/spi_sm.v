`include "spi_defines.v"


// Created by fizzim.pl version 5.10 on 2016:10:06 at 17:47:23 (www.fizzim.com)

module SPI_SM (
  output reg latch_cmd,
  output reg rd_select,
  output reg wr_select,
  input wire clk,
  input wire [3:0] cmd,
  input wire done,
  input wire rst
);

  // state bits
  parameter 
  IDLE       = 3'b000, 
  LATCH      = 3'b001, 
  READ       = 3'b010, 
  WRITE      = 3'b011, 
  WRITE_WAIT = 3'b100; 

  reg [2:0] state;
  reg [2:0] nextstate;
  // comb always block
  always @* begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE      : begin
        if (done) begin
          nextstate = LATCH;
        end
      end
      LATCH     : begin
        if (cmd==`RD) begin
          nextstate = READ;
        end
        else if (cmd==`WR) begin
          nextstate = WRITE_WAIT;
        end
        else begin
          nextstate = IDLE; // return to idle on invalid cmd
        end
      end
      READ      : begin
        if (done) begin
          nextstate = IDLE;
        end
      end
      WRITE     : begin
        begin
          nextstate = IDLE;
        end
      end
      WRITE_WAIT: begin
        if (done) begin
          nextstate = WRITE;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits

  // sequential always block
  always @(posedge clk) begin
    if (rst)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // datapath sequential always block
  always @(posedge clk) begin
    if (rst) begin
      latch_cmd <= 0;
      rd_select <= 0;
      wr_select <= 0;
    end
    else begin
      latch_cmd <= 0; // default
      rd_select <= 0; // default
      wr_select <= 0; // default
      case (nextstate)
        LATCH     : begin
          latch_cmd <= 1;
        end
        READ      : begin
          rd_select <= 1;
        end
        WRITE     : begin
          wr_select <= 1;
        end
      endcase
    end
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [79:0] statename;
  always @* begin
    case (state)
      IDLE      :
        statename = "IDLE";
      LATCH     :
        statename = "LATCH";
      READ      :
        statename = "READ";
      WRITE     :
        statename = "WRITE";
      WRITE_WAIT:
        statename = "WRITE_WAIT";
      default   :
        statename = "XXXXXXXXXX";
    endcase
  end
  `endif

endmodule

