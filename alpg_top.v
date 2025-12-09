`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-09-15
// Module Name           : alpg_top
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
module alpg_top
#(
     localparam GT_LANE    = 4 ,
     localparam CFG_NUM_DW = 9
) 
(
    input                   fpga_clk_p     ,   
    input                   fpga_clk_n     ,
    //GT         
    input                   gtp_ref_clkp   ,
    input                   gtp_ref_clkn   ,
    input  [GT_LANE-1:0]    gtp_rx_datap   ,
    input  [GT_LANE-1:0]    gtp_rx_datan   ,
    output [GT_LANE-1:0]    gtp_tx_datap   ,
    output [GT_LANE-1:0]    gtp_tx_datan   ,
    //gpio  
    (*mark_debug="true"*)(*keep="true"*)input                   tx_pck_suspend ,
    (*mark_debug="true"*)(*keep="true"*)output                  rx_pck_suspend ,
    (*mark_debug="true"*)(*keep="true"*)output                  gtp_rst_done   ,
    (*mark_debug="true"*)(*keep="true"*)input                   gtx_rst_done   ,
    input  [CFG_NUM_DW-1:0] cfg_num_rx     ,
    output                  alpg_rdy       ,
    //ddr
    (*mark_debug="true"*)(*keep="true"*)output wire [14:0]                  ddr3_addr           ,  // output [14:0]		ddr3_addr
    output wire [2:0]                   ddr3_ba             ,  // output [2:0]		ddr3_ba
    output wire                         ddr3_cas_n          ,  // output			ddr3_cas_n
    output wire                         ddr3_ck_n           ,  // output [0:0]		ddr3_ck_n
    output wire                         ddr3_ck_p           ,  // output [0:0]		ddr3_ck_p
    output wire                         ddr3_cke            ,  // output [0:0]		ddr3_cke
    output wire                         ddr3_ras_n          ,  // output			ddr3_ras_n
    output wire                         ddr3_reset_n        ,  // output			ddr3_reset_n
    output wire                         ddr3_we_n           ,  // output			ddr3_we_n
    (*mark_debug="true"*)(*keep="true"*)inout       [31:0]                  ddr3_dq             ,  // inout [31:0]		ddr3_dq
    inout       [3:0]                   ddr3_dqs_n          ,  // inout [3:0]		ddr3_dqs_n
    inout       [3:0]                   ddr3_dqs_p          ,  // inout [3:0]		ddr3_dqs_p
    (*mark_debug="true"*)(*keep="true"*)output wire                         ddr3_cs_n           ,  // output [0:0]		ddr3_cs_n
    output wire [3:0]                   ddr3_dm             ,  // output [3:0]		ddr3_dm
    output wire                         ddr3_odt              // output [0:0]		ddr3_odt
);
    
//assign gpio_test = {50{1'b0}};

assign rx_pck_suspend = 'd0;
assign alpg_rdy       = 'd0;

localparam  DDR_AW         = 32   ;
localparam  DDR_DW         = 32   ;
localparam  DATA_WIDTH     = 256  ; 
localparam  TIMING_DW      = 22   ;

//Ports
wire                sys_clk           ;
wire                sys_rst           ;
wire                alpg_start        ;
wire                alpg_done         ;
wire                pat_data_parse_vld;
wire[TIMING_DW-1:0] pattern_data_rate ;
wire[TIMING_DW-1:0] pattern_a_clk_drv0;
wire[TIMING_DW-1:0] pattern_b_clk_drv0;
wire[TIMING_DW-1:0] pattern_c_clk_drv0;
wire[TIMING_DW-1:0] pattern_a_clk_drv1;
wire[TIMING_DW-1:0] pattern_b_clk_drv1;
wire[TIMING_DW-1:0] pattern_c_clk_drv1;
wire[TIMING_DW-1:0] pattern_a_clk_io  ;
wire[TIMING_DW-1:0] pattern_b_clk_io  ;
wire[TIMING_DW-1:0] pattern_c_clk_io  ;
wire[TIMING_DW-1:0] pattern_drv_r     ;
wire[TIMING_DW-1:0] pattern_drv_f     ;
wire[TIMING_DW-1:0] pattern_strb      ;
wire                base_rate_clk     ;
wire                strb_pluse        ;
wire                pat_a_clk_d0      ;
wire                pat_b_clk_d0      ;
wire                pat_c_clk_d0      ;
wire                pat_a_clk_d1      ;
wire                pat_b_clk_d1      ;
wire                pat_c_clk_d1      ;
wire                pat_a_clk_io      ;
wire                pat_b_clk_io      ;
wire                pat_c_clk_io      ;
wire                pat_drv_r         ;
wire                pat_drv_f         ;
wire                fpga_clk          ;
wire                mig_ref_clk       ;
wire                gt_sys_clk        ;

//(*mark_debug = "true"*)(*keep = "true"*)reg [49:0] test_gpio_d1 = 'd0;

//always @(posedge sys_clk)
//begin
//  test_gpio_d1 <= gpio_test;
//end

assign alpg_done = 'd0;

alpg_clk_core # (
  .TIMING_DW(TIMING_DW)
)
alpg_clk_core_inst (
  .fpga_clkn         (fpga_clk_n        ),
  .fpga_clkp         (fpga_clk_p        ),
  .sys_clk           (sys_clk           ),
  .sys_rst           (sys_rst           ),
  .alpg_start        (alpg_start        ),
  .alpg_done         (alpg_done         ),
  .pat_data_parse_vld(pat_data_parse_vld),
  .pattern_data_rate (pattern_data_rate ),
  .pattern_a_clk_drv0(pattern_a_clk_drv0),
  .pattern_b_clk_drv0(pattern_b_clk_drv0),
  .pattern_c_clk_drv0(pattern_c_clk_drv0),
  .pattern_a_clk_drv1(pattern_a_clk_drv1),
  .pattern_b_clk_drv1(pattern_b_clk_drv1),
  .pattern_c_clk_drv1(pattern_c_clk_drv1),
  .pattern_a_clk_io  (pattern_a_clk_io  ),
  .pattern_b_clk_io  (pattern_b_clk_io  ),
  .pattern_c_clk_io  (pattern_c_clk_io  ),
  .pattern_drv_r     (pattern_drv_r     ),
  .pattern_drv_f     (pattern_drv_f     ),
  .pattern_strb      (pattern_strb      ),
  .base_rate_clk     (base_rate_clk     ),
  .strb_pluse        (strb_pluse        ),
  .pat_a_clk_d0      (pat_a_clk_d0      ),
  .pat_b_clk_d0      (pat_b_clk_d0      ),
  .pat_c_clk_d0      (pat_c_clk_d0      ),
  .pat_a_clk_d1      (pat_a_clk_d1      ),
  .pat_b_clk_d1      (pat_b_clk_d1      ),
  .pat_c_clk_d1      (pat_c_clk_d1      ),
  .pat_a_clk_io      (pat_a_clk_io      ),
  .pat_b_clk_io      (pat_b_clk_io      ),
  .pat_c_clk_io      (pat_c_clk_io      ),
  .pat_drv_r         (pat_drv_r         ),
  .pat_drv_f         (pat_drv_f         ),
  .fpga_clk          (fpga_clk          ),
  .mig_ref_clk       (mig_ref_clk       ),
  .gt_sys_clk        (gt_sys_clk        )
);


  // Parameters
  localparam  GT_LANE_DW  = 32;
  localparam  DATA_NUM_DW = 32;
  localparam  GT_DFX_DW   = 4 ;
  //Ports
  wire                          gt_usrclk      ;
  wire [GT_LANE/2-1:0]          tx_pck_start   ;
  wire                          tx_pck_done    ;
  wire [DATA_NUM_DW-1:0]        cfg_tx_data_num;
  wire [GT_LANE*GT_LANE_DW-1:0] tx_data_bus    ;
  wire [GT_LANE-1:0]            tx_data_vld_bus;
  wire                          rx_cfg_sof     ;
  wire                          rx_cfg_eof     ;
  wire                          rx_data_sof    ;
  wire                          rx_data_eof    ;
  wire [DATA_NUM_DW-1:0]        cfg_rx_data_num;
  wire [GT_LANE*GT_LANE_DW-1:0] rx_data_bus    ;
  wire [GT_LANE-1:0]            rx_data_vld_bus;
  wire [GT_LANE*GT_DFX_DW-1:0]  dfx_rx_err_bus ;
  wire [DATA_NUM_DW-1:0]        cfg_num_tx     ;

  wire gt_rst;


alpg_gtp_core # (
  .GT_LANE    (GT_LANE    ),
  .GT_LANE_DW (GT_LANE_DW ),
  .DATA_NUM_DW(DATA_NUM_DW),
  .GT_DFX_DW  (GT_DFX_DW  )
)
alpg_gtp_core_inst (
  .gt_ref_clkn    (gtp_ref_clkn   ),
  .gt_ref_clkp    (gtp_ref_clkp   ),
  .gt_sys_clk     (gt_sys_clk     ),
  .gt_usrclk      (gt_usrclk      ),
  .sys_rst        (sys_rst || gt_rst        ),
  .gtp_rst_done   (gtp_rst_done   ),
  .gtx_rst_done   (gtx_rst_done   ),
  .tx_pck_start   (tx_pck_start   ),
  .tx_pck_suspend (tx_pck_suspend ),
  .tx_pck_done    (tx_pck_done    ),
  .cfg_num_tx     (cfg_num_tx     ),
  .cfg_tx_data_num(cfg_tx_data_num),
  .tx_data_bus    (tx_data_bus    ),
  .tx_data_vld_bus(tx_data_vld_bus),
  .rx_cfg_sof     (rx_cfg_sof     ),
  .rx_cfg_eof     (rx_cfg_eof     ),
  .rx_data_sof    (rx_data_sof    ),
  .rx_data_eof    (rx_data_eof    ),
  .cfg_num_rx     (cfg_num_rx     ),
  .cfg_rx_data_num(cfg_rx_data_num),
  .rx_data_bus    (rx_data_bus    ),
  .rx_data_vld_bus(rx_data_vld_bus),
  .rxn_in         (gtp_rx_datan   ),
  .rxp_in         (gtp_rx_datap   ),
  .txn_out        (gtp_tx_datan   ),
  .txp_out        (gtp_tx_datap   ),
  .dfx_rx_err_bus (dfx_rx_err_bus )
);


// Parameters
localparam  CFG_AW            = 32         ;
localparam  CFG_DW            = 32         ;
localparam  DATA_TYPE_DW      = 2          ;
localparam  MEM_COPR_DW       = 2          ;
localparam  PC_DW             = 14         ;
localparam  FBC_SUM_DW        = PC_DW + 3  ;
localparam  DUT_NUM           = 16         ;
localparam  MOD_DW            = 2          ;
localparam  MSKTB_DW          = 8          ;
localparam  X_AW              = 15         ;
localparam  Y_AW              = 13         ;
localparam  Z_AW              = 11         ;
localparam  TP_DW             = 32         ;
localparam  MSTA_DW           = 23         ;
localparam  PSTA_DW           = 22         ;
localparam  AS_NUM            = 8          ;
localparam  FMT_NUM           = 9          ;
localparam  INDX_DW           = 33         ;
localparam  REG_NUM0          = 8          ;
localparam  REG_NUM1          = 16         ;
localparam  REG_NUM2          = 32         ;
localparam  REG_DW            = 32         ;
localparam  RATE_DW           = 22         ;
localparam  AS_DW             = 24         ;
localparam  AFM_DW            = 24         ;
localparam  AFM_NUM           = 6          ;
//Ports
wire                          alpg_work_busy     ;
wire                          alpg_cfg_send_start;
wire                          gt_clk             ;
wire [CFG_AW-1:0]             gtx_cfg_addr       ;
wire [CFG_DW-1:0]             gtx_cfg_data       ;
wire                          gtx_cfg_vld        ;
wire [CFG_AW-1:0]             gtp_cfg_addr       ;
wire [CFG_DW-1:0]             gtp_cfg_data       ;
wire                          alpg_wr_start      ;
wire                          alpg_rd_start      ;
wire                          alpg_mem_rst       ;
wire                          alpg_mem_copy      ;
wire                          alpg_restart       ;
wire                          alpg_stop          ;
wire [DDR_AW-1:0]             cfg_alpg_base_addr ;
wire [DATA_NUM_DW-1:0]        cfg_alpg_data_num  ;
wire [DATA_TYPE_DW-1:0]       cfg_alpg_data_type ;
wire [MEM_COPR_DW-1:0]        cfg_alpg_mem_copr  ;
wire [DDR_AW-1:0]             cfg_alpg_addr_d0   ;
wire [DDR_AW-1:0]             cfg_alpg_addr_d1   ;
wire [DDR_AW-1:0]             cfg_alpg_addr_p    ;
wire [DATA_NUM_DW-1:0]        cfg_alpg_mem_size  ;
wire [PC_DW-1:0]              alpg_start_pc      ;
wire [MOD_DW-1:0]             cfg_alpg_run_mod   ;
wire [MOD_DW-1:0]             cfg_alpg_idx_mod   ;
wire [MSKTB_DW-1:0]           cfg_alpg_msktb     ;
wire [X_AW-1:0]               cfg_alpg_x         ;
wire [Y_AW-1:0]               cfg_alpg_y         ;
wire [Z_AW-1:0]               cfg_alpg_z         ;
wire [X_AW-1:0]               cfg_alpg_x_max     ;
wire [Y_AW-1:0]               cfg_alpg_y_max     ;
wire [Z_AW-1:0]               cfg_alpg_z_max     ;
wire [TP_DW-1:0]              cfg_alpg_tp        ;
wire [REG_NUM1-1:0]           cfg_alpg_cflg      ;
wire                          cfg_alpg_me        ;
wire [PSTA_DW-1:0]            cfg_alpg_psta      ;
wire [MSTA_DW-1:0]            cfg_alpg_msta      ;
wire [INDX_DW*REG_NUM1-1:0]   cfg_alpg_indx_bus  ;
wire [TP_DW*REG_NUM2-1:0]     cfg_alpg_tph_bus   ;
wire [TP_DW*REG_NUM1-1:0]     cfg_alpg_dreg_bus  ;
wire [MSTA_DW*REG_NUM0-1:0]   cfg_alpg_qreg_bus  ;
wire [PSTA_DW*REG_NUM0-1:0]   cfg_alpg_preg_bus  ;
wire [AS_DW*REG_NUM0-1:0]     cfg_alpg_ash_bus   ;
wire [AS_DW*REG_NUM0-1:0]     cfg_alpg_asl_bus   ;
wire [PC_DW-1:0]              cfg_alpg_bar       ;
wire [FMT_NUM-1:0]            cfg_alpg_fmt_c0    ;
wire [FMT_NUM-1:0]            cfg_alpg_fmt_c1    ;
wire [FMT_NUM-1:0]            cfg_alpg_fmt_d0    ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_rate_bus  ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_aclk1_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_aclk2_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_aclk3_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_bclk1_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_bclk2_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_bclk3_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_cclk1_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_cclk2_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_cclk3_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_dre_r_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_dre_f_bus ;
wire [RATE_DW*REG_NUM0-1:0]   cfg_alpg_strb_bus  ;
wire [AFM_DW*AFM_NUM-1:0]     cfg_alpg_afm_bus   ;
wire [PC_DW-1:0]              alpg_end_pc        ;
wire [FBC_SUM_DW*DUT_NUM-1:0] alpg_fbc_dut_bus   ;
wire                          alpg_fsr           ;
wire                          alpg_mflg          ;

wire fack_stop;
reg fack_stop_d1 = 'd0;
wire fack_stop_r;

//always @(posedge sys_clk) 
//begin
//  if(alpg_start || alpg_restart)
//  begin
//    alpg_work_busy <= 'd1;
//  end
//  else if(fack_stop_r)
//  begin
//    alpg_work_busy <= 'd0;
//  end
//  else
//  begin
//    alpg_work_busy <= alpg_work_busy;
//  end  
//end

//vio_1 u_stop (
//  .clk(sys_clk),                // input wire clk
//  .probe_out0(fack_stop)  // output wire [0 : 0] probe_out0
//);

vio_1 u_vio_top (
  .clk(sys_clk),                // input wire clk
  .probe_out0(fack_stop),  // output wire [0 : 0] probe_out0
  .probe_out1(gt_rst)  // output wire [0 : 0] probe_out1
);

always @(posedge sys_clk) 
begin
  fack_stop_d1 <= fack_stop;
end

assign fack_stop_r = fack_stop && (!fack_stop_d1);

alpg_cfg_core # (
  .CFG_AW        (CFG_AW         ),
  .CFG_DW        (CFG_DW         ),
  .DATA_NUM_DW   (DATA_NUM_DW    ),
  .DDR_AW        (DDR_AW         ),
  .DATA_TYPE_DW  (DATA_TYPE_DW   ),
  .MEM_COPR_DW   (MEM_COPR_DW    ),
  .PC_DW         (PC_DW          ),
  .FBC_SUM_DW    (FBC_SUM_DW     ),
  .DUT_NUM       (DUT_NUM        ),
  .MOD_DW        (MOD_DW         ),
  .MSKTB_DW      (MSKTB_DW       ),
  .X_AW          (X_AW           ),
  .Y_AW          (Y_AW           ),
  .Z_AW          (Z_AW           ),
  .TP_DW         (TP_DW          ),
  .MSTA_DW       (MSTA_DW        ),
  .PSTA_DW       (PSTA_DW        ),
  .AS_NUM        (AS_NUM         ),
  .FMT_NUM       (FMT_NUM        ),
  .INDX_DW       (INDX_DW        ),
  .REG_NUM0      (REG_NUM0       ),
  .REG_NUM1      (REG_NUM1       ),
  .REG_NUM2      (REG_NUM2       ),
  .REG_DW        (REG_DW         ),
  .RATE_DW       (RATE_DW        ),
  .AS_DW         (AS_DW          ),
  .AFM_DW        (AFM_DW         ),
  .AFM_NUM       (AFM_NUM        )
)
alpg_cfg_core_inst (
  .clk                   (sys_clk                    ),
  .rst                   (sys_rst                    ),
  .alpg_work_busy        (alpg_work_busy             ),
  .alpg_cfg_send_start   (alpg_cfg_send_start        ),
  .gt_clk                (gt_usrclk                  ),
  .gtx_cfg_addr          (gtx_cfg_addr               ),
  .gtx_cfg_data          (gtx_cfg_data               ),
  .gtx_cfg_vld           (gtx_cfg_vld                ),
  .gtp_cfg_addr          (gtp_cfg_addr               ),
  .gtp_cfg_data          (gtp_cfg_data               ),
  .alpg_wr_start         (alpg_wr_start              ),
  .alpg_rd_start         (alpg_rd_start              ),
  .alpg_mem_rst          (alpg_mem_rst               ),
  .alpg_mem_copy         (alpg_mem_copy              ),
  .alpg_start            (alpg_start                 ),
  .alpg_restart          (alpg_restart               ),
  .alpg_stop             (alpg_stop                  ),
  .cfg_alpg_base_addr    (cfg_alpg_base_addr         ),
  .cfg_alpg_data_num     (cfg_alpg_data_num          ),
  .cfg_alpg_data_type    (cfg_alpg_data_type         ),
  .cfg_alpg_mem_copr     (cfg_alpg_mem_copr          ),
  .cfg_alpg_addr_d0      (cfg_alpg_addr_d0           ),
  .cfg_alpg_addr_d1      (cfg_alpg_addr_d1           ),
  .cfg_alpg_addr_p       (cfg_alpg_addr_p            ),
  .cfg_alpg_mem_size     (cfg_alpg_mem_size          ),
  .alpg_start_pc         (alpg_start_pc              ),
  .cfg_alpg_run_mod      (cfg_alpg_run_mod           ),
  .cfg_alpg_idx_mod      (cfg_alpg_idx_mod           ),
  .cfg_alpg_msktb        (cfg_alpg_msktb             ),
  .cfg_alpg_x            (cfg_alpg_x                 ),
  .cfg_alpg_y            (cfg_alpg_y                 ),
  .cfg_alpg_z            (cfg_alpg_z                 ),
  .cfg_alpg_x_max        (cfg_alpg_x_max             ),
  .cfg_alpg_y_max        (cfg_alpg_y_max             ),
  .cfg_alpg_z_max        (cfg_alpg_z_max             ),
  .cfg_alpg_tp           (cfg_alpg_tp                ),
  .cfg_alpg_cflg         (cfg_alpg_cflg              ),
  .cfg_alpg_me           (cfg_alpg_me                ),
  .cfg_alpg_psta         (cfg_alpg_psta              ),
  .cfg_alpg_msta         (cfg_alpg_msta              ),
  .cfg_alpg_indx_bus     (cfg_alpg_indx_bus          ),
  .cfg_alpg_tph_bus      (cfg_alpg_tph_bus           ),
  .cfg_alpg_dreg_bus     (cfg_alpg_dreg_bus          ),
  .cfg_alpg_qreg_bus     (cfg_alpg_qreg_bus          ),
  .cfg_alpg_preg_bus     (cfg_alpg_preg_bus          ),
  .cfg_alpg_ash_bus      (cfg_alpg_ash_bus           ),
  .cfg_alpg_asl_bus      (cfg_alpg_asl_bus           ),
  .cfg_alpg_bar          (cfg_alpg_bar               ),
  .cfg_alpg_fmt_c0       (cfg_alpg_fmt_c0            ),
  .cfg_alpg_fmt_c1       (cfg_alpg_fmt_c1            ),
  .cfg_alpg_fmt_d0       (cfg_alpg_fmt_d0            ),
  .cfg_alpg_rate_bus     (cfg_alpg_rate_bus          ),
  .cfg_alpg_aclk1_bus    (cfg_alpg_aclk1_bus         ),
  .cfg_alpg_aclk2_bus    (cfg_alpg_aclk2_bus         ),
  .cfg_alpg_aclk3_bus    (cfg_alpg_aclk3_bus         ),
  .cfg_alpg_bclk1_bus    (cfg_alpg_bclk1_bus         ),
  .cfg_alpg_bclk2_bus    (cfg_alpg_bclk2_bus         ),
  .cfg_alpg_bclk3_bus    (cfg_alpg_bclk3_bus         ),
  .cfg_alpg_cclk1_bus    (cfg_alpg_cclk1_bus         ),
  .cfg_alpg_cclk2_bus    (cfg_alpg_cclk2_bus         ),
  .cfg_alpg_cclk3_bus    (cfg_alpg_cclk3_bus         ),
  .cfg_alpg_dre_r_bus    (cfg_alpg_dre_r_bus         ),
  .cfg_alpg_dre_f_bus    (cfg_alpg_dre_f_bus         ),
  .cfg_alpg_strb_bus     (cfg_alpg_strb_bus          ),
  .cfg_alpg_afm_bus      (cfg_alpg_afm_bus           ),
  .alpg_end_pc           (alpg_end_pc                ),
  .alpg_fbc_dut_bus      (alpg_fbc_dut_bus           ),
  .alpg_fsr              (alpg_fsr                   ),
  .alpg_mflg             (alpg_mflg                  )
);

assign gtx_cfg_addr = rx_data_bus[GT_LANE_DW-1:0]            ;  
assign gtx_cfg_data = rx_data_bus[2*GT_LANE_DW-1:GT_LANE_DW] ; 
assign gtx_cfg_vld  = rx_data_vld_bus[0]                     ;
assign tx_data_bus[GT_LANE_DW-1:0]            = gtp_cfg_addr ;
assign tx_data_bus[2*GT_LANE_DW-1:GT_LANE_DW] = gtp_cfg_data ;


wire init_start;
wire init_done ;

alpg_ctrl_mst  alpg_ctrl_mst_inst (
  .clk           (sys_clk       ),
  .rst           (sys_rst       ),
  .alpg_start    (alpg_start    ),
  .alpg_restart  (alpg_restart  ),
  .alpg_stop     (fack_stop_r     ),
  //.alpg_stop     (alpg_stop     ),
  .alpg_work_busy(alpg_work_busy),
  .alpg_done     (alpg_done     ),
  .init_start    (init_start    ),
  .init_done     (init_done     )
);

// Parameters
localparam  PROTCL_LEN   = 5  ;
localparam  IDX_DW       = 32 ;
localparam  REG_NUM      = 16 ;

//Ports
wire [GT_LANE_DW-1:0]               gt_rx_data2       ;
wire [GT_LANE_DW-1:0]               gt_rx_data3       ;
wire                                gt_rx_data_vld    ;
wire                                mflg_reg          ;
wire                                clk_base          ;
wire [PROTCL_LEN * GT_LANE_DW-1:0]  pat_func_data     ;
wire                                pat_func_data_vld ;
wire                                dfx_pattern_func  ;

assign gt_rx_data2    = rx_data_bus[3*GT_LANE_DW-1:2*GT_LANE_DW];
assign gt_rx_data3    = rx_data_bus[4*GT_LANE_DW-1:3*GT_LANE_DW];
assign gt_rx_data_vld = rx_data_vld_bus[2];

alpg_pat_task # (
  .GT_LANE_DW   (GT_LANE_DW   ),
  .PROTCL_LEN   (PROTCL_LEN   ),
  .PC_DW        (PC_DW        ),
  .DATA_TYPE_DW (DATA_TYPE_DW ),
  .IDX_DW       (INDX_DW      ),
  .REG_NUM      (REG_NUM      ),
  .RATE_DW      (RATE_DW      ),
  .AS_DW        (AS_DW        ),
  .AFM_DW       (AFM_DW       ),
  .AFM_NUM      (AFM_NUM      )
)
alpg_pat_task_inst (
  .clk                 (sys_clk             ),
  .rst                 (sys_rst             ),
  .gt_clk              (gt_usrclk           ),
  .cfg_alpg_data_type  (cfg_alpg_data_type  ),
  .cfg_alpg_start_pc   (alpg_start_pc       ),
  .cfg_alpg_cflg       (cfg_alpg_cflg       ),
  .cfg_alpg_indx_bus   (cfg_alpg_indx_bus   ),
  .rx_data_sof         (rx_data_sof         ),
  .rx_data_eof         (rx_data_eof         ),
  .gt_rx_data2         (gt_rx_data2         ),
  .gt_rx_data3         (gt_rx_data3         ),
  .gt_rx_data_vld      (gt_rx_data_vld      ),
  .alpg_start          (init_done           ),
  .alpg_restart        (alpg_restart        ),
  .alpg_stop           (alpg_stop           ),
  .mflg_reg            (mflg_reg            ),
  .clk_base            (base_rate_clk       ),
  .pat_func_data       (pat_func_data       ),
  .pat_func_data_vld   (pat_func_data_vld   ),
  .dfx_pattern_func    (dfx_pattern_func    )
);


// Parameters
localparam  TREG_NUM          = 8  ;
localparam  CMD_DW            = 4  ;
localparam  MUX_DW            = 4  ;
localparam  OPR_DW            = 3  ;
localparam  AS_MAP_DW         = 24 ;
localparam  BYTE_DW           = 8  ;
localparam  REG_SEL_DW        = 7  ;
localparam  REG_NUM_PAT       = 3  ;
//Ports
wire [PSTA_DW-1:0]                 pm_addr           ;
wire [DDR_DW-1:0]                  pm_data           ;
wire [MSTA_DW-1:0]                 dum_addr          ;
wire [DDR_DW-1:0]                  dum_data          ;
wire                               alpg_dps_start    ;
wire                               pattern_ck        ;
wire                               pattern_we        ;
wire [CMD_DW-1:0]                  pattern_cmd       ;
wire                               pattern_me        ;
wire [MSKTB_DW-1:0]                pattern_msktb     ;
wire                               pattern_dio       ;

alpg_data_prase # (
  .GT_LANE_DW  (GT_LANE_DW  ),
  .PROTCL_LEN  (PROTCL_LEN  ),
  .FMT_NUM     (FMT_NUM     ),
  .TREG_NUM    (TREG_NUM    ),
  .RATE_DW     (RATE_DW     ),
  .TIMING_DW   (TIMING_DW   ),
  .CMD_DW      (CMD_DW      ),
  .MUX_DW      (MUX_DW      ),
  .OPR_DW      (OPR_DW      ),
  .MSKTB_DW    (MSKTB_DW    ),
  .X_AW        (X_AW        ),
  .Y_AW        (Y_AW        ),
  .Z_AW        (Z_AW        ),
  .TP_DW       (TP_DW       ),
  .MSTA_DW     (MSTA_DW     ),
  .PSTA_DW     (PSTA_DW     ),
  .AS_MAP_DW   (AS_MAP_DW   ),
  .DDR_DW      (DDR_DW      ),
  .BYTE_DW     (BYTE_DW     ),
  .REG_NUM0    (REG_NUM0    ),
  .REG_NUM1    (REG_NUM1    ),
  .REG_NUM2    (REG_NUM2    ),
  .REG_NUM     (REG_NUM_PAT     ),
  .REG_SEL_DW  (REG_SEL_DW  ),
  .REG_DW      (REG_DW      )
)
alpg_data_prase_inst (
  .clk                 (sys_clk             ),
  .rst                 (sys_rst             ),
  .alpg_start          (alpg_start          ),
  .alpg_done           (alpg_done           ),
  .init_start          (init_start          ),
  .init_done           (init_done           ),
  .base_rate_clk       (base_rate_clk       ),
  .pat_func_data       (pat_func_data       ),
  .pat_func_data_vld   (pat_func_data_vld   ),
  .rd_ddr_req          (rd_ddr_req          ),
  .rd_ddr_addr         (rd_ddr_addr         ),
  .rd_ddr_addr_vld     (rd_ddr_addr_vld     ),
  .rd_ddr_addr_vld_last(rd_ddr_addr_vld_last),
  .rd_ddr_data         (rd_ddr_data         ),
  .rd_ddr_data_vld     (rd_ddr_data_vld     ),
  .cfg_alpg_fmt_c0     (cfg_alpg_fmt_c0     ),
  .cfg_alpg_fmt_c1     (cfg_alpg_fmt_c1     ),
  .cfg_alpg_fmt_d0     (cfg_alpg_fmt_d0     ),
  .cfg_alpg_rate_bus   (cfg_alpg_rate_bus   ),
  .cfg_alpg_aclk1_bus  (cfg_alpg_aclk1_bus  ),
  .cfg_alpg_cclk1_bus  (cfg_alpg_cclk1_bus  ),
  .cfg_alpg_bclk1_bus  (cfg_alpg_bclk1_bus  ),
  .cfg_alpg_aclk2_bus  (cfg_alpg_aclk2_bus  ),
  .cfg_alpg_bclk2_bus  (cfg_alpg_bclk2_bus  ),
  .cfg_alpg_cclk2_bus  (cfg_alpg_cclk2_bus  ),
  .cfg_alpg_aclk3_bus  (cfg_alpg_aclk3_bus  ),
  .cfg_alpg_bclk3_bus  (cfg_alpg_bclk3_bus  ),
  .cfg_alpg_cclk3_bus  (cfg_alpg_cclk3_bus  ),
  .cfg_alpg_dre_r_bus  (cfg_alpg_dre_r_bus  ),
  .cfg_alpg_dre_f_bus  (cfg_alpg_dre_f_bus  ),
  .cfg_alpg_strb_bus   (cfg_alpg_strb_bus   ),
  .cfg_alpg_msktb      (cfg_alpg_msktb      ),
  .cfg_alpg_x          (cfg_alpg_x          ),
  .cfg_alpg_y          (cfg_alpg_y          ),
  .cfg_alpg_z          (cfg_alpg_z          ),
  .cfg_alpg_tp         (cfg_alpg_tp         ),
  .cfg_alpg_me         (cfg_alpg_me         ),
  .cfg_alpg_psta       (cfg_alpg_psta       ),
  .cfg_alpg_msta       (cfg_alpg_msta       ),
  .cfg_alpg_tph_bus    (cfg_alpg_tph_bus    ),
  .cfg_alpg_dreg_bus   (cfg_alpg_dreg_bus   ),
  .cfg_alpg_qreg_bus   (cfg_alpg_qreg_bus   ),
  .cfg_alpg_preg_bus   (cfg_alpg_preg_bus   ),
  .cfg_alpg_ash_bus    (cfg_alpg_ash_bus    ),
  .cfg_alpg_asl_bus    (cfg_alpg_asl_bus    ),
  .alpg_dps_start      (alpg_dps_start      ),
  .pat_data_parse_vld  (pat_data_parse_vld  ),
  .pattern_data_rate   (pattern_data_rate   ),
  .pattern_a_clk_drv0  (pattern_a_clk_drv0  ),
  .pattern_b_clk_drv0  (pattern_b_clk_drv0  ),
  .pattern_c_clk_drv0  (pattern_c_clk_drv0  ),
  .pattern_a_clk_drv1  (pattern_a_clk_drv1  ),
  .pattern_b_clk_drv1  (pattern_b_clk_drv1  ),
  .pattern_c_clk_drv1  (pattern_c_clk_drv1  ),
  .pattern_a_clk_io    (pattern_a_clk_io    ),
  .pattern_b_clk_io    (pattern_b_clk_io    ),
  .pattern_c_clk_io    (pattern_c_clk_io    ),
  .pattern_drv_r       (pattern_drv_r       ),
  .pattern_drv_f       (pattern_drv_f       ),
  .pattern_strb        (pattern_strb        ),
  .ck_out              (pattern_ck          ),
  .we_out              (pattern_we          ),
  .pattern_cmd         (pattern_cmd         ),
  .pattern_me          (pattern_me          ),
  .pattern_msktb       (pattern_msktb       ),
  .d_reg               (d_reg               ),
  .pattern_dio         (pattern_dio         )
);

wire               ui_clk                         ;
wire               ddr_wr_req                     ;
wire               ddr_wr_done                    ;
wire               wr_fifo_prog_full              ;
wire  [DDR_AW-1:0] ddr_wr_base_addr               ;           
wire  [DDR_AW-1:0] ddr_wr_data_num                ;
wire  [DDR_DW-1:0] ddr_wr_data                    ;
reg                ddr_wr_data_vld        = 'd0   ;
wire               ddr_rd_req                     ;
wire               ddr_rd_done                    ;
wire               rd_fifo_empty                  ;
wire [DDR_AW-1:0]  ddr_rd_base_addr               ;
wire [DDR_AW-1:0]  ddr_rd_data_num                ;
wire [DDR_DW-1:0]  ddr_rd_data                    ;
wire               ddr_rd_data_vld                ; 

ddr3_core#(
  .DDR_AW      ( DDR_AW      )    ,
  .DDR_DW      ( DDR_DW      )    ,
  .DATA_WIDTH  ( DATA_WIDTH  )                    
)
u_ddr3_core   (
  .sys_clk_i         ( sys_clk           )      , 
  .sys_rst_n         ( ~sys_rst          )     ,
  .ddr_wr_req        ( ddr_wr_req        )      ,
  .ddr_wr_done       ( ddr_wr_done       )      ,
  .wr_fifo_prog_full ( wr_fifo_prog_full )      ,
  .ddr_wr_base_addr  ( ddr_wr_base_addr  )      ,           
  .ddr_wr_data_num   ( ddr_wr_data_num   )      ,
  .ddr_wr_data       ( ddr_wr_data       )      ,
  .ddr_wr_data_vld   ( ddr_wr_data_vld   )      ,
  .ddr_rd_req        ( ddr_rd_req        )      ,
  .ddr_rd_done       ( ddr_rd_done       )      ,
  .rd_fifo_empty     ( rd_fifo_empty     )      ,
  .ddr_rd_base_addr  ( ddr_rd_base_addr  )      ,
  .ddr_rd_data_num   ( ddr_rd_data_num   )      ,
  .ddr_rd_data       ( ddr_rd_data       )      ,
  .ddr_rd_data_vld   ( ddr_rd_data_vld   )      ,
  .init_calib_complete(init_calib_complete)     ,
  .ui_clk             ( ui_clk            )     ,
  .ui_rst_n           ( ui_rst_n          )     ,

  .ddr3_addr          ( ddr3_addr         )     ,  // output [14:0]		ddr3_addr
  .ddr3_ba            ( ddr3_ba           )     ,  // output [2:0]		ddr3_ba
  .ddr3_cas_n         ( ddr3_cas_n        )     ,  // output			ddr3_cas_n
  .ddr3_ck_n          ( ddr3_ck_n         )     ,  // output [0:0]		ddr3_ck_n
  .ddr3_ck_p          ( ddr3_ck_p         )     ,  // output [0:0]		ddr3_ck_p
  .ddr3_cke           ( ddr3_cke          )     ,  // output [0:0]		ddr3_cke
  .ddr3_ras_n         ( ddr3_ras_n        )     ,  // output			ddr3_ras_n
  .ddr3_reset_n       ( ddr3_reset_n      )     ,  // output			ddr3_reset_n
  .ddr3_we_n          ( ddr3_we_n         )     ,  // output			ddr3_we_n
  .ddr3_dq            ( ddr3_dq           )     ,  // inout [31:0]		ddr3_dq
  .ddr3_dqs_n         ( ddr3_dqs_n        )     ,  // inout [3:0]		ddr3_dqs_n
  .ddr3_dqs_p         ( ddr3_dqs_p        )     ,  // inout [3:0]		ddr3_dqs_p
  .ddr3_cs_n          ( ddr3_cs_n         )     ,  // output [0:0]		ddr3_cs_n
  .ddr3_dm            ( ddr3_dm           )     ,  // output [3:0]		ddr3_dm
  .ddr3_odt           ( ddr3_odt          )        // output [0:0]		ddr3_odt
); 

wire ddr_wr_req_flag;
wire ddr_rd_req_flag;
reg ddr_wr_req_flag_d1 = 'd0;
reg ddr_rd_req_flag_d1 = 'd0;

vio_0 your_instance_name (
  .clk       (sys_clk         ),                // input wire clk
  .probe_out0(ddr_wr_req_flag      ),  // output wire [0 : 0] probe_out0
  .probe_out1(ddr_wr_base_addr),  // output wire [31 : 0] probe_out1
  .probe_out2(ddr_wr_data_num ),  // output wire [31 : 0] probe_out2
  .probe_out3(     ),  // output wire [31 : 0] probe_out3
  .probe_out4(                ),  // output wire [0 : 0] probe_out4
  .probe_out5(ddr_rd_req_flag      ),  // output wire [0 : 0] probe_out5
  .probe_out6(ddr_rd_base_addr),  // output wire [31 : 0] probe_out6
  .probe_out7(ddr_rd_data_num ),  // output wire [31 : 0] probe_out7
  .probe_out8()  // output wire [0 : 0] probe_out8

);

reg [31:0] wr_data_cnt = 'd0;

always @(posedge sys_clk) 
begin
  ddr_wr_req_flag_d1 <= ddr_wr_req_flag;
  ddr_rd_req_flag_d1 <= ddr_rd_req_flag;
end

assign ddr_wr_req = (!ddr_wr_req_flag_d1) && ddr_wr_req_flag;
assign ddr_rd_req = (!ddr_rd_req_flag_d1) && ddr_rd_req_flag;

always @(posedge sys_clk) 
begin
  if(ddr_wr_req)
  begin
    ddr_wr_data_vld <= 'd1;
  end
  else if(wr_data_cnt == ddr_wr_data_num - 'd1)
  begin
    ddr_wr_data_vld <= 'd0;
  end  
  else
  begin
    ddr_wr_data_vld <= ddr_wr_data_vld;
  end  
end

always @(posedge sys_clk) 
begin
  if(ddr_wr_data_vld)
  begin
    wr_data_cnt <= wr_data_cnt + 'd1;
  end
  else
  begin
    wr_data_cnt <= 'd0;
  end  
end

assign ddr_wr_data = wr_data_cnt;
//  // Parameters
//  localparam  GT_DATA_LANE = 0;
//  localparam  DATA_NUM_DW = 0;
//  localparam  DATA_TYPE_DW = 0;
//  localparam  MEM_COPR_DW = 0;
//
//  //Ports
//  reg clk;
//  reg rst;
//  reg alpg_wr_start;
//  reg alpg_rd_start;
//  reg alpg_mem_rst;
//  reg alpg_mem_copy;
//  reg [DDR_AW-1:0] cfg_alpg_base_addr;
//  reg [DATA_NUM_DW-1:0] cfg_alpg_data_num;
//  reg [DATA_TYPE_DW-1:0] cfg_alpg_data_type;
//  reg [MEM_COPR_DW-1:0] cfg_alpg_mem_copr;
//  reg [DDR_AW-1:0] cfg_alpg_addr_d0;
//  reg [DDR_AW-1:0] cfg_alpg_addr_d1;
//  reg [DDR_AW-1:0] cfg_alpg_addr_p;
//  reg [DATA_NUM_DW-1:0] cfg_alpg_mem_size;
//  reg rx_data_sof;
//  reg rx_data_eof;
//  reg [DATA_NUM_DW-1:0] cfg_rx_data_num;
//  reg [GT_DATA_LANE*DDR_DW-1:0] rx_data_bus;
//  reg [GT_DATA_LANE-1:0] rx_data_vld_bus;
//  reg pat_rd_req;
//  reg [DDR_AW-1:0] pat_rd_base_addr;
//  reg [DATA_NUM_DW-1:0] pat_data_num;
//  reg pat_wr_req;
//  reg [DDR_AW-1:0] pat_wr_base_addr;
//  wire ddr_rst;
//  wire  ddr_wr_req;
//  reg ddr_wr_done;
//  reg wr_fifo_prog_full;
//  wire reg [DDR_AW-1:0] ddr_wr_base_addr;
//  wire reg [DDR_AW-1:0] ddr_wr_data_num;
//  wire reg [DDR_DW-1:0] ddr_wr_data;
//  wire  ddr_wr_data_vld;
//  wire  ddr_rd_req;
//  reg ddr_rd_done;
//  reg rd_fifo_empty;
//  wire reg [DDR_AW-1:0] ddr_rd_base_addr;
//  wire reg [DDR_AW-1:0] ddr_rd_data_num;
//  reg [DDR_DW-1:0] ddr_rd_data;
//  reg ddr_rd_data_vld;
//  reg ddr_rst_done;
//  reg ui_clk;
//
//  alpg_ddr_task # (
//    .GT_DATA_LANE(GT_DATA_LANE),
//    .DATA_NUM_DW (DATA_NUM_DW ),
//    .DATA_TYPE_DW(DATA_TYPE_DW),
//    .MEM_COPR_DW (MEM_COPR_DW ),
//    .DDR_AW      (DDR_AW      ),
//    .DDR_DW      (DDR_DW      )
//  )
//  alpg_ddr_task_inst (
//    .clk               (sys_clk           ),
//    .rst               (sys_rst           ),
//    .alpg_wr_start     (alpg_wr_start     ),
//    .alpg_rd_start     (alpg_rd_start     ),
//    .alpg_mem_rst      (alpg_mem_rst      ),
//    .alpg_mem_copy     (alpg_mem_copy     ),
//    .cfg_alpg_base_addr(cfg_alpg_base_addr),
//    .cfg_alpg_data_num (cfg_alpg_data_num ),
//    .cfg_alpg_data_type(cfg_alpg_data_type),
//    .cfg_alpg_mem_copr (cfg_alpg_mem_copr ),
//    .cfg_alpg_addr_d0  (cfg_alpg_addr_d0  ),
//    .cfg_alpg_addr_d1  (cfg_alpg_addr_d1  ),
//    .cfg_alpg_addr_p   (cfg_alpg_addr_p   ),
//    .cfg_alpg_mem_size (cfg_alpg_mem_size ),
//    .rx_data_sof       (rx_data_sof       ),
//    .rx_data_eof       (rx_data_eof       ),
//    .cfg_rx_data_num   (cfg_rx_data_num   ),
//    .rx_data_bus       (rx_data_bus       ),
//    .rx_data_vld_bus   (rx_data_vld_bus   ),
//    .pat_rd_req        (pat_rd_req        ),
//    .pat_rd_base_addr  (pat_rd_base_addr  ),
//    .pat_data_num      (pat_data_num      ),
//    .pat_wr_req        (pat_wr_req        ),
//    .pat_wr_base_addr  (pat_wr_base_addr  ),
//    .ddr_rst           (ddr_rst           ),
//    .ddr_wr_req        (ddr_wr_req        ),
//    .ddr_wr_done       (ddr_wr_done       ),
//    .wr_fifo_prog_full (wr_fifo_prog_full ),
//    .ddr_wr_base_addr  (ddr_wr_base_addr  ),
//    .ddr_wr_data_num   (ddr_wr_data_num   ),
//    .ddr_wr_data       (ddr_wr_data       ),
//    .ddr_wr_data_vld   (ddr_wr_data_vld   ),
//    .ddr_rd_req        (ddr_rd_req        ),
//    .ddr_rd_done       (ddr_rd_done       ),
//    .rd_fifo_empty     (rd_fifo_empty     ),
//    .ddr_rd_base_addr  (ddr_rd_base_addr  ),
//    .ddr_rd_data_num   (ddr_rd_data_num   ),
//    .ddr_rd_data       (ddr_rd_data       ),
//    .ddr_rd_data_vld   (ddr_rd_data_vld   ),
//    .ddr_rst_done      (ddr_rst_done      ),
//    .ui_clk            (ui_clk            )
//  );



endmodule
