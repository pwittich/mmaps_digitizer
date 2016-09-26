
// Created by fizzim.pl version 5.10 on 2016:09:25 at 22:32:09 (www.fizzim.com)

module multi_ro (
  output reg CHSEL,
  output reg WR_EN,
  input wire CLK,
  input wire DAVAIL,
  input wire RST 
);

  // state bits
  parameter 
  IDLE         = 0, 
  CH_SELECT    = 1, 
  READOUT      = 2, 
  WRITE_HEADER = 3; 

  reg [3:0] state;
  reg [3:0] nextstate;

  // comb always block
  always @* begin
    nextstate = 4'b0000;
    case (1'b1) // synopsys parallel_case full_case
      state[IDLE]        : begin
        if (DAVAIL) begin
          nextstate[WRITE_HEADER] = 1'b1;
        end
        else begin
          nextstate[IDLE] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[CH_SELECT]   : begin
        begin
          nextstate[READOUT] = 1'b1;
        end
      end
      state[READOUT]     : begin
        if (DAVAIL) begin
          nextstate[READOUT] = 1'b1;
        end
        else begin
          nextstate[IDLE] = 1'b1;
        end
      end
      state[WRITE_HEADER]: begin
        begin
          nextstate[CH_SELECT] = 1'b1;
        end
      end
    endcase
  end

  // sequential always block
  always @(posedge CLK) begin
    if (RST)
      state <= 4'b0001 << IDLE;
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
        nextstate[IDLE]        : begin
          ; // case must be complete for onehot
        end
        nextstate[CH_SELECT]   : begin
          CHSEL <= 1;
          WR_EN <= 1;
        end
        nextstate[READOUT]     : begin
          CHSEL <= 1;
          WR_EN <= 1;
        end
        nextstate[WRITE_HEADER]: begin
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
      state[IDLE]        :
        statename = "IDLE";
      state[CH_SELECT]   :
        statename = "CH_SELECT";
      state[READOUT]     :
        statename = "READOUT";
      state[WRITE_HEADER]:
        statename = "WRITE_HEADER";
      default     :
        statename = "XXXXXXXXXXXX";
    endcase
  end
  `endif

endmodule

