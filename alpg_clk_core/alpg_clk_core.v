`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-16
// Module Name           : alpg_clk_core
// Project Name          : 
// Target Devices        : 
// Tool Versions         : Vivado 2020.2
// Description           : 1.fpga_clk_i_p/n = 200M;
//                         2.sys_clk = 200M ; gt_sys_clk = 100M;
// 
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
// Additional Comments   :
// 
//////////////////////////////////////////////////////////////////////////////////
module alpg_clk_core 
#(
  parameter TIMING_DW         = 22             
) 
(
    input                          fpga_clkn                 ,        //@200M Hz
    input                          fpga_clkp                 ,        //@200M Hz
    output                         sys_clk                   ,        //@200M Hz          
    output                         sys_rst                   ,
    input                          alpg_start                ,
    input                          alpg_done                 ,
    //-------timing cfg------
    input                          pat_data_parse_vld        ,
    input      [TIMING_DW-1:0]     pattern_data_rate         ,
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
    //pat clk
    output                         base_rate_clk             ,
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
    output                         pat_drv_f                 ,
    //intf clk    
    output                         fpga_clk                  , //200M
    output                         mig_ref_clk               , //400M
    output                         gt_sys_clk                 //@100M Hz
);

wire fpga_clk_i;
//wire fpga_clk;

IBUFDS fpga_clk_ibuf (
    .O(fpga_clk_i),   // 1-bit output: Buffer output
    .I(fpga_clkp ),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
    .IB(fpga_clkn)    // 1-bit input: Diff_n buffer input (connect directly to top-level port)
 );

BUFG fpgd_clk_bufg (
    .O(fpga_clk  ), // 1-bit output: Clock output.
    .I(fpga_clk_i)  // 1-bit input: Clock input.
 );

 (*mark_debug="true"*)(*keep="true"*)wire clk_lock     ;
wire clk_200M_45  ;
wire clk_200M_90  ;
wire clk_200M_135 ;
//wire gt_clk       ;
//wire mig_clk      ;

sys_clk u_sys_clk
(
 // Clock out ports
 .sys_clk     (sys_clk     ),     // output sys_clk
 .clk_200M_45 (clk_200M_45 ),     // output clk_200M_90
 .clk_200M_90 (clk_200M_90 ),     // output clk_200M_180
 .clk_200M_135(clk_200M_135),     // output clk_200M_270
 .gt_clk      (gt_sys_clk  ),     // output gt_clk
 .mig_ref_clk (mig_ref_clk ),     // output mig_clk
 // Status and control signals
 .locked      (clk_lock    ),     // output locked
// Clock in ports
 .clk_in1     (fpga_clk    )      // input clk_in1
);                             
 
assign sys_rst = ~clk_lock;

alpg_timg_gen # (
  .TIMING_DW  (TIMING_DW)
)
alpg_timg_gen_inst (
  .sys_clk           (sys_clk           ),
  .sys_rst           (sys_rst           ),
  .clk_200M_45       (clk_200M_45       ),
  .clk_200M_90       (clk_200M_90       ),
  .clk_200M_135      (clk_200M_135      ),
  .alpg_start        (alpg_start        ),
  .alpg_done         (alpg_done         ),
  .pat_data_parse_vld(pat_data_parse_vld),
  .pattern_data_rate (pattern_data_rate ),
  .pattern_a_clk_drv0(pattern_a_clk_drv0),
  .pattern_b_clk_drv0(pattern_b_clk_drv0),
  .pattern_c_clk_drv0(pattern_c_clk_drv0),
  .pattern_a_clk_drv1(pattern_a_clk_drv1),
  .pattern_b_clk_drv1(pattern_b_clk_drv1),
  .pattern_c_clk_drv1(pattern_c_clk_drv1),
  .pattern_a_clk_io  (pattern_a_clk_io  ),
  .pattern_b_clk_io  (pattern_b_clk_io  ),
  .pattern_c_clk_io  (pattern_c_clk_io  ),
  .pattern_drv_r     (pattern_drv_r     ),
  .pattern_drv_f     (pattern_drv_f     ),
  .pattern_strb      (pattern_strb      ),
  .base_rate_clk     (base_rate_clk     ),
  .strb_pluse        (strb_pluse        ),
  .pat_a_clk_d0      (pat_a_clk_d0      ),
  .pat_b_clk_d0      (pat_b_clk_d0      ),
  .pat_c_clk_d0      (pat_c_clk_d0      ),
  .pat_a_clk_d1      (pat_a_clk_d1      ),
  .pat_b_clk_d1      (pat_b_clk_d1      ),
  .pat_c_clk_d1      (pat_c_clk_d1      ),
  .pat_a_clk_io      (pat_a_clk_io      ),
  .pat_b_clk_io      (pat_b_clk_io      ),
  .pat_c_clk_io      (pat_c_clk_io      ),
  .pat_drv_r         (pat_drv_r         ),
  .pat_drv_f         (pat_drv_f         )
);


endmodule