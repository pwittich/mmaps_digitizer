
// Created by fizzim.pl version 5.10 on 2016:09:26 at 13:04:46 (www.fizzim.com)

module SPI_SM ( // State machine for SPI slave on CycloneIII
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
  IDLE      = 0, 
  FIFO_SEND = 1, 
  RD        = 2, 
  WR        = 3; 

  reg [3:0] state;
  reg [3:0] nextstate;
  reg [7:0] FIFO_CNT;
  reg [7:0] next_FIFO_CNT;

  // comb always block
  always @* begin
    nextstate = 4'b0000;
    next_FIFO_CNT[7:0] = FIFO_CNT[7:0];
    case (1'b1) // synopsys parallel_case full_case
      state[IDLE]     : begin
        if (CMD == RD) begin
          nextstate[RD] = 1'b1;
        end
        else if (CMD == WR) begin
          nextstate[WR] = 1'b1;
        end
        else if (CMD == FIFO) begin
          nextstate[FIFO_SEND] = 1'b1;
        end
        else begin
          nextstate[IDLE] = 1'b1;
        end
      end
      state[FIFO_SEND]: begin
        if (DONE==1 && FIFO_CNT==0) begin
          nextstate[IDLE] = 1'b1;
        end
        else if (DONE==1) begin
          nextstate[FIFO_SEND] = 1'b1;
          next_FIFO_CNT[7:0] = FIFO_CNT[7:0] -1;
        end
        else begin
          nextstate[FIFO_SEND] = 1'b1;
        end
      end
      state[RD]       : begin
        if (DONE==1) begin
          nextstate[IDLE] = 1'b1;
        end
        else begin
          nextstate[RD] = 1'b1;
        end
      end
      state[WR]       : begin
        if (DONE==1) begin
          nextstate[IDLE] = 1'b1;
        end
        else begin
          nextstate[WR] = 1'b1;
        end
      end
    endcase
  end

  // sequential always block
  always @(posedge clk) begin
    if (rst) begin
      state <= 4'b0001 << IDLE;
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
      rd_select <= 0;
      wr_select <= 0;
    end
    else begin
      rd_select <= 0; // default
      wr_select <= 0; // default
      case (1'b1) // synopsys parallel_case full_case
        nextstate[IDLE]     : begin
          ; // case must be complete for onehot
        end
        nextstate[FIFO_SEND]: begin
          ; // case must be complete for onehot
        end
        nextstate[RD]       : begin
          rd_select <= 1;
        end
        nextstate[WR]       : begin
          wr_select <= 1;
        end
      endcase
    end
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [71:0] statename;
  always @* begin
    case (1'b1)
      state[IDLE]     :
        statename = "IDLE";
      state[FIFO_SEND]:
        statename = "FIFO_SEND";
      state[RD]       :
        statename = "RD";
      state[WR]       :
        statename = "WR";
      default  :
        statename = "XXXXXXXXX";
    endcase
  end
  `endif

endmodule

