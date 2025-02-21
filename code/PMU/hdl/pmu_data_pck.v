`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-26
// Module Name           : pmu_data_pck
// Project Name          : HV
// Target Devices        : xc7z015
// Tool Versions         : Vivado 2020.2
// Description           : 
//                         1. Receive ADC data;
//                         2. Packaged storage with comparator data 
// Dependencies          : pmu_core
// 
// Revision              :
//                        Revision v0.01 - File Created
//                        Revision v0.02 - Add the ability to convert ADC data to voltage and current, and make code optimizations -2024-09-18 
//                        Revision v0.03 - 1.Modify the mean to enable the original data store;
//                                         2.Add data upload type: Raw Value/Mean Value;              --2024/10/31
// Additional Comments   :
//                       1.MS0 -> ADC_A1;
//                         MS1 -> ADC_A2;
//                         MS2 -> ADC_B1;
//                         MS3 -> ADC_B2;
//                       2.ADC output CH:ADC_A/B0 -> ADC_A/B7  
//                       3.The ADC outputs all 16 channels of data             
//////////////////////////////////////////////////////////////////////////////////
module pmu_data_pck 
#(
    parameter SMP_DW          = 16  ,
    parameter CH_NUM          = 4   ,
    parameter DATA_TYPE_WIDTH = 2   ,
    parameter PMU_MOD_DW      = 3   ,
    parameter PMU_VLU_DW      = 3   ,
    parameter AXIS_FIFO_DW    = 32  ,
    parameter MA_RESULT_DW    = 26  ,
    parameter PMU_VI_DW       = 26  ,
    parameter PMU_TEST_NUM_DW = 16
) 
(
    input                            clk                        ,
    input                            rst                        ,
    //cmd & cfg
    input                            pmu_work_start             ,
    input                            pmu_work_done              ,
    input                            pmu_store_en               ,
    input      [DATA_TYPE_WIDTH-1:0] cfg_data_type              ,    //0-mean data;1-smp data
    input      [PMU_VLU_DW-1:0]      cfg_pmu_cur_value          ,    //0:??5ua; 1:??20uA; 2:??200uA; 3:??2mA; 4:??25mA;
    input      [PMU_MOD_DW-1:0]      cfg_pmu_test_mode          ,    //0:VSIM; 1:MVM; 2:VS; 3:ISVM;
    input      [PMU_TEST_NUM_DW-1:0] cfg_pmu_test_num           ,
    input      [PMU_VI_DW-1:0]       cfg_pmu_cmp_h              ,
    input      [PMU_VI_DW-1:0]       cfg_pmu_cmp_l              ,
    input                            pmu_smp_busy               ,
    output reg                       pmu_smp_done      = 'd0    ,    //module save pmu data into pl fifo
    //cmp & adc data
    input      [CH_NUM*2-1:0]        pmu_cmp_result             ,
    input      [SMP_DW-1:0]          pmu_smp_dataa              ,
    input      [SMP_DW-1:0]          pmu_smp_datab              ,
    input                            pmu_smp_data_vld           ,
    //connect axis_fifo
    (*mark_debug="true"*)(*keep="true"*)output     [AXIS_FIFO_DW-1:0]    pl_rd_data                 ,
    (*mark_debug="true"*)(*keep="true"*)output                           pl_rd_data_vld             ,
    (*mark_debug="true"*)(*keep="true"*)input                            pl_rd_en                   ,
    //DFX
    (*mark_debug="true"*)(*keep="true"*)output                           dfx_fifo_empty_rd          ,
    (*mark_debug="true"*)(*keep="true"*)output                           dfx_fifo_full_wr          
);
    
localparam PMU_START_CH = 1;
localparam PMU_END_CH   = 2;
localparam DATA_CNT_DW  = 4;
localparam ADC_CH       = 8;

localparam FIFO_WRITE_DEPTH = 16384                      ;
localparam DATA_COUNT_WIDTH = $clog2(FIFO_WRITE_DEPTH)+1;
localparam PROG_EMPTY       = 10                        ;
localparam PROG_FULL        = FIFO_WRITE_DEPTH-10       ;
localparam PMU_ADC_NUM      = CH_NUM/2                  ;
localparam CH_CMP_DW        = 2                         ;
localparam SMP_ADD_DW       = PMU_TEST_NUM_DW + SMP_DW  ;
localparam MEAN_DOUT_DW     = SMP_ADD_DW + PMU_TEST_NUM_DW;
localparam I_STEEP0         = 30500000/200000           ;    //1pA
localparam I_STEEP1         = 30500000/50000            ;    //1pA
localparam I_STEEP2         = 3050000/5000              ;    //10pA
localparam I_STEEP3         = 305000/500                ;    //100pA
localparam I_STEEP4         = 30500/40                  ;    //1nA
localparam V_STEEP          = 305                       ;    //1uV
localparam STEEP_DW         = 10                        ;
localparam I_DW             = STEEP_DW + SMP_DW         ;

(*mark_debug="true"*)(*keep="true"*)reg [DATA_CNT_DW-1:0]  smp_data_cnt = 'd0;

always @(posedge clk) 
begin
  //if(rst || (smp_data_cnt == ADC_CH-1))
  if(rst || (!pmu_smp_busy))
  begin
    smp_data_cnt <= 'd0;
  end  
  else if(pmu_smp_data_vld)
  begin
    smp_data_cnt <= smp_data_cnt + 'd1;
  end  
  else 
  begin
    smp_data_cnt <= smp_data_cnt;
  end  
end

//==================================================================
//=========================find the mean============================
//==================================================================
//===========================smp data add=============================
(*mark_debug="true"*)(*keep="true"*)reg [SMP_ADD_DW*CH_NUM-1:0] smp_add_dbus    = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg                         smp_add_vld     = 'd0;
reg                         smp_add_vld_d1  = 'd0;
reg                         smp_add_vld_d2  = 'd0;
reg                         smp_add_vld_d3  = 'd0;
reg                         smp_add_vld_d4  = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg                         div_din_vld     = 'd0;

always @(posedge clk) 
begin
  if(pmu_work_start)  
  begin
    smp_add_dbus <= 'd0;
  end
  else if((smp_data_cnt == PMU_START_CH) && pmu_smp_data_vld)
  begin
    smp_add_dbus[SMP_ADD_DW*CH_NUM-1:SMP_ADD_DW*(CH_NUM-1)]     <= $signed(smp_add_dbus[SMP_ADD_DW*CH_NUM-1:SMP_ADD_DW*(CH_NUM-1)]    ) + $signed(pmu_smp_dataa);  //ch0
    smp_add_dbus[SMP_ADD_DW*(CH_NUM-2)-1:SMP_ADD_DW*(CH_NUM-3)] <= $signed(smp_add_dbus[SMP_ADD_DW*(CH_NUM-2)-1:SMP_ADD_DW*(CH_NUM-3)]) + $signed(pmu_smp_datab);  //ch2
  end
  else if((smp_data_cnt == PMU_END_CH) && pmu_smp_data_vld)
  begin
    smp_add_dbus[SMP_ADD_DW*(CH_NUM-1)-1:SMP_ADD_DW*(CH_NUM-2)] <= $signed(smp_add_dbus[SMP_ADD_DW*(CH_NUM-1)-1:SMP_ADD_DW*(CH_NUM-2)]) + $signed(pmu_smp_dataa);  //ch1
    smp_add_dbus[SMP_ADD_DW*(CH_NUM-3)-1:SMP_ADD_DW*(CH_NUM-4)] <= $signed(smp_add_dbus[SMP_ADD_DW*(CH_NUM-3)-1:SMP_ADD_DW*(CH_NUM-4)]) + $signed(pmu_smp_datab);  //ch3     
  end
  else
  begin
    smp_add_dbus <= smp_add_dbus;
  end  
end

always @(posedge clk) 
begin
  smp_add_vld <= (smp_data_cnt == PMU_END_CH) && pmu_smp_data_vld;
  smp_add_vld_d1 <= smp_add_vld   ;
  smp_add_vld_d2 <= smp_add_vld_d1;
  smp_add_vld_d3 <= smp_add_vld_d2;
  smp_add_vld_d4 <= smp_add_vld_d3;
end

//===========================div din gen=============================
always @(posedge clk) 
begin
  if(smp_add_vld_d4)  
  begin
    div_din_vld <= 'd0;
  end
  //else if(smp_add_vld && pmu_store_en)
  else if(smp_add_vld)
  begin
    div_din_vld <= 'd1;
  end
  else
  begin
    div_din_vld <= div_din_vld;
  end  
end

reg [SMP_ADD_DW*CH_NUM-1:0] div_din_bus = 'd0;

always @(posedge clk) 
begin
  if(smp_add_vld)
  begin
    div_din_bus <= smp_add_dbus;
  end
  else if(div_din_vld)  
  begin
    div_din_bus <= {div_din_bus[SMP_ADD_DW*(CH_NUM-1)-1:0],{(SMP_ADD_DW){1'b0}}};
  end
  else   
  begin
    div_din_bus <= div_din_bus; 
  end
end

//m_axis_dout_tdata[47:16] is quot(signed);m_axis_dout_tdata[15:0] is intrmd;
(*mark_debug="true"*)(*keep="true"*)wire [MEAN_DOUT_DW-1:0] smp_mean    ;
(*mark_debug="true"*)(*keep="true"*)wire                    smp_mean_vld;

div_gen_0 u_smp_mean_div 
(
  .aclk                  (clk                                                       ),   // input wire aclk
  .s_axis_divisor_tvalid (div_din_vld                                               ),   // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata  (cfg_pmu_test_num                                          ),   // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_din_vld                                               ),   // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata (div_din_bus[SMP_ADD_DW*CH_NUM-1:SMP_ADD_DW*(CH_NUM-1)]    ),   // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid    (smp_mean_vld                                              ),   // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata     (smp_mean                                                  )    // output wire [47 : 0] m_axis_dout_tdata
);

//==================================================================
//==================rcv data when pmu_store_en======================
//==================================================================
(*mark_debug="true"*)(*keep="true"*)reg                     rcv_data_vld  = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [DATA_CNT_DW-1:0]   rcv_data_cnt  = 'd0;

//PMU data is adc CHA1/CHA2 & CHB1/CHB2
always @(posedge clk) 
begin
  if(rst || (rcv_data_cnt >= CH_NUM-1)) 
  begin
    rcv_data_vld <= 'd0;
  end
  else if((smp_data_cnt == PMU_END_CH + 1) && pmu_store_en)
  begin
    rcv_data_vld <= 'd1;
  end  
  else
  begin
    rcv_data_vld <= rcv_data_vld;
  end  
end

(*mark_debug="true"*)(*keep="true"*)reg  [CH_NUM*2-1:0]      pmu_cmp_result_shift = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [SMP_DW*CH_NUM-1:0] smp_data_shift       = 'd0;

always @(posedge clk) 
begin
  if(rcv_data_vld)
  begin
    smp_data_shift <= {smp_data_shift[SMP_DW*(CH_NUM-1)-1:0],{(SMP_DW){1'b0}}};
  end
  else if(smp_data_cnt[0] && pmu_smp_data_vld)
  begin
    smp_data_shift[SMP_DW*CH_NUM-1:SMP_DW*(CH_NUM-1)]     <= pmu_smp_dataa;
    smp_data_shift[SMP_DW*(CH_NUM-2)-1:SMP_DW*(CH_NUM-3)] <= pmu_smp_datab;
  end
  else if(pmu_smp_data_vld)
  begin
    smp_data_shift[SMP_DW*(CH_NUM-1)-1:SMP_DW*(CH_NUM-2)] <= pmu_smp_dataa;
    smp_data_shift[SMP_DW*(CH_NUM-3)-1:SMP_DW*(CH_NUM-4)] <= pmu_smp_datab;
  end  
  else   
  begin
    smp_data_shift <= smp_data_shift;
  end
end

always @(posedge clk) 
begin
  if(smp_data_cnt == 'd0)
  begin
    rcv_data_cnt <= 'd0;
  end
  else if(rcv_data_vld)
  begin
    rcv_data_cnt <= rcv_data_cnt + 'd1;
  end
  else
  begin
    rcv_data_cnt <= rcv_data_cnt;
  end  
end
//====================================================================================
//================================find I or V=========================================
//====================================================================================
(*mark_debug="true"*)(*keep="true"*)reg  [SMP_DW-1:0]   v_code           = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [STEEP_DW-1:0] measout_steep    = 'd0;
(*mark_debug="true"*)(*keep="true"*)wire [I_DW-1:0]     measout_code          ;
(*mark_debug="true"*)(*keep="true"*)reg                 measout_mean_vld = 'd0;

always @(posedge clk) 
begin
  if(cfg_pmu_test_mode[0])
  begin
    measout_steep <= V_STEEP;
  end
  else
  begin
    case (cfg_pmu_cur_value)
    'd0:
    begin
      measout_steep <= I_STEEP0;
    end 
    'd1:
    begin
      measout_steep <= I_STEEP1;
    end
    'd2:
    begin
      measout_steep <= I_STEEP2;
    end
    'd3:
    begin
      measout_steep <= I_STEEP3;
    end
    'd4:
    begin
      measout_steep <= I_STEEP4;
    end
    default: 
    begin
      measout_steep <= I_STEEP0;
    end
  endcase
  end  
end

always @(posedge clk) 
begin
  if(smp_mean_vld)
  begin
    v_code <= smp_mean[PMU_TEST_NUM_DW+SMP_DW-1:PMU_TEST_NUM_DW];
  end
  else if(rcv_data_vld)
  begin
    v_code <= smp_data_shift[SMP_DW*CH_NUM-1:SMP_DW*(CH_NUM-1)];
  end
  else
  begin
    v_code <= v_code;
  end  
end

//I = ADC_CODE * ISTEEP; V = ADC_CODE * V_STEEP
//p dly is 4clk
i_gen u_mout_gen (
  .CLK(clk             ),      // input wire CLK
  .A  (v_code          ),      // input wire [15 : 0] A
  .B  (measout_steep   ),      // input wire [9 : 0] B(unsigned)
  .P  (measout_code    )       // output wire [25 : 0] P
);

(*mark_debug="true"*)(*keep="true"*)reg measout_mean_rdy    = 'd0;
reg measout_mean_rdy_d1 = 'd0;
reg measout_mean_rdy_d2 = 'd0;
reg measout_mean_rdy_d3 = 'd0;

always @(posedge clk) 
begin
  measout_mean_rdy    <= smp_mean_vld;
  measout_mean_rdy_d1 <= measout_mean_rdy   ;
  measout_mean_rdy_d2 <= measout_mean_rdy_d1;
  measout_mean_rdy_d3 <= measout_mean_rdy_d2;
  measout_mean_vld    <= measout_mean_rdy_d3;
end

//====================================================================================
//============================w/r fifo when !mean=====================================
//====================================================================================
(*mark_debug="true"*)(*keep="true"*)wire                    wr_en  ;
(*mark_debug="true"*)(*keep="true"*)wire [AXIS_FIFO_DW-1:0] wr_data;

reg rcv_data_vld_d1 = 'd0;
reg rcv_data_vld_d2 = 'd0;
reg rcv_data_vld_d3 = 'd0;
reg rcv_data_vld_d4 = 'd0;
reg measout_rcv_vld = 'd0;

always @(posedge clk) 
begin
  rcv_data_vld_d1 <= rcv_data_vld    ;
  rcv_data_vld_d2 <= rcv_data_vld_d1 ;
  rcv_data_vld_d3 <= rcv_data_vld_d2 ;
  rcv_data_vld_d4 <= rcv_data_vld_d3 ;
  measout_rcv_vld <= rcv_data_vld_d4 ;
end

(*mark_debug="true"*)(*keep="true"*)reg [DATA_CNT_DW-1:0]   measout_data_cnt  = 'd0;

always @(posedge clk) 
begin
  if(measout_rcv_vld)
  begin
    measout_data_cnt <= measout_data_cnt + 'd1;
  end
  else
  begin
    measout_data_cnt <= 'd0;
  end  
end

always @(posedge clk) 
begin
  //if(measout_code_vld && pmu_smp_busy)
  if(measout_rcv_vld && pmu_smp_busy)
  begin
    pmu_cmp_result_shift <= {pmu_cmp_result_shift[CH_NUM*2-CH_CMP_DW-1:0],{(CH_CMP_DW){1'b0}}};
  end  
  else
  begin
    pmu_cmp_result_shift <= pmu_cmp_result;
//    pmu_cmp_result_shift <= 8'b10101101;            //for test
  end  
end

//assign wr_en = measout_code_vld && pmu_store_en;
assign wr_en = measout_rcv_vld;         //data choose dly 1clk;multi dly 4clk
assign wr_data = {measout_data_cnt[CH_NUM-1:0],pmu_cmp_result_shift[CH_NUM*2-1:CH_NUM*2-CH_CMP_DW],measout_code[PMU_VI_DW-1:0]};                                      

//rd ctrl
(*mark_debug="true"*)(*keep="true"*)wire                       rd_en       ;
(*mark_debug="true"*)(*keep="true"*)wire [AXIS_FIFO_DW-1:0]    rd_data     ;
(*mark_debug="true"*)(*keep="true"*)wire                       rd_data_vld ;

assign rd_en = pl_rd_en && pmu_store_en && (cfg_data_type == 'd1);

//==================================================================
//=========================sys st ctrl==============================
//==================================================================
//gen smp_done
(*mark_debug="true"*)(*keep="true"*)reg  smp_mean_vld_d1 = 'd0;
(*mark_debug="true"*)(*keep="true"*)wire smp_mean_vld_f       ;
reg measout_mean_vld_d1 = 'd0;

always @(posedge clk) 
begin
  smp_mean_vld_d1     <= smp_mean_vld    ;
  measout_mean_vld_d1 <= measout_mean_vld;
end

assign smp_mean_vld_f = smp_mean_vld_d1 && (!smp_mean_vld);

always @(posedge clk) 
begin
  //pmu_smp_done <= (measout_data_cnt == CH_NUM-1); 
  pmu_smp_done <= measout_mean_vld_d1 && (!measout_mean_vld); 
end

//send data to ps
(*mark_debug="true"*)(*keep="true"*)reg [PMU_TEST_NUM_DW-1:0] smp_frm_cnt = 'd0;

always @(posedge clk) 
begin
  if(pmu_work_start)
  begin
    smp_frm_cnt <= 'd0;
  end
  else if(smp_mean_vld_f)
  begin
    smp_frm_cnt <= smp_frm_cnt + 'd1;
  end
  else
  begin
    smp_frm_cnt <= smp_frm_cnt;
  end  
end

//mean data compare
(*mark_debug="true"*)(*keep="true"*)reg [CH_NUM-1:0] mean_cmp_hbus = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [CH_NUM-1:0] mean_cmp_lbus = 'd0;

always @(posedge clk) 
begin
  //if(measout_code_vld && pmu_store_en && (smp_frm_cnt == cfg_pmu_test_num))
  if(measout_mean_vld && (smp_frm_cnt == cfg_pmu_test_num))
  begin
    mean_cmp_hbus[CH_NUM-1] <= ($signed(measout_code[PMU_VI_DW-1:0]) < $signed(cfg_pmu_cmp_h));
    mean_cmp_lbus[CH_NUM-1] <= ($signed(measout_code[PMU_VI_DW-1:0]) > $signed(cfg_pmu_cmp_l)); 
    mean_cmp_hbus[CH_NUM-2:0] <= mean_cmp_hbus[CH_NUM-1:1];
    mean_cmp_lbus[CH_NUM-2:0] <= mean_cmp_lbus[CH_NUM-1:1];
  end
  else
  begin
    mean_cmp_hbus <= mean_cmp_hbus;
    mean_cmp_lbus <= mean_cmp_lbus;
  end  
end

//mean data lock
(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW*CH_NUM-1:0] mean_data_lock = 'd0;

always @(posedge clk) 
begin
  //if(measout_code_vld && pmu_store_en && (smp_frm_cnt == cfg_pmu_test_num))
  if(measout_mean_vld && (smp_frm_cnt == cfg_pmu_test_num))
  begin
    mean_data_lock <= {measout_code[PMU_VI_DW-1:0],mean_data_lock[PMU_VI_DW*CH_NUM-1:PMU_VI_DW]};
  end
  else
  begin
    mean_data_lock <= mean_data_lock;
  end
end

//mean data pck
(*mark_debug="true"*)(*keep="true"*)reg [AXIS_FIFO_DW-1:0]        mean_data           = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg                           mean_data_vld       = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [DATA_CNT_DW-1:0]         rd_data_cnt         = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [CH_NUM-1:0]              mean_cmp_hbus_shift = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [CH_NUM-1:0]              mean_cmp_lbus_shift = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [PMU_VI_DW*CH_NUM-1:0]    smp_mean_bus_shift  = 'd0;

always @(posedge clk) 
begin
  if(pl_rd_en && (cfg_data_type == 'd0))
  begin
    rd_data_cnt <= rd_data_cnt + 'd1;
  end
  else
  begin
    rd_data_cnt <= 'd0;
  end  
end

always @(posedge clk) 
begin
  if(pl_rd_en && (cfg_data_type == 'd0))
  begin
    mean_cmp_hbus_shift <= {1'b0,mean_cmp_hbus_shift[CH_NUM-1:1]};
    mean_cmp_lbus_shift <= {1'b0,mean_cmp_lbus_shift[CH_NUM-1:1]};
    smp_mean_bus_shift  <= {{PMU_VI_DW{1'b0}},smp_mean_bus_shift[PMU_VI_DW*CH_NUM-1:PMU_VI_DW]};
  end
  else
  begin
    mean_cmp_hbus_shift <= mean_cmp_hbus  ;
    mean_cmp_lbus_shift <= mean_cmp_lbus  ;
    smp_mean_bus_shift  <= mean_data_lock ;
  end  
end

always @(posedge clk) 
begin
  mean_data <= {rd_data_cnt[CH_NUM-1:0],mean_cmp_lbus_shift[0],mean_cmp_hbus_shift[0],smp_mean_bus_shift[PMU_VI_DW-1:0]};
  mean_data_vld <= pl_rd_en && (cfg_data_type == 'd0);
end

assign pl_rd_data     = (cfg_data_type == 'd0) ? mean_data     : rd_data    ;
assign pl_rd_data_vld = (cfg_data_type == 'd0) ? mean_data_vld : rd_data_vld;
//====================================================================================
//=================================XMP FIFO INST======================================
//====================================================================================
(*mark_debug="true"*)(*keep="true"*)wire                       empty       ;
(*mark_debug="true"*)(*keep="true"*)wire                       full        ;

xpm_fifo_sync #(
    .DOUT_RESET_VALUE   ("0"                    ),           // String
    .ECC_MODE           ("no_ecc"               ),           // String
    .FIFO_MEMORY_TYPE   ("block"                ),           // String
    .FIFO_READ_LATENCY  (2                      ),           // DECIMAL
    .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH       ),           // DECIMAL
    .FULL_RESET_VALUE   (0                      ),           // DECIMAL
    .PROG_EMPTY_THRESH  (PROG_EMPTY             ),           // DECIMAL
    .PROG_FULL_THRESH   (PROG_FULL              ),           // DECIMAL
    .RD_DATA_COUNT_WIDTH(DATA_COUNT_WIDTH       ),           // DECIMAL
    .READ_DATA_WIDTH    (AXIS_FIFO_DW           ),           // DECIMAL
    .READ_MODE          ("std"                  ),           // String
    .SIM_ASSERT_CHK     (0                      ),           // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .USE_ADV_FEATURES   ("1707"                 ),           // String
    .WAKEUP_TIME        (0                      ),           // DECIMAL
    .WRITE_DATA_WIDTH   (AXIS_FIFO_DW           ),           // DECIMAL
    .WR_DATA_COUNT_WIDTH(DATA_COUNT_WIDTH       )            // DECIMAL
 )
 xpm_fifo_sync_inst (
    .almost_empty (                   ),                     // 1-bit output
    .almost_full  (                   ),                     // 1-bit output
    .data_valid   (rd_data_vld        ),                     // 1-bit output
    .dbiterr      (                   ),                     // 1-bit output
    .dout         (rd_data            ),                     // READ_DATA_WIDTH-bit output
    .empty        (empty              ),                     // 1-bit output
    .full         (full               ),                     // 1-bit output
    .overflow     (                   ),                     // 1-bit output
    .prog_empty   (                   ),                     // 1-bit output
    .prog_full    (                   ),                     // 1-bit output
    .rd_data_count(                   ),                     // RD_DATA_COUNT_WIDTH-bit output
    .rd_rst_busy  (                   ),                     // 1-bit output
    .sbiterr      (                   ),                     // 1-bit output
    .underflow    (                   ),                     // 1-bit output
    .wr_ack       (                   ),                     // 1-bit output
    .wr_data_count(                   ),                     // WR_DATA_COUNT_WIDTH-bit output
    .wr_rst_busy  (                   ),                     // 1-bit output
    .din          (wr_data            ),                     // WRITE_DATA_WIDTH-bit input
    .injectdbiterr(1'b0               ),                     // 1-bit input
    .injectsbiterr(1'b0               ),                     // 1-bit input
    .rd_en        (rd_en              ),                     // 1-bit input
    .rst          (rst || pmu_work_start                ),                     // 1-bit input
    .sleep        (1'b0               ),                     // 1-bit input
    .wr_clk       (clk                ),                     // 1-bit input
    .wr_en        (wr_en              )                      // 1-bit input
 );

//DFX
assign dfx_fifo_full_wr  = full && wr_en;
assign dfx_fifo_empty_rd = empty && rd_en;
 
endmodule