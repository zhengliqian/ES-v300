`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-04
// Module Name           : data_parse
// Project Name          : 
// Target Devices        : 
// Tool Versions         : Vivado 2020.2
// Description           : 
// 
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
// Additional Comments   :
// 
//////////////////////////////////////////////////////////////////////////////////
module alpg_data_prase
#(
    parameter GT_LANE_DW        = 32             ,
    parameter PROTCL_LEN        = 5              ,
    parameter FMT_NUM           = 9              ,
    parameter TREG_NUM          = 8              ,
    parameter RATE_DW           = 22             ,
    parameter TIMING_DW         = 22             ,
    parameter CMD_DW            = 4              ,
    parameter MUX_DW            = 4              ,
    parameter OPR_DW            = 3              ,
    parameter MSKTB_DW          = 8              ,
    parameter X_AW              = 15             ,
    parameter Y_AW              = 13             ,
    parameter Z_AW              = 11             ,
    parameter TP_DW             = 32             ,
    parameter MSTA_DW           = 23             ,
    parameter PSTA_DW           = 22             ,
    parameter AS_MAP_DW         = 24             ,
    parameter DDR_DW            = 8              ,
    parameter BYTE_DW           = 8              ,
    parameter REG_NUM0          = 8              ,
    parameter REG_NUM1          = 16             ,
    parameter REG_NUM2          = 32             ,    
    parameter REG_NUM           = 3              ,
    parameter REG_SEL_DW        = 7              ,
    parameter REG_DW            = 32
) 
(
    input                                    clk                           ,            //@200M
    input                                    rst                           ,
    input                                    alpg_start                    ,
    input                                    alpg_done                     ,
    input                                    base_rate_clk                 ,
    (*mark_debug="true"*)(*keep="true"*)input                                    init_start                    ,
    (*mark_debug="true"*)(*keep="true"*)output reg                               init_done              = 'd0  ,
    //pattern func data
    input      [PROTCL_LEN * GT_LANE_DW-1:0] pat_func_data                 ,
    input                                    pat_func_data_vld             ,   
    //DDR DATA
    (*mark_debug="true"*)(*keep="true"*)output reg [PSTA_DW-1:0]                 pm_addr            = 'd0      ,
    input      [DDR_DW-1:0]                  pm_data                       ,
    (*mark_debug="true"*)(*keep="true"*)output reg [MSTA_DW-1:0]                 dum_addr           = 'd0      ,
    input      [DDR_DW-1:0]                  dum_data                      ,
    //CFG
    (*mark_debug="true"*)(*keep="true"*)input      [FMT_NUM-1:0]                 cfg_alpg_fmt_c0               ,             
    (*mark_debug="true"*)(*keep="true"*)input      [FMT_NUM-1:0]                 cfg_alpg_fmt_c1               ,
    (*mark_debug="true"*)(*keep="true"*)input      [FMT_NUM-1:0]                 cfg_alpg_fmt_d0               ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_rate_bus             ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_aclk1_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_cclk1_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_bclk1_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_aclk2_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_bclk2_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_cclk2_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_aclk3_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_bclk3_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_cclk3_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_dre_r_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_dre_f_bus            ,
    input      [RATE_DW*TREG_NUM-1:0]        cfg_alpg_strb_bus             ,
    input      [MSKTB_DW-1:0]                cfg_alpg_msktb                ,            //active in 0
    input      [X_AW-1:0]                    cfg_alpg_x                    ,
    input      [Y_AW-1:0]                    cfg_alpg_y                    ,
    input      [Z_AW-1:0]                    cfg_alpg_z                    ,
    input      [TP_DW-1:0]                   cfg_alpg_tp                   ,
    input                                    cfg_alpg_me                   ,
    input      [PSTA_DW-1:0]                 cfg_alpg_psta                 ,
    input      [MSTA_DW-1:0]                 cfg_alpg_msta                 ,
    input      [TP_DW*REG_NUM2-1:0]          cfg_alpg_tph_bus              ,
    input      [TP_DW*REG_NUM1-1:0]          cfg_alpg_dreg_bus             ,
    input      [MSTA_DW*REG_NUM0-1:0]        cfg_alpg_qreg_bus             ,
    input      [PSTA_DW*REG_NUM0-1:0]        cfg_alpg_preg_bus             ,
    input      [AS_MAP_DW*REG_NUM0-1:0]      cfg_alpg_ash_bus              ,
    input      [AS_MAP_DW*REG_NUM0-1:0]      cfg_alpg_asl_bus              ,
     //-------to zynq---------
    output reg                               alpg_dps_start     = 'd0      ,
    //-------timing cfg------    
    (*mark_debug="true"*)(*keep="true"*)output reg                               pat_data_parse_vld = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_data_rate  = 'd0      ,
    //drv    
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_a_clk_drv0 = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_b_clk_drv0 = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_c_clk_drv0 = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_a_clk_drv1 = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_b_clk_drv1 = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_c_clk_drv1 = 'd0      ,
    //io    
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_a_clk_io   = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_b_clk_io   = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_c_clk_io   = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_drv_r      = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_drv_f      = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TIMING_DW-1:0]               pattern_strb       = 'd0      ,
    //-------pattern data------
    //drv
    (*mark_debug="true"*)(*keep="true"*)output reg                               ck_out             = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg                               we_out             = 'd0      ,
    //dio    
    (*mark_debug="true"*)(*keep="true"*)output      [CMD_DW-1:0]                 pattern_cmd                   ,
    (*mark_debug="true"*)(*keep="true"*)output                                   pattern_me                    ,
    (*mark_debug="true"*)(*keep="true"*)output      [MSKTB_DW-1:0]               pattern_msktb                 ,
    (*mark_debug="true"*)(*keep="true"*)output reg  [BYTE_DW-1:0]                d_reg              = 'd0      ,
    (*mark_debug="true"*)(*keep="true"*)output reg                               pattern_dio        = 'd0     
);

localparam PC_BIT   = 14 ;
localparam CTRL_BIT = 7  ;
localparam CMD_BIT  = 4  ;
localparam TSN_BIT  = 3  ;
localparam WE_BIT   = 1  ;
localparam CK_BIT   = 1  ;
localparam REGA_NUM = 93 ;
localparam AS_DW    = 8  ;
localparam AS_NUM   = 8  ;

(*mark_debug="true"*)(*keep="true"*)wire                            pattern_we      ; 
(*mark_debug="true"*)(*keep="true"*)wire                            pattern_ck      ; 
(*mark_debug="true"*)(*keep="true"*)wire  [MUX_DW-1:0]              pattern_mux     ; //bit3-0:mux_s,mux_d0,mux_d1,mux_d2
(*mark_debug="true"*)(*keep="true"*)wire  [OPR_DW*REG_NUM-1:0]      pattern_opr_bus ;
(*mark_debug="true"*)(*keep="true"*)wire  [OPR_DW-1:0]              pattern_opr0    ;
(*mark_debug="true"*)(*keep="true"*)wire  [OPR_DW-1:0]              pattern_opr1    ;
(*mark_debug="true"*)(*keep="true"*)wire  [OPR_DW-1:0]              pattern_opr2    ;
(*mark_debug="true"*)(*keep="true"*)wire  [REG_SEL_DW-1:0]          pattern_reg_a0  ;
(*mark_debug="true"*)(*keep="true"*)wire  [REG_SEL_DW-1:0]          pattern_reg_a1  ;
(*mark_debug="true"*)(*keep="true"*)wire  [REG_SEL_DW-1:0]          pattern_reg_a2  ;
(*mark_debug="true"*)(*keep="true"*)wire  [REG_DW-1:0]              pattern_reg_b0  ;
(*mark_debug="true"*)(*keep="true"*)wire  [REG_DW-1:0]              pattern_reg_b1  ;
(*mark_debug="true"*)(*keep="true"*)wire  [REG_DW-1:0]              pattern_reg_b2  ;

wire [REG_SEL_DW*REG_NUM-1:0] pattern_rega_bus;
wire [REG_DW*REG_NUM-1:0]     pattern_regb_bus;

assign pattern_we      = pat_func_data[(PROTCL_LEN-1) * GT_LANE_DW + 3]                                                          ;
assign pattern_ck      = pat_func_data[(PROTCL_LEN-1) * GT_LANE_DW + 2]                                                          ;
assign pattern_cmd     = pat_func_data[PROTCL_LEN * GT_LANE_DW-PC_BIT-CTRL_BIT-1:PROTCL_LEN * GT_LANE_DW-PC_BIT-CTRL_BIT-CMD_BIT];
assign pattern_mux     = pat_func_data[REG_DW*3+REG_SEL_DW*3+OPR_DW*REG_NUM+MUX_DW-1:REG_DW*3+REG_SEL_DW*3+OPR_DW*REG_NUM]       ;
//assign pattern_opr_bus = pat_func_data[REG_DW*3+REG_SEL_DW*3+OPR_DW*REG_NUM-1:REG_DW*3+REG_SEL_DW*3]                             ;
assign pattern_opr0    = pat_func_data[REG_DW*3+REG_SEL_DW*3+3*OPR_DW-1:REG_DW*3+REG_SEL_DW*3+2*OPR_DW];
assign pattern_opr1    = pat_func_data[REG_DW*3+REG_SEL_DW*3+2*OPR_DW-1:REG_DW*3+REG_SEL_DW*3+OPR_DW];
assign pattern_opr2    = pat_func_data[REG_DW*3+REG_SEL_DW*3+OPR_DW-1:REG_DW*3+REG_SEL_DW*3];
assign pattern_reg_a0  = pat_func_data[REG_DW*3+REG_SEL_DW*3-1:REG_DW*3+REG_SEL_DW*2]                                            ;
assign pattern_reg_a1  = pat_func_data[REG_DW*3+REG_SEL_DW*2-1:REG_DW*3+REG_SEL_DW]                                              ;
assign pattern_reg_a2  = pat_func_data[REG_DW*3+REG_SEL_DW-1:REG_DW*3]                                                           ;
assign pattern_reg_b0  = pat_func_data[REG_DW*3-1:REG_DW*2]                                                                      ;
assign pattern_reg_b1  = pat_func_data[REG_DW*2-1:REG_DW]                                                                        ;
assign pattern_reg_b2  = pat_func_data[REG_DW-1:0]                                                                               ;

assign pattern_rega_bus = {pattern_reg_a2,pattern_reg_a1,pattern_reg_a0};
assign pattern_regb_bus = {pattern_reg_b2,pattern_reg_b1,pattern_reg_b0}; 
assign pattern_opr_bus  = {pattern_opr2,pattern_opr1,pattern_opr0}      ;

always @(posedge clk) 
begin
  pat_data_parse_vld <= pat_func_data_vld;
end

//=====================================================
//---------------timing data parse---------------
//=====================================================
(*mark_debug="true"*)(*keep="true"*)wire [TSN_BIT-1:0]    tsn_reg;

assign tsn_reg = pat_func_data[PROTCL_LEN * GT_LANE_DW-PC_BIT-CTRL_BIT-CMD_BIT-1:PROTCL_LEN * GT_LANE_DW-PC_BIT-CTRL_BIT-CMD_BIT-TSN_BIT];

(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_aclk_drv0 = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_bclk_drv0 = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_cclk_drv0 = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_aclk_drv1 = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_bclk_drv1 = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_cclk_drv1 = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_aclk_io   = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_bclk_io   = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [RATE_DW*TREG_NUM-1:0] cfg_alpg_cclk_io   = 'd0;

wire [1:0] drv0_timing_sel;
wire [1:0] drv1_timing_sel;
wire [1:0] io_timing_sel  ;

assign drv0_timing_sel = cfg_alpg_fmt_c0[8:7];
assign drv1_timing_sel = cfg_alpg_fmt_c1[8:7];
assign io_timing_sel   = cfg_alpg_fmt_d0[8:7];

always @(posedge clk) 
begin
  if(drv0_timing_sel == 'd1)
  begin
    cfg_alpg_aclk_drv0 <= cfg_alpg_aclk2_bus;
    cfg_alpg_bclk_drv0 <= cfg_alpg_cclk2_bus;
    cfg_alpg_cclk_drv0 <= cfg_alpg_bclk2_bus;
  end
  else if(drv0_timing_sel == 'd2)
  begin
    cfg_alpg_aclk_drv0 <= cfg_alpg_aclk3_bus;
    cfg_alpg_bclk_drv0 <= cfg_alpg_cclk3_bus;
    cfg_alpg_cclk_drv0 <= cfg_alpg_bclk3_bus;    
  end
  else
  begin
    cfg_alpg_aclk_drv0 <= cfg_alpg_aclk1_bus;
    cfg_alpg_bclk_drv0 <= cfg_alpg_cclk1_bus;
    cfg_alpg_cclk_drv0 <= cfg_alpg_bclk1_bus; 
  end
end

always @(posedge clk) 
begin
  if(drv1_timing_sel == 'd1)
  begin
    cfg_alpg_aclk_drv1 <= cfg_alpg_aclk2_bus;
    cfg_alpg_bclk_drv1 <= cfg_alpg_cclk2_bus;
    cfg_alpg_cclk_drv1 <= cfg_alpg_bclk2_bus;
  end
  else if(drv1_timing_sel == 'd2)
  begin
    cfg_alpg_aclk_drv1 <= cfg_alpg_aclk3_bus;
    cfg_alpg_bclk_drv1 <= cfg_alpg_cclk3_bus;
    cfg_alpg_cclk_drv1 <= cfg_alpg_bclk3_bus;    
  end
  else
  begin
    cfg_alpg_aclk_drv1 <= cfg_alpg_aclk1_bus;
    cfg_alpg_bclk_drv1 <= cfg_alpg_cclk1_bus;
    cfg_alpg_cclk_drv1 <= cfg_alpg_bclk1_bus; 
  end
end

always @(posedge clk) 
begin
  if(io_timing_sel == 'd1)
  begin
    cfg_alpg_aclk_io <= cfg_alpg_aclk2_bus;
    cfg_alpg_bclk_io <= cfg_alpg_cclk2_bus;
    cfg_alpg_cclk_io <= cfg_alpg_bclk2_bus;
  end
  else if(io_timing_sel == 'd2)
  begin
    cfg_alpg_aclk_io <= cfg_alpg_aclk3_bus;
    cfg_alpg_bclk_io <= cfg_alpg_cclk3_bus;
    cfg_alpg_cclk_io <= cfg_alpg_bclk3_bus;    
  end
  else
  begin
    cfg_alpg_aclk_io <= cfg_alpg_aclk1_bus;
    cfg_alpg_bclk_io <= cfg_alpg_cclk1_bus;
    cfg_alpg_cclk_io <= cfg_alpg_bclk1_bus; 
  end
end

always @(posedge clk) 
begin
  if(pat_func_data_vld) 
  begin
    case (tsn_reg)
      'd0:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-7)-1:0] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-7)-1:0]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-7)-1:0]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-7)-1:0]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-7)-1:0] ;       
      end 
      'd1:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-6)-1:RATE_DW*(TREG_NUM-7)] ;
      end 
      'd2:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-5)-1:RATE_DW*(TREG_NUM-6)] ;
      end 
      'd3:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-4)-1:RATE_DW*(TREG_NUM-5)] ;
      end 
      'd4:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-3)-1:RATE_DW*(TREG_NUM-4)] ;
      end 
      'd5:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-2)-1:RATE_DW*(TREG_NUM-3)] ;
      end 
      'd6:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-1)-1:RATE_DW*(TREG_NUM-2)] ;
      end 
      'd7:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)]  ;
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*TREG_NUM-1:RATE_DW*(TREG_NUM-1)] ;
      end 
      default:
      begin
        pattern_data_rate  <= cfg_alpg_rate_bus[RATE_DW*(TREG_NUM-7)-1:0] ;
        pattern_a_clk_drv0 <= cfg_alpg_aclk_drv0[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_b_clk_drv0 <= cfg_alpg_bclk_drv0[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_c_clk_drv0 <= cfg_alpg_cclk_drv0[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_a_clk_drv1 <= cfg_alpg_aclk_drv1[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_b_clk_drv1 <= cfg_alpg_bclk_drv1[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_c_clk_drv1 <= cfg_alpg_cclk_drv1[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_a_clk_io   <= cfg_alpg_aclk_io[RATE_DW*(TREG_NUM-7)-1:0]  ;
        pattern_b_clk_io   <= cfg_alpg_bclk_io[RATE_DW*(TREG_NUM-7)-1:0]  ;
        pattern_c_clk_io   <= cfg_alpg_cclk_io[RATE_DW*(TREG_NUM-7)-1:0]  ;          
        pattern_drv_r      <= cfg_alpg_dre_r_bus[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_drv_f      <= cfg_alpg_dre_f_bus[RATE_DW*(TREG_NUM-7)-1:0];
        pattern_strb       <= cfg_alpg_strb_bus[RATE_DW*(TREG_NUM-7)-1:0] ;      
      end 
    endcase
  end 
end

//------------------------reg array map-------------------------------
reg                      pat_func_data_vld_d1 = 'd0;
reg                      pat_func_data_vld_d2 = 'd0;
reg                      pat_func_data_vld_d3 = 'd0;

always @(posedge clk) 
begin
  pat_func_data_vld_d1 <= pat_func_data_vld   ;
  pat_func_data_vld_d2 <= pat_func_data_vld_d1;  
  pat_func_data_vld_d3 <= pat_func_data_vld_d2;  
end

localparam ST_DW = 'd4;

localparam IDLE    = 0 ;
localparam INIT    = 1 ;
localparam WAIT    = 2 ;
localparam RD_REG  = 3 ;
localparam OPR_RDY = 4 ;
localparam OPR_REG = 5 ;
localparam WR_RDY  = 6 ;
localparam WR_REG  = 7 ;

localparam BRAM_DEEP = 128 ;
localparam BRAM_AW   = $clog2(BRAM_DEEP)+1;
localparam BRAM_SIZE = BRAM_DEEP*REG_DW;

reg  [REG_DW-1:0]  wr_bram_data_a    = 'd0;
reg  [REG_DW-1:0]  wr_bram_data_b    = 'd0;
wire [REG_DW-1:0]  rd_bram_data_a         ;
wire [REG_DW-1:0]  rd_bram_data_b         ;
reg  [BRAM_AW-1:0] bram_addr_a       = 'd0;
reg  [BRAM_AW-1:0] bram_addr_b       = 'd0;
reg                bram_ena          = 'd0;
reg                bram_enb          = 'd0;
reg                bram_wr_ena       = 'd0;
reg                bram_wr_enb       = 'd0;
reg                rd_data_vld       = 'd0;
reg  [REG_DW-1:0]  wr_bram_data_a_d1 = 'd0;
reg  [REG_DW-1:0]  wr_bram_data_b_d1 = 'd0;
reg  [BRAM_AW-1:0] bram_addr_a_d1    = 'd0;
reg  [BRAM_AW-1:0] bram_addr_b_d1    = 'd0;
reg                bram_ena_d1       = 'd0;
reg                bram_enb_d1       = 'd0;
reg                bram_wr_ena_d1    = 'd0;
reg                bram_wr_enb_d1    = 'd0;
reg                rd_en_d1          = 'd0;
reg rd_en_d2 = 'd0;
reg rd_en_d3 = 'd0;
reg opr_vld  = 'd0;

reg rd_done = 'd0;
reg wr_done = 'd0;

(*mark_debug="true"*)(*keep="true"*)reg [REG_NUM-1:0] wr_data_cnt = 'd0;


always @(posedge clk) 
begin
  bram_addr_a_d1    <= bram_addr_a   ;
  bram_addr_b_d1    <= bram_addr_b   ;
  bram_ena_d1       <= bram_ena      ;
  bram_enb_d1       <= bram_enb      ;
  bram_wr_ena_d1    <= bram_wr_ena   ;
  bram_wr_enb_d1    <= bram_wr_enb   ;
  wr_bram_data_a_d1 <= wr_bram_data_a;
  wr_bram_data_b_d1 <= wr_bram_data_b; 
end

(*mark_debug="true"*)(*keep="true"*)reg  [REG_DW*REG_NUM-1:0]  wr_bram_data_a_bus    = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [REG_DW*REG_NUM-1:0]  wr_bram_data_b_bus    = 'd0;
(*mark_debug="true"*)(*keep="true"*)wire [REG_DW*REG_NUM-1:0]  rd_bram_data_a_bus         ;
(*mark_debug="true"*)(*keep="true"*)wire [REG_DW*REG_NUM-1:0]  rd_bram_data_b_bus         ;
(*mark_debug="true"*)(*keep="true"*)reg  [BRAM_AW*REG_NUM-1:0] bram_addr_a_bus       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [BRAM_AW*REG_NUM-1:0] bram_addr_b_bus       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [REG_NUM-1:0]         bram_ena_bus          = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [REG_NUM-1:0]         bram_enb_bus          = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [REG_NUM-1:0]         bram_wr_ena_bus       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [REG_NUM-1:0]         bram_wr_enb_bus       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [REG_NUM-1:0]         rd_data_vld_bus       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [REG_NUM-1:0]         opr_vld_bus           = 'd0;

genvar i;

generate
  for(i = 0; i < REG_NUM; i = i + 1)
  begin:u_bram_inst
    xpm_memory_tdpram #(
      .ADDR_WIDTH_A           (BRAM_AW        ),               // DECIMAL
      .ADDR_WIDTH_B           (BRAM_AW        ),               // DECIMAL
      .AUTO_SLEEP_TIME        (0              ),               // DECIMAL
      .BYTE_WRITE_WIDTH_A     (32             ),               // DECIMAL
      .BYTE_WRITE_WIDTH_B     (32             ),               // DECIMAL
      .CASCADE_HEIGHT         (0              ),               // DECIMAL
      .CLOCKING_MODE          ("common_clock" ),               // String
      .ECC_MODE               ("no_ecc"       ),               // String
      .MEMORY_INIT_FILE       ("none"         ),               // String
      .MEMORY_INIT_PARAM      ("0"            ),               // String
      .MEMORY_OPTIMIZATION    ("true"         ),               // String
      .MEMORY_PRIMITIVE       ("auto"         ),               // String
      .MEMORY_SIZE            (BRAM_SIZE      ),               // DECIMAL
      .MESSAGE_CONTROL        (0              ),               // DECIMAL
      .READ_DATA_WIDTH_A      (REG_DW         ),               // DECIMAL
      .READ_DATA_WIDTH_B      (REG_DW         ),               // DECIMAL
      .READ_LATENCY_A         (1              ),               // DECIMAL
      .READ_LATENCY_B         (1              ),               // DECIMAL
      .READ_RESET_VALUE_A     ("0"            ),               // String
      .READ_RESET_VALUE_B     ("0"            ),               // String
      .RST_MODE_A             ("SYNC"         ),               // String
      .RST_MODE_B             ("SYNC"         ),               // String
      .SIM_ASSERT_CHK         (0              ),               // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_EMBEDDED_CONSTRAINT(0              ),               // DECIMAL
      .USE_MEM_INIT           (1              ),               // DECIMAL
      .WAKEUP_TIME            ("disable_sleep"),               // String
      .WRITE_DATA_WIDTH_A     (REG_DW         ),               // DECIMAL
      .WRITE_DATA_WIDTH_B     (REG_DW         ),               // DECIMAL
      .WRITE_MODE_A           ("no_change"    ),               // String
      .WRITE_MODE_B           ("no_change"    )                // String
    )
    xpm_memory_tdpram_inst (
      .dbiterra      (                                                ),                       // 1-bit output
      .dbiterrb      (                                                ),                       // 1-bit output
      .douta         (rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW]     ),                       // READ_DATA_WIDTH_A-bit output
      .doutb         (rd_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW]     ),                       // READ_DATA_WIDTH_B-bit output
      .sbiterra      (                                                ),                       // 1-bit output
      .sbiterrb      (                                                ),                       // 1-bit output
      .addra         (bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW]      ),                       // ADDR_WIDTH_A-bit input
      .addrb         (bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW]      ),                       // ADDR_WIDTH_B-bit input
      .clka          (clk                                             ),                       // 1-bit input
      .clkb          (clk                                             ),                       // 1-bit input
      .dina          (wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW]     ),                       // WRITE_DATA_WIDTH_A-bit input
      .dinb          (wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW]     ),                       // WRITE_DATA_WIDTH_B-bit input
      .ena           (bram_ena_bus[i]                                 ),                       // 1-bit input
      .enb           (bram_enb_bus[i]                                 ),                       // 1-bit input
      .injectdbiterra(1'b0                                            ),                       // 1-bit input
      .injectdbiterrb(1'b0                                            ),                       // 1-bit input
      .injectsbiterra(1'b0                                            ),                       // 1-bit input
      .injectsbiterrb(1'b0                                            ),                       // 1-bit input
      .regcea        (1'b1                                            ),                       // 1-bit input
      .regceb        (1'b1                                            ),                       // 1-bit input
      .rsta          (rst                                             ),                       // 1-bit input
      .rstb          (rst                                             ),                       // 1-bit input
      .sleep         (1'b0                                            ),                       // 1-bit input
      .wea           (bram_wr_ena_bus[i]                              ),                       // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input
      .web           (bram_wr_enb_bus[i]                              )                        // WRITE_DATA_WIDTH_B/BYTE_WRITE_WIDTH_B-bit input
    );
  end
endgenerate

(*mark_debug="true"*)(*keep="true"*)reg [ST_DW-1:0] crt_st = IDLE;
(*mark_debug="true"*)(*keep="true"*)reg [ST_DW-1:0] nxt_st = IDLE;

always @(posedge clk) 
begin
  if(rst || alpg_start)
  begin
    crt_st <= IDLE;
  end
  else
  begin
    crt_st <= nxt_st;
  end
end

always @(*) 
begin
  case (crt_st)
    IDLE:
    begin
      if(init_start)
      begin
        nxt_st = INIT;
      end
      else
      begin
        nxt_st = IDLE;
      end  
    end 
    INIT:
    begin
      if(bram_addr_a_bus[BRAM_AW-1:0] == 'd35)
      begin
        nxt_st = WAIT;
      end
      else
      begin
        nxt_st = INIT;
      end
    end 
    WAIT:
    begin
      if(alpg_done)
      begin
        nxt_st = IDLE;
      end
      else if(pat_func_data_vld && ((pattern_rega_bus[REG_SEL_DW-1:0] != 'd0) || (pattern_cmd == 'd1)))
      begin
        nxt_st = RD_REG;
      end
      else
      begin
        nxt_st = WAIT;
      end
    end
    RD_REG:
    begin
      nxt_st = OPR_RDY;
    end
    OPR_RDY:
    begin
      nxt_st = OPR_REG;
    end
    OPR_REG:
    begin
      nxt_st = WR_RDY;
    end
    WR_RDY:
    begin
      nxt_st = WR_REG;
    end  
    WR_REG:
    begin
      if(wr_data_cnt == REG_NUM-1)
      begin
        nxt_st = WAIT;
      end
      else
      begin
        nxt_st = WR_REG;
      end  
    end
    default: 
    begin
      nxt_st = IDLE;
    end
  endcase
end

always @(posedge clk) 
begin
  init_done <= (crt_st == INIT) && (nxt_st == WAIT); 
end

always @(posedge clk) 
begin
  if(crt_st == WR_REG)
  begin
    wr_data_cnt <= wr_data_cnt + 'd1;
  end
  else 
  begin
    wr_data_cnt <='d0;
  end
end

//always @(posedge clk) 
//begin
//  wr_done <= (wr_data_cnt == REG_NUM-1);
//end

//gen bram en
(*mark_debug="true"*)(*keep="true"*)reg [REG_NUM-1:0] opr_vld_shift = 'd0;

generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_bram_ena
    always @(posedge clk) 
    begin
      if((crt_st == INIT) && (bram_addr_a_bus[BRAM_AW-1:0] < 'd35))        //init wr
      begin
        bram_ena_bus[i] <= 'd1;
      end
      else if((crt_st == RD_REG) && (pattern_rega_bus[(i+1)*REG_SEL_DW-1:i*REG_SEL_DW] > 'd1))        //rd
      begin
        bram_ena_bus[i] <= 'd1;
      end
      else if((crt_st == WR_REG) && (pattern_rega_bus[(i+1)*REG_SEL_DW-1:i*REG_SEL_DW] > 'd1))                             //wr
      begin
        bram_ena_bus[i] <= opr_vld_shift[0];
      end
      else 
      begin
        bram_ena_bus[i] <= 'd0;
      end
    end
  end
endgenerate

generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_bram_enb
    always @(posedge clk) 
    begin
      if((crt_st == INIT) && (bram_addr_a_bus[BRAM_AW-1:0] < 'd35))        //init wr
      begin
        bram_enb_bus[i] <= 'd1;
      end
      else if((crt_st == RD_REG) && (pattern_mux[2-i]))        //rd reg when mux regb
      begin
        bram_enb_bus[i] <= 'd1;
      end
      else if((crt_st == WR_REG) && (pattern_opr_bus[OPR_DW*(i+1)-1:OPR_DW*i] == 'd5))        //wr regb when a <-> b
      begin
        bram_enb_bus[i] <= opr_vld_shift[0];
      end
      else
      begin
        bram_enb_bus[i] <= 'd0;
      end
    end
  end
endgenerate

//gen bram we
generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_bram_wea
    always @(posedge clk) 
    begin
      if((crt_st == INIT) && (bram_addr_a_bus[BRAM_AW-1:0] < 'd35))    //init wr
      begin
        bram_wr_ena_bus[i] <= 'd1;
      end 
      else if((crt_st == WR_REG) && (pattern_rega_bus[(i+1)*REG_SEL_DW-1:i*REG_SEL_DW] > 'd1))
      begin
        bram_wr_ena_bus[i] <= opr_vld_shift[0];
      end
      else
      begin
        bram_wr_ena_bus[i] <= 'd0;
      end
    end
  end
endgenerate

generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_bram_web
    always @(posedge clk) 
    begin
      if((crt_st == INIT) && (bram_addr_a_bus[BRAM_AW-1:0] < 'd35))
        begin
          bram_wr_enb_bus[i] <= 'd1;
        end
      else if((crt_st == WR_REG) && (pattern_opr_bus[OPR_DW*(i+1)-1:OPR_DW*i] == 'd5))
        begin
          bram_wr_enb_bus[i] <= opr_vld_shift[0];
        end
      else
        begin
          bram_wr_enb_bus[i] <= 'd0;        
        end      
    end 
  end
endgenerate

always @(posedge clk) 
begin
  if(crt_st == WR_RDY)
  begin
    opr_vld_shift <= opr_vld_bus;
  end
  else if(crt_st == WR_REG)
  begin
    opr_vld_shift <= {1'b0,opr_vld_shift[REG_NUM-1:1]};
  end
end

//gen bram addr
(*mark_debug="true"*)(*keep="true"*)reg [REG_NUM*REG_SEL_DW-1:0] pattern_rega_shift = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [REG_NUM*REG_DW-1:0]     pattern_regb_shift = 'd0;

generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_bram_ad_a
    always @(posedge clk) 
    begin
      case(crt_st)
        IDLE:
        begin
          bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= 'd0;
        end 
        INIT:
        begin
          if(bram_wr_ena_bus[i])
          begin
            bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] + 'd1;
          end
          else
          begin
            bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW];
          end
        end 
        RD_REG:
        begin
          if(pattern_rega_bus[(i+1)*REG_SEL_DW-1:i*REG_SEL_DW] > 'd1)
          begin
            bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= pattern_rega_bus[(i+1)*REG_SEL_DW-1:i*REG_SEL_DW] - 'd2;
          end
          else
          begin
            bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW];
          end
        end
        WR_REG:
        begin
          bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= pattern_rega_shift[REG_SEL_DW-1:0] - 'd2;
        end
        default:
        begin
          bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_a_bus[(i+1)*BRAM_AW-1:i*BRAM_AW];
        end 
      endcase
    end
  end
endgenerate

generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_bram_ad_b
    always @(posedge clk) 
    begin
      case(crt_st)
        IDLE:
        begin
          bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= 'd36;
        end 
        INIT:
        begin
          if(bram_wr_enb_bus[i])
          begin
            bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] + 'd1;
          end
          else
          begin
            bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW];
          end
        end 
        RD_REG:
        begin
          if(pattern_rega_bus[(i+1)*REG_SEL_DW-1:i*REG_SEL_DW] > 'd0)
          begin
            bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= pattern_regb_bus[REG_DW*i+REG_SEL_DW-1:REG_DW*i] - 'd2;
          end
          else
          begin
            bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW];          
          end
        end
        WR_REG:
        begin
          if(pattern_opr_bus[OPR_DW*(i+1)-1:OPR_DW*i] == 'd5)
          begin
            bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= pattern_regb_shift[REG_SEL_DW-1:0] - 'd2;
          end
          else
          begin
            bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW];          
          end
        end
        default:
        begin
          bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW] <= bram_addr_b_bus[(i+1)*BRAM_AW-1:i*BRAM_AW];
        end 
      endcase
    end
  end
endgenerate

always @(posedge clk) 
begin
  if(crt_st == OPR_REG)
  begin
    pattern_rega_shift <= pattern_rega_bus;
    pattern_regb_shift <= pattern_regb_bus;
  end
  else if(crt_st == WR_REG)
  begin
    pattern_rega_shift <= {{REG_SEL_DW{1'b0}},pattern_rega_shift[REG_SEL_DW*REG_NUM-1:REG_SEL_DW]};
    pattern_regb_shift <= {{REG_DW{1'b0}},pattern_regb_shift[REG_DW*REG_NUM-1:REG_DW]};
  end
  else
  begin
    pattern_rega_shift <= pattern_rega_shift;
    pattern_regb_shift <= pattern_regb_shift;
  end
end

//gen bram wr data
reg [TP_DW*REG_NUM2-1:0]   alpg_tph_bus_shift = 'd0;
reg [TP_DW*REG_NUM1-1:0]   alpg_dreg_shift    = 'd0;
reg [MSTA_DW*REG_NUM0-1:0] alpg_qreg_shift    = 'd0;
reg [PSTA_DW*REG_NUM0-1:0] alpg_preg_shift    = 'd0;

(*mark_debug="true"*)(*keep="true"*)reg [REG_DW*REG_NUM-1:0] opr_abus       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [REG_DW*REG_NUM-1:0] opr_bbus       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [REG_DW*REG_NUM-1:0] opr_abus_shift = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [REG_DW*REG_NUM-1:0] opr_bbus_shift = 'd0;

reg [BRAM_AW-1:0] init_wr_data_cnt = 'd0;

always @(posedge clk) 
begin
  if(crt_st == INIT)
  begin
    init_wr_data_cnt <= init_wr_data_cnt + 'd1;
  end
  else
  begin
    init_wr_data_cnt <= 'd0;
  end
end

generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_wr_data_a
    always @(posedge clk) 
    begin
      case(crt_st)
        INIT:
        begin
          //case(bram_addr_a_bus[BRAM_AW-1:0])
          case(init_wr_data_cnt)
          'd0: wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_tp    ;
          'd1: wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_x     ;
          'd2: wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_y     ;
          'd3: wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_z     ;
          'd4: wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_msta  ;
          'd5: wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_psta  ;
          default: wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= alpg_tph_bus_shift[TP_DW-1:0];
          endcase
        end 
        WR_REG:
        begin
          wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= opr_abus_shift[REG_DW-1:0];
        end
        default:
        begin
          wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] <= wr_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW];
        end
      endcase
    end
  end
endgenerate

always @(posedge clk ) 
begin
  if(crt_st == IDLE)
  begin
    alpg_tph_bus_shift <= cfg_alpg_tph_bus;
  end
  else if((crt_st == INIT) && (init_wr_data_cnt > 'd5))
  begin
    alpg_tph_bus_shift <= {{TP_DW{1'b0}},alpg_tph_bus_shift[TP_DW*REG_NUM2-1:TP_DW]};
  end
  else
  begin
    alpg_tph_bus_shift <= alpg_tph_bus_shift;
  end
end

generate
  for(i = 0;i < REG_NUM; i = i +1)
  begin:u_wr_data_b
    always @(posedge clk) 
    begin
      case(crt_st)
        INIT: 
        begin
          if(init_wr_data_cnt == 'd0)
          begin
            wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_tph_bus[TP_DW*(REG_NUM2-1)-1:TP_DW*(REG_NUM2-2)];
          end
          else if(init_wr_data_cnt == 'd1)
          begin
            wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_tph_bus[TP_DW*REG_NUM2-1:TP_DW*(REG_NUM2-1)];
          end
          else if(init_wr_data_cnt <'d18)
          begin
            wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= alpg_dreg_shift[TP_DW-1:0];
          end
          else if(init_wr_data_cnt < 'd26)
          begin
            wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= alpg_qreg_shift[MSTA_DW-1:0];
          end
          else if(init_wr_data_cnt < 'd34)
          begin
            wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= alpg_preg_shift[PSTA_DW-1:0];
          end  
          else if(init_wr_data_cnt == 'd34)
          begin
            wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_me;
          end
          else
          begin
            wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= cfg_alpg_msktb;
          end
        end
        WR_REG:
        begin
          wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= opr_bbus_shift[REG_DW-1:0];
        end
        default: 
        begin
          wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW] <= wr_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW];
        end
      endcase
    end
  end
endgenerate

always @(posedge clk ) 
begin
  if(crt_st == IDLE)
  begin
    alpg_dreg_shift <= cfg_alpg_dreg_bus;
  end
  else if((crt_st == INIT) && (init_wr_data_cnt > 'd1))
  begin
    alpg_dreg_shift <= {{TP_DW{1'b0}},alpg_dreg_shift[TP_DW*REG_NUM1-1:TP_DW]};
  end
  else
  begin
    alpg_dreg_shift <= alpg_dreg_shift;
  end
end

always @(posedge clk ) 
begin
  if(crt_st == IDLE)
  begin
    alpg_qreg_shift <= cfg_alpg_qreg_bus;
  end
  else if((crt_st == INIT) && (init_wr_data_cnt > 'd17))
  begin
    alpg_qreg_shift <= {{MSTA_DW{1'b0}},alpg_qreg_shift[MSTA_DW*REG_NUM0-1:MSTA_DW]};
  end
  else
  begin
    alpg_qreg_shift <= alpg_qreg_shift;
  end
end

always @(posedge clk ) 
begin
  if(crt_st == IDLE)
  begin
    alpg_preg_shift <= cfg_alpg_preg_bus;
  end
  else if((crt_st == INIT) && (init_wr_data_cnt > 'd25))
  begin
    alpg_preg_shift <= {{PSTA_DW{1'b0}},alpg_preg_shift[PSTA_DW*REG_NUM0-1:PSTA_DW]};
  end
  else
  begin
    alpg_preg_shift <= alpg_preg_shift;
  end
end

always @(posedge clk) 
begin
  if(crt_st == WR_RDY)
  begin
    opr_abus_shift <= opr_abus;
    opr_bbus_shift <= opr_bbus;
  end
  else if(crt_st == WR_REG)
  begin
    opr_abus_shift <= {{REG_DW{1'b0}},opr_abus_shift[REG_DW*REG_NUM-1:REG_DW]};
    opr_bbus_shift <= {{REG_DW{1'b0}},opr_bbus_shift[REG_DW*REG_NUM-1:REG_DW]}; 
  end
  else
  begin
    opr_abus_shift <= opr_abus_shift;
    opr_bbus_shift <= opr_bbus_shift;
  end
end

//data opr
generate
  for(i = 0; i < REG_NUM; i = i + 1)
  begin:u_opra
    always @(posedge clk) 
    begin
      if((crt_st == OPR_REG) && (pattern_rega_bus[(i+1)*REG_SEL_DW-1:i*REG_SEL_DW] > 'd0))
      begin
        case (pattern_opr_bus[(i+1)*OPR_DW-1:i*OPR_DW])
          'd0:
          begin
            if(pattern_mux[2-i])
            begin
              opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW];
            end
            else
            begin
              opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW];
            end
          end 
          'd1:
          begin
            if(pattern_mux[2-i])
            begin
              opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] + rd_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW];
            end
            else
            begin
              opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] + pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW];
            end
          end
          'd2:
          begin
            if(pattern_mux[2-i])
            begin
              opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] - rd_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW];
            end
            else
            begin
              opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] - pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW];
            end
          end
          'd3:
          begin
            opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] >> pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW];
          end
          'd4:
          begin
            opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW] << pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW];
          end
          'd5:
          begin
            opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW];
          end
          'd6:
          begin
            opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= ~rd_bram_data_b_bus[(i+1)*REG_DW-1:i*REG_DW];
          end
          default: 
          begin
            opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= opr_abus[(i+1)*REG_DW-1:i*REG_DW];
          end
        endcase
      end
      else
      begin
        opr_abus[(i+1)*REG_DW-1:i*REG_DW] <= opr_abus[(i+1)*REG_DW-1:i*REG_DW];
      end
    end
  end
endgenerate

generate
  for(i = 0; i < REG_NUM; i = i + 1)
  begin:u_oprb
    always @(posedge clk) 
    begin
      if((crt_st == OPR_REG) && (pattern_opr_bus[OPR_DW-1:0] == 'd5))
      begin
        opr_bbus[(i+1)*REG_DW-1:i*REG_DW] <= rd_bram_data_a_bus[(i+1)*REG_DW-1:i*REG_DW];
      end
      else
      begin
        opr_bbus[(i+1)*REG_DW-1:i*REG_DW] <= opr_bbus[(i+1)*REG_DW-1:i*REG_DW];
      end
    end
  end
endgenerate

always @(posedge clk) 
begin
  if((pattern_rega_bus[REG_SEL_DW-1:0] == 'd0) && (pattern_cmd == 'd1) && (crt_st == OPR_REG))
  begin
    opr_vld_bus[0] <= 'd1;
  end
  else if((crt_st == OPR_REG) && (pattern_rega_bus[REG_SEL_DW-1:0] > 'd0))
  begin
    opr_vld_bus[0] <= 'd1;
  end
  else
  begin
    opr_vld_bus[0] <= 'd0;
  end
end

always @(posedge clk) 
begin
  opr_vld_bus[1] <= ((crt_st == OPR_REG) && (pattern_rega_bus[2*REG_SEL_DW-1:REG_SEL_DW] > 'd0));
  opr_vld_bus[2] <= ((crt_st == OPR_REG) && (pattern_rega_bus[3*REG_SEL_DW-1:2*REG_SEL_DW] > 'd0));
end

//------------------------asn map-------------------------------
reg  [AS_DW-1:0]  as_array[0:AS_NUM-1]    ;
reg  [REG_DW-1:0] reg_array[0:REGA_NUM-1] ;
genvar z;
genvar j;

generate
  for(z = 0; z < REG_NUM0; z = z + 1)
  begin:asn_array_map 
    for(j = 0; j < AS_NUM/2 ; j = j + 1)
    begin:as_map
      always @(posedge clk) 
      begin
        if(cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] < 'd2)
        begin
          as_array[j+4][z] <= cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6];
        end
        else if((cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] > 'd1) && (cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] < 'd17))
        begin
          as_array[j+4][z] <= reg_array[cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] - 'd2][3];
        end
        else if((cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] > 'd16) && (cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] < 'd30))
        begin
          as_array[j+4][z] <= reg_array[cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] - 'd17][4];
        end
        else
        begin
          as_array[j+4][z] <= reg_array[cfg_alpg_ash_bus[(z*AS_MAP_DW)+(j*6) +: 6] - 'd30][5];  
        end
        
        if(cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] < 'd2)
        begin
          as_array[j][z] <= cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6];
        end
        else if((cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] > 'd1) && (cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] < 'd17))
        begin
          as_array[j][z] <= reg_array[cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] - 'd2][3];
        end
        else if((cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] > 'd16) && (cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] < 'd30))
        begin
          as_array[j][z] <= reg_array[cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] - 'd17][4];
        end
        else
        begin
          as_array[j][z] <= reg_array[cfg_alpg_asl_bus[(z*AS_MAP_DW)+(j*6) +: 6] - 'd30][5];  
        end
      end
    end
  end
endgenerate

//=====================================================
//-----------msta/psta gen-----------
//=====================================================
always @(posedge clk) 
begin
  if(pattern_reg_a0 == 'd6)
  begin
    dum_addr <= pat_func_data[REG_DW*3+REG_SEL_DW*3-1:REG_DW*3+REG_SEL_DW*2];
  end
  else if(pattern_reg_a1 == 'd6)
  begin
    dum_addr <= pat_func_data[REG_DW*3+REG_SEL_DW*2-1:REG_DW*3+REG_SEL_DW];
  end
  else if(pattern_reg_a2 == 'd6)
  begin
    dum_addr <= pat_func_data[REG_DW*3+REG_SEL_DW-1:REG_DW*3];
  end
  else if(((pattern_cmd >= 'd4) && (pattern_cmd <'d8)) || (pattern_cmd == 'd9))
  begin
    dum_addr <= dum_addr + 'd1;
  end
  else 
  begin
    dum_addr <= dum_addr;
  end
end

always @(posedge clk) 
begin
  if(pattern_reg_a0 == 'd7) 
  begin
    pm_addr <= pat_func_data[REG_DW*3+REG_SEL_DW*3-1:REG_DW*3+REG_SEL_DW*2];
  end
  else if(pattern_reg_a1 == 'd7)
  begin
    pm_addr <= pat_func_data[REG_DW*3+REG_SEL_DW*2-1:REG_DW*3+REG_SEL_DW];
  end
  else if(pattern_reg_a2 == 'd7)
  begin
    pm_addr <= pat_func_data[REG_DW*3+REG_SEL_DW-1:REG_DW*3];
  end
  else if(((pattern_cmd == 'd1) || (pattern_cmd == 'd6)) && ((pattern_reg_b0 == 'd74) || (pattern_reg_b1 == 'd74) || (pattern_reg_b2 == 'd74)))
  begin
    pm_addr <= pm_addr + 'd1;
  end
  else 
  begin
    pm_addr <= pm_addr;
  end
end

//=====================================================
//-----------dio gen-----------
//=====================================================
//reg[7:0] d_reg = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg[BYTE_DW-1:0] d_shiftreg = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [REG_NUM*BYTE_DW-1:0] d_reg_pre_bus = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg d_reg_pre_vld = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg d_reg_vld     = 'd0;

generate
  for(i = 0; i < REG_NUM; i = i + 1)
  begin:u_d_reg_pre  
    always @(posedge clk) 
    begin
      if(pattern_mux[2-i])
      begin
        if(pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW] < 'd74)
        begin
          d_reg_pre_bus[(i+1)*BYTE_DW-1:i*BYTE_DW] <= opr_abus[(i+1)*REG_DW-1:i*REG_DW];
        end
        else if(pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW] == 'd74)
        begin
          d_reg_pre_bus[(i+1)*BYTE_DW-1:i*BYTE_DW] <= pm_data;
        end
        else if(pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW] == 'd75)
        begin
          d_reg_pre_bus[(i+1)*BYTE_DW-1:i*BYTE_DW] <= ~pm_data;
        end
        else if(pattern_regb_bus[(i+1)*REG_DW-1:i*REG_DW] < 'd84)
        begin
          d_reg_pre_bus[(i+1)*BYTE_DW-1:i*BYTE_DW] <= as_array[pattern_regb_bus[i*REG_DW + REG_SEL_DW-1:i*REG_DW] - 'd76];
        end
        else
        begin
          d_reg_pre_bus[(i+1)*BYTE_DW-1:i*BYTE_DW] <= d_reg_pre_bus[(i+1)*BYTE_DW-1:i*BYTE_DW];
        end
      end
      else
      begin
        d_reg_pre_bus[(i+1)*BYTE_DW-1:i*BYTE_DW] <= opr_abus[(i+1)*REG_DW-1:i*REG_DW];
      end
    end
  end
endgenerate

always @(posedge clk) 
begin
  d_reg_pre_vld <= (opr_vld_bus != 'd0);
  d_reg_vld     <= d_reg_pre_vld       ;
end

always @(posedge clk) 
begin
  if(pattern_cmd == 'd1)
  begin
    if(pattern_rega_bus[REG_SEL_DW-1:0] =='d1)
    begin
      d_reg <= d_reg_pre_bus[BYTE_DW-1:0];
    end
    else if(pattern_rega_bus[2*REG_SEL_DW-1:REG_SEL_DW] =='d1)
    begin
      d_reg <= d_reg_pre_bus[2*BYTE_DW-1:BYTE_DW];
    end 
    else if(pattern_rega_bus[3*REG_SEL_DW-1:2*REG_SEL_DW] =='d1)
    begin
      d_reg <= d_reg_pre_bus[3*BYTE_DW-1:2*BYTE_DW];
    end
    else
    begin
      d_reg <= d_reg;
    end
  end  
  else if(pattern_cmd == 'd5)
  begin
    d_reg <= dum_data;
  end  
  else
  begin
    d_reg <= d_reg;
  end
end

reg  base_rate_clk_d1   = 'd0;
wire base_rate_clk_r         ;
reg  base_rate_clk_r_d1 = 'd0;

always @(posedge clk) 
begin
  base_rate_clk_d1   <= base_rate_clk  ;  
  base_rate_clk_r_d1 <= base_rate_clk_r;
end

assign base_rate_clk_r = base_rate_clk && (!base_rate_clk_d1);

reg [MUX_DW-1:0] pattern_mux_lock = 'd0;
reg [CMD_DW-1:0] pattern_cmd_lock = 'd0;

always @(posedge clk) 
begin
  if(base_rate_clk_r)
  begin
    pattern_mux_lock <= pattern_mux;
    pattern_cmd_lock <= pattern_cmd;
  end
  else
  begin
    pattern_mux_lock <= pattern_mux_lock;
    pattern_cmd_lock <= pattern_cmd_lock;
  end
end

always @(posedge clk) 
begin
  if(base_rate_clk_r_d1)
  begin
    if(((pattern_cmd_lock == 'd1) || (pattern_cmd_lock == 'd2)) && (pattern_mux_lock[MUX_DW-1] == 'd0)) 
    begin
      pattern_dio <= d_reg[0];  
    end
    else if(((pattern_cmd_lock == 'd1) || (pattern_cmd_lock == 'd2)) && (pattern_mux_lock[MUX_DW-1] == 'd1))
    begin
      pattern_dio <= d_shiftreg[0];
    end    
    else
    begin
      pattern_dio <= 'dz;
    end  
  end
  else 
  begin
    pattern_dio <= pattern_dio;
  end 
end

always @(posedge clk) 
begin
  if(base_rate_clk_r_d1 && (pattern_mux_lock[MUX_DW-1] == 'd1))  
  begin
    d_shiftreg <= {1'b0,d_shiftreg[7:1]};
  end
  else if(d_reg_vld)
  begin
    d_shiftreg <= d_reg;
  end  
  else
  begin
    d_shiftreg <= d_shiftreg;
  end  
end

//=====================================================
//-----------used dps in pattern runing-----------
//=====================================================
always @(posedge clk) 
begin
  alpg_dps_start <= (pattern_reg_a0 > 'd83) || (pattern_reg_a1 > 'd83) || (pattern_reg_a2 > 'd83);
end

endmodule
