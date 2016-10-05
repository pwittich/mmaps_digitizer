`include "spi_defines.v"


// Created by fizzim.pl version 5.10 on 2016:10:04 at 13:39:25 (www.fizzim.com)

module SPI_SM ( // State machine for SPI slave on CycloneIII
  output reg fifo_rd_enable,
  output reg fifo_select,
  output reg latch_cmd,
  output reg rd_select,
  output reg wr_select,
  input wire [3:0] CMD,
  input wire DONE,
  input wire [7:0] FIFO_PK_SZ,   // number of words to send
  input wire clk,
  input wire rst 
);

  // state bits
  parameter 
  IDLE        = 3'b000, 
  FIFO_RD_ONE = 3'b001, 
  FIFO_SEND   = 3'b010, 
  LATCH_CMD   = 3'b011, 
  RD          = 3'b100, 
  WR          = 3'b101; 

  reg [2:0] state;
  reg [2:0] nextstate;
  reg [7:0] FIFO_CNT;
  reg [7:0] next_FIFO_CNT;

  // comb always block
  always @* begin
    // Warning I2: Neither implied_loopback nor default_state_is_x attribute is set on state machine - defaulting to implied_loopback to avoid latches being inferred 
    nextstate = state; // default to hold value because implied_loopback is set
    next_FIFO_CNT[7:0] = FIFO_CNT[7:0];
    case (state)
      IDLE       : begin
        if (DONE==1&&(CMD==`RD||CMD==`WR||CMD==`FIFO)) begin
          nextstate = LATCH_CMD;
        end
        else begin
          nextstate = IDLE;
        end
      end
      FIFO_RD_ONE: begin
        begin
          nextstate = FIFO_SEND;
        end
      end
      FIFO_SEND  : begin
        if (DONE==1 && FIFO_CNT==0) begin
          nextstate = IDLE;
        end
        else if (DONE==1) begin
          nextstate = FIFO_SEND;
          next_FIFO_CNT[7:0] = FIFO_CNT[7:0] -1;
        end
        else begin
          nextstate = FIFO_RD_ONE;
        end
      end
      LATCH_CMD  : begin
        if (CMD==`RD) begin
          nextstate = RD;
        end
        else if (CMD==`WR) begin
          nextstate = WR;
        end
        else if (CMD==`FIFO) begin
          nextstate = FIFO_SEND;
          next_FIFO_CNT[7:0] = FIFO_PK_SZ[7:0];
        end
        else begin
          nextstate = IDLE;
        end
      end
      RD         : begin
        if (DONE==1) begin
          nextstate = IDLE;
        end
        else begin
          nextstate = RD;
        end
      end
      WR         : begin
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

  // datapath sequential always block
  always @(posedge clk) begin
    if (rst) begin
      fifo_rd_enable <= 0;
      fifo_select <= 0;
      latch_cmd <= 0;
      rd_select <= 0;
      wr_select <= 0;
    end
    else begin
      fifo_rd_enable <= 0; // default
      fifo_select <= 0; // default
      latch_cmd <= 0; // default
      rd_select <= 0; // default
      wr_select <= 0; // default
      case (nextstate)
        FIFO_RD_ONE: begin
          fifo_rd_enable <= 1;
        end
        FIFO_SEND  : begin
          fifo_select <= 1;
        end
        LATCH_CMD  : begin
          latch_cmd <= 1;
        end
        RD         : begin
          rd_select <= 1;
        end
        WR         : begin
          wr_select <= 1;
        end
      endcase
    end
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [87:0] statename;
  always @* begin
    case (state)
      IDLE       :
        statename = "IDLE";
      FIFO_RD_ONE:
        statename = "FIFO_RD_ONE";
      FIFO_SEND  :
        statename = "FIFO_SEND";
      LATCH_CMD  :
        statename = "LATCH_CMD";
      RD         :
        statename = "RD";
      WR         :
        statename = "WR";
      default    :
        statename = "XXXXXXXXXXX";
    endcase
  end
  `endif

endmodule

