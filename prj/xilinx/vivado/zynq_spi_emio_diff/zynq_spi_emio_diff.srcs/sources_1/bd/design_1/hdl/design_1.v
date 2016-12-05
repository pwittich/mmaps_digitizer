//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.1 (lin64) Build 1538259 Fri Apr  8 15:45:23 MDT 2016
//Date        : Thu Oct 20 23:49:12 2016
//Host        : lnx231.classe.cornell.edu running 64-bit Scientific Linux release 6.8 (Carbon)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=8,numReposBlks=8,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=4,synth_mode=Global}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
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

  wire [0:0]IBUF_DS_N_1;
  wire [0:0]IBUF_DS_P_1;
  wire [0:0]OBUF_IN_1;
  wire [0:0]gnd_0_dout;
  wire [14:0]processing_system7_0_DDR_ADDR;
  wire [2:0]processing_system7_0_DDR_BA;
  wire processing_system7_0_DDR_CAS_N;
  wire processing_system7_0_DDR_CKE;
  wire processing_system7_0_DDR_CK_N;
  wire processing_system7_0_DDR_CK_P;
  wire processing_system7_0_DDR_CS_N;
  wire [3:0]processing_system7_0_DDR_DM;
  wire [31:0]processing_system7_0_DDR_DQ;
  wire [3:0]processing_system7_0_DDR_DQS_N;
  wire [3:0]processing_system7_0_DDR_DQS_P;
  wire processing_system7_0_DDR_ODT;
  wire processing_system7_0_DDR_RAS_N;
  wire processing_system7_0_DDR_RESET_N;
  wire processing_system7_0_DDR_WE_N;
  wire processing_system7_0_FIXED_IO_DDR_VRN;
  wire processing_system7_0_FIXED_IO_DDR_VRP;
  wire [53:0]processing_system7_0_FIXED_IO_MIO;
  wire processing_system7_0_FIXED_IO_PS_CLK;
  wire processing_system7_0_FIXED_IO_PS_PORB;
  wire processing_system7_0_FIXED_IO_PS_SRSTB;
  wire processing_system7_0_SPI1_MOSI_O;
  wire processing_system7_0_SPI1_SCLK_O;
  wire processing_system7_0_SPI1_SS_O;
  wire [0:0]util_ds_buf_0_OBUF_DS_N;
  wire [0:0]util_ds_buf_0_OBUF_DS_P;
  wire [0:0]util_ds_buf_1_OBUF_DS_N;
  wire [0:0]util_ds_buf_1_OBUF_DS_P;
  wire [0:0]util_ds_buf_2_IBUF_OUT;
  wire [0:0]util_ds_buf_3_OBUF_DS_N;
  wire [0:0]util_ds_buf_3_OBUF_DS_P;
  wire [0:0]util_ds_buf_4_OBUF_DS_N;
  wire [0:0]util_ds_buf_4_OBUF_DS_P;
  wire [0:0]vcc_0_dout;

  assign IBUF_DS_N_1 = IBUF_DS_N[0];
  assign IBUF_DS_P_1 = IBUF_DS_P[0];
  assign OBUF_DS_N[0] = util_ds_buf_0_OBUF_DS_N;
  assign OBUF_DS_N_1[0] = util_ds_buf_1_OBUF_DS_N;
  assign OBUF_DS_N_2[0] = util_ds_buf_3_OBUF_DS_N;
  assign OBUF_DS_N_3[0] = util_ds_buf_4_OBUF_DS_N;
  assign OBUF_DS_P[0] = util_ds_buf_0_OBUF_DS_P;
  assign OBUF_DS_P_1[0] = util_ds_buf_1_OBUF_DS_P;
  assign OBUF_DS_P_2[0] = util_ds_buf_3_OBUF_DS_P;
  assign OBUF_DS_P_3[0] = util_ds_buf_4_OBUF_DS_P;
  assign OBUF_IN_1 = OBUF_IN[0];
  design_1_xlconstant_0_0 gnd_0
       (.dout(gnd_0_dout));
  design_1_processing_system7_0_0 processing_system7_0
       (.DDR_Addr(DDR_addr[14:0]),
        .DDR_BankAddr(DDR_ba[2:0]),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm[3:0]),
        .DDR_DQ(DDR_dq[31:0]),
        .DDR_DQS(DDR_dqs_p[3:0]),
        .DDR_DQS_n(DDR_dqs_n[3:0]),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .MIO(FIXED_IO_mio[53:0]),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .SPI1_MISO_I(util_ds_buf_2_IBUF_OUT),
        .SPI1_MOSI_I(gnd_0_dout),
        .SPI1_MOSI_O(processing_system7_0_SPI1_MOSI_O),
        .SPI1_SCLK_I(gnd_0_dout),
        .SPI1_SCLK_O(processing_system7_0_SPI1_SCLK_O),
        .SPI1_SS_I(vcc_0_dout),
        .SPI1_SS_O(processing_system7_0_SPI1_SS_O),
        .USB0_VBUS_PWRFAULT(1'b0));
  design_1_util_ds_buf_0_0 util_ds_buf_0
       (.OBUF_DS_N(util_ds_buf_0_OBUF_DS_N),
        .OBUF_DS_P(util_ds_buf_0_OBUF_DS_P),
        .OBUF_IN(processing_system7_0_SPI1_SCLK_O));
  design_1_util_ds_buf_0_1 util_ds_buf_1
       (.OBUF_DS_N(util_ds_buf_1_OBUF_DS_N),
        .OBUF_DS_P(util_ds_buf_1_OBUF_DS_P),
        .OBUF_IN(processing_system7_0_SPI1_MOSI_O));
  design_1_util_ds_buf_0_4 util_ds_buf_2
       (.IBUF_DS_N(IBUF_DS_N_1),
        .IBUF_DS_P(IBUF_DS_P_1),
        .IBUF_OUT(util_ds_buf_2_IBUF_OUT));
  design_1_util_ds_buf_0_2 util_ds_buf_3
       (.OBUF_DS_N(util_ds_buf_3_OBUF_DS_N),
        .OBUF_DS_P(util_ds_buf_3_OBUF_DS_P),
        .OBUF_IN(processing_system7_0_SPI1_SS_O));
  design_1_util_ds_buf_4_1 util_ds_buf_4
       (.OBUF_DS_N(util_ds_buf_4_OBUF_DS_N),
        .OBUF_DS_P(util_ds_buf_4_OBUF_DS_P),
        .OBUF_IN(OBUF_IN_1));
  design_1_xlconstant_0_1 vcc_0
       (.dout(vcc_0_dout));
endmodule