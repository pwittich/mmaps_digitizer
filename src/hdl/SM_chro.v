`timescale 1ns / 1ps
`default_nettype none

// Created by fizzim.pl version 5.10 on 2016:03:11 at 11:12:37 (www.fizzim.com)

module multi_ro (
  output wire CHSEL,
  output wire WR_EN,
  input wire CLK,
  input wire DAVAIL,
  input wire RST 
);

  // state bits
  parameter 
  IDLE      = 3'b000, // extra=0 WR_EN=0 CHSEL=0 
  CH_SELECT = 3'b011, // extra=0 WR_EN=1 CHSEL=1 
  READOUT   = 3'b111; // extra=1 WR_EN=1 CHSEL=1 

  reg [2:0] state;
  reg [2:0] nextstate;

  // comb always block
  always @* begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE     : begin
        if (DAVAIL) begin
          nextstate = CH_SELECT;
        end
      end
      CH_SELECT: begin
        begin
          nextstate = READOUT;
        end
      end
      READOUT  : begin
        if (DAVAIL) begin
          nextstate = READOUT;
        end
        else begin
          nextstate = IDLE;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  assign CHSEL = state[0];
  assign WR_EN = state[1];

  // sequential always block
  always @(posedge CLK) begin
    if (RST)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [71:0] statename;
  always @* begin
    case (state)
      IDLE     :
        statename = "IDLE";
      CH_SELECT:
        statename = "CH_SELECT";
      READOUT  :
        statename = "READOUT";
      default  :
        statename = "XXXXXXXXX";
    endcase
  end
  `endif

endmodule

