// Created by fizzim.pl version 5.20 on 2016:09:28 at 13:22:06 (www.fizzim.com)

module spi_cmd_sm (
  output wire SPI_CMD_reading,
  input wire SPI_done,
  input wire clk,
  input wire reset
);

  // state bits
  parameter 
  IDLE    = 1'b0, // SPI_CMD_reading=0 
  READING = 1'b1; // SPI_CMD_reading=1 

  reg state;
  reg nextstate;

  // comb always block
  always @* begin
    // Warning I2: Neither implied_loopback nor default_state_is_x attribute is set on state machine - defaulting to implied_loopback to avoid latches being inferred 
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE   : begin
        if (SPI_done == 1) begin
          nextstate = READING;
        end
      end
      READING: begin
        if (SPI_done == 1) begin
          nextstate = IDLE;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  assign SPI_CMD_reading = state;

  // sequential always block
  always @(posedge clk or posedge reset) begin
    if (reset)
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
      READING:
        statename = "READING";
      default:
        statename = "XXXXXXX";
    endcase
  end
  `endif

endmodule
