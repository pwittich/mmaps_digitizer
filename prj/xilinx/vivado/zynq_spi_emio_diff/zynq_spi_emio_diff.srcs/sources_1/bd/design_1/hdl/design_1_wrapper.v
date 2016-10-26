//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.1 (lin64) Build 1538259 Fri Apr  8 15:45:23 MDT 2016
//Date        : Thu Oct 20 23:49:12 2016
//Host        : lnx231.classe.cornell.edu running 64-bit Scientific Linux release 6.8 (Carbon)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    IBUF_DS_N,
    IBUF_DS_P,
    OBUF_DS_N,
    OBUF_DS_N_1,
    OBUF_DS_N_2,
    OBUF_DS_N_3,
    OBUF_DS_P,
    OBUF_DS_P_1,
    OBUF_DS_P_2,
    OBUF_DS_P_3,
    OBUF_IN);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input [0:0]IBUF_DS_N;
  input [0:0]IBUF_DS_P;
  output [0:0]OBUF_DS_N;
  output [0:0]OBUF_DS_N_1;
  output [0:0]OBUF_DS_N_2;
  output [0:0]OBUF_DS_N_3;
  output [0:0]OBUF_DS_P;
  output [0:0]OBUF_DS_P_1;
  output [0:0]OBUF_DS_P_2;
  output [0:0]OBUF_DS_P_3;
  input [0:0]OBUF_IN;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [0:0]IBUF_DS_N;
  wire [0:0]IBUF_DS_P;
  wire [0:0]OBUF_DS_N;
  wire [0:0]OBUF_DS_N_1;
  wire [0:0]OBUF_DS_N_2;
  wire [0:0]OBUF_DS_N_3;
  wire [0:0]OBUF_DS_P;
  wire [0:0]OBUF_DS_P_1;
  wire [0:0]OBUF_DS_P_2;
  wire [0:0]OBUF_DS_P_3;
  wire [0:0]OBUF_IN;

  design_1 design_1_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .IBUF_DS_N(IBUF_DS_N),
        .IBUF_DS_P(IBUF_DS_P),
        .OBUF_DS_N(OBUF_DS_N),
        .OBUF_DS_N_1(OBUF_DS_N_1),
        .OBUF_DS_N_2(OBUF_DS_N_2),
        .OBUF_DS_N_3(OBUF_DS_N_3),
        .OBUF_DS_P(OBUF_DS_P),
        .OBUF_DS_P_1(OBUF_DS_P_1),
        .OBUF_DS_P_2(OBUF_DS_P_2),
        .OBUF_DS_P_3(OBUF_DS_P_3),
        .OBUF_IN(OBUF_IN));
endmodule
