`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-22
// Module Name           : pmu_drv_task
// Project Name          : HV
// Target Devices        : xc7z015
// Tool Versions         : Vivado 2020.2
// Description           : 
//                         1. The control pmu_drv module completes the drive of the AD5522 chip;
//                         2. Read back the comparison register of the AD5522 and read the comparator value;
// Dependencies          : pmu_task
// 
// Revision              :
//                        Revision v0.01 - File Created
//                        Revision v0.02 - Modify the test mode to the actual usage mode of the user
//                                         (from FVMI/FVMV/FIMV/FVMI to VSIM/MVM/VS/ISVM)            -- 2024-09-18
//                        Revision v0.03 - Add PMU close   
//                        Revision v0.04 - Modify fin dac code from 1 time for 4ch to 4 time for 4ch -- 2024-12-04  
// Additional Comments   :
//                         1.In normal test mode, 
//                           The register configuration sequence for the first drive is:sys_reg -> pmu_reg -> DAC_reg(FIN -> clamp -> cmp);
//                           Subsequent drivers only need to be configured with PMU registers (to be verified);
//                         2.After the driver ends, the readback comparison register needs to wait at least 1us
//////////////////////////////////////////////////////////////////////////////////
module pmu_drv_task 
#(
    parameter SYS_MOD_DW      = 3    ,
    parameter PMU_MOD_DW      = 3    ,
    parameter PMU_VLU_DW      = 3    ,
    parameter PMU_VI_DW       = 26   ,
    parameter CH_NUM          = 4    ,
    parameter PMU_TEST_NUM_DW = 16   ,
    parameter PMU_CFG_DW      = 29
) (
    input                       clk                      ,
    input                       rst                      ,
    //cmd
    input                       pmu_work_start           ,
    input                       pmu_drv_start            ,
    output reg                  pmu_drv_done     = 'd0   ,
    (*mark_debug="true"*)(*keep="true"*)output reg                  pmu_cfg_rd_req   = 'd0   ,
    (*mark_debug="true"*)(*keep="true"*)input                       pmu_cfg_rd_done          ,
    (*mark_debug="true"*)(*keep="true"*)output reg                  pmu_cfg_wr_req   = 'd0   ,     
    (*mark_debug="true"*)(*keep="true"*)input                       pmu_cfg_wr_done          ,
    input                       pmu_busyn                ,
    input                       pmu_close                ,
    input                       pmu_smp_done             ,
    //cfg
    input      [CH_NUM-1:0]     cfg_pmu_ch_en            ,
    input      [SYS_MOD_DW-1:0] cfg_sys_work_mode        ,       //0:test mod; 1:diag mod; 2:cal mod
    input      [PMU_MOD_DW-1:0] cfg_pmu_test_mode        ,       //0:VSIM; 1:MVM; 2:VS; 3:ISVM;
    input      [PMU_VLU_DW-1:0] cfg_pmu_cur_value        ,       //0:±5ua; 1:±20uA; 2:±200uA; 3:±2mA; 4:±25mA;
    //input      [PMU_VI_DW-1:0]  cfg_pmu_vol_value        ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch0_value        ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch1_value        ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch2_value        ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_ch3_value        ,
    input      [CH_NUM-1:0]     cfg_pmu_cmp_en           ,
    input                       cfg_pmu_cmp_type         ,       //0:I ; 1:V
    input      [PMU_VI_DW-1:0]  cfg_pmu_cmp_h            ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_cmp_l            ,
    input      [CH_NUM-1:0]     cfg_pmu_clamp_en         ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_clamp_h          ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_clamp_l          ,
    input      [PMU_VI_DW-1:0]  cfg_pmu_vchk             ,       //used in diag mod
    input      [PMU_VI_DW-1:0]  cfg_pmu_ichk             ,       //used in diag mod
    //data
    (*mark_debug="true"*)(*keep="true"*)output reg [PMU_CFG_DW-1:0] pmu_cfg_wr_data  = 'd0   ,
    (*mark_debug="true"*)(*keep="true"*)input      [PMU_CFG_DW-1:0] pmu_cmp_result           ,
    (*mark_debug="true"*)(*keep="true"*)input                       pmu_cmp_result_vld       ,
    (*mark_debug="true"*)(*keep="true"*)output reg [CH_NUM*2-1:0]   pmu_cmp_rslt2pck = 'd0
);

localparam CMP_TIME    = 500                 ;    //5us in 100M clk
localparam CMP_TIME_DW = $clog2(CMP_TIME) + 1;
localparam ST_DW       = 4                   ;

localparam IDLE            = 0 ;
localparam SYS_CFG         = 1 ;
localparam PMU_CFG         = 2 ;
//localparam OFFSET_DAC_CFG  = 3 ;
localparam FIN_DAC0_CFG    = 3 ;
localparam FIN_DAC1_CFG    = 4 ;
localparam FIN_DAC2_CFG    = 5 ;
localparam FIN_DAC3_CFG    = 6 ;
localparam CLAMPH_DAC_CFG  = 7 ;
localparam CLAMPL_DAC_CFG  = 8 ;
localparam CMPH_DAC_CFG    = 9 ;
localparam CMPL_DAC_CFG    = 10;
localparam WAITING         = 11;
localparam RD              = 12;
localparam FIN_DRV_DONE    = 13;
localparam PMU_DRV_DONE    = 14;

localparam CMP_HBIT        = 26      ;
localparam CMP_LBIT        = 19      ;
localparam PMU_MEAS_DW     = 2       ;
localparam FIN_DAC_DW      = 3       ;
localparam V_DAC_AD        = 3'b101  ;
localparam SYS_DEFAULT_VLU = 'h20    ;

//=====================================================================
//============================ST CTRL==================================
//first drive is:sys_reg -> pmu_reg -> DAC_reg(FIN -> clamp -> cmp);
//Subsequent drivers only need to be configured with PMU registers (to be verified);
//=====================================================================
(*mark_debug="true"*)(*keep="true"*)reg [ST_DW-1:0]           crt_st        = IDLE;
reg [ST_DW-1:0]           nxt_st        = IDLE;
(*mark_debug="true"*)(*keep="true"*)reg [CMP_TIME_DW-1:0]     wait_time_cnt = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg [PMU_TEST_NUM_DW-1:0] drv_cnt       = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg                       cfg_wr_rdy    = 'd1 ;

always @(posedge clk) 
begin
  if(rst)
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
      if(pmu_drv_start)
      begin
        nxt_st = SYS_CFG;
      end 
      else if(pmu_smp_done)
      begin
        nxt_st = RD;
      end
      else if(pmu_close)
      begin
        //nxt_st = FIN_DRV_DONE;
        nxt_st = PMU_DRV_DONE;
      end   
      else
      begin
        nxt_st = IDLE;
      end  
    end
    SYS_CFG:
    begin
      if(pmu_cfg_wr_done)
      begin
        nxt_st = PMU_CFG;
      end  
      else
      begin
        nxt_st = SYS_CFG;
      end  
    end      
    PMU_CFG:
    begin
      if(pmu_cfg_wr_done && (drv_cnt == 'd0))
      begin
        nxt_st = FIN_DAC0_CFG;
      end  
      else if(pmu_cfg_wr_done)
      begin
        nxt_st = WAITING;
      end  
      else
      begin
        nxt_st = PMU_CFG;
      end  
    end    
    FIN_DAC0_CFG:
    begin
      if((pmu_cfg_wr_done && cfg_pmu_ch_en[0]) || !cfg_pmu_ch_en[0])
      begin
        nxt_st = FIN_DAC1_CFG;  
      end
      else
      begin
        nxt_st = FIN_DAC0_CFG;
      end 
    end 
    FIN_DAC1_CFG:
    begin
      if((pmu_cfg_wr_done && cfg_pmu_ch_en[1]) || !cfg_pmu_ch_en[1])
      begin
        nxt_st = FIN_DAC2_CFG;  
      end
      else
      begin
        nxt_st = FIN_DAC1_CFG;
      end   
    end   
    FIN_DAC2_CFG:
    begin
      if((pmu_cfg_wr_done && cfg_pmu_ch_en[2]) || !cfg_pmu_ch_en[2])
      begin
        nxt_st = FIN_DAC3_CFG;  
      end
      else
      begin
        nxt_st = FIN_DAC2_CFG;
      end     
    end       
    FIN_DAC3_CFG:
    begin
      if(((pmu_cfg_wr_done && cfg_pmu_ch_en[3]) || !cfg_pmu_ch_en[3]) && cfg_pmu_clamp_en)
      begin
        nxt_st = CLAMPH_DAC_CFG;
      end
      else if(((pmu_cfg_wr_done && cfg_pmu_ch_en[3]) || !cfg_pmu_ch_en[3]) && cfg_pmu_cmp_en)
      begin
        nxt_st = CMPH_DAC_CFG;
      end
      else if((pmu_cfg_wr_done && cfg_pmu_ch_en[3]) || !cfg_pmu_ch_en[3])
      begin
        nxt_st = WAITING;  
      end
      else
      begin
        nxt_st = FIN_DAC3_CFG;
      end    
    end  
    CLAMPH_DAC_CFG:
    begin
      if(pmu_cfg_wr_done)
      begin
        nxt_st = CLAMPL_DAC_CFG;
      end
      else  
      begin
        nxt_st = CLAMPH_DAC_CFG;  
      end
    end
    CLAMPL_DAC_CFG:
    begin
      if(pmu_cfg_wr_done && cfg_pmu_cmp_en)  
      begin
        nxt_st = CMPH_DAC_CFG;
      end
      else if(pmu_cfg_wr_done)
      begin
        nxt_st = WAITING;
      end
      else  
      begin
        nxt_st = CLAMPL_DAC_CFG;  
      end  
    end
    CMPH_DAC_CFG:
    begin
      if(pmu_cfg_wr_done)
      begin
        nxt_st = CMPL_DAC_CFG;
      end  
      else
      begin
        nxt_st = CMPH_DAC_CFG;
      end  
    end 
    CMPL_DAC_CFG: 
    begin
      if(pmu_cfg_wr_done)
      begin
        nxt_st = WAITING;
      end  
      else
      begin
        nxt_st = CMPL_DAC_CFG;
      end    
    end
    WAITING:
    begin
      if(wait_time_cnt == CMP_TIME-1)
      begin
        nxt_st = IDLE;
      end  
      else
      begin
        nxt_st = WAITING;
      end
    end    
    RD:
    begin
      if(pmu_cfg_rd_done)
      begin
        nxt_st = IDLE;
      end  
      else
      begin
        nxt_st = RD;
      end  
    end
    FIN_DRV_DONE:
    begin
      if(pmu_cfg_wr_done)
      begin
        nxt_st = PMU_DRV_DONE;
      end  
      else
      begin
        nxt_st = FIN_DRV_DONE;
      end  
    end    
    PMU_DRV_DONE:
    begin
      if(pmu_cfg_wr_done)
      begin
        nxt_st = IDLE;
      end
      else
      begin
        nxt_st = PMU_DRV_DONE;
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
  if(crt_st == WAITING)  
  begin
    wait_time_cnt <=  wait_time_cnt + 'd1;
  end
  else
  begin
    wait_time_cnt <= 'd0;
  end  
end

always @(posedge clk) 
begin
  if(rst || pmu_work_start)
  begin
    drv_cnt <= 'd0;
  end
  else if(pmu_drv_done)
  begin
    drv_cnt <= drv_cnt + 'd1;
  end
  else 
  begin
    drv_cnt <= drv_cnt;
  end  
end

//=====================================================================
//=========================cmd gen=====================================
//=====================================================================
(*mark_debug="true"*)(*keep="true"*)reg pmu_drv_start_d1   = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg pmu_cfg_rd_req_pre = 'd0;
reg       pmu_busyn_d1 = 'd1;
reg       pmu_busyn_d2 = 'd1;
reg       pmu_busyn_d3 = 'd1;
(*mark_debug="true"*)(*keep="true"*)wire      pmu_busyn_r;
reg       pmu_close_d1 = 'd0;

always @(posedge clk) 
begin
  pmu_busyn_d3 <= pmu_busyn_d2;
  pmu_busyn_d2 <= pmu_busyn_d1;
  pmu_busyn_d1 <= pmu_busyn   ;
end

assign pmu_busyn_r = pmu_busyn_d2 && (!pmu_busyn_d3);

always @(posedge clk) 
begin
  pmu_cfg_rd_req_pre <= (crt_st == IDLE) && (nxt_st == RD);
end

always @(posedge clk) 
begin
  pmu_drv_start_d1 <= pmu_drv_start;
  pmu_close_d1     <= pmu_close    ;
end

always @(posedge clk) 
begin
  pmu_cfg_wr_req <= pmu_drv_start_d1 || (pmu_busyn_r && (((crt_st > SYS_CFG) && (crt_st < WAITING)) || (crt_st == PMU_DRV_DONE))) || pmu_close_d1; 
  pmu_cfg_rd_req <= pmu_cfg_rd_req_pre;
end

always @(posedge clk) 
begin
  if(pmu_cfg_wr_req)
  begin
    cfg_wr_rdy <= 'd0;
  end
  else if(pmu_cfg_wr_done)
  begin
    cfg_wr_rdy <= 'd1;
  end
  else
  begin
    cfg_wr_rdy <= cfg_wr_rdy;
  end  
end

always @(posedge clk) 
begin
  pmu_drv_done <= (crt_st == WAITING) && (nxt_st == IDLE);   
end

//=====================================================================
//=========================pmu cfg gen=================================
//=====================================================================
(*mark_debug="true"*)(*keep="true"*)wire                    cmp_en        ;
(*mark_debug="true"*)(*keep="true"*)wire                    clamp_en      ;
(*mark_debug="true"*)(*keep="true"*)wire                    pmu_force0    ;
(*mark_debug="true"*)(*keep="true"*)wire                    pmu_force1    ;
(*mark_debug="true"*)(*keep="true"*)wire                    pmu_meas0     ;
(*mark_debug="true"*)(*keep="true"*)wire                    pmu_meas1     ;
(*mark_debug="true"*)(*keep="true"*)wire [FIN_DAC_DW-1:0]   fin_dac_addr  ;
wire [FIN_DAC_DW-1:0]   cmp_dac_addr  ;         
wire                    pmu_en        ;   

assign cmp_en        = |cfg_pmu_cmp_en;
assign clamp_en      = |cfg_pmu_clamp_en;
assign pmu_en        = |cfg_pmu_ch_en;
assign pmu_force0    = (cfg_pmu_test_mode < 'd3) ? 'd0 : 'd1;
assign pmu_force1    = (cfg_pmu_test_mode == 'd1);                              //force V
assign pmu_meas0     = (cfg_pmu_test_mode != 'd2) ? cfg_pmu_test_mode[0] : 'd1;
assign pmu_meas1     = (cfg_pmu_test_mode == 'd2);   
assign fin_dac_addr  = cfg_pmu_test_mode[0] ? cfg_pmu_cur_value : V_DAC_AD;
assign cmp_dac_addr  = (cfg_pmu_test_mode == 'd0) ? cfg_pmu_cur_value : V_DAC_AD;

localparam CPML_ADDR = 3'b100;

always @(posedge clk) 
begin
  case (crt_st)
    SYS_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,4'd0,2'd0,cfg_pmu_clamp_en,cfg_pmu_cmp_en,cmp_en,1'b0,2'b01,1'b0,1'b0,2'b00,1'b1,2'd0,1'b0,2'd0};  
    end       
    PMU_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'd0,pmu_en,pmu_force1,pmu_force0,1'b0,cfg_pmu_cur_value,pmu_meas1,pmu_meas0,1'b1,2'd0,clamp_en,cmp_en,cfg_pmu_cmp_type,1'b0,6'd0};  
    end      
    FIN_DAC0_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b001,fin_dac_addr,cfg_pmu_ch0_value[15:0]};
    end 
    FIN_DAC1_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b001,fin_dac_addr,cfg_pmu_ch1_value[15:0]};
    end 
    FIN_DAC2_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b001,fin_dac_addr,cfg_pmu_ch2_value[15:0]};
    end 
    FIN_DAC3_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b001,fin_dac_addr,cfg_pmu_ch3_value[15:0]};
    end           
    CLAMPH_DAC_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b011,{2'b10,cfg_pmu_test_mode[0]},cfg_pmu_clamp_h[15:0]}; 
    end
    CLAMPL_DAC_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b010,{2'b10,cfg_pmu_test_mode[0]},cfg_pmu_clamp_l[15:0]};       
    end
    CMPH_DAC_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b101,cmp_dac_addr,cfg_pmu_cmp_h[15:0]};  
    end  
    CMPL_DAC_CFG:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b100,cmp_dac_addr,cfg_pmu_cmp_l[15:0]};  
      //pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,CPML_ADDR,cmp_dac_addr,cfg_pmu_cmp_l[15:0]};  
      //pmu_cfg_wr_data <= 29'd1;  
    end
    RD:
    begin
      pmu_cfg_wr_data <= {1'b1,4'd0,2'b01,22'd0}; 
    end 
    FIN_DRV_DONE:
    begin
      pmu_cfg_wr_data <= {1'b0,cfg_pmu_ch_en,2'b11,3'b001,3'b101,16'd32768};
    end
    PMU_DRV_DONE:
    begin
      pmu_cfg_wr_data <= {1'b0,4'b1111,2'd0,1'b0,pmu_force1,pmu_force0,1'b0,cfg_pmu_cur_value,pmu_meas1,pmu_meas0,1'b1,2'd0,clamp_en,cmp_en,cfg_pmu_cmp_type,1'b0,6'd0};    //close the pmu channel
    end  
    default:
    begin
      pmu_cfg_wr_data <= SYS_DEFAULT_VLU; 
    end 
  endcase
end

//=====================================================================
//========================get cmp data=================================
//=====================================================================
always @(posedge clk) 
begin
  if(pmu_cmp_result_vld) 
  begin
    pmu_cmp_rslt2pck <= pmu_cmp_result[CMP_HBIT:CMP_LBIT];
  end 
  else
  begin
    pmu_cmp_rslt2pck <= pmu_cmp_rslt2pck;
  end  
end

endmodule