`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/02 09:10:42
// Design Name: 
// Module Name: ddr3_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ddr3_core#(
                 parameter DDR_AW         = 'd32                          ,
                 parameter DDR_DW         = 'd32                          ,
                 parameter DATA_WIDTH     = 'd256                       
                                     

               )(
                  input                               sys_clk_i           , 
                  (*mark_debug = "true"*)(*keep = "true"*)input                               sys_rst_n           ,  
                  (*mark_debug = "true"*)(*keep = "true"*)input                               ddr_wr_req          ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                          ddr_wr_done         ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                         wr_fifo_prog_full   ,
                  (*mark_debug = "true"*)(*keep = "true"*)input  [DDR_AW-1:0]                 ddr_wr_base_addr    ,           
                  (*mark_debug = "true"*)(*keep = "true"*)input  [DDR_AW-1:0]                 ddr_wr_data_num     ,
                  (*mark_debug = "true"*)(*keep = "true"*)input  [DDR_DW-1:0]                 ddr_wr_data         ,
                  (*mark_debug = "true"*)(*keep = "true"*)input                               ddr_wr_data_vld     ,
                  (*mark_debug = "true"*)(*keep = "true"*)input                               ddr_rd_req          ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                         ddr_rd_done         ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                         rd_fifo_empty       ,
                  (*mark_debug = "true"*)(*keep = "true"*)input     [DDR_AW-1:0]              ddr_rd_base_addr    ,
                  (*mark_debug = "true"*)(*keep = "true"*)input     [DDR_AW-1:0]              ddr_rd_data_num     ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire[DDR_DW-1:0]             ddr_rd_data         ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                         ddr_rd_data_vld     ,
                  output wire                         init_calib_complete ,
                  output wire                         ui_clk              ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                         ui_rst_n            ,
                  
                  output wire [14:0]                  ddr3_addr           ,  // output [14:0]		ddr3_addr
                  output wire [2:0]                   ddr3_ba             ,  // output [2:0]		ddr3_ba
                  output wire                         ddr3_cas_n          ,  // output			ddr3_cas_n
                  output wire                         ddr3_ck_n           ,  // output [0:0]		ddr3_ck_n
                  output wire                         ddr3_ck_p           ,  // output [0:0]		ddr3_ck_p
                  output wire                         ddr3_cke            ,  // output [0:0]		ddr3_cke
                  output wire                         ddr3_ras_n          ,  // output			ddr3_ras_n
                  output wire                         ddr3_reset_n        ,  // output			ddr3_reset_n
                  output wire                         ddr3_we_n           ,  // output			ddr3_we_n
                  inout       [31:0]                  ddr3_dq             ,  // inout [31:0]		ddr3_dq
                  inout       [3:0]                   ddr3_dqs_n          ,  // inout [3:0]		ddr3_dqs_n
                  inout       [3:0]                   ddr3_dqs_p          ,  // inout [3:0]		ddr3_dqs_p
	              output wire                         ddr3_cs_n           ,  // output [0:0]		ddr3_cs_n
                  output wire [3:0]                   ddr3_dm             ,  // output [3:0]		ddr3_dm
                  output wire                         ddr3_odt              // output [0:0]		ddr3_odt
                );
 
localparam APP_ADDR_WIDTH = 'd29                  ;
localparam APP_CMD_WIDTH  = 'd3                   ;
localparam APP_MASK_WIDTH = 'd32                  ;
localparam APP_DATA_WIDTH = 'd256                 ;     


(*mark_debug = "true"*)(*keep = "true"*)wire [APP_ADDR_WIDTH-1:0]app_addr                    ;  
(*mark_debug = "true"*)(*keep = "true"*)wire [APP_CMD_WIDTH -1:0]app_cmd                     ; 
(*mark_debug = "true"*)(*keep = "true"*)wire                     app_en                      ;
(*mark_debug = "true"*)(*keep = "true"*)wire [APP_DATA_WIDTH-1:0]app_wdf_data                ;
(*mark_debug = "true"*)(*keep = "true"*)wire [APP_MASK_WIDTH-1:0]app_wdf_mask                ; 
(*mark_debug = "true"*)(*keep = "true"*)wire                     app_wdf_end                 ;  
(*mark_debug = "true"*)(*keep = "true"*)wire                     app_wdf_wren                ; 
(*mark_debug = "true"*)(*keep = "true"*)wire [APP_DATA_WIDTH-1:0]app_rd_data                 ;     
(*mark_debug = "true"*)(*keep = "true"*)wire                     app_rd_data_end             ; 
(*mark_debug = "true"*)(*keep = "true"*)wire                     app_rd_data_valid           ;
(*mark_debug = "true"*)(*keep = "true"*)wire                     app_rdy                     ; 
(*mark_debug = "true"*)(*keep = "true"*)wire                     app_wdf_rdy                 ; 
(*mark_debug = "true"*)(*keep = "true"*)wire                     ui_clk_sync_rst             ;     

 
assign ui_rst_n  = sys_rst_n  && (~ui_clk_sync_rst); 
 
ddr3_wr_rd #(
                  .DDR_AW             (  DDR_AW          )                    ,
                  .DDR_DW             (  DDR_DW          )                    ,
                  .DATA_WIDTH         (  DATA_WIDTH      )                    ,
                  .APP_ADDR_WIDTH     (  APP_ADDR_WIDTH  )                    ,
                  .APP_CMD_WIDTH      (  APP_CMD_WIDTH   )                    ,
                  .APP_MASK_WIDTH     (  APP_MASK_WIDTH  )                    ,
                  .APP_DATA_WIDTH     (  APP_DATA_WIDTH  )                        
                                                   
                  )
u_ddr3_wr_rd     (
                  .sys_clk             (  sys_clk_i          ) ,
                  .ui_clk              (  ui_clk             ) ,
                  .sys_rst_n           (  ui_rst_n           ) ,
                  .ddr_wr_req          (  ddr_wr_req         ) ,
                  .ddr_wr_done         (  ddr_wr_done        ) ,
                  .wr_fifo_prog_full   (  wr_fifo_prog_full  ) ,
                  .ddr_wr_base_addr    (  ddr_wr_base_addr   ) ,           
                  .ddr_wr_data_num     (  ddr_wr_data_num    ) ,
                  .ddr_wr_data         (  ddr_wr_data        ) ,
                  .ddr_wr_data_vld     (  ddr_wr_data_vld    ) ,
                  .ddr_rd_req          (  ddr_rd_req         ) ,
                  .ddr_rd_done         (  ddr_rd_done        ) ,
                  .rd_fifo_empty       (  rd_fifo_empty      ) ,
                  .ddr_rd_base_addr    (  ddr_rd_base_addr   ) ,
                  .ddr_rd_data_num     (  ddr_rd_data_num    ) ,
                  .ddr_rd_data         (  ddr_rd_data        ) ,
                  .ddr_rd_data_vld     (  ddr_rd_data_vld    ) ,
                  .init_calib_complete (  init_calib_complete) ,
                  .app_addr            (  app_addr           ) ,  
                  .app_cmd             (  app_cmd            ) ,  
                  .app_en              (  app_en             ) , 
                  .app_wdf_data        (  app_wdf_data       ) , 
                  .app_wdf_mask        (  app_wdf_mask       ) , 
                  .app_wdf_end         (  app_wdf_end        ) ,  
                  .app_wdf_wren        (  app_wdf_wren       ) ,  
                  .app_rd_data         (  app_rd_data        ) , 
                  .app_rd_data_end     (  app_rd_data_end    ) ,  
                  .app_rd_data_valid   (  app_rd_data_valid  ) ,  
                  .app_rdy             (  app_rdy            ) ,  
                  .app_wdf_rdy         (  app_wdf_rdy        )
                 );
                 
 ddr3_mig u_ddr3_mig (


    // Memory interface ports
    .ddr3_addr                      (   ddr3_addr          ),  // output [14:0]		ddr3_addr
    .ddr3_ba                        (   ddr3_ba            ),  // output [2:0]		ddr3_ba
    .ddr3_cas_n                     (   ddr3_cas_n         ),  // output			ddr3_cas_n
    .ddr3_ck_n                      (   ddr3_ck_n          ),  // output [0:0]		ddr3_ck_n
    .ddr3_ck_p                      (   ddr3_ck_p          ),  // output [0:0]		ddr3_ck_p
    .ddr3_cke                       (   ddr3_cke           ),  // output [0:0]		ddr3_cke
    .ddr3_ras_n                     (   ddr3_ras_n         ),  // output			ddr3_ras_n
    .ddr3_reset_n                   (   ddr3_reset_n       ),  // output			ddr3_reset_n
    .ddr3_we_n                      (   ddr3_we_n          ),  // output			ddr3_we_n
    .ddr3_dq                        (   ddr3_dq            ),  // inout [31:0]		ddr3_dq
    .ddr3_dqs_n                     (   ddr3_dqs_n         ),  // inout [3:0]		ddr3_dqs_n
    .ddr3_dqs_p                     (   ddr3_dqs_p         ),  // inout [3:0]		ddr3_dqs_p
    .init_calib_complete            (  init_calib_complete ),  // output			init_calib_complete


	.ddr3_cs_n                      (   ddr3_cs_n          ),  // output [0:0]		ddr3_cs_n
    .ddr3_dm                        (   ddr3_dm            ),  // output [3:0]		ddr3_dm
    .ddr3_odt                       (   ddr3_odt           ),  // output [0:0]		ddr3_odt
    // Application interface ports
    .app_addr                       (    app_addr          ),  // input [28:0]		app_addr
    .app_cmd                        (    app_cmd           ),  // input [2:0]		app_cmd
    .app_en                         (    app_en            ),  // input				app_en
    .app_wdf_data                   (    app_wdf_data      ),  // input [255:0]		app_wdf_data
    .app_wdf_end                    (    app_wdf_end       ),  // input				app_wdf_end
    .app_wdf_wren                   (    app_wdf_wren      ),  // input				app_wdf_wren
    .app_rd_data                    (    app_rd_data       ),  // output [255:0]		app_rd_data
    .app_rd_data_end                (    app_rd_data_end   ),  // output			app_rd_data_end
    .app_rd_data_valid              (    app_rd_data_valid ),  // output			app_rd_data_valid
    .app_rdy                        (    app_rdy           ),  // output			app_rdy
    .app_wdf_rdy                    (    app_wdf_rdy       ),  // output			app_wdf_rdy
    .app_sr_req                     (     1'b0             ),  // input			app_sr_req
    .app_ref_req                    (     1'b0             ),  // input			app_ref_req
    .app_zq_req                     (     1'b0             ),  // input			app_zq_req
    .app_sr_active                  (                      ),  // output			app_sr_active
    .app_ref_ack                    (                      ),  // output			app_ref_ack
    .app_zq_ack                     (                      ),  // output			app_zq_ack
    .ui_clk                         (    ui_clk            ),  // output			ui_clk
    .ui_clk_sync_rst                (    ui_clk_sync_rst   ),  // output			ui_clk_sync_rst
    .app_wdf_mask                   (    app_wdf_mask      ),  // input [31:0]		app_wdf_mask
    // System Clock Ports

    .sys_clk_i                      (    sys_clk_i         ),
    // Reference Clock Ports
    //.clk_ref_i                      (    sys_clk_i         ),
    .sys_rst                        (    sys_rst_n        ) // input sys_rst

    );
endmodule
