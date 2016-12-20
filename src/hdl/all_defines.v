// SPI command definitions for the SPI state machine
// allows these definitions to be used inside a state machine designed in fizzim.
`define RD    4'b0000
`define WR    4'b0001
`define FIFO  4'b0010


`define TOP8BITS 	8'h00
`define BOTTOM8BITS 8'h01
`define ALL12BITS 	8'h02


`define ADCMODE_CONSTWORD 	8'h39
`define ADCMODE_RAMPUP 		8'h79
`define ADCMODE_DATA 		8'h09


`define DIGIMANY_NOTEST 	8'h00
`define VHDL_TEST 			8'h01
`define SINGLECHANNEL_TEST	8'h02


`define DEFAULT_WORD_12BITS 	12'haff
`define DEFAULT_WORD_8BITS 		8'hcc