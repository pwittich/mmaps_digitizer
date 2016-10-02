`include "spi_defines.v"


// Created by fizzim.pl version 5.10 on 2016:10:01 at 19:24:42 (www.fizzim.com)

module SPI_SM ( // State machine for SPI slave on CycloneIII
  output wire fifo_select,
  output wire latch_cmd,
  output wire rd_select,
  output wire wr_select,
  input wire [3:0] CMD,
  input wire DONE,
  input wire [7:0] FIFO_PK_SZ,   // number of words to send
  input wire clk,
  input wire rst 
);

  // state bits
  parameter 
  IDLE      = 4'b0000, // wr_select=0 rd_select=0 latch_cmd=0 fifo_select=0 
  FIFO_SEND = 4'b0001, // wr_select=0 rd_select=0 latch_cmd=0 fifo_select=1 
  LATCH_CMD = 4'b0010, // wr_select=0 rd_select=0 latch_cmd=1 fifo_select=0 
  RD        = 4'b0100, // wr_select=0 rd_select=1 latch_cmd=0 fifo_select=0 
  WR        = 4'b1000; // wr_select=1 rd_select=0 latch_cmd=0 fifo_select=0 

  reg [3:0] state;
  reg [3:0] nextstate;
  reg [7:0] FIFO_CNT;
  reg [7:0] next_FIFO_CNT;

  // comb always block
  always @* begin
    // Warning I2: Neither implied_loopback nor default_state_is_x attribute is set on state machine - defaulting to implied_loopback to avoid latches being inferred 
    nextstate = state; // default to hold value because implied_loopback is set
    next_FIFO_CNT[7:0] = FIFO_CNT[7:0];
    case (state)
      IDLE     : begin
        if (DONE==1&&(CMD==`RD||CMD==`WR||CMD==`FIFO)) begin
          nextstate = LATCH_CMD;
        end
        else begin
          nextstate = IDLE;
        end
      end
      FIFO_SEND: begin
        if (DONE==1 && FIFO_CNT==0) begin
          nextstate = IDLE;
        end
        else if (DONE==1) begin
          nextstate = FIFO_SEND;
          next_FIFO_CNT[7:0] = FIFO_CNT[7:0] -1;
        end
        else begin
          nextstate = FIFO_SEND;
        end
      end
      LATCH_CMD: begin
        if (CMD==`RD) begin
          nextstate = RD;
        end
        else if (CMD==`WR) begin
          nextstate = WR;
        end
        else if (CMD==`FIFO) begin
          nextstate = FIFO_SEND;
        end
        else begin
          nextstate = IDLE;
        end
      end
      RD       : begin
        if (DONE==1) begin
          nextstate = IDLE;
        end
        else begin
          nextstate = RD;
        end
      end
      WR       : begin
        if (DONE==1) begin
          nextstate = IDLE;
        end
        else begin
          nextstate = WR;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  assign fifo_select = state[0];
  assign latch_cmd = state[1];
  assign rd_select = state[2];
  assign wr_select = state[3];

  // sequential always block
  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
      FIFO_CNT[7:0] <= 8'h00;
      end
    else begin
      state <= nextstate;
      FIFO_CNT[7:0] <= next_FIFO_CNT[7:0];
      end
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [71:0] statename;
  always @* begin
    case (state)
      IDLE     :
        statename = "IDLE";
      FIFO_SEND:
        statename = "FIFO_SEND";
      LATCH_CMD:
        statename = "LATCH_CMD";
      RD       :
        statename = "RD";
      WR       :
        statename = "WR";
      default  :
        statename = "XXXXXXXXX";
    endcase
  end
  `endif

endmodule

