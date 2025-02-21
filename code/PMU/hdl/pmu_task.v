`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-22
// Module Name           : pmu_task
// Project Name          : HV
// Target Devices        : xc7z015
// Tool Versions         : Vivado 2020.2
// Description           : 
//                         1. The control driver module completes the readback of the AD5522's driver and comparator results
// Dependencies          : pmu_core
// 
// Revision              :
//                        Revision v0.01 - File Created
//                        Revision v0.02 - Add AD5522 X1 code calculation
//                        Revision v0.03 - Delect AD5522 X1 code calculation
// Additional Comments   :
//                         1.Currently, only the AD5522 normal test mode is supported
//////////////////////////////////////////////////////////////////////////////////
module pmu_task
#(
    parameter SYS_MOD_DW      = 3    ,
    parameter PMU_MOD_DW      = 3    ,
    parameter PMU_VLU_DW      = 3    ,
    parameter PMU_VI_DW       = 26   ,
    parameter CH_NUM          = 4    ,
    parameter PMU_TEST_NUM_DW = 16   ,
    parameter PMU_CFG_DW      = 29
) 
(
    input                       clk                     ,
    input                       rst                     ,
    //cmd
    input                       pmu_work_start          ,
    input                       pmu_drv_start           ,
    output                      pmu_drv_done            ,
    output                      pmu_cfg_rd_req          ,
    input                       pmu_cfg_rd_done         ,
    output                      pmu_cfg_wr_req          ,     
    input                       pmu_cfg_wr_done         ,
    input                       pmu_busyn               ,
    input                       pmu_close               ,
    input                       pmu_smp_done            ,
    //cfg
    input      [CH_NUM-1:0]     cfg_pmu_ch_en           ,
    input      [SYS_MOD_DW-1:0] cfg_sys_work_mode       ,       //0:test mod; 1:diag mod; 2:cal mod
    input      [PMU_MOD_DW-1:0] cfg_pmu_test_mode       ,       //0:VSIM; 1:MVM; 2:VS; 3:ISVM;
    input      [PMU_VLU_DW-1:0] cfg_pmu_cur_value       ,       //0:¡À5ua; 1:¡À20uA; 2:¡À200uA; 3:¡À2mA; 4:¡À25mA;
//    input      [PMU_VI_DW-1:0]  cfg_pmu_vol_value       ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch0_value       ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch1_value       ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch2_value       ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch3_value       ,
    input      [CH_NUM-1:0]     cfg_pmu_cmp_en          ,
    input                       cfg_pmu_cmp_type        ,       //0:I ; 1:V
    input      [PMU_VI_DW-1:0]  cfg_pmu_cmp_h           ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_cmp_l           ,
    input      [CH_NUM-1:0]     cfg_pmu_clamp_en        ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_clamp_h         ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_clamp_l         ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_vchk            ,       //used in diag mod
    input      [PMU_VI_DW-1:0]  cfg_pmu_ichk            ,       //used in diag mod
    //data
    output     [PMU_CFG_DW-1:0] pmu_cfg_wr_data         ,
    input      [PMU_CFG_DW-1:0] pmu_cmp_result          ,
    input                       pmu_cmp_result_vld      ,
    output     [CH_NUM*2-1:0]   pmu_cmp_rslt2pck
);

////AD5522 X1 code calculation
////vout = 22.5*(x1_code/2^16)-11.25  -> x1_code_v = ((cfg+11250000)/10^6/22.5)*(2^16)
////iout = 22.5*((x1_code-32768)/2^16)/(Rsense*10)  -> x1_code_i = (((cfg*steep/10^12)*10*Rsense)/22.5)*(2^16)+32768
//localparam DIV1         = 22500000;
//localparam DIVI0        = 172     ;     // 1pA
//localparam DIVI1        = 687     ;     // 1pA
//localparam DIVI2        = 687     ;     // 10pA
//localparam DIVI3        = 687     ;     // 100pA
//localparam DIVI4        = 858     ;     // 1nA
//localparam DIVIDEN_VADD = 11250000;
//localparam DIVIDEN_IADD = 32768   ;
//
//localparam DIV_OUT_DW  = 56      ;
//localparam DIV_CNT_DW  = 4       ;
//localparam DIV_NUM     = 7       ;   //value/clamp*2/cmp*2/chk*2
//
//(*mark_debug="true"*)(*keep="true"*)reg  [PMU_VI_DW-1:0]  cfg_div          = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg  [PMU_VI_DW-1:0]  cfg_dividend     = 'd0;
//(*mark_debug="true"*)(*keep="true"*)wire [DIV_OUT_DW-1:0] cfg_div_out           ;
//(*mark_debug="true"*)(*keep="true"*)wire                  cfg_div_out_vld       ;
//(*mark_debug="true"*)(*keep="true"*)wire                  s_axis_divisor_tready ;
//(*mark_debug="true"*)(*keep="true"*)wire                  s_axis_dividend_tready;
//
//(*mark_debug="true"*)(*keep="true"*)wire                  cfg_div_flag        ;
//(*mark_debug="true"*)(*keep="true"*)reg [DIV_CNT_DW-1:0]  cfg_div_cnt    = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg                   cfg_div_rdy    = 'd0;
//reg  [PMU_VI_DW-1:0]  cfg_div_i        = 'd0;
//
//always @(posedge clk) 
//begin
//  case(cfg_pmu_cur_value)
//  'd0:
//  begin
//    cfg_div_i <= DIVI0;
//  end 
//  'd1:
//  begin
//    cfg_div_i <= DIVI1;
//  end
//  'd2:
//  begin
//    cfg_div_i <= DIVI2;
//  end  
//  'd3:
//  begin
//    cfg_div_i <= DIVI3;
//  end 
//  'd4:
//  begin
//    cfg_div_i <= DIVI4;
//  end 
//  default: 
//  begin
//    cfg_div_i <= DIVI0;
//  end
//  endcase
//end
//
//always @(posedge clk) 
//begin
//  if(rst || ((cfg_div_cnt == DIV_NUM-1) && cfg_div_flag))
//  begin
//    cfg_div_rdy <= 'd0;
//  end
//  else if(pmu_work_start)
//  begin
//    cfg_div_rdy <= 'd1;
//  end
//  else
//  begin
//    cfg_div_rdy <= cfg_div_rdy;
//  end  
//end
//
//assign cfg_div_flag = cfg_div_rdy && s_axis_divisor_tready && s_axis_divisor_tready;
//
//always @(posedge clk) 
//begin
//  if(!cfg_div_rdy)
//  begin
//    cfg_div_cnt <= 'd0;
//  end
//  else if(cfg_div_flag)
//  begin
//    cfg_div_cnt <= cfg_div_cnt + 'd1;
//  end
//  else
//  begin
//    cfg_div_cnt <= cfg_div_cnt;
//  end  
//end
//
////fv -> clamp i;fi -> clamp v
//always @(*) 
//begin
//  case (cfg_div_cnt)
//    'd0: 
//    begin
//      cfg_dividend <= (cfg_pmu_test_mode == 3'b011) ? cfg_pmu_vol_value : (cfg_pmu_vol_value + DIVIDEN_VADD);
//      cfg_div      <= (cfg_pmu_test_mode == 3'b011) ? cfg_div_i : DIV1;
//    end 
//    'd1:
//    begin
//      cfg_dividend <= (cfg_pmu_test_mode == 3'b011)  ? (cfg_pmu_clamp_h + DIVIDEN_VADD) : cfg_pmu_clamp_h;
//      cfg_div      <= (cfg_pmu_test_mode == 3'b011)  ? DIV1 : cfg_div_i;
//    end
//    'd2:
//    begin
//      cfg_dividend <= (cfg_pmu_test_mode == 3'b011)  ? (cfg_pmu_clamp_l + DIVIDEN_VADD) : cfg_pmu_clamp_l;
//      cfg_div      <= (cfg_pmu_test_mode == 3'b011)  ? DIV1 : cfg_div_i;
//    end
//    'd3:
//    begin
//      cfg_dividend <= (cfg_pmu_test_mode == 3'b011) ? (cfg_pmu_cmp_h + DIVIDEN_VADD) : cfg_pmu_cmp_h;
//      cfg_div      <= (cfg_pmu_test_mode == 3'b011) ? DIV1 : cfg_div_i;
//    end
//    'd4:
//    begin
//      cfg_dividend <= (cfg_pmu_test_mode == 3'b011) ? (cfg_pmu_cmp_l + DIVIDEN_VADD) : cfg_pmu_cmp_l; 
//      cfg_div      <= (cfg_pmu_test_mode == 3'b011) ? DIV1 : cfg_div_i;    
//    end
//    'd5:
//    begin
//      cfg_dividend <= cfg_pmu_vchk + DIVIDEN_VADD;
//      cfg_div <= DIV1;
//    end
//    'd6:
//    begin
//      cfg_dividend <= cfg_pmu_ichk;
//      cfg_div <= cfg_div_i;
//    end
//    default: 
//    begin
//      cfg_dividend <= cfg_pmu_vol_value + DIVIDEN_VADD;
//      cfg_div <= DIV1;
//    end
//  endcase  
//end
//
//div_cfg u_div_cfg (
//  .aclk                  (clk                   ),     // input wire aclk
//  .s_axis_divisor_tvalid (cfg_div_flag          ),     // input wire s_axis_divisor_tvalid
//  .s_axis_divisor_tready (s_axis_divisor_tready ),     // output wire s_axis_divisor_tready
//  .s_axis_divisor_tdata  ({6'd0,cfg_div}        ),     // input wire [31 : 0] s_axis_divisor_tdata
//  .s_axis_dividend_tvalid(cfg_div_flag          ),     // input wire s_axis_dividend_tvalid
//  .s_axis_dividend_tready(s_axis_dividend_tready),     // output wire s_axis_dividend_tready
//  .s_axis_dividend_tdata ({6'd0,cfg_dividend}   ),     // input wire [31 : 0] s_axis_dividend_tdata
//  .m_axis_dout_tvalid    (cfg_div_out_vld       ),     // output wire m_axis_dout_tvalid
//  .m_axis_dout_tuser     (                      ),     // output wire [0 : 0] m_axis_dout_tuser
//  .m_axis_dout_tdata     (cfg_div_out           )      // output wire [55 : 0] m_axis_dout_tdata
//);
//
//(*mark_debug="true"*)(*keep="true"*)reg [DIV_NUM-1:0]    cfg_div_out_cnt = 'd0 ;
//(*mark_debug="true"*)(*keep="true"*)reg [DIV_OUT_DW-1:0] cfg_act_vol     = 'd0 ;
//(*mark_debug="true"*)(*keep="true"*)reg [DIV_NUM-1:0]    cfg_act_cnt     = 'd0 ;
//(*mark_debug="true"*)(*keep="true"*)reg                  cfg_act_vol_vld = 'd0 ;
//
//always @(posedge clk) 
//begin
//  if(rst || (cfg_div_out_cnt == DIV_NUM-1))
//  begin
//    cfg_div_out_cnt <= 'd0;
//  end
//  else if(cfg_div_out_vld)
//  begin
//    cfg_div_out_cnt <= cfg_div_out_cnt + 'd1;
//  end
//  else
//  begin
//    cfg_div_out_cnt <= cfg_div_out_cnt;
//  end  
//end
//
//always @(posedge clk) 
//begin
//  if(cfg_div_out_vld && ((cfg_pmu_test_mode == 3'b011) && (cfg_div_out_cnt == 'd0)))
//  begin
//    cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] <= cfg_div_out[PMU_VI_DW*2-1:PMU_VI_DW] + DIVIDEN_IADD;
//  end
//  else if(cfg_div_out_vld && ((cfg_pmu_test_mode == 'd0) && ((cfg_div_out_cnt > 'd0) && (cfg_div_out_cnt < 'd5))))
//  begin
//    cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] <= cfg_div_out[PMU_VI_DW*2-1:PMU_VI_DW] + DIVIDEN_IADD;
//  end
//  else if(cfg_div_out_vld)
//  begin
//    cfg_act_vol <= cfg_div_out << 16;
//  end
//  else
//  begin
//    cfg_act_vol <= cfg_act_vol;
//  end  
//end
//
//always @(posedge clk) 
//begin
//  cfg_act_vol_vld <= cfg_div_out_vld;
//end
//
//always @(posedge clk) 
//begin
//  if(pmu_work_start)
//  begin
//    cfg_act_cnt <= 'd1;
//  end
//  else if(cfg_act_vol_vld)
//  begin
//    cfg_act_cnt <= {cfg_act_cnt[DIV_NUM-2:0],1'b0};
//  end
//  else
//  begin
//    cfg_act_cnt <= cfg_act_cnt;
//  end  
//end
//
//(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW-1:0]  cfg_pmu_vol_value_lock = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW-1:0]  cfg_pmu_clamp_h_lock   = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW-1:0]  cfg_pmu_clamp_l_lock   = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW-1:0]  cfg_pmu_cmp_h_lock     = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW-1:0]  cfg_pmu_cmp_l_lock     = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW-1:0]  cfg_pmu_vchk_lock      = 'd0;
//(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW-1:0]  cfg_pmu_ichk_lock      = 'd0;
//
//
//always @(posedge clk)
//begin
//  cfg_pmu_vol_value_lock <= cfg_act_cnt[0] ? cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] : cfg_pmu_vol_value_lock ;
//  cfg_pmu_clamp_h_lock   <= cfg_act_cnt[1] ? cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] : cfg_pmu_clamp_h_lock   ;
//  cfg_pmu_clamp_l_lock   <= cfg_act_cnt[2] ? cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] : cfg_pmu_clamp_l_lock   ;
//  cfg_pmu_cmp_h_lock     <= cfg_act_cnt[3] ? cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] : cfg_pmu_cmp_h_lock     ;
//  cfg_pmu_cmp_l_lock     <= cfg_act_cnt[4] ? cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] : cfg_pmu_cmp_l_lock     ;
//  cfg_pmu_vchk_lock      <= cfg_act_cnt[5] ? cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] : cfg_pmu_vchk_lock      ;
//  cfg_pmu_ichk_lock      <= cfg_act_cnt[6] ? cfg_act_vol[PMU_VI_DW*2-1:PMU_VI_DW] : cfg_pmu_ichk_lock      ;
//end

//inst

wire pmu_cmp_type;

assign pmu_cmp_type = (cfg_pmu_test_mode == 3'b011);

  pmu_drv_task # (
    .SYS_MOD_DW     (SYS_MOD_DW     ),
    .PMU_MOD_DW     (PMU_MOD_DW     ),
    .PMU_VLU_DW     (PMU_VLU_DW     ),
    .PMU_VI_DW      (PMU_VI_DW      ),
    .CH_NUM         (CH_NUM         ),
    .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW),
    .PMU_CFG_DW     (PMU_CFG_DW     )
  )
  pmu_drv_task_inst (
    .clk               (clk                    ),          // I , 1 bit
    .rst               (rst                    ),          // I , 1 bit
    .pmu_work_start    (pmu_work_start         ),          // I , 1 bit
    .pmu_drv_start     (pmu_drv_start          ),          // I , 1 bit
    .pmu_drv_done      (pmu_drv_done           ),          // I , 1 bit
    .pmu_cfg_rd_req    (pmu_cfg_rd_req         ),          // I , 1 bit
    .pmu_cfg_rd_done   (pmu_cfg_rd_done        ),          // I , 1 bit
    .pmu_cfg_wr_req    (pmu_cfg_wr_req         ),          // I , 1 bit
    .pmu_cfg_wr_done   (pmu_cfg_wr_done        ),          // I , 1 bit
    .pmu_busyn         (pmu_busyn              ),          // I , 1 bit
    .pmu_close         (pmu_close              ),          // I , 1 bit
    .pmu_smp_done      (pmu_smp_done           ),          // I , 1 bit
    .cfg_pmu_ch_en     (cfg_pmu_ch_en          ),          // I , CH_NUM bit
    .cfg_sys_work_mode (cfg_sys_work_mode      ),          // I , SYS_MOD_DW bit
    .cfg_pmu_test_mode (cfg_pmu_test_mode      ),          // I , PMU_MOD_DW bit
    .cfg_pmu_cur_value (cfg_pmu_cur_value      ),          // I , PMU_VLU_DW bit
//    .cfg_pmu_vol_value (cfg_pmu_vol_value      ),          // I , PMU_VI_DW bit
    .cfg_pmu_ch0_value (cfg_pmu_ch0_value      ),          // I , PMU_VI_DW bit
    .cfg_pmu_ch1_value (cfg_pmu_ch1_value      ),          // I , PMU_VI_DW bit
    .cfg_pmu_ch2_value (cfg_pmu_ch2_value      ),          // I , PMU_VI_DW bit
    .cfg_pmu_ch3_value (cfg_pmu_ch3_value      ),          // I , PMU_VI_DW bit     
    .cfg_pmu_cmp_en    (cfg_pmu_cmp_en         ),          // I , CH_NUM bit
    .cfg_pmu_cmp_type  (pmu_cmp_type           ),          // I , 1 bit
    .cfg_pmu_cmp_h     (cfg_pmu_cmp_h          ),          // I , PMU_VI_DW bit
    .cfg_pmu_cmp_l     (cfg_pmu_cmp_l          ),          // I , PMU_VI_DW bit
    .cfg_pmu_clamp_en  (cfg_pmu_clamp_en       ),          // I , CH_NUM bit
    .cfg_pmu_clamp_h   (cfg_pmu_clamp_h        ),          // I , PMU_VI_DW bit
    .cfg_pmu_clamp_l   (cfg_pmu_clamp_l        ),          // I , PMU_VI_DW bit
    .cfg_pmu_vchk      (cfg_pmu_vchk           ),          // I , PMU_VI_DW bit
    .cfg_pmu_ichk      (cfg_pmu_ichk           ),          // I , PMU_VI_DW bit
    .pmu_cfg_wr_data   (pmu_cfg_wr_data        ),          // I , 1 bit
    .pmu_cmp_result    (pmu_cmp_result         ),          // I , PMU_CFG_DW bit
    .pmu_cmp_result_vld(pmu_cmp_result_vld     ),          // I , PMU_CFG_DW bit
    .pmu_cmp_rslt2pck  (pmu_cmp_rslt2pck       )           // I , CH_NUM*2 bit
  );


    
endmodule