//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-28
// Module Name           : pmu_core
// Project Name          : HV
// Target Devices        : xc7z015
// Tool Versions         : Vivado 2020.2
// Description           : 
// 
// Dependencies          : hv_top
// 
// Revision              :
//                        Revision v0.01 - File Created
// Additional Comments   :
// 
//////////////////////////////////////////////////////////////////////////////////
module pmu_core 
#(
    parameter PMU_TIME_DW     = 15   ,
    parameter PMU_TEST_NUM_DW = 16   ,
    parameter DATA_TYPE_WIDTH = 2    ,
    parameter SYS_MOD_DW      = 3    ,
    parameter PMU_MOD_DW      = 3    ,
    parameter PMU_VLU_DW      = 3    ,
    parameter PMU_VI_DW       = 26   ,
    parameter CH_NUM          = 4    ,
    parameter SMP_DW          = 16   ,
    parameter AXIS_FIFO_DW    = 32   ,
    parameter MA_RESULT_DW    = 26   ,  //pck data dw
    parameter PMU_CLOSE_T_DW  = 20   ,
    parameter PMU_SMP_WAIT_DW = 16   ,
    parameter AD5522_DFX_DW   = 2
) 
(
    input                             clk                        ,
    input                             rst                        ,
    //cfg
    input      [PMU_TIME_DW-1:0]      cfg_pmu_time               ,
    input      [PMU_SMP_WAIT_DW-1:0]  cfg_pmu_smp_wait_time      ,          //need > 100us
    input      [PMU_TEST_NUM_DW-1:0]  cfg_pmu_test_num           ,
    input      [CH_NUM-1:0]           cfg_pmu_ch_en              ,
    input      [SYS_MOD_DW-1:0]       cfg_sys_work_mode          ,       //0:test mod; 1:diag mod; 2:cal mod
    input      [PMU_MOD_DW-1:0]       cfg_pmu_test_mode          ,       //0:FVMV; 1:FVMI; 2:FIMI; 3:FIMV
    input      [PMU_VLU_DW-1:0]       cfg_pmu_cur_value          ,       //0:??5ua; 1:??20uA; 2:??200uA; 3:??2mA; 4:??25mA;
    //input      [PMU_VI_DW-1:0]        cfg_pmu_vol_value          ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_ch0_value          ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_ch1_value          ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_ch2_value          ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_ch3_value          ,
    input      [CH_NUM-1:0]           cfg_pmu_cmp_en             ,
    input                             cfg_pmu_cmp_type           ,       //0:I ; 1:V
    input      [PMU_VI_DW-1:0]        cfg_pmu_cmp_h              ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_cmp_l              ,
    input      [CH_NUM-1:0]           cfg_pmu_clamp_en           ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_clamp_h            ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_clamp_l            ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_vchk               ,       //used in diag mod
    input      [PMU_VI_DW-1:0]        cfg_pmu_ichk               ,       //used in diag mod
    input                             cfg_pmu_store_en           ,
    input      [DATA_TYPE_WIDTH-1:0]  cfg_data_type              ,      //0-mean data;1-smp data
    input      [PMU_VI_DW-1:0]        cfg_pmu_cmp_orgh           ,
    input      [PMU_VI_DW-1:0]        cfg_pmu_cmp_orgl           ,
    input      [PMU_CLOSE_T_DW-1:0]   cfg_pmu_close_time         ,       //step is 100us
    //cmd
    input                             pmu_work_start             ,
    output                            pmu_busy                   ,
    input                             pmu_rd_start               ,
    input                             ad5522_warn_clear          ,
    //adc data
    //output                            pmu_drv_done               ,
    input                             adc_ready                  ,
    output                            pmu_smp_start              ,
    input      [SMP_DW-1:0]           pmu_smp_dataa              ,
    input      [SMP_DW-1:0]           pmu_smp_datab              ,
    input                             pmu_smp_data_vld           ,
    //connect axis_fifo_ctrl
    output     [AXIS_FIFO_DW-1:0]     pl_rd_data                 ,
    output                            pl_rd_data_vld             ,
    input                             pl_rd_en                   ,
    output                            pmu_pck_start              ,
    input                             packet_done                ,
    //connect AD5522  
    output                            pmu_spi_clk                ,
    output                            pmu_spi_csn                ,
    input                             pmu_spi_sdi                ,
    output                            pmu_spi_sdo                ,
    output                            pmu_spi_lvds               ,
    input                             pmu_busyn                  ,
    input                             pmu_cgalm                  ,
    input                             pmu_tmpn                   ,
    output                            pmu_rstn                   ,
    output                            pmu_loadn                  ,
    //dfx
    output     [AD5522_DFX_DW-1:0]    dfx_ad5522_warn             
);

