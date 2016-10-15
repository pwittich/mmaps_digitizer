`timescale 1ns / 1ps
`default_nettype none

// Created by fizzim.pl version 5.10 on 2016:03:09 at 14:09:53 (www.fizzim.com)

module SM1 (
  output wire RO_ENABLE,
  output wire WR_ENABLE,
  input wire DAVAIL,
  input wire ROREQUEST,
  input wire TRIGGER,
  input wire clk,
  input wire RODONE_n,
  input wire rst 
);

  // state bits
  parameter 
  IDLE        = 3'b000, // extra=0 WR_ENABLE=0 RO_ENABLE=0 
  ADC_RUNNING = 3'b010, // extra=0 WR_ENABLE=1 RO_ENABLE=0 
  READOUT     = 3'b001, // extra=0 WR_ENABLE=0 RO_ENABLE=1 
  TRIGGERED   = 3'b100; // extra=1 WR_ENABLE=0 RO_ENABLE=0 

  reg [2:0] state;
  reg [2:0] nextstate;

  // comb always block
  always @* begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE       : begin
        if (DAVAIL) begin
          nextstate = ADC_RUNNING;
        end
      end
      ADC_RUNNING: begin
        if (TRIGGER) begin
          nextstate = TRIGGERED;
        end
        else if (!DAVAIL) begin
          nextstate = IDLE;
        end
      end
      READOUT    : begin
			if (ROREQUEST) begin
        //if (RODONE_n) begin
          nextstate = READOUT;
        end
        else if (DAVAIL) begin
          nextstate = ADC_RUNNING;
        end
        else if (!DAVAIL) begin
          nextstate = IDLE;
        end
      end
      TRIGGERED  : begin
        if (ROREQUEST) begin
          nextstate = READOUT;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  assign RO_ENABLE = state[0];
  assign WR_ENABLE = state[1];

  // sequential always block
  always @(posedge clk) begin
    if (rst)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [87:0] statename;
  always @* begin
    case (state)
      IDLE       :
        statename = "IDLE";
      ADC_RUNNING:
        statename = "ADC_RUNNING";
      READOUT    :
        statename = "READOUT";
      TRIGGERED  :
        statename = "TRIGGERED";
      default    :
        statename = "XXXXXXXXXXX";
    endcase
  end
  `endif

endmodule

