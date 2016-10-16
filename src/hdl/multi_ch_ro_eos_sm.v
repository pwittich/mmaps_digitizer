// Created by fizzim.pl version 5.20 on 2016:10:16 at 13:42:18 (www.fizzim.com)

module multi_ch_ro (
  output wire FIFO_RD_EN,
  output wire FIFO_WR_EN,
  input wire EOS,
  input wire ZYNQ_RD_RQ,
  input wire clk,
  input wire rst_n,
  input wire trigger
);

  // state bits
  parameter 
  IDLE    = 2'b00, // FIFO_WR_EN=0 FIFO_RD_EN=0 
  FIFO_RD = 2'b10, // FIFO_WR_EN=1 FIFO_RD_EN=0 
  ZYNQ_RD = 2'b01; // FIFO_WR_EN=0 FIFO_RD_EN=1 

  reg [1:0] state;
  reg [1:0] nextstate;

  // comb always block
  always @* begin
    // Warning I2: Neither implied_loopback nor default_state_is_x attribute is set on state machine - defaulting to implied_loopback to avoid latches being inferred 
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE   : begin
        if (EOS == 1) begin
          nextstate = FIFO_RD;
        end
      end
      FIFO_RD: begin
        if (ZYNQ_RD_RQ == 1) begin
          nextstate = ZYNQ_RD;
        end
        else if (trigger == 1) begin
          nextstate = FIFO_RD;
        end
        else if (trigger == 0) begin
          nextstate = IDLE;
        end
      end
      ZYNQ_RD: begin
        if (ZYNQ_RD_RQ == 1) begin
          nextstate = ZYNQ_RD;
        end
        else if (trigger == 1) begin
          nextstate = FIFO_RD;
        end
        else if (trigger == 0) begin
          nextstate = IDLE;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  assign FIFO_RD_EN = state[0];
  assign FIFO_WR_EN = state[1];

  // sequential always block
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [55:0] statename;
  always @* begin
    case (state)
      IDLE   :
        statename = "IDLE";
      FIFO_RD:
        statename = "FIFO_RD";
      ZYNQ_RD:
        statename = "ZYNQ_RD";
      default:
        statename = "XXXXXXX";
    endcase
  end
  `endif

endmodule
