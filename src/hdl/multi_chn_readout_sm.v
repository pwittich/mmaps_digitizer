// Created by fizzim.pl version 5.20 on 2016:10:18 at 13:05:16 (www.fizzim.com)

module multi_chn_readout (
  output reg ZYNQ_RD_EN,
  input wire EOS,
  input wire SPI_complete,
  input wire clk,
  input wire reset
);

  // state bits
  parameter 
  IDLE    = 1'b0, 
  READOUT = 1'b1; 

  reg state;
  reg nextstate;

  // comb always block
  always @* begin
    // Warning I2: Neither implied_loopback nor default_state_is_x attribute is set on state machine - defaulting to implied_loopback to avoid latches being inferred 
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE   : begin
        if (EOS == 1) begin
          nextstate = READOUT;
        end
      end
      READOUT: begin
        if (SPI_complete == 1) begin
          nextstate = IDLE;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits

  // sequential always block
  always @(posedge clk) begin
    if (reset)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // datapath sequential always block
  always @(posedge clk) begin
    if (reset) begin
      // Warning R18: No reset value set for datapath output ZYNQ_RD_EN.   Assigning a reset value of 0 based on value in reset state IDLE 
      ZYNQ_RD_EN <= 0;
    end
    else begin
      ZYNQ_RD_EN <= 0; // default
      case (nextstate)
        READOUT: begin
          ZYNQ_RD_EN <= 1;
        end
      endcase
    end
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [55:0] statename;
  always @* begin
    case (state)
      IDLE   :
        statename = "IDLE";
      READOUT:
        statename = "READOUT";
      default:
        statename = "XXXXXXX";
    endcase
  end
  `endif

endmodule