// Parameters
localparam  PMU_CFG_DW      = 29;
localparam  SPI_DIV         = 8 ;
localparam  SPI_CPO         = 0 ;
localparam  SPI_CPH         = 1 ;
//ports
wire                     pmu_work_busy     ;
wire                     pmu_work_done     ;
wire                     pmu_drv_start     ;
wire                     pmu_drv_done      ;
wire                     pmu_smp_done      ;
wire                     pmu_smp_busy      ;
//wire                     pmu_rd_start      ;
//wire                     pmu_pck_start     ;
wire                     pmu_pck_done      ;
wire                     pmu_close         ;
wire                     pmu_cfg_rd_req    ;
wire                     pmu_cfg_rd_done   ;
wire                     pmu_cfg_wr_req    ;
wire                     pmu_cfg_wr_done   ;
wire [PMU_CFG_DW-1:0]    pmu_cfg_wr_data   ;
wire [PMU_CFG_DW-1:0]    pmu_cmp_result    ;
wire                     pmu_cmp_result_vld;
wire [CH_NUM*2-1:0]      pmu_cmp_rslt2pck  ;
wire                     ad5522_rst_busy   ;
//dfx
wire                     dfx_fifo_empty_rd ;
wire                     dfx_fifo_full_wr  ;
wire                     dfx_cmp_err       ;

