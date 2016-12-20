`timescale 1ns / 1ps
`default_nettype none

// simple lvds transmitter; does not generate a frame- how to do this?
module lvds_transmitter(
	input wire [11:0] DIN,
	input wire CLK,
	output wire O_CLK,
	//output wire O_FRAME,
	output wire [1:0] O_D
);

	// this is a megafunction that is two channel, internal PLL
	lvds_tx	lvds_tx_inst (
	.tx_in ( DIN ),
	.tx_inclock ( CLK ),
	.tx_out ( O_D ),
	.tx_coreclock ( O_CLK )
	);
endmodule