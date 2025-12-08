`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-19
// Module Name           : alpg_cfg_core
// Project Name          : 
// Target Devices        : 
// Tool Versions         : Vivado 2020.2
// Description           : 1.gt_clk(125M) -> sys_clk(200M)
// 
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
// Additional Comments   :
// 
//////////////////////////////////////////////////////////////////////////////////

module alpg_cfg_core 
#(
    parameter CFG_AW            = 32             ,
    parameter CFG_DW            = 32             ,
    parameter DATA_NUM_DW       = 32             ,   
    parameter DDR_AW            = 29             ,   
    parameter DATA_TYPE_DW      = 2              ,
    parameter MEM_COPR_DW       = 2              ,
    parameter PC_DW             = 14             ,
    parameter FBC_SUM_DW        = PC_DW + 3      ,
    parameter DUT_NUM           = 16             ,
    parameter MOD_DW            = 2              , 
    parameter MSKTB_DW          = 8              ,
    parameter X_AW              = 15             ,
    parameter Y_AW              = 13             ,
    parameter Z_AW              = 11             ,
    parameter TP_DW             = 32             ,
    parameter MSTA_DW           = 23             ,
    parameter PSTA_DW           = 22             ,
    parameter AS_NUM            = 8              ,
    parameter FMT_NUM           = 9              ,
    parameter INDX_DW           = 33             ,
    parameter REG_NUM0          = 8              ,
    parameter REG_NUM1          = 16             ,
    parameter REG_NUM2          = 32             ,
    parameter REG_DW            = 32             ,
    parameter RATE_DW           = 22             ,
    parameter AS_DW             = 24             ,
    parameter AFM_DW            = 24             ,
    parameter AFM_NUM           = 6
) 
(
    input                               clk                      ,
    input                               rst                      ,
	  (*mark_debug="true"*)(*keep="true"*)input                               alpg_work_busy           ,
	  (*mark_debug="true"*)(*keep="true"*)input                               alpg_cfg_send_start      ,
    //===============gt lane0&1 data @gt_tx_outclk2 = 125M===============
    input                               gt_clk                   ,
    (*mark_debug="true"*)(*keep="true"*)input      [CFG_AW-1:0]             gtx_cfg_addr             ,
    (*mark_debug="true"*)(*keep="true"*)input      [CFG_DW-1:0]             gtx_cfg_data             ,
    (*mark_debug="true"*)(*keep="true"*)input                               gtx_cfg_vld              ,
	  output reg [CFG_AW-1:0]             gtp_cfg_addr       = 'd0 ,
	  output reg [CFG_DW-1:0]             gtp_cfg_data       = 'd0 ,
    //======================cfg&cmd @sys_clk = 200M======================
    //mem cmd
    (*mark_debug="true"*)(*keep="true"*)output reg                          alpg_wr_start       = 'd0 , 
    output reg                          alpg_rd_start      = 'd0 , 
    output reg                          alpg_mem_rst       = 'd0 ,
    output reg                          alpg_mem_copy      = 'd0 ,
    //cmd
    (*mark_debug="true"*)(*keep="true"*)output reg                          alpg_start          = 'd0 ,
    output reg                          alpg_restart       = 'd0 ,
    output reg                          alpg_stop          = 'd0 ,
    //cfg of mem copr
    output reg [DDR_AW-1:0]             cfg_alpg_base_addr = 'd0 ,
    output reg [DATA_NUM_DW-1:0]        cfg_alpg_data_num  = 'd0 ,   //max dum_data is 512MB*3
    (*mark_debug="true"*)(*keep="true"*)output reg [DATA_TYPE_DW-1:0]       cfg_alpg_data_type = 'd0 ,   //0:PM;1:DUM;2:pattern_func
    output reg [MEM_COPR_DW-1:0]        cfg_alpg_mem_copr  = 'd0 ,   //0:DUM2DUM;1:OR_COPY_DUM;2:DUM2PM;3:PM2DUM;
    output reg [DDR_AW-1:0]             cfg_alpg_addr_d0   = 'd0 ,   //ddr addr of dum0
    output reg [DDR_AW-1:0]             cfg_alpg_addr_d1   = 'd0 ,   //ddr addr of dum1
    output reg [DDR_AW-1:0]             cfg_alpg_addr_p    = 'd0 ,   //ddr addr of pm
    output reg [DATA_NUM_DW-1:0]        cfg_alpg_mem_size  = 'd0 ,   //ddr copr size
    //cfg of pattern reg
    output reg [PC_DW-1:0]              alpg_start_pc  = 'd0 ,   
    (*mark_debug="true"*)(*keep="true"*)output reg [MOD_DW-1:0]             cfg_alpg_run_mod   = 'd0 ,   //0:DUM;1:FBC;2:AFM
    (*mark_debug="true"*)(*keep="true"*)output reg [MOD_DW-1:0]             cfg_alpg_idx_mod   = 'd0 ,   //0:loop start of 0;1:loop start of 1
    (*mark_debug="true"*)(*keep="true"*)output reg [MSKTB_DW-1:0]           cfg_alpg_msktb     = 'd0 ,
    output reg [X_AW-1:0]               cfg_alpg_x         = 'd0 ,
    output reg [Y_AW-1:0]               cfg_alpg_y         = 'd0 ,
    output reg [Z_AW-1:0]               cfg_alpg_z         = 'd0 ,
    output reg [X_AW-1:0]               cfg_alpg_x_max     = 'd0 ,
    output reg [Y_AW-1:0]               cfg_alpg_y_max     = 'd0 ,
    output reg [Z_AW-1:0]               cfg_alpg_z_max     = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg [TP_DW-1:0]              cfg_alpg_tp        = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg [REG_NUM1-1:0]           cfg_alpg_cflg      = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg                          cfg_alpg_me        = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg [PSTA_DW-1:0]            cfg_alpg_psta      = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg [MSTA_DW-1:0]            cfg_alpg_msta      = 'd0 ,
    output reg [INDX_DW*REG_NUM1-1:0]   cfg_alpg_indx_bus  = 'd0 ,
    output reg [TP_DW*REG_NUM2-1:0]     cfg_alpg_tph_bus   = 'd0 ,
    output reg [TP_DW*REG_NUM1-1:0]     cfg_alpg_dreg_bus  = 'd0 ,
    output reg [MSTA_DW*REG_NUM0-1:0]   cfg_alpg_qreg_bus  = 'd0 ,
    output reg [PSTA_DW*REG_NUM0-1:0]   cfg_alpg_preg_bus  = 'd0 ,
    output reg [AS_DW*REG_NUM0-1:0]     cfg_alpg_ash_bus   = 'd0 ,
    output reg [AS_DW*REG_NUM0-1:0]     cfg_alpg_asl_bus   = 'd0 ,
    output reg [PC_DW-1:0]              cfg_alpg_bar       = 'd0 ,
    //cfg of timing
    output reg [FMT_NUM-1:0]            cfg_alpg_fmt_c0    = 'd0 ,
    output reg [FMT_NUM-1:0]            cfg_alpg_fmt_c1    = 'd0 ,
    output reg [FMT_NUM-1:0]            cfg_alpg_fmt_d0    = 'd0 ,
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_rate_bus  = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_aclk1_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_aclk2_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_aclk3_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_bclk1_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_bclk2_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_bclk3_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_cclk1_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_cclk2_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_cclk3_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_dre_r_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_dre_f_bus = 'd0 , 
    output reg [RATE_DW*REG_NUM0-1:0]   cfg_alpg_strb_bus  = 'd0 , 
    //cfg of AFM
    output reg [AFM_DW*AFM_NUM-1:0]     cfg_alpg_afm_bus   = 'd0 ,
    //pattern run result
    input      [PC_DW-1:0]              alpg_end_pc              , 
    input      [FBC_SUM_DW*DUT_NUM-1:0] alpg_fbc_dut_bus         , 
    input                               alpg_fsr                 ,
    input                               alpg_mflg                
);

//=====================REG ADDR===========================
localparam PLUSE_NUM    = 7   ;
localparam WR_REG_NUM   = 233 ;
localparam RD_REG_NUM   = 251 ;
localparam RD_START_AD  = 94  ;

localparam RD_DLY           = 2                   ;
localparam BUFFER_DEP       = 256                 ;
localparam BUFFER_CNT_DW    = $clog2(BUFFER_DEP)+1;
localparam BUFFER_DW        = CFG_AW + CFG_DW     ;
//ALPG
localparam ADDR_ALPG_WR_START = 'h0414;   // WO
localparam ADDR_ALPG_RD_START = 'h0418;   // WO
localparam ADDR_ALPG_BASE_ADD = 'h041c;   // WR
localparam ADDR_ALPG_DATA_NUM = 'h0420;   // WR
localparam ADDR_ALPG_DATA_TYPE= 'h0424;   // WR
localparam ADDR_ALPG_MEM_RST  = 'h0428;   // WO
localparam ADDR_ALPG_MEM_COPY = 'h042c;   // WO
localparam ADDR_ALPG_MEM_COPR = 'h0430;   // WR
localparam ADDR_ALPG_ADDR_D0  = 'h0434;   // WR
localparam ADDR_ALPG_ADDR_D1  = 'h0438;   // WR
localparam ADDR_ALPG_ADDR_P   = 'h043c;   // WR
localparam ADDR_ALPG_MEM_SIZE = 'h0440;   // WR
localparam ADDR_ALPG_START    = 'h0444;   // WO
localparam ADDR_ALPG_RESTART  = 'h0448;   // WO
localparam ADDR_ALPG_STOP     = 'h044c;   // WO
localparam ADDR_ALPG_START_PC = 'h0450;   // WR
localparam ADDR_ALPG_END_PC   = 'h0454;   // RO
localparam ADDR_ALPG_FBC0     = 'h0458;   // RO
localparam ADDR_ALPG_FBC1     = 'h045c;   // RO
localparam ADDR_ALPG_FBC2     = 'h0460;   // RO
localparam ADDR_ALPG_FBC3     = 'h0464;   // RO
localparam ADDR_ALPG_FBC4     = 'h0468;   // RO
localparam ADDR_ALPG_FBC5     = 'h046c;   // RO
localparam ADDR_ALPG_FBC6     = 'h0470;   // RO
localparam ADDR_ALPG_FBC7     = 'h0474;   // RO
localparam ADDR_ALPG_FBC8     = 'h0478;   // RO
localparam ADDR_ALPG_FBC9     = 'h047c;   // RO
localparam ADDR_ALPG_FBC10    = 'h0480;   // RO
localparam ADDR_ALPG_FBC11    = 'h0484;   // RO
localparam ADDR_ALPG_FBC12    = 'h0488;   // RO
localparam ADDR_ALPG_FBC13    = 'h048c;   // RO
localparam ADDR_ALPG_FBC14    = 'h0490;   // RO
localparam ADDR_ALPG_FBC15    = 'h0494;   // RO
localparam ADDR_ALPG_FSR      = 'h0498;   // RO
localparam ADDR_ALPG_MFLG     = 'h049c;   // RO
localparam ADDR_ALPG_RUN_MOD  = 'h04a0;   // WR
localparam ADDR_ALPG_IDX_MOD  = 'h04a4;   // WR
localparam ADDR_ALPG_MSKSTB   = 'h04a8;   // WR
localparam ADDR_ALPG_X        = 'h04ac;   // WR
localparam ADDR_ALPG_Y        = 'h04b0;   // WR
localparam ADDR_ALPG_Z        = 'h04b4;   // WR
localparam ADDR_ALPG_XMAX     = 'h04b8;   // WR
localparam ADDR_ALPG_YMAX     = 'h04bc;   // WR
localparam ADDR_ALPG_ZMAX     = 'h04c0;   // WR
localparam ADDR_ALPG_TP       = 'h04c4;   // WR
localparam ADDR_ALPG_CFLAG    = 'h04c8;   // WR
localparam ADDR_ALPG_ME       = 'h04cc;   // WR
localparam ADDR_ALPG_PSTA     = 'h04d0;   // WR
localparam ADDR_ALPG_MSTA     = 'h04d4;   // WR
//localparam ADDR_ALPG_ASH      = 'h04d8;   // WR
//localparam ADDR_ALPG_ASL      = 'h04dc;   // WR
localparam ADDR_ALPG_FMT_C0   = 'h04e0;   // WR
localparam ADDR_ALPG_FMT_C1   = 'h04e4;   // WR
localparam ADDR_ALPG_FMT_D0   = 'h04e8;   // WR
localparam ADDR_ALPG_INDX0    = 'h04ec;   // WR
localparam ADDR_ALPG_INDX1    = 'h04f0;   // WR
localparam ADDR_ALPG_INDX2    = 'h04f4;   // WR
localparam ADDR_ALPG_INDX3    = 'h04f8;   // WR
localparam ADDR_ALPG_INDX4    = 'h04fc;   // WR
localparam ADDR_ALPG_INDX5    = 'h0500;   // WR
localparam ADDR_ALPG_INDX6    = 'h0504;   // WR
localparam ADDR_ALPG_INDX7    = 'h0508;   // WR
localparam ADDR_ALPG_INDX8    = 'h050c;   // WR
localparam ADDR_ALPG_INDX9    = 'h0510;   // WR
localparam ADDR_ALPG_INDX10   = 'h0514;   // WR
localparam ADDR_ALPG_INDX11   = 'h0518;   // WR
localparam ADDR_ALPG_INDX12   = 'h051c;   // WR
localparam ADDR_ALPG_INDX13   = 'h0520;   // WR
localparam ADDR_ALPG_INDX14   = 'h0524;   // WR
localparam ADDR_ALPG_INDX15   = 'h0528;   // WR
localparam ADDR_ALPG_TPH0     = 'h052c;   // WR
localparam ADDR_ALPG_TPH1     = 'h0530;   // WR
localparam ADDR_ALPG_TPH2     = 'h0534;   // WR
localparam ADDR_ALPG_TPH3     = 'h0538;   // WR
localparam ADDR_ALPG_TPH4     = 'h053c;   // WR
localparam ADDR_ALPG_TPH5     = 'h0540;   // WR
localparam ADDR_ALPG_TPH6     = 'h0544;   // WR
localparam ADDR_ALPG_TPH7     = 'h0548;   // WR
localparam ADDR_ALPG_TPH8     = 'h054c;   // WR
localparam ADDR_ALPG_TPH9     = 'h0550;   // WR
localparam ADDR_ALPG_TPH10    = 'h0554;   // WR
localparam ADDR_ALPG_TPH11    = 'h0558;   // WR
localparam ADDR_ALPG_TPH12    = 'h055c;   // WR
localparam ADDR_ALPG_TPH13    = 'h0560;   // WR
localparam ADDR_ALPG_TPH14    = 'h0564;   // WR
localparam ADDR_ALPG_TPH15    = 'h0568;   // WR
localparam ADDR_ALPG_TPH16    = 'h056c;   // WR
localparam ADDR_ALPG_TPH17    = 'h0570;   // WR
localparam ADDR_ALPG_TPH18    = 'h0574;   // WR
localparam ADDR_ALPG_TPH19    = 'h0578;   // WR
localparam ADDR_ALPG_TPH20    = 'h057c;   // WR
localparam ADDR_ALPG_TPH21    = 'h0580;   // WR
localparam ADDR_ALPG_TPH22    = 'h0584;   // WR
localparam ADDR_ALPG_TPH23    = 'h0588;   // WR
localparam ADDR_ALPG_TPH24    = 'h058c;   // WR
localparam ADDR_ALPG_TPH25    = 'h0590;   // WR
localparam ADDR_ALPG_TPH26    = 'h0594;   // WR
localparam ADDR_ALPG_TPH27    = 'h0598;   // WR
localparam ADDR_ALPG_TPH28    = 'h059c;   // WR
localparam ADDR_ALPG_TPH29    = 'h05a0;   // WR
localparam ADDR_ALPG_TPH30    = 'h05a4;   // WR
localparam ADDR_ALPG_TPH31    = 'h05a8;   // WR
localparam ADDR_ALPG_D0       = 'h05ac;   // WR
localparam ADDR_ALPG_D1       = 'h05b0;   // WR
localparam ADDR_ALPG_D2       = 'h05b4;   // WR
localparam ADDR_ALPG_D3       = 'h05b8;   // WR
localparam ADDR_ALPG_D4       = 'h05bc;   // WR
localparam ADDR_ALPG_D5       = 'h05c0;   // WR
localparam ADDR_ALPG_D6       = 'h05c4;   // WR
localparam ADDR_ALPG_D7       = 'h05c8;   // WR
localparam ADDR_ALPG_D8       = 'h05cc;   // WR
localparam ADDR_ALPG_D9       = 'h05d0;   // WR
localparam ADDR_ALPG_D10      = 'h05d4;   // WR
localparam ADDR_ALPG_D11      = 'h05d8;   // WR
localparam ADDR_ALPG_D12      = 'h05dc;   // WR
localparam ADDR_ALPG_D13      = 'h05e0;   // WR
localparam ADDR_ALPG_D14      = 'h05e4;   // WR
localparam ADDR_ALPG_D15      = 'h05e8;   // WR
localparam ADDR_ALPG_Q0       = 'h05ec;   // WR
localparam ADDR_ALPG_Q1       = 'h05f0;   // WR
localparam ADDR_ALPG_Q2       = 'h05f4;   // WR
localparam ADDR_ALPG_Q3       = 'h05f8;   // WR
localparam ADDR_ALPG_Q4       = 'h05fc;   // WR
localparam ADDR_ALPG_Q5       = 'h0600;   // WR
localparam ADDR_ALPG_Q6       = 'h0604;   // WR
localparam ADDR_ALPG_Q7       = 'h0608;   // WR
localparam ADDR_ALPG_P0       = 'h060c;   // WR
localparam ADDR_ALPG_P1       = 'h0610;   // WR
localparam ADDR_ALPG_P2       = 'h0614;   // WR
localparam ADDR_ALPG_P3       = 'h0618;   // WR
localparam ADDR_ALPG_P4       = 'h061c;   // WR
localparam ADDR_ALPG_P5       = 'h0620;   // WR
localparam ADDR_ALPG_P6       = 'h0624;   // WR
localparam ADDR_ALPG_P7       = 'h0628;   // WR
localparam ADDR_ALPG_RATE0    = 'h062c;   // WR
localparam ADDR_ALPG_ACLK1_0  = 'h0630;   // WR
localparam ADDR_ALPG_ACLK2_0  = 'h0634;   // WR
localparam ADDR_ALPG_ACLK3_0  = 'h0638;   // WR
localparam ADDR_ALPG_BCLK1_0  = 'h063c;   // WR
localparam ADDR_ALPG_BCLK2_0  = 'h0640;   // WR
localparam ADDR_ALPG_BCLK3_0  = 'h0644;   // WR
localparam ADDR_ALPG_CCLK1_0  = 'h0648;   // WR
localparam ADDR_ALPG_CCLK2_0  = 'h064c;   // WR
localparam ADDR_ALPG_CCLK3_0  = 'h0650;   // WR
localparam ADDR_ALPG_DRE_R0   = 'h0654;   // WR
localparam ADDR_ALPG_DRE_F0   = 'h0658;   // WR
localparam ADDR_ALPG_STRB0    = 'h065c;   // WR
localparam ADDR_ALPG_RATE1    = 'h0660;   // WR
localparam ADDR_ALPG_ACLK1_1  = 'h0664;   // WR
localparam ADDR_ALPG_ACLK2_1  = 'h0668;   // WR
localparam ADDR_ALPG_ACLK3_1  = 'h066c;   // WR
localparam ADDR_ALPG_BCLK1_1  = 'h0670;   // WR
localparam ADDR_ALPG_BCLK2_1  = 'h0674;   // WR
localparam ADDR_ALPG_BCLK3_1  = 'h0678;   // WR
localparam ADDR_ALPG_CCLK1_1  = 'h067c;   // WR
localparam ADDR_ALPG_CCLK2_1  = 'h0680;   // WR
localparam ADDR_ALPG_CCLK3_1  = 'h0684;   // WR
localparam ADDR_ALPG_DRE_R1   = 'h0688;   // WR
localparam ADDR_ALPG_DRE_F1   = 'h068c;   // WR
localparam ADDR_ALPG_STRB1    = 'h0690;   // WR
localparam ADDR_ALPG_RATE2    = 'h0694;   // WR
localparam ADDR_ALPG_ACLK1_2  = 'h0698;   // WR
localparam ADDR_ALPG_ACLK2_2  = 'h069c;   // WR
localparam ADDR_ALPG_ACLK3_2  = 'h06a0;   // WR
localparam ADDR_ALPG_BCLK1_2  = 'h06a4;   // WR
localparam ADDR_ALPG_BCLK2_2  = 'h06a8;   // WR
localparam ADDR_ALPG_BCLK3_2  = 'h06ac;   // WR
localparam ADDR_ALPG_CCLK1_2  = 'h06b0;   // WR
localparam ADDR_ALPG_CCLK2_2  = 'h06b4;   // WR
localparam ADDR_ALPG_CCLK3_2  = 'h06b8;   // WR
localparam ADDR_ALPG_DRE_R2   = 'h06bc;   // WR
localparam ADDR_ALPG_DRE_F2   = 'h06c0;   // WR
localparam ADDR_ALPG_STRB2    = 'h06c4;   // WR
localparam ADDR_ALPG_RATE3    = 'h06c8;   // WR
localparam ADDR_ALPG_ACLK1_3  = 'h06cc;   // WR
localparam ADDR_ALPG_ACLK2_3  = 'h06d0;   // WR
localparam ADDR_ALPG_ACLK3_3  = 'h06d4;   // WR
localparam ADDR_ALPG_BCLK1_3  = 'h06d8;   // WR
localparam ADDR_ALPG_BCLK2_3  = 'h06dc;   // WR
localparam ADDR_ALPG_BCLK3_3  = 'h06e0;   // WR
localparam ADDR_ALPG_CCLK1_3  = 'h06e4;   // WR
localparam ADDR_ALPG_CCLK2_3  = 'h06e8;   // WR
localparam ADDR_ALPG_CCLK3_3  = 'h06ec;   // WR
localparam ADDR_ALPG_DRE_R3   = 'h06f0;   // WR
localparam ADDR_ALPG_DRE_F3   = 'h06f4;   // WR
localparam ADDR_ALPG_STRB3    = 'h06f8;   // WR
localparam ADDR_ALPG_RATE4    = 'h06fc;   // WR
localparam ADDR_ALPG_ACLK1_4  = 'h0700;   // WR
localparam ADDR_ALPG_ACLK2_4  = 'h0704;   // WR
localparam ADDR_ALPG_ACLK3_4  = 'h0708;   // WR
localparam ADDR_ALPG_BCLK1_4  = 'h070c;   // WR
localparam ADDR_ALPG_BCLK2_4  = 'h0710;   // WR
localparam ADDR_ALPG_BCLK3_4  = 'h0714;   // WR
localparam ADDR_ALPG_CCLK1_4  = 'h0718;   // WR
localparam ADDR_ALPG_CCLK2_4  = 'h071c;   // WR
localparam ADDR_ALPG_CCLK3_4  = 'h0720;   // WR
localparam ADDR_ALPG_DRE_R4   = 'h0724;   // WR
localparam ADDR_ALPG_DRE_F4   = 'h0728;   // WR
localparam ADDR_ALPG_STRB4    = 'h072c;   // WR
localparam ADDR_ALPG_RATE5    = 'h0730;   // WR
localparam ADDR_ALPG_ACLK1_5  = 'h0734;   // WR
localparam ADDR_ALPG_ACLK2_5  = 'h0738;   // WR
localparam ADDR_ALPG_ACLK3_5  = 'h073c;   // WR
localparam ADDR_ALPG_BCLK1_5  = 'h0740;   // WR
localparam ADDR_ALPG_BCLK2_5  = 'h0744;   // WR
localparam ADDR_ALPG_BCLK3_5  = 'h0748;   // WR
localparam ADDR_ALPG_CCLK1_5  = 'h074c;   // WR
localparam ADDR_ALPG_CCLK2_5  = 'h0750;   // WR
localparam ADDR_ALPG_CCLK3_5  = 'h0754;   // WR
localparam ADDR_ALPG_DRE_R5   = 'h0758;   // WR
localparam ADDR_ALPG_DRE_F5   = 'h075c;   // WR
localparam ADDR_ALPG_STRB5    = 'h0760;   // WR
localparam ADDR_ALPG_RATE6    = 'h0764;   // WR
localparam ADDR_ALPG_ACLK1_6  = 'h0768;   // WR
localparam ADDR_ALPG_ACLK2_6  = 'h076c;   // WR
localparam ADDR_ALPG_ACLK3_6  = 'h0770;   // WR
localparam ADDR_ALPG_BCLK1_6  = 'h0774;   // WR
localparam ADDR_ALPG_BCLK2_6  = 'h0778;   // WR
localparam ADDR_ALPG_BCLK3_6  = 'h077c;   // WR
localparam ADDR_ALPG_CCLK1_6  = 'h0780;   // WR
localparam ADDR_ALPG_CCLK2_6  = 'h0784;   // WR
localparam ADDR_ALPG_CCLK3_6  = 'h0788;   // WR
localparam ADDR_ALPG_DRE_R6   = 'h078c;   // WR
localparam ADDR_ALPG_DRE_F6   = 'h0790;   // WR
localparam ADDR_ALPG_STRB6    = 'h0794;   // WR
localparam ADDR_ALPG_RATE7    = 'h0798;   // WR
localparam ADDR_ALPG_ACLK1_7  = 'h079c;   // WR
localparam ADDR_ALPG_ACLK2_7  = 'h07a0;   // WR
localparam ADDR_ALPG_ACLK3_7  = 'h07a4;   // WR
localparam ADDR_ALPG_BCLK1_7  = 'h07a8;   // WR
localparam ADDR_ALPG_BCLK2_7  = 'h07ac;   // WR
localparam ADDR_ALPG_BCLK3_7  = 'h07b0;   // WR
localparam ADDR_ALPG_CCLK1_7  = 'h07b4;   // WR
localparam ADDR_ALPG_CCLK2_7  = 'h07b8;   // WR
localparam ADDR_ALPG_CCLK3_7  = 'h07bc;   // WR
localparam ADDR_ALPG_DRE_R7   = 'h07c0;   // WR
localparam ADDR_ALPG_DRE_F7   = 'h07c4;   // WR
localparam ADDR_ALPG_STRB7    = 'h07c8;   // WR
localparam ADDR_ALPG_AS0L     = 'h07cc;   // WR
localparam ADDR_ALPG_AS0H     = 'h07d0;   // WR
localparam ADDR_ALPG_AS1L     = 'h07d4;   // WR
localparam ADDR_ALPG_AS1H     = 'h07d8;   // WR
localparam ADDR_ALPG_AS2L     = 'h07dc;   // WR
localparam ADDR_ALPG_AS2H     = 'h07e0;   // WR
localparam ADDR_ALPG_AS3L     = 'h07e4;   // WR
localparam ADDR_ALPG_AS3H     = 'h07e8;   // WR
localparam ADDR_ALPG_AS4L     = 'h07ec;   // WR
localparam ADDR_ALPG_AS4H     = 'h07f0;   // WR
localparam ADDR_ALPG_AS5L     = 'h07f4;   // WR
localparam ADDR_ALPG_AS5H     = 'h07f8;   // WR
localparam ADDR_ALPG_AS6L     = 'h07fc;   // WR
localparam ADDR_ALPG_AS6H     = 'h0800;   // WR
localparam ADDR_ALPG_AS7L     = 'h0804;   // WR
localparam ADDR_ALPG_AS7H     = 'h0808;   // WR
localparam ADDR_ALPG_AFM0     = 'h080c;   // WR
localparam ADDR_ALPG_AFM1     = 'h0810;   // WR
localparam ADDR_ALPG_AFM2     = 'h0814;   // WR
localparam ADDR_ALPG_AFM3     = 'h0818;   // WR
localparam ADDR_ALPG_AFM4     = 'h081c;   // WR
localparam ADDR_ALPG_AFM5     = 'h0820;   // WR
localparam ADDR_ALPG_BAR      = 'h0824;   // WR

//=======================cfg rcv,cdc,gt_clk -> sys_clk(251 cfg regs)===========================
(*mark_debug="true"*)(*keep="true"*)reg                  rcv_buffer_rd_en       = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)wire [BUFFER_DW-1:0] rcv_buffer_rd_data           ;
(*mark_debug="true"*)(*keep="true"*)wire                 rcv_buffer_rd_data_vld       ;
(*mark_debug="true"*)(*keep="true"*)reg                  rcv_buffer_wr_en       = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg  [BUFFER_DW-1:0] rcv_buffer_wr_data     = 'd0 ; 
(*mark_debug="true"*)(*keep="true"*)wire                 gt_alpg_sys_busy  ;
(*mark_debug="true"*)(*keep="true"*)wire                 rcv_buffer_empty             ;
(*mark_debug="true"*)(*keep="true"*)wire                 rcv_buffer_full              ;

//wr cfg data at gt clk
always @(posedge gt_clk) 
begin
  if((!gt_alpg_sys_busy) && gtx_cfg_vld)
  begin
    if((gtx_cfg_addr <= ADDR_ALPG_START_PC) || (gtx_cfg_addr >= ADDR_ALPG_RUN_MOD))
    begin
      rcv_buffer_wr_en <= 'd1;
    end
    else
    begin
      rcv_buffer_wr_en <= 'd0;
    end
  end
  else 
  begin
    rcv_buffer_wr_en <= 'd0;
  end
end

always @(posedge gt_clk) 
begin
  rcv_buffer_wr_data <= {gtx_cfg_addr,gtx_cfg_data};
end

//rd cfg data at sys clk
always @(posedge clk) 
begin
  rcv_buffer_rd_en <= (!rcv_buffer_empty);
end

xpm_fifo_async #(
      .CDC_SYNC_STAGES    (2             ),           // DECIMAL
      .DOUT_RESET_VALUE   ("0"           ),           // String
      .ECC_MODE           ("no_ecc"      ),           // String
      .FIFO_MEMORY_TYPE   ("block"       ),           // String
      .FIFO_READ_LATENCY  (RD_DLY        ),           // DECIMAL
      .FIFO_WRITE_DEPTH   (BUFFER_DEP    ),           // DECIMAL
      .FULL_RESET_VALUE   (0             ),           // DECIMAL
      .PROG_EMPTY_THRESH  (10            ),           // DECIMAL
      .PROG_FULL_THRESH   (10            ),           // DECIMAL
      .RD_DATA_COUNT_WIDTH(BUFFER_CNT_DW ),           // DECIMAL
      .READ_DATA_WIDTH    (BUFFER_DW     ),           // DECIMAL
      .READ_MODE          ("std"         ),           // String
      .RELATED_CLOCKS     (0             ),           // DECIMAL
      .SIM_ASSERT_CHK     (0             ),           // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES   ("1707"        ),           // String
      .WAKEUP_TIME        (0             ),           // DECIMAL
      .WRITE_DATA_WIDTH   (BUFFER_DW     ),           // DECIMAL
      .WR_DATA_COUNT_WIDTH(BUFFER_CNT_DW )            // DECIMAL
   )
   cfg_rcv_buffer (
      .almost_empty (                            ),                     // 1-bit output
      .almost_full  (                            ),                     // 1-bit output
      .data_valid   (rcv_buffer_rd_data_vld      ),                     // 1-bit output
      .dbiterr      (                            ),                     // 1-bit output
      .dout         (rcv_buffer_rd_data          ),                     // READ_DATA_WIDTH-bit output
      .empty        (rcv_buffer_empty            ),                     // 1-bit output
      .full         (rcv_buffer_full             ),                     // 1-bit output
      .overflow     (                            ),                     // 1-bit output
      .prog_empty   (                            ),                     // 1-bit output
      .prog_full    (                            ),                     // 1-bit output
      .rd_data_count(                            ),                     // RD_DATA_COUNT_WIDTH-bit output
      .rd_rst_busy  (                            ),                     // 1-bit output
      .sbiterr      (                            ),                     // 1-bit output
      .underflow    (                            ),                     // 1-bit output
      .wr_ack       (                            ),                     // 1-bit output
      .wr_data_count(                            ),                     // WR_DATA_COUNT_WIDTH-bit output
      .wr_rst_busy  (                            ),                     // 1-bit output
      .din          (rcv_buffer_wr_data          ),                     // WRITE_DATA_WIDTH-bit input
      .injectdbiterr(1'b0                        ),                     // 1-bit input
      .injectsbiterr(1'b0                        ),                     // 1-bit input
      .rd_clk       (clk                         ),                     // 1-bit input
      .rd_en        (rcv_buffer_rd_en            ),                     // 1-bit input
      .rst          (rst                         ),                     // 1-bit input
      .sleep        (1'b0                        ),                     // 1-bit input
      .wr_clk       (gt_clk                      ),                     // 1-bit input
      .wr_en        (rcv_buffer_wr_en            )                      // 1-bit input
   );


xpm_cdc_single #(
	.DEST_SYNC_FF  (4),   // DECIMAL; range: 2-10
	.INIT_SYNC_FF  (0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
	.SIM_ASSERT_CHK(0),   // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.SRC_INPUT_REG (1)    // DECIMAL; 0=do not register input, 1=register input
 )
 xpm_cdc_alpg_work_busy (
	.dest_out (gt_alpg_sys_busy),     // 1-bit output: src_in synchronized to the destination clock domain. This output is registered.
	.dest_clk (gt_clk          ),     // 1-bit input: Clock signal for the destination clock domain.
	.src_clk  (clk             ),     // 1-bit input: optional; required when SRC_INPUT_REG = 1
	.src_in   (alpg_work_busy  )      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );

//=======================================cfg analyzing @sys_clk========================================
//wire [CFG_AW-1:0] sys_cfg_addr;
//wire [CFG_DW-1:0] sys_cfg_data;
//
//assign sys_cfg_addr = rcv_buffer_rd_data[BUFFER_DW-1:CFG_DW] ;
//assign sys_cfg_data = rcv_buffer_rd_data[CFG_DW-1:0]       ;

(*mark_debug="true"*)(*keep="true"*)reg [CFG_AW-1:0] sys_cfg_addr = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [CFG_DW-1:0] sys_cfg_data = 'd0;
reg sys_cfg_vld = 'd0;

always @(posedge clk) 
begin
  if(rcv_buffer_rd_data_vld)
  begin
    sys_cfg_addr <= rcv_buffer_rd_data[BUFFER_DW-1:CFG_DW];
    sys_cfg_data <= rcv_buffer_rd_data[CFG_DW-1:0]        ;
    sys_cfg_vld  <= 'd1;
  end
  else
  begin
    sys_cfg_addr <= sys_cfg_addr;
    sys_cfg_data <= sys_cfg_data;
    sys_cfg_vld  <= 'd0;
  end  
end

//cmd rcv
wire [PLUSE_NUM-1:0]         cfg_rcv_pluse               ;

assign cfg_rcv_pluse[0] = sys_cfg_vld && (sys_cfg_addr == ADDR_ALPG_WR_START );
assign cfg_rcv_pluse[1] = sys_cfg_vld && (sys_cfg_addr == ADDR_ALPG_RD_START );
assign cfg_rcv_pluse[2] = sys_cfg_vld && (sys_cfg_addr == ADDR_ALPG_MEM_RST  );
assign cfg_rcv_pluse[3] = sys_cfg_vld && (sys_cfg_addr == ADDR_ALPG_MEM_COPY );
assign cfg_rcv_pluse[4] = sys_cfg_vld && (sys_cfg_addr == ADDR_ALPG_START    );
assign cfg_rcv_pluse[5] = sys_cfg_vld && (sys_cfg_addr == ADDR_ALPG_RESTART  );
assign cfg_rcv_pluse[6] = sys_cfg_vld && (sys_cfg_addr == ADDR_ALPG_STOP     );

always @(posedge clk) 
begin
  alpg_wr_start <= cfg_rcv_pluse[0] && sys_cfg_data[0];
  alpg_rd_start <= cfg_rcv_pluse[1] && sys_cfg_data[0];
  alpg_mem_rst  <= cfg_rcv_pluse[2] && sys_cfg_data[0];
  alpg_mem_copy <= cfg_rcv_pluse[3] && sys_cfg_data[0];
  alpg_start    <= (!alpg_work_busy) && cfg_rcv_pluse[4] && sys_cfg_data[0];
  alpg_restart  <= (!alpg_work_busy) && cfg_rcv_pluse[5] && sys_cfg_data[0];
  alpg_stop     <= cfg_rcv_pluse[6] && sys_cfg_data[0];
end

//rcv cfg
always @(posedge clk) 
begin
//  if(rcv_buffer_rd_data_vld)  
//  begin
    case(sys_cfg_addr)
      ADDR_ALPG_BASE_ADD : cfg_alpg_base_addr <= sys_cfg_data[DDR_AW-1:0]                                                 ;
      ADDR_ALPG_DATA_NUM : cfg_alpg_data_num  <= sys_cfg_data[DATA_NUM_DW-1:0]                                            ;
      ADDR_ALPG_DATA_TYPE: cfg_alpg_data_type <= sys_cfg_data[DATA_TYPE_DW-1:0]                                           ;
      ADDR_ALPG_MEM_COPR : cfg_alpg_mem_copr  <= sys_cfg_data[MEM_COPR_DW-1:0]                                            ;
      ADDR_ALPG_ADDR_D0  : cfg_alpg_addr_d0   <= sys_cfg_data[DDR_AW-1:0]                                                 ;
      ADDR_ALPG_ADDR_D1  : cfg_alpg_addr_d1   <= sys_cfg_data[DDR_AW-1:0]                                                 ;
      ADDR_ALPG_ADDR_P   : cfg_alpg_addr_p    <= sys_cfg_data[DDR_AW-1:0]                                                 ;
      ADDR_ALPG_MEM_SIZE : cfg_alpg_mem_size  <= sys_cfg_data[DATA_NUM_DW-1:0]                                            ;
      ADDR_ALPG_START_PC : alpg_start_pc  <= sys_cfg_data[PC_DW-1:0]                                                  ;
      ADDR_ALPG_RUN_MOD  : cfg_alpg_run_mod   <= sys_cfg_data[MOD_DW-1:0]                                                 ;
      ADDR_ALPG_IDX_MOD  : cfg_alpg_idx_mod   <= sys_cfg_data[MOD_DW-1:0]                                                 ;
      ADDR_ALPG_MSKSTB   : cfg_alpg_msktb     <= sys_cfg_data[MSKTB_DW-1:0]                                               ;
      ADDR_ALPG_X        : cfg_alpg_x         <= sys_cfg_data[X_AW-1:0]                                                   ;
      ADDR_ALPG_Y        : cfg_alpg_y         <= sys_cfg_data[Y_AW-1:0]                                                   ;
      ADDR_ALPG_Z        : cfg_alpg_z         <= sys_cfg_data[Z_AW-1:0]                                                   ;
      ADDR_ALPG_XMAX     : cfg_alpg_x_max     <= sys_cfg_data[X_AW-1:0]                                                   ;
      ADDR_ALPG_YMAX     : cfg_alpg_y_max     <= sys_cfg_data[Y_AW-1:0]                                                   ;
      ADDR_ALPG_ZMAX     : cfg_alpg_z_max     <= sys_cfg_data[Z_AW-1:0]                                                   ;
      ADDR_ALPG_TP       : cfg_alpg_tp        <= sys_cfg_data[TP_DW-1:0]                                                  ;
      ADDR_ALPG_CFLAG    : cfg_alpg_cflg      <= sys_cfg_data[REG_NUM1-1:0]                                               ;
      ADDR_ALPG_ME       : cfg_alpg_me        <= sys_cfg_data[0]                                                          ;
      ADDR_ALPG_PSTA     : cfg_alpg_psta      <= sys_cfg_data[PSTA_DW-1:0]                                                ;
      ADDR_ALPG_MSTA     : cfg_alpg_msta      <= sys_cfg_data[MSTA_DW-1:0]                                                ;
      ADDR_ALPG_FMT_C0   : cfg_alpg_fmt_c0    <= sys_cfg_data[FMT_NUM-1:0]                                                ;
      ADDR_ALPG_FMT_C1   : cfg_alpg_fmt_c1    <= sys_cfg_data[FMT_NUM-1:0]                                                ;
      ADDR_ALPG_FMT_D0   : cfg_alpg_fmt_d0    <= sys_cfg_data[FMT_NUM-1:0]                                                ;
      ADDR_ALPG_INDX0    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-15)-1:INDX_DW*(REG_NUM1-16)]  <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-15)-1:INDX_DW*(REG_NUM1-16)]  <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX1    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-14)-1:INDX_DW*(REG_NUM1-15)]  <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-14)-1:INDX_DW*(REG_NUM1-15)]  <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX2    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-13)-1:INDX_DW*(REG_NUM1-14)]  <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-13)-1:INDX_DW*(REG_NUM1-14)]  <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX3    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-12)-1:INDX_DW*(REG_NUM1-13)]  <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-12)-1:INDX_DW*(REG_NUM1-13)]  <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX4    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-11)-1:INDX_DW*(REG_NUM1-12)]  <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-11)-1:INDX_DW*(REG_NUM1-12)]  <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX5    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-10)-1:INDX_DW*(REG_NUM1-11)]  <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-10)-1:INDX_DW*(REG_NUM1-11)]  <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX6    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-9)-1:INDX_DW*(REG_NUM1-10)]   <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-9)-1:INDX_DW*(REG_NUM1-10)]   <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX7    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-8)-1:INDX_DW*(REG_NUM1-9)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-8)-1:INDX_DW*(REG_NUM1-9)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX8    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-7)-1:INDX_DW*(REG_NUM1-8)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-7)-1:INDX_DW*(REG_NUM1-8)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX9    :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-6)-1:INDX_DW*(REG_NUM1-7)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-6)-1:INDX_DW*(REG_NUM1-7)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX10   :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-5)-1:INDX_DW*(REG_NUM1-6)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-5)-1:INDX_DW*(REG_NUM1-6)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX11   :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-4)-1:INDX_DW*(REG_NUM1-5)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-4)-1:INDX_DW*(REG_NUM1-5)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX12   :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-3)-1:INDX_DW*(REG_NUM1-4)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-3)-1:INDX_DW*(REG_NUM1-4)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX13   :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-2)-1:INDX_DW*(REG_NUM1-3)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-2)-1:INDX_DW*(REG_NUM1-3)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX14   :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-1)-1:INDX_DW*(REG_NUM1-2)]    <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*(REG_NUM1-1)-1:INDX_DW*(REG_NUM1-2)]    <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_INDX15   :
      begin
        if(cfg_alpg_idx_mod)
        begin
          cfg_alpg_indx_bus[INDX_DW*REG_NUM1-1:INDX_DW*(REG_NUM1-1)]        <= sys_cfg_data[CFG_DW-1:0] + 'd1;
        end
        else
        begin
          cfg_alpg_indx_bus[INDX_DW*REG_NUM1-1:INDX_DW*(REG_NUM1-1)]        <= sys_cfg_data[CFG_DW-1:0] + 'd2;        
        end  
      end  
      ADDR_ALPG_TPH0     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-31)-1:TP_DW*(REG_NUM2-32)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH1     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-30)-1:TP_DW*(REG_NUM2-31)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH2     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-29)-1:TP_DW*(REG_NUM2-30)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH3     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-28)-1:TP_DW*(REG_NUM2-29)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH4     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-27)-1:TP_DW*(REG_NUM2-28)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH5     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-26)-1:TP_DW*(REG_NUM2-27)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH6     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-25)-1:TP_DW*(REG_NUM2-26)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH7     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-24)-1:TP_DW*(REG_NUM2-25)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH8     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-23)-1:TP_DW*(REG_NUM2-24)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH9     : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-22)-1:TP_DW*(REG_NUM2-23)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH10    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-21)-1:TP_DW*(REG_NUM2-22)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH11    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-20)-1:TP_DW*(REG_NUM2-21)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH12    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-19)-1:TP_DW*(REG_NUM2-20)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH13    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-18)-1:TP_DW*(REG_NUM2-19)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH14    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-17)-1:TP_DW*(REG_NUM2-18)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH15    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-16)-1:TP_DW*(REG_NUM2-17)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH16    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-15)-1:TP_DW*(REG_NUM2-16)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH17    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-14)-1:TP_DW*(REG_NUM2-15)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH18    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-13)-1:TP_DW*(REG_NUM2-14)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH19    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-12)-1:TP_DW*(REG_NUM2-13)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH20    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-11)-1:TP_DW*(REG_NUM2-12)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH21    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-10)-1:TP_DW*(REG_NUM2-11)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH22    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-9)-1:TP_DW*(REG_NUM2-10)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH23    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-8)-1:TP_DW*(REG_NUM2-9)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH24    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-7)-1:TP_DW*(REG_NUM2-8)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH25    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-6)-1:TP_DW*(REG_NUM2-7)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH26    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-5)-1:TP_DW*(REG_NUM2-6)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH27    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-4)-1:TP_DW*(REG_NUM2-5)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH28    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-3)-1:TP_DW*(REG_NUM2-4)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH29    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-2)-1:TP_DW*(REG_NUM2-3)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH30    : cfg_alpg_tph_bus[TP_DW*(REG_NUM2-1)-1:TP_DW*(REG_NUM2-2)]         <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_TPH31    : cfg_alpg_tph_bus[TP_DW*REG_NUM2-1:TP_DW*(REG_NUM2-1)]             <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D0       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-15)-1:TP_DW*(REG_NUM1-16)]      <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D1       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-14)-1:TP_DW*(REG_NUM1-15)]      <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D2       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-13)-1:TP_DW*(REG_NUM1-14)]      <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D3       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-12)-1:TP_DW*(REG_NUM1-13)]      <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D4       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-11)-1:TP_DW*(REG_NUM1-12)]      <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D5       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-10)-1:TP_DW*(REG_NUM1-11)]      <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D6       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-9)-1:TP_DW*(REG_NUM1-10)]       <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D7       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-8)-1:TP_DW*(REG_NUM1-9)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D8       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-7)-1:TP_DW*(REG_NUM1-8)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D9       : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-6)-1:TP_DW*(REG_NUM1-7)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D10      : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-5)-1:TP_DW*(REG_NUM1-6)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D11      : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-4)-1:TP_DW*(REG_NUM1-5)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D12      : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-3)-1:TP_DW*(REG_NUM1-4)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D13      : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-2)-1:TP_DW*(REG_NUM1-3)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D14      : cfg_alpg_dreg_bus[TP_DW*(REG_NUM1-1)-1:TP_DW*(REG_NUM1-2)]        <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_D15      : cfg_alpg_dreg_bus[TP_DW*REG_NUM1-1:TP_DW*(REG_NUM1-1)]            <= sys_cfg_data[TP_DW-1:0]   ;
      ADDR_ALPG_Q0       : cfg_alpg_qreg_bus[MSTA_DW*(REG_NUM0-7)-1:MSTA_DW*(REG_NUM0-8)]    <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_Q1       : cfg_alpg_qreg_bus[MSTA_DW*(REG_NUM0-6)-1:MSTA_DW*(REG_NUM0-7)]    <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_Q2       : cfg_alpg_qreg_bus[MSTA_DW*(REG_NUM0-5)-1:MSTA_DW*(REG_NUM0-6)]    <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_Q3       : cfg_alpg_qreg_bus[MSTA_DW*(REG_NUM0-4)-1:MSTA_DW*(REG_NUM0-5)]    <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_Q4       : cfg_alpg_qreg_bus[MSTA_DW*(REG_NUM0-3)-1:MSTA_DW*(REG_NUM0-4)]    <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_Q5       : cfg_alpg_qreg_bus[MSTA_DW*(REG_NUM0-2)-1:MSTA_DW*(REG_NUM0-3)]    <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_Q6       : cfg_alpg_qreg_bus[MSTA_DW*(REG_NUM0-1)-1:MSTA_DW*(REG_NUM0-2)]    <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_Q7       : cfg_alpg_qreg_bus[MSTA_DW*REG_NUM0-1:MSTA_DW*(REG_NUM0-1)]        <= sys_cfg_data[MSTA_DW-1:0] ;
      ADDR_ALPG_P0       : cfg_alpg_preg_bus[PSTA_DW*(REG_NUM0-7)-1:PSTA_DW*(REG_NUM0-8)]    <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_P1       : cfg_alpg_preg_bus[PSTA_DW*(REG_NUM0-6)-1:PSTA_DW*(REG_NUM0-7)]    <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_P2       : cfg_alpg_preg_bus[PSTA_DW*(REG_NUM0-5)-1:PSTA_DW*(REG_NUM0-6)]    <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_P3       : cfg_alpg_preg_bus[PSTA_DW*(REG_NUM0-4)-1:PSTA_DW*(REG_NUM0-5)]    <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_P4       : cfg_alpg_preg_bus[PSTA_DW*(REG_NUM0-3)-1:PSTA_DW*(REG_NUM0-4)]    <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_P5       : cfg_alpg_preg_bus[PSTA_DW*(REG_NUM0-2)-1:PSTA_DW*(REG_NUM0-3)]    <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_P6       : cfg_alpg_preg_bus[PSTA_DW*(REG_NUM0-1)-1:PSTA_DW*(REG_NUM0-2)]    <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_P7       : cfg_alpg_preg_bus[PSTA_DW*REG_NUM0-1:PSTA_DW*(REG_NUM0-1)]        <= sys_cfg_data[PSTA_DW-1:0] ;
      ADDR_ALPG_RATE0    : cfg_alpg_rate_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_0  : cfg_alpg_aclk1_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_0  : cfg_alpg_aclk2_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_0  : cfg_alpg_aclk3_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_0  : cfg_alpg_bclk1_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_0  : cfg_alpg_bclk2_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_0  : cfg_alpg_bclk3_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_0  : cfg_alpg_cclk1_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_0  : cfg_alpg_cclk2_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_0  : cfg_alpg_cclk3_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R0   : cfg_alpg_dre_r_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F0   : cfg_alpg_dre_f_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB0    : cfg_alpg_strb_bus[RATE_DW*(REG_NUM0-7)-1:RATE_DW*(REG_NUM0-8)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_RATE1    : cfg_alpg_rate_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_1  : cfg_alpg_aclk1_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_1  : cfg_alpg_aclk2_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_1  : cfg_alpg_aclk3_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_1  : cfg_alpg_bclk1_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_1  : cfg_alpg_bclk2_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_1  : cfg_alpg_bclk3_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_1  : cfg_alpg_cclk1_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_1  : cfg_alpg_cclk2_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_1  : cfg_alpg_cclk3_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R1   : cfg_alpg_dre_r_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F1   : cfg_alpg_dre_f_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB1    : cfg_alpg_strb_bus[RATE_DW*(REG_NUM0-6)-1:RATE_DW*(REG_NUM0-7)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_RATE2    : cfg_alpg_rate_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_2  : cfg_alpg_aclk1_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_2  : cfg_alpg_aclk2_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_2  : cfg_alpg_aclk3_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_2  : cfg_alpg_bclk1_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_2  : cfg_alpg_bclk2_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_2  : cfg_alpg_bclk3_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_2  : cfg_alpg_cclk1_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_2  : cfg_alpg_cclk2_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_2  : cfg_alpg_cclk3_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R2   : cfg_alpg_dre_r_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F2   : cfg_alpg_dre_f_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB2    : cfg_alpg_strb_bus[RATE_DW*(REG_NUM0-5)-1:RATE_DW*(REG_NUM0-6)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_RATE3    : cfg_alpg_rate_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_3  : cfg_alpg_aclk1_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_3  : cfg_alpg_aclk2_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_3  : cfg_alpg_aclk3_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_3  : cfg_alpg_bclk1_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_3  : cfg_alpg_bclk2_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_3  : cfg_alpg_bclk3_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_3  : cfg_alpg_cclk1_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_3  : cfg_alpg_cclk2_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_3  : cfg_alpg_cclk3_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R3   : cfg_alpg_dre_r_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F3   : cfg_alpg_dre_f_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB3    : cfg_alpg_strb_bus[RATE_DW*(REG_NUM0-4)-1:RATE_DW*(REG_NUM0-5)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_RATE4    : cfg_alpg_rate_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_4  : cfg_alpg_aclk1_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_4  : cfg_alpg_aclk2_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_4  : cfg_alpg_aclk3_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_4  : cfg_alpg_bclk1_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_4  : cfg_alpg_bclk2_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_4  : cfg_alpg_bclk3_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_4  : cfg_alpg_cclk1_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_4  : cfg_alpg_cclk2_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_4  : cfg_alpg_cclk3_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R4   : cfg_alpg_dre_r_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F4   : cfg_alpg_dre_f_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB4    : cfg_alpg_strb_bus[RATE_DW*(REG_NUM0-3)-1:RATE_DW*(REG_NUM0-4)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_RATE5    : cfg_alpg_rate_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_5  : cfg_alpg_aclk1_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_5  : cfg_alpg_aclk2_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_5  : cfg_alpg_aclk3_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_5  : cfg_alpg_bclk1_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_5  : cfg_alpg_bclk2_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_5  : cfg_alpg_bclk3_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_5  : cfg_alpg_cclk1_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_5  : cfg_alpg_cclk2_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_5  : cfg_alpg_cclk3_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R5   : cfg_alpg_dre_r_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F5   : cfg_alpg_dre_f_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB5    : cfg_alpg_strb_bus[RATE_DW*(REG_NUM0-2)-1:RATE_DW*(REG_NUM0-3)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_RATE6    : cfg_alpg_rate_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_6  : cfg_alpg_aclk1_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_6  : cfg_alpg_aclk2_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_6  : cfg_alpg_aclk3_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_6  : cfg_alpg_bclk1_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_6  : cfg_alpg_bclk2_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_6  : cfg_alpg_bclk3_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_6  : cfg_alpg_cclk1_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_6  : cfg_alpg_cclk2_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_6  : cfg_alpg_cclk3_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R6   : cfg_alpg_dre_r_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F6   : cfg_alpg_dre_f_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]   <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB6    : cfg_alpg_strb_bus[RATE_DW*(REG_NUM0-1)-1:RATE_DW*(REG_NUM0-2)]    <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_RATE7    : cfg_alpg_rate_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]        <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK1_7  : cfg_alpg_aclk1_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK2_7  : cfg_alpg_aclk2_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_ACLK3_7  : cfg_alpg_aclk3_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK1_7  : cfg_alpg_bclk1_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK2_7  : cfg_alpg_bclk2_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_BCLK3_7  : cfg_alpg_bclk3_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK1_7  : cfg_alpg_cclk1_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK2_7  : cfg_alpg_cclk2_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_CCLK3_7  : cfg_alpg_cclk3_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_R7   : cfg_alpg_dre_r_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_DRE_F7   : cfg_alpg_dre_f_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]       <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_STRB7    : cfg_alpg_strb_bus[RATE_DW*REG_NUM0-1:RATE_DW*(REG_NUM0-1)]        <= sys_cfg_data[RATE_DW-1:0] ;
      ADDR_ALPG_AS0L     : cfg_alpg_asl_bus[AS_DW*(REG_NUM0-7)-1:AS_DW*(REG_NUM0-8)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS0H     : cfg_alpg_ash_bus[AS_DW*(REG_NUM0-7)-1:AS_DW*(REG_NUM0-8)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS1L     : cfg_alpg_asl_bus[AS_DW*(REG_NUM0-6)-1:AS_DW*(REG_NUM0-7)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS1H     : cfg_alpg_ash_bus[AS_DW*(REG_NUM0-6)-1:AS_DW*(REG_NUM0-7)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS2L     : cfg_alpg_asl_bus[AS_DW*(REG_NUM0-5)-1:AS_DW*(REG_NUM0-6)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS2H     : cfg_alpg_ash_bus[AS_DW*(REG_NUM0-5)-1:AS_DW*(REG_NUM0-6)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS3L     : cfg_alpg_asl_bus[AS_DW*(REG_NUM0-4)-1:AS_DW*(REG_NUM0-5)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS3H     : cfg_alpg_ash_bus[AS_DW*(REG_NUM0-4)-1:AS_DW*(REG_NUM0-5)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS4L     : cfg_alpg_asl_bus[AS_DW*(REG_NUM0-3)-1:AS_DW*(REG_NUM0-4)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS4H     : cfg_alpg_ash_bus[AS_DW*(REG_NUM0-3)-1:AS_DW*(REG_NUM0-4)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS5L     : cfg_alpg_asl_bus[AS_DW*(REG_NUM0-2)-1:AS_DW*(REG_NUM0-3)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS5H     : cfg_alpg_ash_bus[AS_DW*(REG_NUM0-2)-1:AS_DW*(REG_NUM0-3)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS6L     : cfg_alpg_asl_bus[AS_DW*(REG_NUM0-1)-1:AS_DW*(REG_NUM0-2)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS6H     : cfg_alpg_ash_bus[AS_DW*(REG_NUM0-1)-1:AS_DW*(REG_NUM0-2)]         <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS7L     : cfg_alpg_asl_bus[AS_DW*REG_NUM0-1:AS_DW*(REG_NUM0-1)]             <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AS7H     : cfg_alpg_ash_bus[AS_DW*REG_NUM0-1:AS_DW*(REG_NUM0-1)]             <= sys_cfg_data[AS_DW-1:0]   ;
      ADDR_ALPG_AFM0     : cfg_alpg_afm_bus[AFM_DW*(AFM_NUM-5)-1:AFM_DW*(AFM_NUM-6)]         <= sys_cfg_data[AFM_DW-1:0]  ;
      ADDR_ALPG_AFM1     : cfg_alpg_afm_bus[AFM_DW*(AFM_NUM-4)-1:AFM_DW*(AFM_NUM-5)]         <= sys_cfg_data[AFM_DW-1:0]  ;
      ADDR_ALPG_AFM2     : cfg_alpg_afm_bus[AFM_DW*(AFM_NUM-3)-1:AFM_DW*(AFM_NUM-4)]         <= sys_cfg_data[AFM_DW-1:0]  ;
      ADDR_ALPG_AFM3     : cfg_alpg_afm_bus[AFM_DW*(AFM_NUM-2)-1:AFM_DW*(AFM_NUM-3)]         <= sys_cfg_data[AFM_DW-1:0]  ;
      ADDR_ALPG_AFM4     : cfg_alpg_afm_bus[AFM_DW*(AFM_NUM-1)-1:AFM_DW*(AFM_NUM-2)]         <= sys_cfg_data[AFM_DW-1:0]  ;
      ADDR_ALPG_AFM5     : cfg_alpg_afm_bus[AFM_DW*AFM_NUM-1:AFM_DW*(AFM_NUM-1)]             <= sys_cfg_data[AFM_DW-1:0]  ;
      ADDR_ALPG_BAR      : cfg_alpg_bar                                                      <= sys_cfg_data[PC_DW-1:0]   ;
      default:
      begin
        cfg_alpg_base_addr <= cfg_alpg_base_addr ;
        cfg_alpg_data_num  <= cfg_alpg_data_num  ;
        cfg_alpg_data_type <= cfg_alpg_data_type ;
        cfg_alpg_mem_copr  <= cfg_alpg_mem_copr  ;
        cfg_alpg_addr_d0   <= cfg_alpg_addr_d0   ;
        cfg_alpg_addr_d1   <= cfg_alpg_addr_d1   ;
        cfg_alpg_addr_p    <= cfg_alpg_addr_p    ;
        cfg_alpg_mem_size  <= cfg_alpg_mem_size  ;
        alpg_start_pc  <= alpg_start_pc  ;
        cfg_alpg_run_mod   <= cfg_alpg_run_mod   ;
        cfg_alpg_idx_mod   <= cfg_alpg_idx_mod   ;
        cfg_alpg_msktb     <= cfg_alpg_msktb     ;
        cfg_alpg_x         <= cfg_alpg_x         ;
        cfg_alpg_y         <= cfg_alpg_y         ;
        cfg_alpg_z         <= cfg_alpg_z         ;
        cfg_alpg_x_max     <= cfg_alpg_x_max     ;
        cfg_alpg_y_max     <= cfg_alpg_y_max     ;
        cfg_alpg_z_max     <= cfg_alpg_z_max     ;
        cfg_alpg_tp        <= cfg_alpg_tp        ;
        cfg_alpg_cflg      <= cfg_alpg_cflg      ;
        cfg_alpg_me        <= cfg_alpg_me        ;
        cfg_alpg_psta      <= cfg_alpg_psta      ;
        cfg_alpg_msta      <= cfg_alpg_msta      ;
        cfg_alpg_indx_bus  <= cfg_alpg_indx_bus  ;
        cfg_alpg_tph_bus   <= cfg_alpg_tph_bus   ;
        cfg_alpg_dreg_bus  <= cfg_alpg_dreg_bus  ;
        cfg_alpg_qreg_bus  <= cfg_alpg_qreg_bus  ;
        cfg_alpg_preg_bus  <= cfg_alpg_preg_bus  ;
        cfg_alpg_ash_bus   <= cfg_alpg_ash_bus   ;
        cfg_alpg_asl_bus   <= cfg_alpg_asl_bus   ;
        cfg_alpg_bar       <= cfg_alpg_bar       ;
        cfg_alpg_fmt_c0    <= cfg_alpg_fmt_c0    ;
        cfg_alpg_fmt_c1    <= cfg_alpg_fmt_c1    ;
        cfg_alpg_fmt_d0    <= cfg_alpg_fmt_d0    ;
        cfg_alpg_rate_bus  <= cfg_alpg_rate_bus  ;
        cfg_alpg_aclk1_bus <= cfg_alpg_aclk1_bus ;
        cfg_alpg_aclk2_bus <= cfg_alpg_aclk2_bus ;
        cfg_alpg_aclk3_bus <= cfg_alpg_aclk3_bus ;
        cfg_alpg_bclk1_bus <= cfg_alpg_bclk1_bus ;
        cfg_alpg_bclk2_bus <= cfg_alpg_bclk2_bus ;
        cfg_alpg_bclk3_bus <= cfg_alpg_bclk3_bus ;
        cfg_alpg_cclk1_bus <= cfg_alpg_cclk1_bus ;
        cfg_alpg_cclk2_bus <= cfg_alpg_cclk2_bus ;
        cfg_alpg_cclk3_bus <= cfg_alpg_cclk3_bus ;
        cfg_alpg_dre_r_bus <= cfg_alpg_dre_r_bus ;
        cfg_alpg_dre_f_bus <= cfg_alpg_dre_f_bus ;
        cfg_alpg_strb_bus  <= cfg_alpg_strb_bus  ;
        cfg_alpg_afm_bus   <= cfg_alpg_afm_bus   ;
      end 
    endcase  
  end
  //else
  //begin
  //      cfg_alpg_base_addr <= cfg_alpg_base_addr ;
  //      cfg_alpg_data_num  <= cfg_alpg_data_num  ;
  //      cfg_alpg_data_type <= cfg_alpg_data_type ;
  //      cfg_alpg_mem_copr  <= cfg_alpg_mem_copr  ;
  //      cfg_alpg_addr_d0   <= cfg_alpg_addr_d0   ;
  //      cfg_alpg_addr_d1   <= cfg_alpg_addr_d1   ;
  //      cfg_alpg_addr_p    <= cfg_alpg_addr_p    ;
  //      cfg_alpg_mem_size  <= cfg_alpg_mem_size  ;
  //      alpg_start_pc  <= alpg_start_pc  ;
  //      cfg_alpg_run_mod   <= cfg_alpg_run_mod   ;
  //      cfg_alpg_idx_mod   <= cfg_alpg_idx_mod   ;
  //      cfg_alpg_msktb     <= cfg_alpg_msktb     ;
  //      cfg_alpg_x         <= cfg_alpg_x         ;
  //      cfg_alpg_y         <= cfg_alpg_y         ;
  //      cfg_alpg_z         <= cfg_alpg_z         ;
  //      cfg_alpg_x_max     <= cfg_alpg_x_max     ;
  //      cfg_alpg_y_max     <= cfg_alpg_y_max     ;
  //      cfg_alpg_z_max     <= cfg_alpg_z_max     ;
  //      cfg_alpg_tp        <= cfg_alpg_tp        ;
  //      cfg_alpg_cflg      <= cfg_alpg_cflg      ;
  //      cfg_alpg_me        <= cfg_alpg_me        ;
  //      cfg_alpg_psta      <= cfg_alpg_psta      ;
  //      cfg_alpg_msta      <= cfg_alpg_msta      ;
  //      cfg_alpg_indx_bus  <= cfg_alpg_indx_bus  ;
  //      cfg_alpg_tph_bus   <= cfg_alpg_tph_bus   ;
  //      cfg_alpg_dreg_bus  <= cfg_alpg_dreg_bus  ;
  //      cfg_alpg_qreg_bus  <= cfg_alpg_qreg_bus  ;
  //      cfg_alpg_preg_bus  <= cfg_alpg_preg_bus  ;
  //      cfg_alpg_ash_bus   <= cfg_alpg_ash_bus   ;
  //      cfg_alpg_asl_bus   <= cfg_alpg_asl_bus   ;
  //      cfg_alpg_bar       <= cfg_alpg_bar       ;
  //      cfg_alpg_fmt_c0    <= cfg_alpg_fmt_c0    ;
  //      cfg_alpg_fmt_c1    <= cfg_alpg_fmt_c1    ;
  //      cfg_alpg_fmt_d0    <= cfg_alpg_fmt_d0    ;
  //      cfg_alpg_rate_bus  <= cfg_alpg_rate_bus  ;
  //      cfg_alpg_aclk1_bus <= cfg_alpg_aclk1_bus ;
  //      cfg_alpg_aclk2_bus <= cfg_alpg_aclk2_bus ;
  //      cfg_alpg_aclk3_bus <= cfg_alpg_aclk3_bus ;
  //      cfg_alpg_bclk1_bus <= cfg_alpg_bclk1_bus ;
  //      cfg_alpg_bclk2_bus <= cfg_alpg_bclk2_bus ;
  //      cfg_alpg_bclk3_bus <= cfg_alpg_bclk3_bus ;
  //      cfg_alpg_cclk1_bus <= cfg_alpg_cclk1_bus ;
  //      cfg_alpg_cclk2_bus <= cfg_alpg_cclk2_bus ;
  //      cfg_alpg_cclk3_bus <= cfg_alpg_cclk3_bus ;
  //      cfg_alpg_dre_r_bus <= cfg_alpg_dre_r_bus ;
  //      cfg_alpg_dre_f_bus <= cfg_alpg_dre_f_bus ;
  //      cfg_alpg_strb_bus  <= cfg_alpg_strb_bus  ;
  //      cfg_alpg_afm_bus   <= cfg_alpg_afm_bus   ;
  //end  
//end

//=======================================cfg send @sys_clk========================================
//always @(posedge clk) 
//begin
//  if(gt_alpg_sys_busy && rcv_rd_data_vld)
//  begin
//	if(rcv_rd_addr < WR_REG_NUM)
//	begin
//	  gtp_cfg_addr <= rd_data[BRAM_DW-1:CFG_DW] ;
//	end
//	else
//    begin
//	  gtp_cfg_addr <= ADDR_ALPG_END_PC + 'h4;
//	end		
//  end
//  else
//  begin
//	gtp_cfg_addr <= ADDR_ALPG_BASE_ADD;
//  end	
//end
//
//reg [FBC_SUM_DW*DUT_NUM-1:0] alpg_fbc_dut_bus_shift = 'd0;
//
//always @(posedge clk) 
//begin
//  if(gt_alpg_sys_busy && rd_data_vld)
//  begin
//	if(rd_addr < WR_REG_NUM)
//	begin
//	  gtp_cfg_data <= rd_data[CFG_DW-1:0]       ;
//	end
//	else if(rd_addr == WR_REG_NUM)
//    begin
//	  gtp_cfg_data <= alpg_end_pc;
//	end	
//	else if(rd_addr < ADDR_ALPG_FSR)	
//	begin
//	  gtp_cfg_data <= alpg_fbc_dut_bus_shift[FBC_SUM_DW-1:0];
//	end	
//	else if(rd_addr == ADDR_ALPG_FSR)
//	begin
//	  gtp_cfg_data <= alpg_fsr;
//	end
//	else
//	begin
//	  gtp_cfg_data <= alpg_mflg;
//	end
//  end
//  else
//  begin
//    gtp_cfg_data <= 'hbfbfbfbf;
//  end	
//end
//
//always @(posedge clk) 
//begin
//  if((rd_addr > WR_REG_NUM) && (rd_addr < ADDR_ALPG_FSR))
//  begin
//	alpg_fbc_dut_bus_shift <= {{(FBC_SUM_DW){1'b0}},alpg_fbc_dut_bus_shift[FBC_SUM_DW*DUT_NUM-1:FBC_SUM_DW]};
//  end	
//  else
//  begin
//	alpg_fbc_dut_bus_shift <= alpg_fbc_dut_bus;
//  end	
//end

endmodule                                                                  

