`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-09
// Module Name           : axi_bram_ctrl
// Project Name          : hv
// Target Devices        : xc7z015
// Tool Versions         : Vivado 2020.2
// Description           : 
//                        rcv cfg/cmd from axi_bram
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
//                        Revision v0.02 - 1.Modify the mean to enable the original data store;
//                                         2.Add data upload type: Raw Value/Mean Value;              --2024/10/31
//                        Revision v0.03 - Modify fin dac code from 1 time for 4ch to 4 time for 4ch -- 2024-12-04  
// Additional Comments   :
//                          
//////////////////////////////////////////////////////////////////////////////////

module axi_bram_ctrl 
#(
    parameter AXI_BRAM_AW     = 16    ,
    parameter AXI_BRAM_DW     = 32    ,
    parameter EN_WIDTH        = AXI_BRAM_DW/8  ,
    parameter DATA_TYPE_WIDTH = 2     ,
    parameter PMU_TIME_DW     = 15    ,
    parameter PMU_TEST_NUM_DW = 16    ,
    parameter SYS_MOD_DW      = 3     ,
    parameter PMU_MOD_DW      = 3     ,
    parameter PMU_VLU_DW      = 3     ,
    parameter PMU_VI_DW       = 26    ,
    parameter CH_NUM          = 4     ,
    parameter SMP_DW          = 16    ,
    parameter AXIS_FIFO_DW    = 32    ,
    parameter MA_RESULT_DW    = 26    ,  //pck data dw
    parameter PMU_CLOSE_T_DW  = 20    ,
    parameter PMU_SMP_WAIT_DW = 16    ,
    parameter AD5522_DFX_DW   = 2
) 
(
    input                               clk                ,    //pl clk
    input                               rst                ,    //pl clk
    //===========axis bram port,link ps============
    input                               ps_axi_bram_clk    ,    //ps clk
    input                               ps_axi_bram_rst    ,    //ps clk
    input       [AXI_BRAM_AW-1:0]       ps_axi_bram_addr   ,
    input                               ps_axi_bram_en     ,
    input       [EN_WIDTH-1:0]          ps_axi_bram_we     ,
    input       [AXI_BRAM_DW-1:0]       ps_axi_bram_wrdata ,
    output reg  [AXI_BRAM_DW-1:0]       ps_axi_bram_rddata = 'd0,
    //================cfg & cmd====================
    //cmd
    output                              pmu_work_start     ,
    input                               pmu_busy           ,
    output                              pmu_rd_start       ,
    output                              ad5522_warn_clear  ,
    output                              sys_rst            ,
    //cfg
    output reg  [PMU_TIME_DW-1:0]       cfg_pmu_time       = 'd1000, 
    output reg  [PMU_SMP_WAIT_DW-1:0]   cfg_pmu_smp_wait_time = 'd10000,
    output reg  [PMU_TEST_NUM_DW-1:0]   cfg_pmu_test_num   = 'd0, 
    output reg  [CH_NUM-1:0]            cfg_pmu_ch_en      = 'd0, 
    output reg  [SYS_MOD_DW-1:0]        cfg_sys_work_mode  = 'd0, 
    output reg  [PMU_MOD_DW-1:0]        cfg_pmu_test_mode  = 'd0, 
    output reg  [PMU_VLU_DW-1:0]        cfg_pmu_cur_value  = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_ch0_value  = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_ch1_value  = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_ch2_value  = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_ch3_value  = 'd0, 
    //output reg  [PMU_VI_DW-1:0]         cfg_pmu_vol_value  = 'd0, 
    output reg  [CH_NUM-1:0]            cfg_pmu_cmp_en     = 'd0, 
    output reg                          cfg_pmu_cmp_type   = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_cmp_h      = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_cmp_l      = 'd0, 
    output reg  [CH_NUM-1:0]            cfg_pmu_clamp_en   = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_clamp_h    = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_clamp_l    = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_vchk       = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_ichk       = 'd0, 
    output reg                          cfg_pmu_store_en   = 'd0, 
    output reg  [DATA_TYPE_WIDTH-1:0]   cfg_data_type      = 'd0,
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_cmp_orgh   = 'd0, 
    output reg  [PMU_VI_DW-1:0]         cfg_pmu_cmp_orgl   = 'd0, 
    output reg  [PMU_CLOSE_T_DW-1:0]    cfg_pmu_close_time = 'd0,
    output reg                          cfg_pmu_rd_data_type = 'd0,
    input       [AD5522_DFX_DW-1:0]     dfx_ad5522_warn       
);

localparam PL_VER = 'd20250109;

//=====================REG ADDR===========================
localparam PLUSE_NUM = 3;
localparam REG_NUM   = 23;
//PMU
localparam ADDR_PMU_CH_EN      = 'h0000;   //W/R
localparam ADDR_PMU_START      = 'h0004;   //WO
localparam ADDR_PMU_TEST_MOD   = 'h0008;   //W/R
localparam ADDR_PMU_CMP_EN     = 'h000C;   //W/R
localparam ADDR_PMU_CMP_H      = 'h0018;   //W/R
localparam ADDR_PMU_CMP_L      = 'h001C;   //W/R
localparam ADDR_PMU_CLAMP_EN   = 'h0020;   //W/R
localparam ADDR_PMU_CLAMP_H    = 'h0024;   //W/R
localparam ADDR_PMU_CLAMP_L    = 'h0028;   //W/R
localparam ADDR_PMU_VCHK       = 'h002C;   //W/R
localparam ADDR_PMU_ICHK       = 'h0030;   //W/R
localparam ADDR_PMU_SMP_CFG    = 'h003C;   //W/R
localparam ADDR_PMU_MEAS_RSLT  = 'h0040;   //W/R
localparam ADDR_PMU_WAIT_TIME  = 'h004C;   //W/R
localparam ADDR_SYS_WORK_MOD   = 'h0200;   //W/R
localparam ADDR_SYS_RST        = 'h0204;   //WO
localparam ADDR_SYS_ST         = 'h0208;   //RO
localparam ADDR_SYS_WARN_CLR   = 'h020C;   //WO
localparam ADDR_PMU_CMP_ORGH   = 'h0088;   //W/R
localparam ADDR_PMU_CMP_ORGL   = 'h008C;   //W/R
localparam ADDR_PMU_OFF_TIME   = 'h0090;   //W/R
localparam ADDR_PMU_CH0_CODE   = 'h0300;   //W/R
localparam ADDR_PMU_CH1_CODE   = 'h0304;   //W/R
localparam ADDR_PMU_CH2_CODE   = 'h0308;   //W/R
localparam ADDR_PMU_CH3_CODE   = 'h030C;   //W/R
localparam ADDR_PMU_VER        = 'h0210;   //RO

//==============================================================
//=========================PS WR BRAM===========================
//==============================================================
//wr addr choose
wire [PLUSE_NUM-1:0]         ps_wr_pluse               ;
wire [REG_NUM-1:0]           ps_wr_cfg                 ;
wire [AXI_BRAM_DW-1:0]       cfg_reg_init [REG_NUM-1:0];

assign ps_wr_pluse[0] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_START    );
//assign ps_wr_pluse[1] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_MEAS_RSLT);
assign ps_wr_pluse[1] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_SYS_RST      );
assign ps_wr_pluse[2] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_SYS_WARN_CLR );

assign ps_wr_cfg[0]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CH_EN     );
assign ps_wr_cfg[1]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_TEST_MOD  );
assign ps_wr_cfg[2]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CMP_EN    );
assign ps_wr_cfg[3]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CMP_H     );
assign ps_wr_cfg[4]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CMP_L     );
assign ps_wr_cfg[5]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CLAMP_EN  );
assign ps_wr_cfg[6]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CLAMP_H   );
assign ps_wr_cfg[7]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CLAMP_L   );
assign ps_wr_cfg[8]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_VCHK      );
assign ps_wr_cfg[9]  = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_ICHK      );
assign ps_wr_cfg[10] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_SMP_CFG   );
assign ps_wr_cfg[11] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_WAIT_TIME );
assign ps_wr_cfg[12] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_SYS_WORK_MOD  );
assign ps_wr_cfg[13] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_MEAS_RSLT );
assign ps_wr_cfg[14] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_SYS_ST        );
assign ps_wr_cfg[15] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CMP_ORGH  );
assign ps_wr_cfg[16] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CMP_ORGL  );
assign ps_wr_cfg[17] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_OFF_TIME  );
assign ps_wr_cfg[18] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CH0_CODE  );
assign ps_wr_cfg[19] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CH1_CODE  );
assign ps_wr_cfg[20] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CH2_CODE  );
assign ps_wr_cfg[21] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_CH3_CODE  );
assign ps_wr_cfg[22] = ps_axi_bram_en && (ps_axi_bram_we == 'hf) && (ps_axi_bram_addr == ADDR_PMU_VER       );

assign cfg_reg_init[0]  = 'd0;
assign cfg_reg_init[1]  = 'd0;
assign cfg_reg_init[2]  = 'd0;
assign cfg_reg_init[3]  = 'd0;
assign cfg_reg_init[4]  = 'd0;
assign cfg_reg_init[5]  = 'd0;
assign cfg_reg_init[6]  = 'd0;
assign cfg_reg_init[7]  = 'd0;
assign cfg_reg_init[8]  = 'd0;
assign cfg_reg_init[9]  = 'd0;
assign cfg_reg_init[10] = 'h150001;                     //10us
assign cfg_reg_init[11] = 'd500;                        //50ms
assign cfg_reg_init[12] = 'd0;
assign cfg_reg_init[13] = 'd0;
assign cfg_reg_init[14] = 'd0;
assign cfg_reg_init[15] = 'd0;
assign cfg_reg_init[16] = 'd0;
assign cfg_reg_init[17] = 'd0;
assign cfg_reg_init[18] = 'd0;
assign cfg_reg_init[19] = 'd0;
assign cfg_reg_init[20] = 'd0;
assign cfg_reg_init[21] = 'd0;
assign cfg_reg_init[22] = 'd0;

//pluse
reg                          pmu_work_start_ps = 'd0 ;
reg                          pmu_rd_start_ps   = 'd0 ;
reg                          sys_rst_ps        = 'd0 ;
reg                          sys_warn_clr_ps   = 'd0 ;

always @(posedge ps_axi_bram_clk) 
begin
  pmu_rd_start_ps   <= (!pmu_busy) && ps_wr_cfg[13] && ps_axi_bram_wrdata[0];
  pmu_work_start_ps <= (!pmu_busy) && ps_wr_pluse[0] && ps_axi_bram_wrdata[0];
  sys_rst_ps        <= ps_wr_pluse[1] && ps_axi_bram_wrdata[0];
  sys_warn_clr_ps   <= ps_wr_pluse[2] && ps_axi_bram_wrdata[0];
end

//cfg reg
reg [AXI_BRAM_DW-1:0] cfg_reg_ps [REG_NUM-1:0];

genvar i;
generate
  for (i = 0; i < REG_NUM; i = i+1) 
  begin:u_cfg_reg
    always @(posedge ps_axi_bram_clk) 
    begin
      if(ps_axi_bram_rst)
      begin
        cfg_reg_ps[i] <= cfg_reg_init[i];
      end
      else if(ps_wr_cfg[i])
      begin
        cfg_reg_ps[i] <= ps_axi_bram_wrdata;
      end  
      else
      begin
        cfg_reg_ps[i] <= cfg_reg_ps[i];
      end  
    end
  end
endgenerate

//PL clk
wire [AXI_BRAM_DW-1:0] cfg_reg [REG_NUM-1:0];

always @(posedge clk) 
begin
  if(pmu_work_start)
  begin
    cfg_pmu_ch_en      <= cfg_reg[0][CH_NUM-1:0]                        ;
    cfg_pmu_cur_value  <= cfg_reg[1][AXI_BRAM_DW-1:PMU_VI_DW+PMU_MOD_DW];
    cfg_pmu_test_mode  <= cfg_reg[1][PMU_VI_DW+PMU_MOD_DW-1:PMU_VI_DW]  ;
    //cfg_pmu_vol_value  <= cfg_reg[1][PMU_VI_DW-1:0]                     ;
   // cfg_pmu_vol_value <= 'd2913                     ;
    cfg_pmu_cmp_en     <= cfg_reg[2][CH_NUM-1:0]                        ;
    cfg_pmu_cmp_type   <= cfg_reg[2][CH_NUM]                            ;
    cfg_pmu_cmp_h      <= cfg_reg[3][PMU_VI_DW-1:0]                     ;
    cfg_pmu_cmp_l      <= cfg_reg[4][PMU_VI_DW-1:0]                     ;
    cfg_pmu_clamp_en   <= cfg_reg[5][CH_NUM-1:0]                        ;
    cfg_pmu_clamp_h    <= cfg_reg[6][PMU_VI_DW-1:0]                     ;
    cfg_pmu_clamp_l    <= cfg_reg[7][PMU_VI_DW-1:0]                     ;
    cfg_pmu_vchk       <= cfg_reg[8][PMU_VI_DW-1:0]                     ;
    cfg_pmu_ichk       <= cfg_reg[9][PMU_VI_DW-1:0]                     ;
    cfg_pmu_time       <= cfg_reg[10][AXI_BRAM_DW-1:PMU_TEST_NUM_DW+1]  ;
    cfg_pmu_store_en   <= cfg_reg[10][PMU_TEST_NUM_DW]                  ;
    cfg_pmu_test_num   <= cfg_reg[10][PMU_TEST_NUM_DW-1:0]              ;
    cfg_pmu_smp_wait_time <= cfg_reg[11][PMU_SMP_WAIT_DW-1:0]              ;
    cfg_sys_work_mode  <= cfg_reg[12][SYS_MOD_DW-1:0]                   ;
    cfg_data_type      <= cfg_reg[13][DATA_TYPE_WIDTH-1:1]              ;
    cfg_pmu_cmp_orgh   <= cfg_reg[15][PMU_VI_DW-1:0]                    ;
    cfg_pmu_cmp_orgl   <= cfg_reg[16][PMU_VI_DW-1:0]                    ;
    cfg_pmu_close_time <= cfg_reg[17][PMU_CLOSE_T_DW-1:0]               ;
    cfg_pmu_ch0_value  <= cfg_reg[18][PMU_VI_DW-1:0]                    ;
    cfg_pmu_ch1_value  <= cfg_reg[19][PMU_VI_DW-1:0]                    ;
    cfg_pmu_ch2_value  <= cfg_reg[20][PMU_VI_DW-1:0]                    ;
    cfg_pmu_ch3_value  <= cfg_reg[21][PMU_VI_DW-1:0]                    ; 
  end
  else
  begin
    cfg_pmu_ch_en      <= cfg_pmu_ch_en      ;
    cfg_pmu_cur_value  <= cfg_pmu_cur_value  ;
    cfg_pmu_test_mode  <= cfg_pmu_test_mode  ;
    //cfg_pmu_vol_value  <= cfg_pmu_vol_value  ;
    cfg_pmu_cmp_en     <= cfg_pmu_cmp_en     ;
    cfg_pmu_cmp_type   <= cfg_pmu_cmp_type   ;
    cfg_pmu_cmp_h      <= cfg_pmu_cmp_h      ;
    cfg_pmu_cmp_l      <= cfg_pmu_cmp_l      ;
    cfg_pmu_clamp_en   <= cfg_pmu_clamp_en   ;
    cfg_pmu_clamp_h    <= cfg_pmu_clamp_h    ;
    cfg_pmu_clamp_l    <= cfg_pmu_clamp_l    ;
    cfg_pmu_vchk       <= cfg_pmu_vchk       ;
    cfg_pmu_ichk       <= cfg_pmu_ichk       ;
    cfg_pmu_time       <= cfg_pmu_time       ;
    cfg_pmu_store_en   <= cfg_pmu_store_en   ;
    cfg_pmu_test_num   <= cfg_pmu_test_num   ;
    cfg_pmu_smp_wait_time <= cfg_pmu_smp_wait_time ;
    cfg_sys_work_mode  <= cfg_sys_work_mode  ;
    cfg_data_type      <= cfg_reg[13][DATA_TYPE_WIDTH-1:1]      ;
    cfg_pmu_cmp_orgh   <= cfg_pmu_cmp_orgh   ;
    cfg_pmu_cmp_orgl   <= cfg_pmu_cmp_orgl   ; 
    cfg_pmu_close_time <= cfg_pmu_close_time ;
    cfg_pmu_ch0_value  <= cfg_pmu_ch0_value  ;
    cfg_pmu_ch1_value  <= cfg_pmu_ch1_value  ;
    cfg_pmu_ch2_value  <= cfg_pmu_ch2_value  ;
    cfg_pmu_ch3_value  <= cfg_pmu_ch3_value  ;
  end  
end

//==============================================================
//cdc,from ps clk to pl clk
//==============================================================
//pluse
xpm_cdc_pulse #(
  .DEST_SYNC_FF  (4),       // DECIMAL
  .INIT_SYNC_FF  (0),       // DECIMAL
  .REG_OUTPUT    (0),       // DECIMAL
  .RST_USED      (1),       // DECIMAL
  .SIM_ASSERT_CHK(0)        // DECIMAL
)
cdc_pmu_rd_start (
  .dest_pulse(pmu_rd_start      ),       // 1-bit output
  .dest_clk  (clk               ),       // 1-bit input
  .dest_rst  (rst               ),       // 1-bit input
  .src_clk   (ps_axi_bram_clk   ),       // 1-bit input
  .src_pulse (pmu_rd_start_ps   ),       // 1-bit input
  .src_rst   (ps_axi_bram_rst   )        // 1-bit input
);

xpm_cdc_pulse #(
  .DEST_SYNC_FF  (4),       // DECIMAL
  .INIT_SYNC_FF  (0),       // DECIMAL
  .REG_OUTPUT    (0),       // DECIMAL
  .RST_USED      (1),       // DECIMAL
  .SIM_ASSERT_CHK(0)        // DECIMAL
)
cdc_pmu_work_start (
  .dest_pulse(pmu_work_start    ),       // 1-bit output
  .dest_clk  (clk               ),       // 1-bit input
  .dest_rst  (rst               ),       // 1-bit input
  .src_clk   (ps_axi_bram_clk   ),       // 1-bit input
  .src_pulse (pmu_work_start_ps ),       // 1-bit input
  .src_rst   (ps_axi_bram_rst   )        // 1-bit input
);

xpm_cdc_pulse #(
  .DEST_SYNC_FF  (4),       // DECIMAL
  .INIT_SYNC_FF  (0),       // DECIMAL
  .REG_OUTPUT    (0),       // DECIMAL
  .RST_USED      (1),       // DECIMAL
  .SIM_ASSERT_CHK(0)        // DECIMAL
)
cdc_sys_rst (
  .dest_pulse(sys_rst           ),       // 1-bit output
  .dest_clk  (clk               ),       // 1-bit input
  .dest_rst  (rst               ),       // 1-bit input
  .src_clk   (ps_axi_bram_clk   ),       // 1-bit input
  .src_pulse (sys_rst_ps        ),       // 1-bit input
  .src_rst   (ps_axi_bram_rst   )        // 1-bit input
);

xpm_cdc_pulse #(
  .DEST_SYNC_FF  (4),       // DECIMAL
  .INIT_SYNC_FF  (0),       // DECIMAL
  .REG_OUTPUT    (0),       // DECIMAL
  .RST_USED      (1),       // DECIMAL
  .SIM_ASSERT_CHK(0)        // DECIMAL
)
cdc_warn_clr (
  .dest_pulse(ad5522_warn_clear ),       // 1-bit output
  .dest_clk  (clk               ),       // 1-bit input
  .dest_rst  (rst               ),       // 1-bit input
  .src_clk   (ps_axi_bram_clk   ),       // 1-bit input
  .src_pulse (sys_warn_clr_ps   ),       // 1-bit input
  .src_rst   (ps_axi_bram_rst   )        // 1-bit input
);

//reg
generate
  for (i = 0; i < REG_NUM; i = i + 1 ) 
  begin:u_cdc_cfg
    xpm_cdc_array_single #(
      .DEST_SYNC_FF  (4              ),          // DECIMAL; 
      .INIT_SYNC_FF  (0              ),          // DECIMAL; 
      .SIM_ASSERT_CHK(0              ),          // DECIMAL; 
      .SRC_INPUT_REG (1              ),          // DECIMAL; 
      .WIDTH         (AXI_BRAM_DW    )           // DECIMAL; 
    )
    cdc_cfg (
      .dest_out(cfg_reg[i]     ),     // WIDTH-bit output
      .dest_clk(clk            ),     // 1-bit input
      .src_clk (ps_axi_bram_clk),     // 1-bit input
      .src_in  (cfg_reg_ps[i]  )      // WIDTH-bit input
    );
  end
endgenerate

//==============================================================
//=======================PS RD BRAM=============================
//==============================================================
always @(posedge ps_axi_bram_clk) 
begin
  if(ps_axi_bram_en && (ps_axi_bram_we == 'h0))
  begin
    case (ps_axi_bram_addr)
      ADDR_PMU_CH_EN    : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-CH_NUM){1'b0}},cfg_pmu_ch_en}                         ; 
      ADDR_PMU_TEST_MOD : ps_axi_bram_rddata <= {cfg_pmu_cur_value,cfg_pmu_test_mode,{(AXI_BRAM_DW-PMU_VLU_DW-PMU_MOD_DW){1'b0}}}              ; 
      ADDR_PMU_CMP_EN   : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-CH_NUM-1){1'b0}},cfg_pmu_cmp_type,cfg_pmu_cmp_en}     ; 
      ADDR_PMU_CMP_H    : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_cmp_h}                      ; 
      ADDR_PMU_CMP_L    : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_cmp_l}                      ; 
      ADDR_PMU_CLAMP_EN : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-CH_NUM){1'b0}},cfg_pmu_clamp_en}                      ; 
      ADDR_PMU_CLAMP_H  : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_clamp_h}                    ; 
      ADDR_PMU_CLAMP_L  : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_clamp_l}                    ; 
      ADDR_PMU_VCHK     : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_vchk}                       ; 
      ADDR_PMU_ICHK     : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_ichk}                       ; 
      ADDR_PMU_SMP_CFG  : ps_axi_bram_rddata <= {cfg_pmu_time,cfg_pmu_store_en,cfg_pmu_test_num}                     ; 
      ADDR_PMU_MEAS_RSLT: ps_axi_bram_rddata <= {{(AXI_BRAM_DW-DATA_TYPE_WIDTH-1){1'b0}},cfg_data_type,1'b0}         ; 
      ADDR_PMU_WAIT_TIME: ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_SMP_WAIT_DW-1){1'b0}},cfg_pmu_smp_wait_time}                                                                  ; 
      ADDR_SYS_WORK_MOD : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-SYS_MOD_DW){1'b0}},cfg_sys_work_mode}                 ;  
      ADDR_SYS_ST       : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-AD5522_DFX_DW-8){1'b0}},dfx_ad5522_warn,7'd0,pmu_busy};         
      ADDR_PMU_CMP_ORGH : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_cmp_orgh}                   ;
      ADDR_PMU_CMP_ORGL : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_cmp_orgl}                   ;
      ADDR_PMU_OFF_TIME : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_CLOSE_T_DW){1'b0}},cfg_pmu_close_time}            ;
      ADDR_PMU_CH0_CODE : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_ch0_value}                  ;
      ADDR_PMU_CH1_CODE : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_ch1_value}                  ;
      ADDR_PMU_CH2_CODE : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_ch2_value}                  ;
      ADDR_PMU_CH3_CODE : ps_axi_bram_rddata <= {{(AXI_BRAM_DW-PMU_VI_DW){1'b0}},cfg_pmu_ch3_value}                  ;     
      ADDR_PMU_VER      : ps_axi_bram_rddata <= PL_VER;
      default           : ps_axi_bram_rddata<= 'd0                                                                   ;
    endcase
  end
  else
  begin
    ps_axi_bram_rddata <= ps_axi_bram_rddata;
  end  
end


endmodule