assign pmu_busy = pmu_work_busy || ad5522_rst_busy ;

  pmu_ctrl_mst # (
    .PMU_TIME_DW    (PMU_TIME_DW    ),
    .PMU_CLOSE_T_DW (PMU_CLOSE_T_DW ),
    .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW),
    .PMU_SMP_WAIT_DW(PMU_SMP_WAIT_DW)
  )
  pmu_ctrl_mst_inst (
    .clk               (clk               ),    // I , 1 bit
    .rst               (rst               ),    // I , 1 bit
    .cfg_pmu_time      (cfg_pmu_time      ),    // I , PMU_TIME_DW bit
    .cfg_pmu_smp_wait_time(cfg_pmu_smp_wait_time),    // I , PMU_SMP_WAIT_DW bit
    .cfg_pmu_test_num  (cfg_pmu_test_num  ),    // I , PMU_TEST_NUM_DW bit
    .cfg_pmu_close_time(cfg_pmu_close_time),    // I
    .adc_ready         (adc_ready         ),    // I , 1 bit
    .pmu_close         (pmu_close         ),    // O , 1 bit
    .pmu_cfg_rd_done   (pmu_cfg_rd_done   ),    // I , 1 bit
    .pmu_smp_start     (pmu_smp_start     ),    // O , 1 bit
    .pmu_work_start    (pmu_work_start    ),    // I , 1 bit
    .pmu_work_busy     (pmu_work_busy     ),    // O , 1 bit
    .pmu_work_done     (pmu_work_done     ),    // O , 1 bit
    .pmu_drv_start     (pmu_drv_start     ),    // O , 1 bit
    .pmu_drv_done      (pmu_drv_done      ),    // I , 1 bit
    .pmu_smp_done      (pmu_smp_done      ),    // I , 1 bit
    .pmu_smp_busy      (pmu_smp_busy      ),    // O , 1 bit
    .pmu_rd_start      (pmu_rd_start      ),    // I , 1 bit
    .pmu_pck_start     (pmu_pck_start     ),    // O , 1 bit
    .pmu_pck_done      (packet_done       )     // I , 1 bit
  );

  pmu_task # (
    .SYS_MOD_DW     (SYS_MOD_DW     ),
    .PMU_MOD_DW     (PMU_MOD_DW     ),
    .PMU_VLU_DW     (PMU_VLU_DW     ),
    .PMU_VI_DW      (PMU_VI_DW      ),
    .CH_NUM         (CH_NUM         ),
    .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW),
    .PMU_CFG_DW     (PMU_CFG_DW     )
  )
  pmu_task_inst (
    .clk               (clk               ),   // I , 1 bit
    .rst               (rst               ),   // I , 1 bit
    .pmu_work_start    (pmu_work_start    ),   // I , 1 bit
    .pmu_drv_start     (pmu_drv_start     ),   // I , 1 bit
    .pmu_drv_done      (pmu_drv_done      ),   // O , 1 bit
    .pmu_cfg_rd_req    (pmu_cfg_rd_req    ),   // O , 1 bit
    .pmu_cfg_rd_done   (pmu_cfg_rd_done   ),   // I , 1 bit
    .pmu_cfg_wr_req    (pmu_cfg_wr_req    ),   // O , 1 bit
    .pmu_cfg_wr_done   (pmu_cfg_wr_done   ),   // I , 1 bit
    .pmu_busyn         (pmu_busyn         ),   // I , 1 bit
    .pmu_close         (pmu_close         ),   // I , 1 bit
    .pmu_smp_done      (pmu_smp_done      ),   // I , 1 bit
    .cfg_pmu_ch_en     (cfg_pmu_ch_en     ),   // I , CH_NUM bit
    .cfg_sys_work_mode (cfg_sys_work_mode ),   // I , SYS_MOD_DW bit
    .cfg_pmu_test_mode (cfg_pmu_test_mode ),   // I , PMU_MOD_DW bit
    .cfg_pmu_cur_value (cfg_pmu_cur_value ),   // I , PMU_VLU_DW bit
    //.cfg_pmu_vol_value (cfg_pmu_vol_value ),   // I , PMU_VI_DW bit
    .cfg_pmu_ch0_value (cfg_pmu_ch0_value ),   // I , PMU_VI_DW bit
    .cfg_pmu_ch1_value (cfg_pmu_ch1_value ),   // I , PMU_VI_DW bit
    .cfg_pmu_ch2_value (cfg_pmu_ch2_value ),   // I , PMU_VI_DW bit
    .cfg_pmu_ch3_value (cfg_pmu_ch3_value ),   // I , PMU_VI_DW bit 
    .cfg_pmu_cmp_en    (cfg_pmu_cmp_en    ),   // I , CH_NUM bit
    .cfg_pmu_cmp_type  (cfg_pmu_cmp_type  ),   // I , 1 bit
    .cfg_pmu_cmp_h     (cfg_pmu_cmp_h     ),   // I , PMU_VI_DW bit
    .cfg_pmu_cmp_l     (cfg_pmu_cmp_l     ),   // I , PMU_VI_DW bit
    .cfg_pmu_clamp_en  (cfg_pmu_clamp_en  ),   // I , CH_NUM bit
    .cfg_pmu_clamp_h   (cfg_pmu_clamp_h   ),   // I , PMU_VI_DW bit
    .cfg_pmu_clamp_l   (cfg_pmu_clamp_l   ),   // I , PMU_VI_DW bit
    .cfg_pmu_vchk      (cfg_pmu_vchk      ),   // I , PMU_VI_DW bit
    .cfg_pmu_ichk      (cfg_pmu_ichk      ),   // I , PMU_VI_DW bit
    .pmu_cfg_wr_data   (pmu_cfg_wr_data   ),   // O , PMU_CFG_DW bit
    .pmu_cmp_result    (pmu_cmp_result    ),   // I , PMU_CFG_DW bit
    .pmu_cmp_result_vld(pmu_cmp_result_vld),   // I , 1 bit
    .pmu_cmp_rslt2pck  (pmu_cmp_rslt2pck  )    // O , CH_NUM*2 bit
  );

  pmu_data_pck # (
    .SMP_DW         (SMP_DW         ),
    .CH_NUM         (CH_NUM         ),
    .DATA_TYPE_WIDTH(DATA_TYPE_WIDTH),
    .PMU_MOD_DW     (PMU_MOD_DW     ),
    .PMU_VLU_DW     (PMU_VLU_DW     ),
    .AXIS_FIFO_DW   (AXIS_FIFO_DW   ),
    .MA_RESULT_DW   (MA_RESULT_DW   ),
    .PMU_VI_DW      (PMU_VI_DW      ),
    .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW)
  )
  pmu_data_pck_inst (
    .clk               (clk               ),    // I , 1 bit
    .rst               (rst               ),    // I , 1 bit
    .pmu_work_start    (pmu_work_start    ),    // I , 1 bit
    .pmu_work_done     (pmu_work_done     ),    // I , 1 bit
    .cfg_pmu_cur_value (cfg_pmu_cur_value ),    // I , PMU_VLU_DW bit
    .cfg_pmu_test_mode (cfg_pmu_test_mode ),    // I , PMU_MOD_DW bit
    .pmu_store_en      (cfg_pmu_store_en  ),    // I , 1 bit
    .cfg_data_type     (cfg_data_type     ),    // I , DATA_TYPE_WIDTH bit 
    .cfg_pmu_test_num  (cfg_pmu_test_num  ),    // I , PMU_TEST_NUM_DW bit
    .cfg_pmu_cmp_h     (cfg_pmu_cmp_orgh  ),    // I , PMU_VI_DW bit
    .cfg_pmu_cmp_l     (cfg_pmu_cmp_orgl  ),    // I , PMU_VI_DW bit
    .pmu_smp_busy      (pmu_smp_busy      ),    // I , 1 bit
    .pmu_smp_done      (pmu_smp_done      ),    // O , 1 bit
    .pmu_cmp_result    (pmu_cmp_rslt2pck  ),    // I , CH_NUM*2 bit
    .pmu_smp_dataa     (pmu_smp_dataa     ),    // I , SMP_DW bit
    .pmu_smp_datab     (pmu_smp_datab     ),    // I , SMP_DW bit
    .pmu_smp_data_vld  (pmu_smp_data_vld  ),    // I , 1 bit
    .pl_rd_data        (pl_rd_data        ),    // O , AXIS_FIFO_DW bit
    .pl_rd_data_vld    (pl_rd_data_vld    ),    // O , 1 bit
    .pl_rd_en          (pl_rd_en          ),    // I , 1 bit
    .dfx_fifo_empty_rd (dfx_fifo_empty_rd ),    // O , 1 bit
    .dfx_fifo_full_wr  (dfx_fifo_full_wr  )     // O , 1 bit
  );

  pmu_drv # (
    .PMU_CFG_DW   (PMU_CFG_DW   ),
    .SPI_DIV      (SPI_DIV      ),
    .SPI_CPO      (SPI_CPO      ),
    .SPI_CPH      (SPI_CPH      ),
    .AD5522_DFX_DW(AD5522_DFX_DW)
  )
  pmu_drv_inst (
    .clk               (clk               ),   // I , 1 bit
    .rst               (rst               ),   // I , 1 bit
    .pmu_cfg_rd_req    (pmu_cfg_rd_req    ),   // I , 1 bit
    .pmu_cfg_rd_done   (pmu_cfg_rd_done   ),   // O , 1 bit
    .pmu_cfg_wr_req    (pmu_cfg_wr_req    ),   // I , 1 bit
    .pmu_cfg_wr_done   (pmu_cfg_wr_done   ),   // O , 1 bit
    .pmu_cfg_wr_data   (pmu_cfg_wr_data   ),   // I , PMU_CFG_DW bit
    .pmu_cmp_result    (pmu_cmp_result    ),   // O , PMU_CFG_DW bit
    .pmu_cmp_result_vld(pmu_cmp_result_vld),   // O , 1 bit
    .pmu_spi_clk       (pmu_spi_clk       ),   // O , 1 bit
    .pmu_spi_csn       (pmu_spi_csn       ),   // O , 1 bit
    .pmu_spi_sdi       (pmu_spi_sdi       ),   // I , 1 bit
    .pmu_spi_sdo       (pmu_spi_sdo       ),   // O , 1 bit
    .pmu_spi_lvds      (pmu_spi_lvds      ),   // O , 1 bit
    .pmu_busyn         (pmu_busyn         ),   // I , 1 bit
    .pmu_cgalm         (pmu_cgalm         ),   // I , 1 bit
    .pmu_tmpn          (pmu_tmpn          ),   // I , 1 bit
    .pmu_rstn          (pmu_rstn          ),   // O , 1 bit
    .pmu_loadn         (pmu_loadn         ),   // O , 1 bit
    .ad5522_warn_clear (ad5522_warn_clear ),   // I , 1 bit 
    .ad5522_rst_busy   (ad5522_rst_busy   ),   // O , 1 bit
    .dfx_ad5522_warn   (dfx_ad5522_warn   ),   // O , AD5522_DFX_DW bit
    .dfx_cmp_err       (dfx_cmp_err       )    // O , 1 bit
  );


endmodule