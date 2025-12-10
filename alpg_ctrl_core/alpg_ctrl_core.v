`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-25
// Module Name           : alpg_ctrl_core
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
module alpg_ctrl_core 
#(
    parameter GT_LANE_DW        = 32   ,
    parameter GT_DATA_LANE      = 2    ,
    parameter DATA_NUM_DW       = 32   ,
    //parameter PROTCL_LEN        = 5    ,
    parameter MEM_COPR_DW       = 2    ,
    parameter PC_DW             = 14   ,
    parameter DATA_TYPE_DW      = 2    ,
    parameter IDX_DW            = 33   ,
    parameter FMT_NUM           = 9    ,
    parameter TREG_NUM          = 8    ,
    parameter RATE_DW           = 22   ,
    parameter TIMING_DW         = 22   ,
    parameter CMD_DW            = 4    ,
    parameter MUX_DW            = 4    ,
    parameter OPR_DW            = 3    ,
    parameter MSKTB_DW          = 8    ,
    parameter X_AW              = 15   ,
    parameter Y_AW              = 13   ,
    parameter Z_AW              = 11   ,
    parameter TP_DW             = 32   ,
    parameter MSTA_DW           = 23   ,
    parameter PSTA_DW           = 22   ,
    parameter AS_MAP_DW         = 24   ,
    parameter DDR_DW            = 32   ,
    parameter DDR_AW            = 18   ,
    parameter BYTE_DW           = 8    ,
    parameter REG_NUM0          = 8    ,
    parameter REG_NUM1          = 16   ,
    parameter REG_NUM2          = 32   ,    
    parameter REG_NUM           = 3    ,
    parameter REG_SEL_DW        = 7    ,
    parameter REG_DW            = 32
) 
(
    input                                clk                   ,            //@200M
    input                                rst                   ,
    input                                gt_clk                ,            //@50M
    //-------------------------cmd----------------------  
    input                                alpg_start            ,
    input                                alpg_restart          ,
    input                                alpg_stop             ,
    output                               alpg_work_busy        ,
    input                                alpg_done             ,
    //mem cmd
    input                                alpg_wr_start         ,
    input                                alpg_rd_start         ,
    input                                alpg_mem_rst          ,
    input                                alpg_mem_copy         ,
    //output                               init_start          ,
    //input                                init_done
    //-------------------------cfg----------------------
    input  [DATA_TYPE_DW-1:0]            cfg_alpg_data_type    ,            //2:pattern func
    input  [PC_DW-1:0]                   cfg_alpg_start_pc     ,
    input  [REG_NUM1-1:0]                cfg_alpg_cflg         ,
    input  [IDX_DW*REG_NUM1-1:0]         cfg_alpg_indx_bus     ,
    input  [FMT_NUM-1:0]                 cfg_alpg_fmt_c0       ,
    input  [FMT_NUM-1:0]                 cfg_alpg_fmt_c1       ,
    input  [FMT_NUM-1:0]                 cfg_alpg_fmt_d0       ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_rate_bus     ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_aclk1_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_cclk1_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_bclk1_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_aclk2_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_bclk2_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_cclk2_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_aclk3_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_bclk3_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_cclk3_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_dre_r_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_dre_f_bus    ,
    input  [RATE_DW*TREG_NUM-1:0]        cfg_alpg_strb_bus     ,
    input  [MSKTB_DW-1:0]                cfg_alpg_msktb        ,            //active in 0
    input  [X_AW-1:0]                    cfg_alpg_x            ,
    input  [Y_AW-1:0]                    cfg_alpg_y            ,
    input  [Z_AW-1:0]                    cfg_alpg_z            ,
    input  [TP_DW-1:0]                   cfg_alpg_tp           ,
    input                                cfg_alpg_me           ,
    input  [PSTA_DW-1:0]                 cfg_alpg_psta         ,
    input  [MSTA_DW-1:0]                 cfg_alpg_msta         ,
    input  [TP_DW*REG_NUM2-1:0]          cfg_alpg_tph_bus      ,
    input  [TP_DW*REG_NUM1-1:0]          cfg_alpg_dreg_bus     ,
    input  [MSTA_DW*REG_NUM0-1:0]        cfg_alpg_qreg_bus     ,
    input  [PSTA_DW*REG_NUM0-1:0]        cfg_alpg_preg_bus     ,
    input  [AS_MAP_DW*REG_NUM0-1:0]      cfg_alpg_ash_bus      ,
    input  [AS_MAP_DW*REG_NUM0-1:0]      cfg_alpg_asl_bus      ,
    input  [MEM_COPR_DW-1:0]             cfg_alpg_mem_copr     ,
    input  [DDR_AW-1:0]                  cfg_alpg_addr_d0      ,
    input  [DDR_AW-1:0]                  cfg_alpg_addr_d1      ,
    input  [DDR_AW-1:0]                  cfg_alpg_addr_p       ,
    input  [DATA_NUM_DW-1:0]             cfg_alpg_mem_size     ,
    input  [DDR_AW-1:0]                  cfg_alpg_base_addr    ,
    input  [DATA_NUM_DW-1:0]             cfg_alpg_data_num     ,
    //--------------------GT intf-----------------------
    input                                rx_data_sof           ,
    input                                rx_data_eof           ,
    input  [GT_DATA_LANE*GT_LANE_DW-1:0] rx_data_bus           ,
    input  [GT_DATA_LANE-1:0]            rx_data_vld_bus       ,
    output [GT_DATA_LANE*GT_LANE_DW-1:0] tx_data_bus           , 
    output [GT_DATA_LANE-1:0]            tx_data_vld_bus       , 
    //-------------------DDR CORE INTF------------------
    input                                ui_clk                ,
    output [DDR_DW-1:0]                  ddr_wr_data           ,   //写数据
    output                               ddr_wr_data_vld       ,   //写数据有效
    output [DDR_AW-1:0]                  ddr_wr_addr           ,   //写地址
    output                               ddr_wr_addr_vld       ,   //写地址有效
    output                               ddr_wr_addr_vld_last  ,   //最后一个写地址
    input                                ddr_rd_fifo_full      ,   //读满信号
    input                                ddr_wr_done           ,   //本次写完
    output [DDR_AW-1:0]                  ddr_rd_addr           ,   //读地址
    output                               ddr_rd_addr_vld       ,   //读地址有效
    output                               ddr_rd_addr_vld_last  ,   //最后一个读地址
    output                               ddr_task_rdy          ,   //下游模块准备好信
    input  [DDR_DW-1:0]                  ddr_rd_data           ,   //读取的数据
    input                                ddr_rd_data_vld       ,   //读取的数据有效
    input                                ddr_rd_done           ,   //本次读完
    //-----------------to ZYNQ GPIO---------------------
    output                               alpg_dps_start        ,
    //----------------timing core intf------------------
    input                                base_rate_clk         ,
    output                               pat_data_parse_vld    ,
    output  [TIMING_DW-1:0]              pattern_data_rate     ,
    //drv    
    output  [TIMING_DW-1:0]              pattern_a_clk_drv0    ,
    output  [TIMING_DW-1:0]              pattern_b_clk_drv0    ,
    output  [TIMING_DW-1:0]              pattern_c_clk_drv0    ,
    output  [TIMING_DW-1:0]              pattern_a_clk_drv1    ,
    output  [TIMING_DW-1:0]              pattern_b_clk_drv1    ,
    output  [TIMING_DW-1:0]              pattern_c_clk_drv1    ,
    //io    
    output  [TIMING_DW-1:0]              pattern_a_clk_io      ,
    output  [TIMING_DW-1:0]              pattern_b_clk_io      ,
    output  [TIMING_DW-1:0]              pattern_c_clk_io      ,
    output  [TIMING_DW-1:0]              pattern_drv_r         ,
    output  [TIMING_DW-1:0]              pattern_drv_f         ,
    output  [TIMING_DW-1:0]              pattern_strb          ,
    //------------------pat core intf-------------------
    //data cmp result
    input                                mflg_reg                   ,
    input                                pat_wr_req                 ,
    input   [DDR_AW-1:0]                 pat_wr_ddr_addr            ,
    input                                pat_wr_ddr_addr_vld        ,
    input                                pat_wr_ddr_addr_vld_last   ,                          
    input   [DDR_DW-1:0]                 pat_wr_ddr_data            ,
    input                                pat_wr_ddr_data_vld        ,
    //drv
    output                               ck_out                ,
    output                               we_out                ,
    //dio
    output  [CMD_DW-1:0]                 pattern_cmd           ,
    output                               pattern_me            ,
    output  [MSKTB_DW-1:0]               pattern_msktb         ,
    output  [BYTE_DW-1:0]                d_reg                 ,
    output                               pattern_dio           ,
    //---------------------DFX--------------------------
    output                               dfx_pattern_func    
);

wire init_start ;    
wire init_done  ;

alpg_ctrl_mst  alpg_ctrl_mst_inst (
  .clk            (clk            ),
  .rst            (rst            ),
  .alpg_start     (alpg_start     ),
  .alpg_restart   (alpg_restart   ),
  .alpg_stop      (alpg_stop      ),
  .alpg_work_busy (alpg_work_busy ),
  .alpg_done      (alpg_done      ),
  .init_start     (init_start     ),
  .init_done      (init_done      )
);

localparam  AS_DW             = 24;
localparam  AFM_DW            = 24;
localparam  AFM_NUM           = 6 ;
localparam  PROTCL_LEN        = 5 ;

wire [GT_LANE_DW-1:0]              gt_rx_data2        ;
wire [GT_LANE_DW-1:0]              gt_rx_data3        ;
wire                               gt_rx_data_vld     ;
wire [PROTCL_LEN * GT_LANE_DW-1:0] pat_func_data      ;
wire                               pat_func_data_vld  ;

assign gt_rx_data2    = rx_data_bus[GT_LANE_DW-1:0];
assign gt_rx_data3    = rx_data_bus[GT_DATA_LANE*GT_LANE_DW-1:GT_LANE_DW];
assign gt_rx_data_vld = rx_data_vld_bus[0];

alpg_pat_task # (
  .GT_LANE_DW    (GT_LANE_DW    ),
  .PROTCL_LEN    (PROTCL_LEN    ),
  .PC_DW         (PC_DW         ),
  .DATA_TYPE_DW  (DATA_TYPE_DW  ),
  .IDX_DW        (IDX_DW        ),
  .REG_NUM       (REG_NUM1      ),
  .RATE_DW       (RATE_DW       ),
  .AS_DW         (AS_DW         ),
  .AFM_DW        (AFM_DW        ),
  .AFM_NUM       (AFM_NUM       )
)
alpg_pat_task_inst (
  .clk                 (clk                 ),
  .rst                 (rst                 ),
  .gt_clk              (gt_clk              ),
  .cfg_alpg_data_type  (cfg_alpg_data_type  ),
  .cfg_alpg_start_pc   (cfg_alpg_start_pc   ),
  .cfg_alpg_cflg       (cfg_alpg_cflg       ),
  .cfg_alpg_indx_bus   (cfg_alpg_indx_bus   ),
  .rx_data_sof         (rx_data_sof         ),
  .rx_data_eof         (rx_data_eof         ),
  .gt_rx_data2         (gt_rx_data2         ),
  .gt_rx_data3         (gt_rx_data3         ),
  .gt_rx_data_vld      (gt_rx_data_vld      ),
  .alpg_start          (alpg_start          ),
  .alpg_restart        (alpg_restart        ),
  .alpg_stop           (alpg_stop           ),
  .mflg_reg            (mflg_reg            ),
  .clk_base            (clk_base            ),
  .pat_func_data       (pat_func_data       ),
  .pat_func_data_vld   (pat_func_data_vld   ),
  .dfx_pattern_func    (dfx_pattern_func    )
);

wire                rd_ddr_req           ;
wire  [DDR_AW-1:0]  rd_ddr_addr          ;
wire                rd_ddr_addr_vld      ;
wire                rd_ddr_addr_vld_last ;
wire  [DDR_DW-1:0]  rd_ddr_data          ;
wire                rd_ddr_data_vld      ;

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
  .DDR_DW      (BYTE_DW     ),
  .DDR_AW      (DDR_AW      ),
  .BYTE_DW     (BYTE_DW     ),
  .REG_NUM0    (REG_NUM0    ),
  .REG_NUM1    (REG_NUM1    ),
  .REG_NUM2    (REG_NUM2    ),
  .REG_NUM     (REG_NUM     ),
  .REG_SEL_DW  (REG_SEL_DW  ),
  .REG_DW      (REG_DW      )
)
alpg_data_prase_inst (
  .clk                    (clk                     ),
  .rst                    (rst                     ),
  .alpg_start             (alpg_start              ),
  .alpg_done              (alpg_done               ),
  .base_rate_clk          (base_rate_clk           ),
  .init_start             (init_start              ),
  .init_done              (init_done               ),
  .pat_func_data          (pat_func_data           ),
  .pat_func_data_vld      (pat_func_data_vld       ),
  .rd_ddr_req             (rd_ddr_req              ),
  .rd_ddr_addr            (rd_ddr_addr             ),
  .rd_ddr_addr_vld        (rd_ddr_addr_vld         ),
  .rd_ddr_addr_vld_last   (rd_ddr_addr_vld_last    ),
  .rd_ddr_data            (rd_ddr_data             ),
  .rd_ddr_data_vld        (rd_ddr_data_vld         ),
  .cfg_alpg_fmt_c0        (cfg_alpg_fmt_c0         ),
  .cfg_alpg_fmt_c1        (cfg_alpg_fmt_c1         ),
  .cfg_alpg_fmt_d0        (cfg_alpg_fmt_d0         ),
  .cfg_alpg_rate_bus      (cfg_alpg_rate_bus       ),
  .cfg_alpg_aclk1_bus     (cfg_alpg_aclk1_bus      ),
  .cfg_alpg_cclk1_bus     (cfg_alpg_cclk1_bus      ),
  .cfg_alpg_bclk1_bus     (cfg_alpg_bclk1_bus      ),
  .cfg_alpg_aclk2_bus     (cfg_alpg_aclk2_bus      ),
  .cfg_alpg_bclk2_bus     (cfg_alpg_bclk2_bus      ),
  .cfg_alpg_cclk2_bus     (cfg_alpg_cclk2_bus      ),
  .cfg_alpg_aclk3_bus     (cfg_alpg_aclk3_bus      ),
  .cfg_alpg_bclk3_bus     (cfg_alpg_bclk3_bus      ),
  .cfg_alpg_cclk3_bus     (cfg_alpg_cclk3_bus      ),
  .cfg_alpg_dre_r_bus     (cfg_alpg_dre_r_bus      ),
  .cfg_alpg_dre_f_bus     (cfg_alpg_dre_f_bus      ),
  .cfg_alpg_strb_bus      (cfg_alpg_strb_bus       ),
  .cfg_alpg_msktb         (cfg_alpg_msktb          ),
  .cfg_alpg_x             (cfg_alpg_x              ),
  .cfg_alpg_y             (cfg_alpg_y              ),
  .cfg_alpg_z             (cfg_alpg_z              ),
  .cfg_alpg_tp            (cfg_alpg_tp             ),
  .cfg_alpg_me            (cfg_alpg_me             ),
  .cfg_alpg_psta          (cfg_alpg_psta           ),
  .cfg_alpg_msta          (cfg_alpg_msta           ),
  .cfg_alpg_tph_bus       (cfg_alpg_tph_bus        ),
  .cfg_alpg_dreg_bus      (cfg_alpg_dreg_bus       ),
  .cfg_alpg_qreg_bus      (cfg_alpg_qreg_bus       ),
  .cfg_alpg_preg_bus      (cfg_alpg_preg_bus       ),
  .cfg_alpg_ash_bus       (cfg_alpg_ash_bus        ),
  .cfg_alpg_asl_bus       (cfg_alpg_asl_bus        ),
  .alpg_dps_start         (alpg_dps_start          ),
  .pat_data_parse_vld     (pat_data_parse_vld      ),
  .pattern_data_rate      (pattern_data_rate       ),
  .pattern_a_clk_drv0     (pattern_a_clk_drv0      ),
  .pattern_b_clk_drv0     (pattern_b_clk_drv0      ),
  .pattern_c_clk_drv0     (pattern_c_clk_drv0      ),
  .pattern_a_clk_drv1     (pattern_a_clk_drv1      ),
  .pattern_b_clk_drv1     (pattern_b_clk_drv1      ),
  .pattern_c_clk_drv1     (pattern_c_clk_drv1      ),
  .pattern_a_clk_io       (pattern_a_clk_io        ),
  .pattern_b_clk_io       (pattern_b_clk_io        ),
  .pattern_c_clk_io       (pattern_c_clk_io        ),
  .pattern_drv_r          (pattern_drv_r           ),
  .pattern_drv_f          (pattern_drv_f           ),
  .pattern_strb           (pattern_strb            ),
  .ck_out                 (ck_out                  ),
  .we_out                 (we_out                  ),
  .pattern_cmd            (pattern_cmd             ),
  .pattern_me             (pattern_me              ),
  .pattern_msktb          (pattern_msktb           ),
  .d_reg                  (d_reg                   ),
  .pattern_dio            (pattern_dio             )
);   


alpg_ddr_task # (
  .GT_DATA_LANE  (GT_DATA_LANE  ),
  .GT_LANE_DW    (GT_LANE_DW    ),
  .DATA_NUM_DW   (DATA_NUM_DW   ),
  .DATA_TYPE_DW  (DATA_TYPE_DW  ),
  .MEM_COPR_DW   (MEM_COPR_DW   ),
  .DDR_DW        (DDR_DW        ),
  .DDR_AW        (DDR_AW        )
)
alpg_ddr_task_inst (
  .clk                       (clk                       ),
  .rst                       (rst                       ),
  .alpg_start                (alpg_start                ),
  .alpg_restart              (alpg_restart              ),
  .alpg_done                 (alpg_done                 ),
  .alpg_stop                 (alpg_stop                 ),
  .alpg_wr_start             (alpg_wr_start             ),
  .alpg_rd_start             (alpg_rd_start             ),
  .alpg_mem_rst              (alpg_mem_rst              ),
  .alpg_mem_copy             (alpg_mem_copy             ),
  .cfg_alpg_mem_copr         (cfg_alpg_mem_copr         ),
  .cfg_alpg_addr_d0          (cfg_alpg_addr_d0          ),
  .cfg_alpg_addr_d1          (cfg_alpg_addr_d1          ),
  .cfg_alpg_addr_p           (cfg_alpg_addr_p           ),
  .cfg_alpg_mem_size         (cfg_alpg_mem_size         ),
  .gt_clk                    (gt_clk                    ),
  .cfg_alpg_base_addr        (cfg_alpg_base_addr        ),
  .cfg_alpg_data_num         (cfg_alpg_data_num         ),
  .cfg_alpg_data_type        (cfg_alpg_data_type        ),
  .rx_data_sof               (rx_data_sof               ),
  .rx_data_eof               (rx_data_eof               ),
  .rx_data_bus               (rx_data_bus               ),
  .rx_data_vld_bus           (rx_data_vld_bus           ),
  .tx_data_bus               (tx_data_bus               ),
  .tx_data_vld_bus           (tx_data_vld_bus           ),
  .pat_wr_req                (pat_wr_req                ),
  .pat_wr_ddr_addr           (pat_wr_ddr_addr           ),
  .pat_wr_ddr_addr_vld       (pat_wr_ddr_addr_vld       ),
  .pat_wr_ddr_addr_vld_last  (pat_wr_ddr_addr_vld_last  ),
  .pat_wr_ddr_data           (pat_wr_ddr_data           ),
  .pat_wr_ddr_data_vld       (pat_wr_ddr_data_vld       ),
  .pat_rd_req                (rd_ddr_req                ),
  .pat_rd_ddr_addr           (rd_ddr_addr               ),
  .pat_rd_ddr_addr_vld       (rd_ddr_addr_vld           ),
  .pat_rd_ddr_addr_vld_last  (rd_ddr_addr_vld_last      ),
  .pat_rd_ddr_data           (rd_ddr_data               ),
  .pat_rd_ddr_data_vld       (rd_ddr_data_vld           ),
  .ui_clk                    (ui_clk                    ),
  .ddr_wr_data               (ddr_wr_data               ),
  .ddr_wr_data_vld           (ddr_wr_data_vld           ),
  .ddr_wr_addr               (ddr_wr_addr               ),
  .ddr_wr_addr_vld           (ddr_wr_addr_vld           ),
  .ddr_wr_addr_vld_last      (ddr_wr_addr_vld_last      ),
  .ddr_rd_fifo_full          (ddr_rd_fifo_full          ),
  .ddr_wr_done               (ddr_wr_done               ),
  .ddr_rd_addr               (ddr_rd_addr               ),
  .ddr_rd_addr_vld           (ddr_rd_addr_vld           ),
  .ddr_rd_addr_vld_last      (ddr_rd_addr_vld_last      ),
  .ddr_task_rdy              (ddr_task_rdy              ),
  .ddr_rd_data               (ddr_rd_data               ),
  .ddr_rd_data_vld           (ddr_rd_data_vld           ),
  .ddr_rd_done               (ddr_rd_done               )
);

endmodule    
