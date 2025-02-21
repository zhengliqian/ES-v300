`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-22
// Module Name           : pmu_ctrl_mst
// Project Name          : hv
// Target Devices        : xc7z015
// Tool Versions         : Vivado 2020.2
// Description           : 
//                        1.Control the PMU according to the running state, and output two sub-task control instructions;
//                        2.Deliver the corresponding parameters of the two subtask modules;
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
//                        Revision v0.02 - Add pmu close ctrl function;
//                        Revision v0.03 - Modify smp_wait_time from 10us to 100us;    --2024-11-14
//                        Revision v0.04 - Modify T & T1 from localparam to cfg_reg;    --2024-12-10
// Additional Comments   :
// 
//////////////////////////////////////////////////////////////////////////////////
module pmu_ctrl_mst
#(
    parameter PMU_TIME_DW     = 15 ,
    parameter PMU_TEST_NUM_DW = 16 ,
    parameter PMU_CLOSE_T_DW  = 20 ,
    parameter PMU_SMP_WAIT_DW = 16
) 
(
    input                             clk                 ,
    input                             rst                 ,
    //cfg
    (*mark_debug="true"*)(*keep="true"*)input      [PMU_TIME_DW-1:0]      cfg_pmu_time        ,                   //need > 8.5us,steep 1us
    (*mark_debug="true"*)(*keep="true"*)input      [PMU_SMP_WAIT_DW-1:0]  cfg_pmu_smp_wait_time        ,          //need > 100us,steep 0.1ms
    input      [PMU_TEST_NUM_DW-1:0]  cfg_pmu_test_num    ,
    (*mark_debug="true"*)(*keep="true"*)input      [PMU_CLOSE_T_DW-1:0]   cfg_pmu_close_time  ,      //step is 100us
    (*mark_debug="true"*)(*keep="true"*)input                             adc_ready           ,
    (*mark_debug="true"*)(*keep="true"*)output                            pmu_smp_start       ,
    //cmd
    input                             pmu_cfg_rd_done     ,
    (*mark_debug="true"*)(*keep="true"*)output reg                        pmu_close     = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)input                             pmu_work_start      ,
    (*mark_debug="true"*)(*keep="true"*)output reg                        pmu_work_busy = 'd0 ,     
    (*mark_debug="true"*)(*keep="true"*)output reg                        pmu_work_done = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg                        pmu_drv_start = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)input                             pmu_drv_done        ,
    (*mark_debug="true"*)(*keep="true"*)input                             pmu_smp_done        ,
    (*mark_debug="true"*)(*keep="true"*)output reg                        pmu_smp_busy  = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)input                             pmu_rd_start        ,
    (*mark_debug="true"*)(*keep="true"*)output reg                        pmu_pck_start = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)input                             pmu_pck_done                     
);
    
localparam ST_DW = 4;

localparam IDLE     = 0;
localparam DRV      = 1;
localparam WAIT_SMP = 2;
localparam SMP      = 3;
localparam PROCE    = 4;
localparam WAIT_RD  = 5;
localparam PCK      = 6;

localparam WAIT_SMP_TIME = 10000;    //100us in 100M clk
localparam WAIT_SMP_TIME_DW = $clog2(WAIT_SMP_TIME)+1;

wire adc_start;
reg adc_start_d1 = 'd0;
wire adc_start_r;

//vio_0 u_adc_start (
//  .clk(clk),                // input wire clk
//  .probe_out0(adc_start)  // output wire [0 : 0] probe_out0
//);

always @(posedge clk) 
begin
  adc_start_d1 <= adc_start;
end

assign adc_start_r = adc_start && (!adc_start_d1);

//=============================================================================
//==================================st ctrl====================================
//=============================================================================
(*mark_debug="true"*)(*keep="true"*)reg   [ST_DW-1:0]           crt_st        = IDLE;
reg   [ST_DW-1:0]           nxt_st        = IDLE;
(*mark_debug="true"*)(*keep="true"*)reg   [PMU_TIME_DW-1:0]     pmu_work_time = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg   [PMU_TEST_NUM_DW-1:0] pmu_smp_cnt   = 'd0;

(*mark_debug="true"*)(*keep="true"*)reg [WAIT_SMP_TIME_DW-1:0] wait_smp_time = 'd0;

reg [7:0] us_cnt = 'd0;  //smp_time t steep is 1us
reg [15:0] ms_cnt = 'd0;
localparam WAIT_TIME_STEEP = 10000;    //0.1ms
localparam US_NUM = 100;

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
      if(pmu_work_start)
      begin
        nxt_st = DRV; 
      end  
      else if(pmu_rd_start)
      begin
        nxt_st = PCK;
      end
      else
      begin
        nxt_st = IDLE;
      end  
    end
    DRV: 
    begin
      if(pmu_drv_done)
      begin
        nxt_st = WAIT_SMP;
      end  
      else
      begin
        nxt_st = DRV;
      end  
    end   
    WAIT_SMP:
    begin
      if((wait_smp_time == cfg_pmu_smp_wait_time - 'd1) && ((ms_cnt == WAIT_TIME_STEEP-1)))
      //if(adc_start_r)
      begin
        nxt_st = SMP;
      end
      else
      begin
        nxt_st = WAIT_SMP;
      end  
    end
    SMP: 
    begin
      if(pmu_smp_done)
      begin
        nxt_st = PROCE;
      end  
      else
      begin
        nxt_st = SMP;
      end    
    end   
    PROCE: 
    begin
      //if((pmu_smp_cnt == cfg_pmu_test_num) && pmu_cfg_rd_done) 
      if((pmu_smp_cnt == cfg_pmu_test_num) && (pmu_work_time == cfg_pmu_time-'d1) && (us_cnt == (US_NUM - 'd1))) 
      begin
        nxt_st = IDLE;
      end
      //else if(pmu_cfg_rd_done)
      else if((pmu_work_time == cfg_pmu_time - 'd1) && (us_cnt == (US_NUM - 'd1)))
      begin
        nxt_st = SMP;
      end  
      else
      begin
        nxt_st = PROCE;
      end  
    end 
    PCK:  
    begin
      if(pmu_pck_done)
      begin
        nxt_st = IDLE;
      end  
      else
      begin
        nxt_st = PCK;
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
  if(ms_cnt == WAIT_TIME_STEEP-1)
  begin
    ms_cnt <= 'd0;
  end
  else if(crt_st == WAIT_SMP)
  begin
    ms_cnt <= ms_cnt + 'd1;
  end
  else
  begin
    ms_cnt <= 'd0;
  end  
end

always @(posedge clk) 
begin
  if(crt_st != WAIT_SMP)
  begin
    wait_smp_time <= 'd0;
  end
  else if(ms_cnt == WAIT_TIME_STEEP-1)
  begin
    wait_smp_time <= wait_smp_time + 'd1;
  end
  else
  begin
    wait_smp_time <= wait_smp_time;
  end  
end

//=============================================================================
//==================================cmd gen====================================
//=============================================================================
always @(posedge clk) 
begin
  pmu_drv_start   <= (nxt_st == DRV) && ((crt_st == IDLE) || (crt_st == PROCE));
  pmu_pck_start   <= (nxt_st == PCK) && (crt_st == IDLE)                    ;
  pmu_work_busy   <= (crt_st != IDLE)                                          ;
  pmu_work_done   <= (nxt_st == IDLE) && (crt_st == PROCE)                  ;
end

assign pmu_smp_start = adc_ready && (!pmu_smp_busy) && (crt_st == SMP);

always @(posedge clk) 
begin
  if(rst || pmu_smp_done)
  begin
    pmu_smp_busy <= 'd0;
  end
  else if(pmu_smp_start)
  begin
    pmu_smp_busy <= 'd1;
  end
  else
  begin
    pmu_smp_busy <= pmu_smp_busy;
  end  
end


always @(posedge clk) 
begin
  if(us_cnt == (US_NUM - 'd1))
  begin
    us_cnt <= 'd0;
  end
  else if((crt_st == SMP) || (crt_st == PROCE))
  begin
    us_cnt <= us_cnt + 'd1;
  end  
  else
  begin
    us_cnt <= 'd0;
  end  
end

always @(posedge clk) 
begin
  if(pmu_work_time == cfg_pmu_time)
  begin
    pmu_work_time <= 'd0;
  end
  else if(us_cnt == (US_NUM - 'd1))
  begin
    pmu_work_time <= pmu_work_time + 'd1;
  end  
  else
  begin
    pmu_work_time <= pmu_work_time;
  end  
end

always @(posedge clk) 
begin
  if(pmu_rd_start)
  begin
    pmu_smp_cnt <= 'd0;
  end
  else if(pmu_smp_done)
  begin
    pmu_smp_cnt <= pmu_smp_cnt + 'd1;
  end
  else
  begin
    pmu_smp_cnt <= pmu_smp_cnt;
  end  
end

//add pmu close function
localparam PMU_CLOSE_WAIT_DW = 16;
localparam PMU_CLOSE_WAIT_TIME = 10000 ;  //100us

(*mark_debug="true"*)(*keep="true"*)reg [PMU_CLOSE_WAIT_DW-1:0] pmu_close_wait_time      = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg                         pmu_close_wait_flag      = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [PMU_CLOSE_T_DW-1:0]    pmu_close_wait_100u_num  = 'd0;

always @(posedge clk) 
begin
  //if(pmu_close_wait_flag)
  //begin
  //  pmu_close_wait_time <= pmu_close_wait_time + 'd1;
  //end
  //else
  //begin
  //  pmu_close_wait_time <= 'd0;
  //end  
  if((!pmu_close_wait_flag) || (pmu_close_wait_time == PMU_CLOSE_WAIT_TIME-1))
  begin
    pmu_close_wait_time <= 'd0;
  end
  else
  begin
    pmu_close_wait_time <= pmu_close_wait_time + 'd1;
  end  
end

always @(posedge clk) 
begin
  if(!pmu_close_wait_flag)
  begin
    pmu_close_wait_100u_num <= 'd0;
  end
  else if(pmu_close_wait_time == PMU_CLOSE_WAIT_TIME-1)
  begin
    pmu_close_wait_100u_num <= pmu_close_wait_100u_num + 'd1;
  end  
  else
  begin
    pmu_close_wait_100u_num <= pmu_close_wait_100u_num;
  end  
end

always @(posedge clk) 
begin
  //if(rst || (pmu_close_wait_time == PMU_CLOSE_WAIT_TIME-1))
  if(rst || (pmu_close_wait_100u_num == cfg_pmu_close_time))
  begin
    pmu_close_wait_flag <= 'd0;
  end
  else if(pmu_work_done && (cfg_pmu_close_time != 'd0))
  begin
    pmu_close_wait_flag <= 'd1;
  end
  else
  begin
    pmu_close_wait_flag <= pmu_close_wait_flag;
  end  
end

always @(posedge clk) 
begin
  //pmu_close <= (pmu_close_wait_time == PMU_CLOSE_WAIT_TIME-1);
  pmu_close <= (pmu_close_wait_time == PMU_CLOSE_WAIT_TIME-1) && (pmu_close_wait_100u_num == cfg_pmu_close_time - 'd1);
end

endmodule