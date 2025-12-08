`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-25
// Module Name           : alpg_timg_gen
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
module alpg_timg_gen
#(
    parameter TIMING_DW         = 22             
) 
(            
    input                          sys_clk                   ,            
    input                          sys_rst                   ,            
    input                          clk_200M_45               ,            
    input                          clk_200M_90               ,            
    input                          clk_200M_135              , 
    input                          alpg_start                ,   
    input                          alpg_done                 ,        
    //-------timing cfg------
    (*mark_debug="true"*)(*keep="true"*)input                          pat_data_parse_vld        ,
    (*mark_debug="true"*)(*keep="true"*)input      [TIMING_DW-1:0]     pattern_data_rate         ,
    //drv
    input      [TIMING_DW-1:0]     pattern_a_clk_drv0        ,
    input      [TIMING_DW-1:0]     pattern_b_clk_drv0        ,
    input      [TIMING_DW-1:0]     pattern_c_clk_drv0        ,
    input      [TIMING_DW-1:0]     pattern_a_clk_drv1        ,
    input      [TIMING_DW-1:0]     pattern_b_clk_drv1        ,
    input      [TIMING_DW-1:0]     pattern_c_clk_drv1        ,
    //io
    input      [TIMING_DW-1:0]     pattern_a_clk_io          ,
    input      [TIMING_DW-1:0]     pattern_b_clk_io          ,
    input      [TIMING_DW-1:0]     pattern_c_clk_io          ,
    input      [TIMING_DW-1:0]     pattern_drv_r             ,
    input      [TIMING_DW-1:0]     pattern_drv_f             ,
    input      [TIMING_DW-1:0]     pattern_strb              ,
    //alpg_timing
    (*mark_debug="true"*)(*keep="true"*)output                         base_rate_clk             ,
    output                         strb_pluse                ,
    output                         pat_a_clk_d0              ,
    output                         pat_b_clk_d0              ,
    output                         pat_c_clk_d0              ,
    output                         pat_a_clk_d1              ,
    output                         pat_b_clk_d1              ,
    output                         pat_c_clk_d1              ,
    output                         pat_a_clk_io              ,
    output                         pat_b_clk_io              ,
    output                         pat_c_clk_io              ,
    output                         pat_drv_r                 ,                
    output                         pat_drv_f                                 
);

alpg_clk_gen # (
  .TIMING_DW(TIMING_DW)
)
u_base_clk (
  .sys_clk           (sys_clk           ),
  .sys_rst           (sys_rst           ),
  .clk_200M_45       (clk_200M_45       ),
  .clk_200M_90       (clk_200M_90       ),
  .clk_200M_135      (clk_200M_135      ),
  .alpg_start        (alpg_start        ),
  .alpg_done         (alpg_done         ),
  .pat_data_parse_vld(pat_data_parse_vld),
  .pattern_data_rate (pattern_data_rate ),
  .pat_timing_cfg    ('d0               ),
  .base_timing_flag  ('d1               ),
  .pattern_clk       (base_rate_clk     )
);

localparam PAT_CLK_CFG_NUM = 12;

wire [PAT_CLK_CFG_NUM*TIMING_DW-1:0] pat_cfg_clk_bus;
wire [PAT_CLK_CFG_NUM-1:0]           pat_clk_bus    ;

assign pat_cfg_clk_bus = {pattern_strb,pattern_drv_f,pattern_drv_r,
                          pattern_c_clk_io,pattern_b_clk_io,pattern_a_clk_io,
                          pattern_c_clk_drv1,pattern_b_clk_drv1,pattern_a_clk_drv1,
                          pattern_c_clk_drv0,pattern_b_clk_drv0,pattern_a_clk_drv0};

genvar i;

generate
  for (i = 0; i < PAT_CLK_CFG_NUM ; i = i + 1) 
  begin:u_pat_clk_gen
    alpg_clk_gen # (
      .TIMING_DW(TIMING_DW)
    )
    u_pat_clk (
      .sys_clk           (sys_clk                                          ),
      .sys_rst           (sys_rst                                          ),
      .clk_200M_45       (clk_200M_45                                      ),
      .clk_200M_90       (clk_200M_90                                      ),
      .clk_200M_135      (clk_200M_135                                     ),
      .alpg_start        (alpg_start                                       ),
      .alpg_done         (alpg_done                                        ),
      .pat_data_parse_vld(pat_data_parse_vld                               ),
      .pattern_data_rate (pattern_data_rate                                ),
      .pat_timing_cfg    (pat_cfg_clk_bus[(i+1)*TIMING_DW-1:i*TIMING_DW]   ),
      .base_timing_flag  ('d0                                              ),
      .pattern_clk       (pat_clk_bus[i]                                   )
    );
  end
endgenerate

assign pat_a_clk_d0 = pat_clk_bus[0];
assign pat_b_clk_d0 = pat_clk_bus[1];
assign pat_c_clk_d0 = pat_clk_bus[2];
assign pat_a_clk_d1 = pat_clk_bus[3];
assign pat_b_clk_d1 = pat_clk_bus[4];
assign pat_c_clk_d1 = pat_clk_bus[5];
assign pat_a_clk_io = pat_clk_bus[6];
assign pat_b_clk_io = pat_clk_bus[7];
assign pat_c_clk_io = pat_clk_bus[8];
assign pat_drv_r    = pat_clk_bus[9];
assign pat_drv_f    = pat_clk_bus[10];
assign strb_pluse   = pat_clk_bus[11];

endmodule