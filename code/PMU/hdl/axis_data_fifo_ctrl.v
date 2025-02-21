`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-09
// Module Name           : axis_data_fifo_ctrl
// Project Name          : hv
// Target Devices        : xc7z015
// Tool Versions         : vivado 2020.2
// Description           : 
//                         packet data and upload
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
//                        Revision v0.02 - Modify the frame rate configuration mode from static parameter configuration to dynamic parameter configuration
// Additional Comments   :
// 
//////////////////////////////////////////////////////////////////////////////////
module axis_data_fifo_ctrl 
#(
    parameter DW              = 32     ,
//    parameter CH_NUM          = 4      ,
    parameter DATA_TYPE_WIDTH = 2      ,
    parameter PMU_TEST_NUM_DW = 16
//    parameter FRM_NUM         = 5 
)
(
    input                              clk                     ,
    input                              rst                     ,    //active 0
    //cmd & cfg
    input                              packet_start            ,
    output reg                         packet_done       = 'd0 ,
    input      [DATA_TYPE_WIDTH-1:0]   data_type               , 
    input      [PMU_TEST_NUM_DW-1:0]   cfg_data_num            ,
    //==============axis_fifo port=========================
    output reg [DW-1:0]                axis_fifo_wr_data = 'd0 ,
    output reg                         axis_fifo_last    = 'd0 ,
    input                              axis_fifo_ready         ,
    output reg                         axis_fifo_valid   = 'd0 ,
    //==============rd sens data===========================
    input      [DW-1:0]                pl_rd_data              ,
    input                              pl_rd_data_vld          ,
    output reg                         pl_rd_en          = 'd0
);

//localparam DATA_NUM    = CH_NUM*FRM_NUM     ;
//localparam DATA_CNT_DW = $clog2(DATA_NUM)+1  ;
localparam DATA_CNT_DW = PMU_TEST_NUM_DW ;

//======================rd sens data ctrl===========================
(*mark_debug="true"*)(*keep="true"*)reg                     pl_rd_rdy       = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg [DATA_CNT_DW-1:0]   pl_rd_data_cnt  = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg                     pl_rd_data_last = 'd0 ;

always @(posedge clk) 
begin
  if(rst || (pl_rd_data_cnt == (cfg_data_num-'d2)))
  begin
    pl_rd_rdy <= 'd0;
  end  
  else if(packet_start)
  begin
    pl_rd_rdy <= 'd1;
  end  
end

always @(posedge clk) 
begin
  pl_rd_en <= pl_rd_rdy && axis_fifo_ready;
end

always @(posedge clk) 
begin
  if(rst || (pl_rd_data_cnt == (cfg_data_num-'d1))) 
  begin
    pl_rd_data_cnt <= 'd0;
  end 
  else if(pl_rd_en)
  begin
    pl_rd_data_cnt <= pl_rd_data_cnt + 'd1;
  end  
  else
  begin
    pl_rd_data_cnt <= pl_rd_data_cnt;
  end  
end

always @(posedge clk) 
begin
  packet_done <= (pl_rd_data_cnt == (cfg_data_num-'d1)) ;
end

//assign packet_done = pl_rd_data_last;
//======================axis fifo wr ctrl===========================
(*mark_debug="true"*)(*keep="true"*)reg axis_fifo_last_pre = 'd0 ;
reg [DATA_CNT_DW-1:0]   pl_rd_vld_cnt  = 'd0 ;

always @(posedge clk) 
begin
  axis_fifo_wr_data <= pl_rd_data     ;
  axis_fifo_valid   <= pl_rd_data_vld ;
end

always @(posedge clk) 
begin
  if(pl_rd_data_vld)
  begin
    pl_rd_vld_cnt <= pl_rd_vld_cnt + 'd1;
  end
  else
  begin
    pl_rd_vld_cnt <= 'd0;
  end  
end

always @(posedge clk) 
begin
  axis_fifo_last <= (pl_rd_vld_cnt == (cfg_data_num-'d1));
end

//always @(posedge clk) 
//begin
//  axis_fifo_last_pre <= pl_rd_data_last;
//  axis_fifo_last     <= axis_fifo_last_pre;
//end

endmodule