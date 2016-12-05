
// Created by fizzim.pl version 5.10 on 2016:09:26 at 10:33:48 (www.fizzim.com)

module multi_ro (
  output reg CHSEL,
  output reg WR_EN,
  input wire CLK,
  input wire DAVAIL,
  input wire RST 
);

  // state bits
  parameter
  IDLE_BIT = 0,
  CH_SELECT_BIT = 1,
  READOUT_BIT = 2,
  WRITE_HEADER_BIT = 3;

  parameter 
  IDLE         = 4'b1<<IDLE_BIT, 
  CH_SELECT    = 4'b1<<CH_SELECT_BIT, 
  READOUT      = 4'b1<<READOUT_BIT, 
  WRITE_HEADER = 4'b1<<WRITE_HEADER_BIT, 
  XXX          = 4'bx;

  reg [3:0] state;
  reg [3:0] nextstate;

  // comb always block
  always @* begin
    nextstate = XXX; // default to x because default_state_is_x is set
    case (1'b1) // synopsys parallel_case full_case
      state[IDLE_BIT]    : begin
        if (DAVAIL) begin
          nextstate = WRITE_HEADER;
        end
        else begin
          nextstate[IDLE] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[CH_SELECT_BIT]: begin
        begin
          nextstate = READOUT;
        end
      end
      state[READOUT_BIT] : begin
        if (DAVAIL) begin
          nextstate = READOUT;
        end
        else begin
          nextstate = IDLE;
        end
      end
      state[WRITE_HEADER_BIT]: begin
        begin
          nextstate = CH_SELECT;
        end
      end
    endcase
  end

  // sequential always block
  always @(posedge CLK) begin
    if (RST)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // datapath sequential always block
  always @(posedge CLK) begin
    if (RST) begin
      CHSEL <= 0;
      WR_EN <= 0;
    end
    else begin
      CHSEL <= 0; // default
      WR_EN <= 0; // default
      case (1'b1) // synopsys parallel_case full_case
        nextstate[IDLE_BIT]    : begin
          ; // case must be complete for onehot
        end
        nextstate[CH_SELECT_BIT]: begin
          CHSEL <= 1;
          WR_EN <= 1;
        end
        nextstate[READOUT_BIT] : begin
          CHSEL <= 1;
          WR_EN <= 1;
        end
        nextstate[WRITE_HEADER_BIT]: begin
          WR_EN <= 1;
        end
      endcase
    end
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [95:0] statename;
  always @* begin
    case (1'b1)
      state[IDLE_BIT]    :
        statename = "IDLE";
      state[CH_SELECT_BIT]:
        statename = "CH_SELECT";
      state[READOUT_BIT] :
        statename = "READOUT";
      state[WRITE_HEADER_BIT]:
        statename = "WRITE_HEADER";
      default     :
        statename = "XXXXXXXXXXXX";
    endcase
  end
  `endif

endmodule

