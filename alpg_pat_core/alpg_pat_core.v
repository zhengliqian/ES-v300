`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-19
// Module Name           : alpg_pat_core
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
module alpg_pat_core 
#(
  parameter FMT_NUM    = 9   ,
  parameter PE_DUT     = 16  ,
  parameter BYTE_DW    = 8   ,
  parameter MOD_DW     = 2   , 
  parameter MSKTB_DW   = 8   ,
  parameter CMD_DW     = 4   ,
  parameter FBC_SUM_DW = 17  ,
  parameter DDR_AW     = 18  ,  
  parameter DDR_DW     = 32     
) 
(
  input                                clk                           ,            //@200M
  input                                rst                           ,
  input                                alpg_start                    , 
  input                                alpg_work_busy                ,
  //CFG
  input  [FMT_NUM-1:0]                 cfg_alpg_fmt_c0               ,
  input  [FMT_NUM-1:0]                 cfg_alpg_fmt_c1               ,
  input  [FMT_NUM-1:0]                 cfg_alpg_fmt_d0               ,
  input  [MOD_DW-1:0]                  cfg_alpg_run_mod              ,   //0:DUM;1:FBC;2:AFM
  input  [MSKTB_DW-1:0]                cfg_alpg_msktb                ,
  input                                cfg_alpg_me                   ,
  //pattern data to pe io pin      
  input  [PE_DUT-1:0]                  pattern_data_bus              ,
  input                                pattern_we                    ,
  input                                pattern_ck                    ,
  //pat func data
  input                                pat_data_parse_vld            ,   
  input  [BYTE_DW*PE_DUT-1:0]          d_reg_bus                     ,
  input  [CMD_DW-1:0]                  pattern_cmd                   ,
  input                                pattern_me                    ,
  input  [MSKTB_DW-1:0]                pattern_msktb                 ,
  output                               mflg_reg                      ,
  //ddr data
  input  [4*DDR_DW-1:0]                dum_data                      ,
  //pattern timing
  input                                base_rate_clk                 ,
  input                                strb_pluse                    ,
  input                                pat_a_clk_d0                  ,
  input                                pat_b_clk_d0                  ,
  input                                pat_c_clk_d0                  ,
  input                                pat_a_clk_d1                  ,
  input                                pat_b_clk_d1                  ,
  input                                pat_c_clk_d1                  ,
  input                                pat_a_clk_io                  ,
  input                                pat_b_clk_io                  ,
  input                                pat_c_clk_io                  ,
  input                                pat_drv_r                     ,
  input                                pat_drv_f                     ,
  //to ddr task
  output                               pat_wr_req                    ,
  output [DDR_AW-1:0]                  pat_wr_ddr_addr               ,
  output                               pat_wr_ddr_addr_vld           ,
  output                               pat_wr_ddr_addr_vld_last      ,
  output [DDR_DW-1:0]                  pat_wr_ddr_data               ,
  output                               pat_wr_ddr_data_vld           ,
  //PE pin
  input  [PE_DUT-1:0]                  dut_din                       ,
  output [PE_DUT-1:0]                  pat_drv0_bus                  ,   
  output [PE_DUT-1:0]                  pat_drv1_bus                  ,   
  output [PE_DUT-1:0]                  pat_dio_bus         
);

wire pat_drv0;
wire pat_drv1;

alpg_data_gen # (
  .FMT_NUM(FMT_NUM),
  .PE_DUT (PE_DUT )
)
drv0_data_gen_inst (
  .clk           (clk                  ),
  .rst           (rst                  ),
  .alpg_work_busy(alpg_work_busy       ),
  .alpg_fmt      (cfg_alpg_fmt_c0      ),
  .pattern_data  (pattern_we           ),
  .pat_a_clk     (pat_a_clk_d0         ),
  .pat_b_clk     (pat_b_clk_d0         ),
  .pat_c_clk     (pat_c_clk_d0         ),
  .pat_drv_en    ('d0                  ),
  .pat_dout      (pat_drv0             )
);

alpg_data_gen # (
  .FMT_NUM(FMT_NUM),
  .PE_DUT (PE_DUT )
)
drv1_data_gen_inst (
  .clk           (clk                  ),
  .rst           (rst                  ),
  .alpg_work_busy(alpg_work_busy       ),
  .alpg_fmt      (cfg_alpg_fmt_c1      ),
  .pattern_data  (pattern_we           ),
  .pat_a_clk     (pat_a_clk_d1         ),
  .pat_b_clk     (pat_b_clk_d1         ),
  .pat_c_clk     (pat_c_clk_d1         ),
  .pat_drv_en    ('d0                  ),
  .pat_dout      (pat_drv1             )
);

assign pat_drv0_bus = {PE_DUT{pat_drv0}};
assign pat_drv1_bus = {PE_DUT{pat_drv1}};

wire pat_drv_en ;

genvar i;  

generate
  for (i = 0;i < PE_DUT ;i = i + 1 ) 
  begin:u_dio
    alpg_data_gen # (
      .FMT_NUM(FMT_NUM),
      .PE_DUT (PE_DUT )
    )
    io_data_gen_inst (
      .clk           (clk                  ),
      .rst           (rst                  ),
      .alpg_work_busy(alpg_work_busy       ),
      .alpg_fmt      (cfg_alpg_fmt_d0      ),
      .pattern_data  (pattern_data_bus[i]  ),
      .pat_a_clk     (pat_a_clk_io         ),
      .pat_b_clk     (pat_b_clk_io         ),
      .pat_c_clk     (pat_c_clk_io         ),
      .pat_drv_en    (pat_drv_en           ),
      .pat_dout      (pat_dio_bus[i]       )
    );
  end
endgenerate


wire [PE_DUT-1:0]            mflg_bus   ;
wire [FBC_SUM_DW*PE_DUT-1:0] fbc_cnt_bus;
wire [BYTE_DW*PE_DUT-1:0]    fsr_out_bus;

generate
  for (i = 0;i < PE_DUT ;i = i + 1 ) 
  begin:u_data_cmp
    alpg_data_cmp # (
      .BYTE_DW    (BYTE_DW     ),
      .MOD_DW     (MOD_DW      ),
      .MSKTB_DW   (MSKTB_DW    ),
      .CMD_DW     (CMD_DW      ),
      .FBC_SUM_DW (FBC_SUM_DW  ),
      .DDR_DW     (DDR_DW      )
    )
    u_data_cmp_inst (
      .clk                 (clk                                           ),
      .rst                 (rst                                           ),
      .alpg_start          (alpg_start                                    ),
      .cfg_alpg_run_mod    (cfg_alpg_run_mod                              ),
      .cfg_alpg_msktb      (cfg_alpg_msktb                                ),
      .cfg_alpg_me         (cfg_alpg_me                                   ),
      .strb_pluse          (strb_pluse                                    ),
      .base_rate_clk       (base_rate_clk                                 ),
      .pat_data_parse_vld  (pat_data_parse_vld                            ),
      .d_reg               (d_reg_bus[(i+1)*BYTE_DW-1:i*BYTE_DW]          ),
      .pattern_cmd         (pattern_cmd                                   ),
      .pattern_me          (pattern_me                                    ),
      .pattern_msktb       (pattern_msktb                                 ),
      .dum_data            (dum_data[(i+1)*BYTE_DW-1:i*BYTE_DW]           ),
      .dut_din             (dut_din[i]                                    ),
      .mflg_out            (mflg_bus[i]                                   ),
      .fbc_cnt             (fbc_cnt_bus[(i+1)*FBC_SUM_DW-1:i*FBC_SUM_DW]  ),
      .fsr_out             (fsr_out_bus[(i+1)*BYTE_DW-1:i*BYTE_DW]        )
    );
  end
endgenerate





endmodule
