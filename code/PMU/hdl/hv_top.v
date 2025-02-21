`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2024-08-09
// Module Name           : hv_top
// Project Name          : 
// Target Devices        : 
// Tool Versions         : Vivado 2020.2
// Description           : 
// 
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
//                        Revision v0.02 - Add pmu close ctrl function;
//                        Revision v0.03 - Add the ability to convert ADC data to voltage and current, and make code optimizations -2024-09-18
//                        Revision v0.04 - 1.Modify the mean to enable the original data store;
//                                         2.Add data upload type: Raw Value/Mean Value;              --2024/10/31                    
// Additional Comments   :
// 
//////////////////////////////////////////////////////////////////////////////////

module hv_top
(
    input pl_clk_50m ,

    inout [14:0]DDR_addr           ,
    inout [2:0] DDR_ba             ,
    inout       DDR_cas_n          ,
    inout       DDR_ck_n           ,
    inout       DDR_ck_p           ,
    inout       DDR_cke            ,
    inout       DDR_cs_n           ,
    inout [3:0] DDR_dm             ,
    inout [31:0]DDR_dq             ,
    inout [3:0] DDR_dqs_n          ,
    inout [3:0] DDR_dqs_p          ,
    inout       DDR_odt            ,
    inout       DDR_ras_n          ,
    inout       DDR_reset_n        ,
    inout       DDR_we_n           ,
    inout       FIXED_IO_ddr_vrn   ,
    inout       FIXED_IO_ddr_vrp   ,
    inout [53:0]FIXED_IO_mio       ,
    inout       FIXED_IO_ps_clk    ,
    inout       FIXED_IO_ps_porb   ,
    inout       FIXED_IO_ps_srstb  ,
    //AD5522
    output      pmu_spi_clk        ,
    output      pmu_spi_csn        ,
    input       pmu_spi_sdi        ,
    output      pmu_spi_sdo        ,
    output      pmu_spi_lvds       ,
    input       pmu_busyn          ,
    input       pmu_cgalm          ,
    input       pmu_tmpn           ,
    output      pmu_loadn          ,
    output      pmu_rstn           ,
    //ADS8686S                                         
    input       ad8686_busy        ,//      ADS8686S处于工作状态指示信号
    input       ad8686_db11_sdob   ,//      SDOB串行数据输入引脚
    input       ad8686_db12_sdoa   ,//      SDOA串行数据输入引脚
    output      ad8686_refsel      ,//      芯片的参考基准选择信号(完全复位时锁存)
    output      ad8686_reset_n     ,//      芯片的复位信号
    output      ad8686_seqen       ,//      序列发生器的控制信号(完全复位时锁存)
    output [1:0]ad8686_rangesel    ,//      选择硬件或软件的模式运行(完全复位时锁存)
    output      ad8686_ser_byte_par,//      选择串行/字节/并行接口(完全复位时锁存)
    output      ad8686_db0         ,//      硬件串行时直接接低电平
    output      ad8686_db1         ,//      硬件串行时直接接低电平
    output      ad8686_db2         ,//      硬件串行时直接接低电平
    output      ad8686_db3         ,//      硬件串行时直接接低电平
    output      ad8686_db4_ser1w   ,//      选择SDOA输出还是SDOA和SDOB同时输出(完全复位时锁存)
    output      ad8686_db5_crcen   ,//      CRC校验功能使能(完全复位时锁存)
    output      ad8686_db6         ,//      硬件串行时直接接低电平
    output      ad8686_db7         ,//      硬件串行时直接接低电平
    output      ad8686_db8         ,//      硬件串行时直接接低电平
    output      ad8686_db9_bytesel ,//      字节接口模式/串行接口模式选择（完全复位时锁存)
    output      ad8686_db10_sdi    ,//      硬件串行时直接接低电平
    output      ad8686_db13_os0    ,//      过采样选择位0 (完全复位时锁存)
    output      ad8686_db14_os1    ,//      过采样选择位1(完全复位时锁存)
    output      ad8686_db15_os2    ,//      过采样选择位2(完全复位时锁存)
    output      ad8686_wr_burst    ,//      启用或者禁用突发模式(完全复位时锁存)
    output      ad8686_sclk_rd     ,//      对ADS8686S进行访问的同步时钟
    output      ad8686_cs_n        ,//      片选信号
    output [2:0]ad8686_chsel       ,//      为下一次转换选择通道
    output      ad8686_convst       //      启动一次转换
);

localparam  FPGA_DATA       = 'h20240925;
localparam  FPGA_VER        = 'h00000001;

localparam  PS_BRAM_AW      = 16 ;
localparam  PS_BRAM_DW      = 32 ;
localparam  EN_WIDTH        = PS_BRAM_DW/8  ;
localparam  DATA_TYPE_WIDTH = 2  ;
localparam  FIFO_DW         = 32 ;
localparam  MA_RESULT_DW    = 26 ;
localparam  PMU_TIME_DW     = 32 ;
localparam  PMU_TEST_NUM_DW = 16 ;
localparam  SYS_MOD_DW      = 3  ;
localparam  PMU_MOD_DW      = 3  ;
localparam  PMU_VLU_DW      = 3  ;
localparam  PMU_VI_DW       = 26 ;
localparam  CH_NUM          = 4  ;
localparam  SMP_DW          = 16 ;
localparam  AXIS_FIFO_DW    = 32 ;
localparam  AD5522_DFX_DW   = 2  ;
localparam  PMU_CLOSE_T_DW  = 20 ;
localparam  PMU_SMP_WAIT_DW = 16 ;

(*mark_debug="true"*)(*keep="true"*)wire                                 ps_axi_bram_clk    ;
(*mark_debug="true"*)(*keep="true"*)wire                                 ps_axi_bram_rst    ;
(*mark_debug="true"*)(*keep="true"*)wire [PS_BRAM_AW-1:0]                ps_axi_bram_addr   ;
(*mark_debug="true"*)(*keep="true"*)wire                                 ps_axi_bram_en     ;
(*mark_debug="true"*)(*keep="true"*)wire [EN_WIDTH-1:0]                  ps_axi_bram_we     ;
(*mark_debug="true"*)(*keep="true"*)wire [PS_BRAM_DW-1:0]                ps_axi_bram_wrdata ;
(*mark_debug="true"*)(*keep="true"*)wire [PS_BRAM_DW-1:0]                ps_axi_bram_rddata ;
(*mark_debug="true"*)(*keep="true"*)wire                                 packet_start       ;
(*mark_debug="true"*)(*keep="true"*)wire [DATA_TYPE_WIDTH-1:0]           cfg_data_type      ;

(*mark_debug="true"*)(*keep="true"*)wire [FIFO_DW-1:0]                   axis_fifo_wr_data  ;
(*mark_debug="true"*)(*keep="true"*)wire                                 axis_fifo_last     ;
(*mark_debug="true"*)(*keep="true"*)wire                                 axis_fifo_ready    ;
(*mark_debug="true"*)(*keep="true"*)wire                                 axis_fifo_valid    ;  
(*mark_debug="true"*)(*keep="true"*)wire [FIFO_DW-1:0]                   pl_rd_data         ;
(*mark_debug="true"*)(*keep="true"*)wire                                 pl_rd_data_vld     ;
(*mark_debug="true"*)(*keep="true"*)wire                                 pl_rd_en           ;

(*mark_debug="true"*)(*keep="true"*)reg  [PMU_TEST_NUM_DW-1:0]           cfg_data_num = 'd0 ;

(*mark_debug="true"*)(*keep="true"*)wire [PMU_TIME_DW-1:0]     cfg_pmu_time     ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_TEST_NUM_DW-1:0] cfg_pmu_test_num ;
(*mark_debug="true"*)(*keep="true"*)wire [CH_NUM-1:0]          cfg_pmu_ch_en    ;
(*mark_debug="true"*)(*keep="true"*)wire [SYS_MOD_DW-1:0]      cfg_sys_work_mode;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_MOD_DW-1:0]      cfg_pmu_test_mode;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VLU_DW-1:0]      cfg_pmu_cur_value;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VI_DW-1:0]       cfg_pmu_vol_value;
(*mark_debug="true"*)(*keep="true"*)wire [CH_NUM-1:0]          cfg_pmu_cmp_en   ;
(*mark_debug="true"*)(*keep="true"*)wire                       cfg_pmu_cmp_type ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VI_DW-1:0]       cfg_pmu_cmp_h    ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VI_DW-1:0]       cfg_pmu_cmp_l    ;
(*mark_debug="true"*)(*keep="true"*)wire [CH_NUM-1:0]          cfg_pmu_clamp_en ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VI_DW-1:0]       cfg_pmu_clamp_h  ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VI_DW-1:0]       cfg_pmu_clamp_l  ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VI_DW-1:0]       cfg_pmu_vchk     ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_VI_DW-1:0]       cfg_pmu_ichk     ;
(*mark_debug="true"*)(*keep="true"*)wire                       cfg_pmu_store_en ;
(*mark_debug="true"*)(*keep="true"*)wire                       pmu_work_start   ;
(*mark_debug="true"*)(*keep="true"*)wire                       pmu_busy         ;
(*mark_debug="true"*)(*keep="true"*)wire                       pmu_rd_start     ;
(*mark_debug="true"*)(*keep="true"*)wire                       ad5522_warn_clear;
(*mark_debug="true"*)(*keep="true"*)wire                       pmu_drv_done     ;
(*mark_debug="true"*)(*keep="true"*)wire [SMP_DW-1:0]          pmu_smp_dataa    ;
(*mark_debug="true"*)(*keep="true"*)wire [SMP_DW-1:0]          pmu_smp_datab    ;
(*mark_debug="true"*)(*keep="true"*)wire                       pmu_smp_data_vld ;
(*mark_debug="true"*)(*keep="true"*)wire                       packet_done      ;
(*mark_debug="true"*)(*keep="true"*)wire                       pmu_pck_start    ;
(*mark_debug="true"*)(*keep="true"*)wire [AD5522_DFX_DW-1:0]   dfx_ad5522_warn  ;
(*mark_debug="true"*)(*keep="true"*)wire                       ps_sys_rst       ;
wire [PMU_VI_DW-1:0]       cfg_pmu_cmp_orgh    ;
wire [PMU_VI_DW-1:0]       cfg_pmu_cmp_orgl    ;
wire [PMU_VI_DW-1:0]       cfg_pmu_ch0_value   ;
wire [PMU_VI_DW-1:0]       cfg_pmu_ch1_value   ;
wire [PMU_VI_DW-1:0]       cfg_pmu_ch2_value   ;
wire [PMU_VI_DW-1:0]       cfg_pmu_ch3_value   ;
(*mark_debug="true"*)(*keep="true"*)wire [PMU_CLOSE_T_DW-1:0]  cfg_pmu_close_time  ;
wire [PMU_SMP_WAIT_DW-1:0] cfg_pmu_smp_wait_time;
 
wire                   sys_clk       ;
wire                   adc_ready     ;
wire                   pmu_smp_start ;

//==========================================================================
//rst gen
//==========================================================================
(*mark_debug="true"*)(*keep="true"*)wire      ext_rst      ;
(*mark_debug="true"*)(*keep="true"*)wire      sys_rst      ;
(*mark_debug="true"*)(*keep="true"*)reg [3:0] rst_cnt = 'd0;

assign ext_rst = (rst_cnt > 'd10);

always @(posedge pl_clk_50m) 
begin
  if(!ext_rst)
  begin
    rst_cnt <= rst_cnt + 'd1;
  end
  else
  begin
    rst_cnt <= rst_cnt;
  end  
end

(*mark_debug="true"*)(*keep="true"*)wire clk_locked;
wire sys_rstn;

clk_wiz_0 instance_name
(
 // Clock out ports
 .clk_out1(sys_clk        ),     // output clk_out1
 .locked  (sys_rstn       ),     // output locked
// Clock in ports
 .clk_in1 (pl_clk_50m     )      // input clk_in1
 );    

//=====================================================================
//pl data gen
//=====================================================================
always @(posedge sys_clk) 
begin
  //if(cfg_pmu_store_en)
  if(cfg_data_type == 'd0)
  begin
    cfg_data_num <= CH_NUM; 
  end
  else
  begin
    cfg_data_num <= cfg_pmu_test_num << 2;  
  end    
end

//=====================================================================
//ps bd
//=====================================================================
design_1_wrapper u_design_1_wrapper
(
  .DDR_addr         (DDR_addr            ),
  .DDR_ba           (DDR_ba              ),
  .DDR_cas_n        (DDR_cas_n           ),
  .DDR_ck_n         (DDR_ck_n            ),
  .DDR_ck_p         (DDR_ck_p            ),
  .DDR_cke          (DDR_cke             ),
  .DDR_cs_n         (DDR_cs_n            ),
  .DDR_dm           (DDR_dm              ),
  .DDR_dq           (DDR_dq              ),
  .DDR_dqs_n        (DDR_dqs_n           ),
  .DDR_dqs_p        (DDR_dqs_p           ),
  .DDR_odt          (DDR_odt             ),
  .DDR_ras_n        (DDR_ras_n           ),
  .DDR_reset_n      (DDR_reset_n         ),
  .DDR_we_n         (DDR_we_n            ),
  .FIXED_IO_ddr_vrn (FIXED_IO_ddr_vrn    ),
  .FIXED_IO_ddr_vrp (FIXED_IO_ddr_vrp    ),
  .FIXED_IO_mio     (FIXED_IO_mio        ),
  .FIXED_IO_ps_clk  (FIXED_IO_ps_clk     ),
  .FIXED_IO_ps_porb (FIXED_IO_ps_porb    ),
  .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb   ),
  .BRAM_PORTA_0_addr(ps_axi_bram_addr    ),
  .BRAM_PORTA_0_clk (ps_axi_bram_clk     ),
  .BRAM_PORTA_0_din (ps_axi_bram_wrdata  ),
  .BRAM_PORTA_0_dout(ps_axi_bram_rddata  ),
  .BRAM_PORTA_0_en  (ps_axi_bram_en      ),
  .BRAM_PORTA_0_rst (ps_axi_bram_rst     ),
  .BRAM_PORTA_0_we  (ps_axi_bram_we      ), 
  .S_AXIS_0_tdata   (axis_fifo_wr_data   ),
  .S_AXIS_0_tlast   (axis_fifo_last      ),
  .S_AXIS_0_tready  (axis_fifo_ready     ),
  .S_AXIS_0_tvalid  (axis_fifo_valid     ),
  .s_axis_aclk_0    (sys_clk             ),
  .s_axis_aresetn_0 (sys_rstn            )
);

//=====================================================================
//pl inst
//=====================================================================
axi_bram_ctrl 
#(
  .AXI_BRAM_AW       (PS_BRAM_AW        ),
  .AXI_BRAM_DW       (PS_BRAM_DW        ),
  .DATA_TYPE_WIDTH   (DATA_TYPE_WIDTH   ),
  .PMU_TIME_DW       (PMU_TIME_DW       ),
  .PMU_TEST_NUM_DW   (PMU_TEST_NUM_DW   ),
  .SYS_MOD_DW        (SYS_MOD_DW        ),
  .PMU_MOD_DW        (PMU_MOD_DW        ),
  .PMU_VLU_DW        (PMU_VLU_DW        ),
  .PMU_VI_DW         (PMU_VI_DW         ),
  .CH_NUM            (CH_NUM            ),
  .SMP_DW            (SMP_DW            ),
  .AXIS_FIFO_DW      (AXIS_FIFO_DW      ),
  .MA_RESULT_DW      (MA_RESULT_DW      ),
  .PMU_CLOSE_T_DW    (PMU_CLOSE_T_DW    ),
  .PMU_SMP_WAIT_DW   (PMU_SMP_WAIT_DW   ),
  .AD5522_DFX_DW     (AD5522_DFX_DW     )
)
axi_bram_ctrl_inst (
  .clk               (sys_clk           ),     // I , 1 bit
  .rst               (~sys_rstn         ),     // I , 1 bit
  .ps_axi_bram_clk   (ps_axi_bram_clk   ),     // I , 1 bit
  .ps_axi_bram_rst   (ps_axi_bram_rst   ),     // I , 1 bit
  .ps_axi_bram_addr  (ps_axi_bram_addr  ),     // I , AXI_BRAM_AW bit
  .ps_axi_bram_en    (ps_axi_bram_en    ),     // I , 1 bit
  .ps_axi_bram_we    (ps_axi_bram_we    ),     // I , EN_WIDTH bit
  .ps_axi_bram_wrdata(ps_axi_bram_wrdata),     // I , AXI_BRAM_DW bit
  .ps_axi_bram_rddata(ps_axi_bram_rddata),     // O , AXI_BRAM_DW bit
  //cfg
  .cfg_pmu_time      (cfg_pmu_time      ),     // O , PMU_TIME_DW bit
  .cfg_pmu_smp_wait_time  (cfg_pmu_smp_wait_time),     // O , PMU_SMP_WAIT_DW bit
  .cfg_pmu_test_num  (cfg_pmu_test_num  ),     // O , PMU_TEST_NUM_DW bit
  .cfg_pmu_ch_en     (cfg_pmu_ch_en     ),     // O , CH_NUM bit
  .cfg_sys_work_mode (cfg_sys_work_mode ),     // O , SYS_MOD_DW bit
  .cfg_pmu_test_mode (cfg_pmu_test_mode ),     // O , PMU_MOD_DW bit
  .cfg_pmu_cur_value (cfg_pmu_cur_value ),     // O , PMU_VLU_DW bit
  .cfg_pmu_ch0_value (cfg_pmu_ch0_value ),     // O , PMU_VI_DW bit
  .cfg_pmu_ch1_value (cfg_pmu_ch1_value ),     // O , PMU_VI_DW bit
  .cfg_pmu_ch2_value (cfg_pmu_ch2_value ),     // O , PMU_VI_DW bit
  .cfg_pmu_ch3_value (cfg_pmu_ch3_value ),     // O , PMU_VI_DW bit 
//  .cfg_pmu_vol_value (cfg_pmu_vol_value ),     // O , PMU_VI_DW bit
  .cfg_pmu_cmp_en    (cfg_pmu_cmp_en    ),     // O , CH_NUM bit
  .cfg_pmu_cmp_type  (cfg_pmu_cmp_type  ),     // O , 1 bit
  .cfg_pmu_cmp_h     (cfg_pmu_cmp_h     ),     // O , PMU_VI_DW bit
  .cfg_pmu_cmp_l     (cfg_pmu_cmp_l     ),     // O , PMU_VI_DW bit
  .cfg_pmu_clamp_en  (cfg_pmu_clamp_en  ),     // O , CH_NUM bit
  .cfg_pmu_clamp_h   (cfg_pmu_clamp_h   ),     // O , PMU_VI_DW bit
  .cfg_pmu_clamp_l   (cfg_pmu_clamp_l   ),     // O , PMU_VI_DW bit
  .cfg_pmu_vchk      (cfg_pmu_vchk      ),     // O , PMU_VI_DW bit
  .cfg_pmu_ichk      (cfg_pmu_ichk      ),     // O , PMU_VI_DW bit
  .cfg_pmu_store_en  (cfg_pmu_store_en  ),     // O , 1 bit
  .cfg_data_type     (cfg_data_type     ),     // O , DATA_TYPE_WIDTH bit 
  .cfg_pmu_cmp_orgh  (cfg_pmu_cmp_orgh  ),     // O , PMU_VI_DW bit
  .cfg_pmu_cmp_orgl  (cfg_pmu_cmp_orgl  ),     // O , PMU_VI_DW bit
  .cfg_pmu_close_time(cfg_pmu_close_time),     // O , PMU_CLOSE_T_DW bit
  //cmd
  .pmu_work_start    (pmu_work_start    ),     // O , 1 bit
  .pmu_busy          (pmu_busy ||(!adc_ready)),     // I , 1 bit
  .pmu_rd_start      (pmu_rd_start      ),     // O , 1 bit
  .ad5522_warn_clear (ad5522_warn_clear ),     // O , 1 bit
  .sys_rst           (ps_sys_rst        ),     // O , 1 bit
  //dfx for rd
  .dfx_ad5522_warn   (dfx_ad5522_warn   )      // I , AD5522_DFX_DW bit
);

axis_data_fifo_ctrl # (
  .DW             (AXIS_FIFO_DW   ),
  .DATA_TYPE_WIDTH(DATA_TYPE_WIDTH),
  .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW)
)
axis_data_fifo_ctrl_inst (
  .clk              (sys_clk               ),   // I , 1 bit
  .rst              ((~sys_rstn) || ps_sys_rst ),   // I , 1 bit
  .packet_start     (pmu_pck_start         ),   // I , 1 bit
  .packet_done      (packet_done           ),   // O , 1 bit
  .data_type        (cfg_data_type         ),   // I , DATA_TYPE_WIDTH bit
  .cfg_data_num     (cfg_data_num          ),   // I , PMU_TEST_NUM_DW bit
  .axis_fifo_wr_data(axis_fifo_wr_data     ),   // O , AXIS_FIFO_DW bit
  .axis_fifo_last   (axis_fifo_last        ),   // O , 1 bit
  .axis_fifo_ready  (axis_fifo_ready       ),   // I , 1 bit
  .axis_fifo_valid  (axis_fifo_valid       ),   // O , 1 bit
  .pl_rd_data       (pl_rd_data            ),   // I , AXIS_FIFO_DW bit
  .pl_rd_data_vld   (pl_rd_data_vld        ),   // I , 1 bit
  .pl_rd_en         (pl_rd_en              )    // O , 1 bit
);

pmu_core # (
  .PMU_TIME_DW    ('d32           ),
  .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW),
  .DATA_TYPE_WIDTH(DATA_TYPE_WIDTH),
  .SYS_MOD_DW     (SYS_MOD_DW     ),
  .PMU_MOD_DW     (PMU_MOD_DW     ),
  .PMU_VLU_DW     (PMU_VLU_DW     ),
  .PMU_VI_DW      (PMU_VI_DW      ),
  .CH_NUM         (CH_NUM         ),
  .SMP_DW         (SMP_DW         ),
  .AXIS_FIFO_DW   (AXIS_FIFO_DW   ),
  .MA_RESULT_DW   (MA_RESULT_DW   ),
  .PMU_CLOSE_T_DW (PMU_CLOSE_T_DW ),
  .PMU_SMP_WAIT_DW(PMU_SMP_WAIT_DW),
  .AD5522_DFX_DW  (AD5522_DFX_DW  )
)
pmu_core_inst (
  .clk               (sys_clk              ),     // I , 1 bit
  .rst               ((~sys_rstn) || ps_sys_rst),     // I , 1 bit
  //CFG
  .cfg_pmu_time      (cfg_pmu_time      ),     // I , PMU_TIME_DW bit
  .cfg_pmu_smp_wait_time (cfg_pmu_smp_wait_time),     // I , PMU_SMP_WAIT_DW bit
  .cfg_pmu_test_num  (cfg_pmu_test_num  ),     // I , PMU_TEST_NUM bit
  .cfg_pmu_ch_en     (cfg_pmu_ch_en     ),     // I , CH_NUM bit
  .cfg_sys_work_mode (cfg_sys_work_mode ),     // I , SYS_MOD_DW bit
  .cfg_pmu_test_mode (cfg_pmu_test_mode ),     // I , PMU_MOD_DW bit
  .cfg_pmu_cur_value (cfg_pmu_cur_value ),     // I , PMU_VLU_DW bit
//  .cfg_pmu_vol_value (cfg_pmu_vol_value ),     // I , PMU_VI_DW bit
  .cfg_pmu_ch0_value (cfg_pmu_ch0_value ),     // I , PMU_VI_DW bit
  .cfg_pmu_ch1_value (cfg_pmu_ch1_value ),     // I , PMU_VI_DW bit
  .cfg_pmu_ch2_value (cfg_pmu_ch2_value ),     // I , PMU_VI_DW bit
  .cfg_pmu_ch3_value (cfg_pmu_ch3_value ),     // I , PMU_VI_DW bit 
  .cfg_pmu_cmp_en    (cfg_pmu_cmp_en    ),     // I , CH_NUM bit
  .cfg_pmu_cmp_type  (cfg_pmu_cmp_type  ),     // I , 1 bit
  .cfg_pmu_cmp_h     (cfg_pmu_cmp_h     ),     // I , PMU_VI_DW bit
  .cfg_pmu_cmp_l     (cfg_pmu_cmp_l     ),     // I , PMU_VI_DW bit
  .cfg_pmu_clamp_en  (cfg_pmu_clamp_en  ),     // I , CH_NUM bit
  .cfg_pmu_clamp_h   (cfg_pmu_clamp_h   ),     // I , PMU_VI_DW bit
  .cfg_pmu_clamp_l   (cfg_pmu_clamp_l   ),     // I , PMU_VI_DW bit
  .cfg_pmu_vchk      (cfg_pmu_vchk      ),     // I , PMU_VI_DW bit
  .cfg_pmu_ichk      (cfg_pmu_ichk      ),     // I , PMU_VI_DW bit
  .cfg_pmu_store_en  (cfg_pmu_store_en  ),     // I , 1 bit
  .cfg_data_type     (cfg_data_type     ),     // I , DATA_TYPE_WIDTH bit 
  .cfg_pmu_cmp_orgh  (cfg_pmu_cmp_orgh  ),     // I , PMU_VI_DW bit
  .cfg_pmu_cmp_orgl  (cfg_pmu_cmp_orgl  ),     // I , PMU_VI_DW bit
  .cfg_pmu_close_time(cfg_pmu_close_time),     // I , PMU_CLOSE_T_DW bit
  //CMD
  .pmu_work_start   (pmu_work_start   ),     // I , 1 bit
  .pmu_busy         (pmu_busy         ),     // O , 1 bit
  .pmu_rd_start     (pmu_rd_start     ),     // I , 1 bit
  .ad5522_warn_clear(ad5522_warn_clear),     // I , 1 bit
  //connect adc_core
  //.pmu_drv_done     (pmu_drv_done     ),     // O , 1 bit
  .adc_ready        (adc_ready        ),     // I , 1 bit
  .pmu_smp_start    (pmu_smp_start    ),     // O , 1 bit
  .pmu_smp_dataa    (pmu_smp_dataa    ),     // I , SMP_DW bit
  .pmu_smp_datab    (pmu_smp_datab    ),     // I , SMP_DW bit
  .pmu_smp_data_vld (pmu_smp_data_vld ),     // I , 1 bit
  //connect axis_fifo_ctrl
  .pl_rd_data       (pl_rd_data       ),     // O , AXIS_FIFO_DW bit
  .pl_rd_data_vld   (pl_rd_data_vld   ),     // O , 1 bit
  .pl_rd_en         (pl_rd_en         ),     // I , 1 bit
  .pmu_pck_start    (pmu_pck_start    ),     // O , 1 bit
  .packet_done      (packet_done      ),     // I , 1 bit
  //connect AD5522
  .pmu_spi_clk      (pmu_spi_clk      ),     // O , 1 bit
  .pmu_spi_csn      (pmu_spi_csn      ),     // O , 1 bit
  .pmu_spi_sdi      (pmu_spi_sdi      ),     // I , 1 bit
  .pmu_spi_sdo      (pmu_spi_sdo      ),     // O , 1 bit
  .pmu_spi_lvds     (pmu_spi_lvds     ),     // O , 1 bit
  .pmu_busyn        (pmu_busyn        ),     // I , 1 bit
  .pmu_cgalm        (pmu_cgalm        ),     // I , 1 bit
  .pmu_tmpn         (pmu_tmpn         ),     // I , 1 bit
  .pmu_rstn         (pmu_rstn         ),     // O , 1 bit
  .pmu_loadn        (pmu_loadn        ),     // O , 1 bit
  //dfx to axi_bram_ctrl
  .dfx_ad5522_warn  (dfx_ad5522_warn  )      // O , AD5522_DFX_DW bit
);

wire adc_rst;
reg adc_rst_d1 = 'd0;
wire adc_rst_r;

vio_0 u_adc_rst (
  .clk(sys_clk),                // input wire clk
  .probe_out0(adc_rst)  // output wire [0 : 0] probe_out0
);

always @(posedge sys_clk) 
begin
  adc_rst_d1 <= adc_rst;
end

assign adc_rst_r = adc_rst && (!adc_rst_d1);

  // Parameters
  localparam  DIVIDE         = 2         ;
  localparam  WAIT_CNT_WIDTH = 20        ;
  localparam  FULL_RST_NUM   = 20'd800000;
  localparam  PART_RST_NUM   = 4'd8      ;
  localparam  CONV_HTIME     = 3'd6      ;

  wire  rst      ;

  assign rst = (~sys_rstn) || ps_sys_rst;

  ad8686_driver # (
    .DIVIDE        (DIVIDE        ),
    .WAIT_CNT_WIDTH(WAIT_CNT_WIDTH),
    .FULL_RST_NUM  (FULL_RST_NUM  ),
    .PART_RST_NUM  (PART_RST_NUM  ),
    .CONV_HTIME    (CONV_HTIME    )
  )
  ad8686_driver_inst (
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (!rst               ),
    .req_convst         (pmu_smp_start      ),
    .req_rst_ad8686     (adc_rst_r          ),
    .cha_rdata          (pmu_smp_dataa      ),
    .chb_rdata          (pmu_smp_datab      ),
    .ch_rdata_vld       (pmu_smp_data_vld   ),
    .ready              (adc_ready          ),
    .init_device_done   (                   ),
    .rst_device_done    (                   ),
    .ad8686_busy        (ad8686_busy        ),
    .ad8686_db11_sdob   (ad8686_db11_sdob   ),
    .ad8686_db12_sdoa   (ad8686_db12_sdoa   ),
    .ad8686_refsel      (ad8686_refsel      ),
    .ad8686_reset_n     (ad8686_reset_n     ),
    .ad8686_seqen       (ad8686_seqen       ),
    .ad8686_rangesel    (ad8686_rangesel    ),
    .ad8686_ser_byte_par(ad8686_ser_byte_par),
    .ad8686_db0         (ad8686_db0         ),
    .ad8686_db1         (ad8686_db1         ),
    .ad8686_db2         (ad8686_db2         ),
    .ad8686_db3         (ad8686_db3         ),
    .ad8686_db4_ser1w   (ad8686_db4_ser1w   ),
    .ad8686_db5_crcen   (ad8686_db5_crcen   ),
    .ad8686_db6         (ad8686_db6         ),
    .ad8686_db7         (ad8686_db7         ),
    .ad8686_db8         (ad8686_db8         ),
    .ad8686_db9_bytesel (ad8686_db9_bytesel ),
    .ad8686_db10_sdi    (ad8686_db10_sdi    ),
    .ad8686_db13_os0    (ad8686_db13_os0    ),
    .ad8686_db14_os1    (ad8686_db14_os1    ),
    .ad8686_db15_os2    (ad8686_db15_os2    ),
    .ad8686_wr_burst    (ad8686_wr_burst    ),
    .ad8686_sclk_rd     (ad8686_sclk_rd     ),
    .ad8686_cs_n        (ad8686_cs_n        ),
    .ad8686_chsel       (ad8686_chsel       ),
    .ad8686_convst      (ad8686_convst      )
  );

// for test adc work time
  (*mark_debug="true"*)(*keep="true"*)reg time_flag = 'd0;

always @(posedge sys_clk) 
begin
  if(ad8686_convst)
  begin
    time_flag <= 'd1;
  end
  else if(pmu_smp_data_vld)
  begin
    time_flag <= 'd0;
  end
  else
  begin
    time_flag <= time_flag;
  end    
end

(*mark_debug="true"*)(*keep="true"*)reg [15:0] adc_time_cnt = 'd0;

always @(posedge sys_clk) 
begin
  if(time_flag)
  begin
    adc_time_cnt <= adc_time_cnt + 'd1;
  end
  else
  begin
    adc_time_cnt <= 'd0;
  end  
end

//==============================================
//test data gen(fake)
//==============================================
reg [15:0] test_data         = 'd0;
reg        test_data_vld     = 'd0;

always @(posedge sys_clk) 
begin
  if(test_data == 'd7)
  begin
    test_data_vld <= 'd0;
  end
  else if(pmu_drv_done)
  begin
    test_data_vld <= 'd1;
  end
  else
  begin
    test_data_vld <= test_data_vld;
  end  
end

always @(posedge sys_clk) 
begin
  if(test_data_vld)
  begin
    test_data <= test_data + 'd1;
  end
  else
  begin
    test_data <= 'd0;
  end  
end

//assign pmu_smp_data_vld  = test_data_vld;
//assign pmu_smp_dataa     = test_data    ;
//assign pmu_smp_datab     = test_data    ;

endmodule