`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/01 09:32:41
// Design Name: 
// Module Name: ddr3_wr_rd
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


module ddr3_wr_rd #(
                  parameter DDR_AW         = 'd32                        ,
                  parameter DDR_DW         = 'd32                        ,
                  parameter DATA_WIDTH     = 'd256                       ,
                  parameter APP_ADDR_WIDTH = 'd29                        ,
                  parameter APP_CMD_WIDTH  = 'd3                         ,
                  parameter APP_MASK_WIDTH = 'd32                        ,
                  parameter APP_DATA_WIDTH = 'd256                      
                                                   
                  )
                 (
                  input                              sys_clk             ,
                  (*mark_debug = "true"*)(*keep = "true"*)input                              ui_clk              ,
                  input                              sys_rst_n           ,
                  input                              ddr_wr_req          ,
                  output wire                        ddr_wr_done         ,
                  output wire                         wr_fifo_prog_full  ,
                  input  [DDR_AW-1:0]                 ddr_wr_base_addr   ,           
                  input  [DDR_AW-1:0]                 ddr_wr_data_num    ,
                  input  [DDR_DW-1:0]                 ddr_wr_data        ,
                  input                               ddr_wr_data_vld    ,
                  
                  input                               ddr_rd_req         ,
                  output wire                         ddr_rd_done        ,
                  output wire                         rd_fifo_empty      ,
                  input     [DDR_AW-1:0]              ddr_rd_base_addr   ,
                  input     [DDR_AW-1:0]              ddr_rd_data_num    ,
                  output reg[DDR_DW-1:0]              ddr_rd_data        ,
                  output reg                          ddr_rd_data_vld    ,
                  
                  input                              init_calib_complete ,
                  (*mark_debug = "true"*)(*keep = "true"*)output wire [APP_ADDR_WIDTH-1:0]   app_addr            ,  
                  (*mark_debug = "true"*)(*keep = "true"*)output wire [APP_CMD_WIDTH -1:0]   app_cmd             ,  
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                        app_en              , 

                  (*mark_debug = "true"*)(*keep = "true"*)output wire [APP_DATA_WIDTH-1:0]   app_wdf_data        , 
                  (*mark_debug = "true"*)(*keep = "true"*)output wire [APP_MASK_WIDTH-1:0]   app_wdf_mask        , 

                  (*mark_debug = "true"*)(*keep = "true"*)output wire                        app_wdf_end         ,  
                  (*mark_debug = "true"*)(*keep = "true"*)output wire                        app_wdf_wren        ,  

                  (*mark_debug = "true"*)(*keep = "true"*)input       [APP_DATA_WIDTH-1:0]   app_rd_data         , 
                  (*mark_debug = "true"*)(*keep = "true"*)input                              app_rd_data_end     ,  

                  (*mark_debug = "true"*)(*keep = "true"*)input                              app_rd_data_valid   ,  
                  (*mark_debug = "true"*)(*keep = "true"*)input                              app_rdy             ,  

                  (*mark_debug = "true"*)(*keep = "true"*)input                              app_wdf_rdy               
 
                 );

localparam FIFO_DEPTH        = 1024                    ;
localparam PROG_EMPTY_THRESH = 10                      ;
localparam PROG_FULL_THRESH  = (FIFO_DEPTH/8)*7        ;
localparam DATA_COUNT_WIDTH  = ($clog2(FIFO_DEPTH)) + 1;
localparam DATA_FLOOR_WIDTH  =  3                      ;

localparam  STATE_WIDTH      = 'd2                     ;
localparam  SP_CNT_WIDTH     = 'd4                     ;
localparam  SP_CNT_END       = 'd8                     ;
localparam  ALIGN_CNT_WIDTH  = 'd3                     ;
localparam  ALIGN_CNT_END    = 'd8                     ;
localparam  REMAINDER_WIDTH  = 'd3                     ;
localparam  SHIFT_REG_WIDTH  = 'd20                    ;
localparam  WAIT_CNT_WIDTH    = 'd3                    ;
localparam  WAIT_CNT_END      = 'd5                    ;

localparam  WAIT_INIT        = 'd0                     ;
localparam  IDLE             = 'd1                     ;
localparam  WRITE            = 'd2                     ;
localparam  READ             = 'd3                     ;


(*mark_debug = "true"*)(*keep = "true"*)reg  [STATE_WIDTH-1 :0] state_c = WAIT_INIT            ;
(*mark_debug = "true"*)(*keep = "true"*)reg  [STATE_WIDTH-1 :0] state_n = WAIT_INIT            ;

(*mark_debug = "true"*)(*keep = "true"*)reg  [APP_DATA_WIDTH-1:0]wr_fifo_din            = 'd0 ; 
reg  [APP_DATA_WIDTH-1:0]wr_fifo_din_tmp0            = 'd0 ;
reg  [APP_DATA_WIDTH-1:0]wr_fifo_din_tmp1            = 'd0 ;
reg  [APP_DATA_WIDTH-1:0]wr_fifo_din_tmp2            = 'd0 ;
reg  [APP_DATA_WIDTH-1:0]wr_fifo_din_tmp3            = 'd0 ;
(*mark_debug = "true"*)(*keep = "true"*)reg  [APP_DATA_WIDTH-1:0]wr_fifo_din_tmp_ualign = 'd0 ;  
(*mark_debug = "true"*)(*keep = "true"*)reg  [APP_DATA_WIDTH-1:0]wr_fifo_din_tmp_align  = 'd0 ;
wire     rd_fifo_rd_en                                   ;
//wire  [APP_DATA_WIDTH-1:0]rd_fifo_din            = 'd0 ;
(*mark_debug = "true"*)(*keep = "true"*)reg  [SP_CNT_WIDTH-1:0]sp_cnt        = 'd0             ;
(*mark_debug = "true"*)(*keep = "true"*)wire             add_sp_cnt                            ;
(*mark_debug = "true"*)(*keep = "true"*)wire             end_sp_cnt                            ; 

(*mark_debug = "true"*)(*keep = "true"*)reg  [ALIGN_CNT_WIDTH-1:0]wr_align_cnt  = 'd0          ;
(*mark_debug = "true"*)(*keep = "true"*)wire                  add_wr_align_cnt                 ;
(*mark_debug = "true"*)(*keep = "true"*)wire                  end_wr_align_cnt                 ;

(*mark_debug = "true"*)(*keep = "true"*)reg  [ALIGN_CNT_WIDTH-1:0]rd_align_cnt  = 'd0          ;
(*mark_debug = "true"*)(*keep = "true"*)wire                  add_rd_align_cnt                 ;
(*mark_debug = "true"*)(*keep = "true"*)wire                  end_rd_align_cnt                 ;

(*mark_debug = "true"*)(*keep = "true"*)reg                   wr_align_flag     =  'd0         ;
(*mark_debug = "true"*)(*keep = "true"*)reg                   rd_align_flag     =  'd0         ;

//(*mark_debug = "true"*)(*keep = "true"*)reg  [SP_CNT_WIDTH-1:0]spt_cnt        = 'd0            ;
//(*mark_debug = "true"*)(*keep = "true"*)wire             add_spt_cnt                           ;
//(*mark_debug = "true"*)(*keep = "true"*)wire             end_spt_cnt                           ;

(*mark_debug = "true"*)(*keep = "true"*)reg  [DDR_AW-1:0]wr_data_num_cnt    = 'd0              ;
(*mark_debug = "true"*)(*keep = "true"*)wire             add_wr_data_num_cnt                   ;
(*mark_debug = "true"*)(*keep = "true"*)wire             end_wr_data_num_cnt                   ;

(*mark_debug = "true"*)(*keep = "true"*)reg  [DDR_AW-1:0]wr_data_num_cnt_end                   ;

(*mark_debug = "true"*)(*keep = "true"*)reg  [DDR_AW-1:0]wr_fifo_rdata_cnt  = 'd0              ;
(*mark_debug = "true"*)(*keep = "true"*)wire             add_wr_fifo_rdata_cnt                 ;
(*mark_debug = "true"*)(*keep = "true"*)wire             end_wr_fifo_rdata_cnt                 ;
(*mark_debug = "true"*)(*keep = "true"*)reg  [DDR_AW-1:0]wr_fifo_rdata_cnt_end= 'd0            ;

(*mark_debug = "true"*)(*keep = "true"*)reg  [DDR_AW:0]  rd_fifo_rdata_cnt  = 'd0              ;
(*mark_debug = "true"*)(*keep = "true"*)wire             add_rd_fifo_rdata_cnt                 ;
(*mark_debug = "true"*)(*keep = "true"*)wire             end_rd_fifo_rdata_cnt                 ;

(*mark_debug = "true"*)(*keep = "true"*)reg [DDR_AW-1:0]rd_ddr_data_cnt      = 'd0             ;
(*mark_debug = "true"*)(*keep = "true"*)wire            add_rd_ddr_data_cnt                    ;
(*mark_debug = "true"*)(*keep = "true"*)wire            end_rd_ddr_data_cnt                    ;
(*mark_debug = "true"*)(*keep = "true"*)reg [DDR_AW-1:0]rd_ddr_data_cnt_end  = 'd0             ;          
       
reg   [DDR_AW-1:0]          ddr_wr_data_num_ff  = 'd0  ;
reg   [DDR_AW-1:0]          ddr_rd_data_num_ff  = 'd0  ;
reg   [DDR_AW-1:0]          ddr_wr_base_addr_ff = 'd0  ;
reg   [DDR_AW-1:0]          ddr_rd_base_addr_ff = 'd0  ;

(*mark_debug = "true"*)(*keep = "true"*)reg   [DDR_AW:0]            ddr_wr_data_num_tmp = 'd0  ;
(*mark_debug = "true"*)(*keep = "true"*)reg   [DDR_AW:0]            ddr_rd_data_num_tmp = 'd0  ;

(*mark_debug = "true"*)(*keep = "true"*)reg   [APP_ADDR_WIDTH-1:0]       wr_app_addr = 'd0     ;
(*mark_debug = "true"*)(*keep = "true"*)reg   [APP_ADDR_WIDTH-1:0]       rd_app_addr = 'd0     ;


(*mark_debug = "true"*)(*keep = "true"*)reg   [APP_MASK_WIDTH-1:0]    app_wdf_mask_header_tmp0 = 'd0 ;
                                         reg   [APP_MASK_WIDTH-1:0]    app_wdf_mask_header_tmp1 = 'd0 ;
                                         wire  [APP_MASK_WIDTH-1:0]    app_wdf_mask_header            ;
(*mark_debug = "true"*)(*keep = "true"*)reg   [APP_MASK_WIDTH-1:0]    app_wdf_mask_end         = 'd0 ;


(*mark_debug = "true"*)(*keep = "true"*)reg                          ddr_wr_data_vld_d0     = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg                          ddr_wr_data_vld_d1     = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg [DDR_DW-1:0]             ddr_wr_data_d0         = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg [DDR_DW-1:0]             ddr_wr_data_d1         = 'd0   ;
reg  [ALIGN_CNT_WIDTH-1:0]wr_align_cnt_d0                                                    = 'd0   ;
reg  [SP_CNT_WIDTH-1:0]sp_cnt_d0                                                             = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg                          end_sp_cnt_d0          = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg                          end_wr_data_num_cnt_d0 = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg                          end_sp_cnt_d1          = 'd0   ;
                                         reg                          end_sp_cnt_d2          = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg                          end_wr_data_num_cnt_d1 = 'd0   ;
                                         reg                          end_wr_data_num_cnt_d2 = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg                          end_wr_align_cnt_d0    = 'd0   ;
(*mark_debug = "true"*)(*keep = "true"*)reg                          end_wr_align_cnt_d1    = 'd0   ;
                    

wire   [REMAINDER_WIDTH-1:0]ddr_wr_base_addr_remainder ;
wire   [REMAINDER_WIDTH-1:0]ddr_rd_base_addr_remainder ; 

(*mark_debug = "true"*)(*keep = "true"*)wire wait_init2idle_start                              ;
(*mark_debug = "true"*)(*keep = "true"*)wire idle2write_start                                  ;
(*mark_debug = "true"*)(*keep = "true"*)wire idle2read_start                                   ;
(*mark_debug = "true"*)(*keep = "true"*)wire write2idle_start                                  ;
(*mark_debug = "true"*)(*keep = "true"*)wire read2idle_start                                   ;

(*mark_debug = "true"*)(*keep = "true"*)wire                      wr_fifo_empty                ;
(*mark_debug = "true"*)(*keep = "true"*)reg                       wr_fifo_wr_en     = 'd0      ;
(*mark_debug = "true"*)(*keep = "true"*)wire                      rd_fifo_prog_full            ;
(*mark_debug = "true"*)(*keep = "true"*)wire  [DDR_DW-1:0]        rd_fifo_dout                 ;
(*mark_debug = "true"*)(*keep = "true"*)wire                      ddr_wr_req_sync              ;
(*mark_debug = "true"*)(*keep = "true"*)wire                      ddr_rd_req_sync              ;
(*mark_debug = "true"*)(*keep = "true"*)wire [DDR_AW-1:0]         ddr_wr_base_addr_sync        ;
(*mark_debug = "true"*)(*keep = "true"*)wire [DDR_AW-1:0]         ddr_rd_base_addr_sync        ;

(*mark_debug = "true"*)(*keep = "true"*)reg   [SHIFT_REG_WIDTH-1:0]wr_done_shift_reg  = 'd0    ;
(*mark_debug = "true"*)(*keep = "true"*)reg   [SHIFT_REG_WIDTH-1:0]rd_done_shift_reg  = 'd0    ;
                                         reg   [WAIT_CNT_WIDTH-1:0] wait_cnt           = 'd0    ;
                                         wire                       add_wait_cnt                ;
                                         wire                       end_wait_cnt                ;
                                         reg                        flag_add_wait     = 'd0     ;
//                                         reg                        ddr_rd_req_d0     = 'd0     ;
assign ddr_wr_base_addr_remainder = ddr_wr_base_addr_ff[REMAINDER_WIDTH-1:0];
assign ddr_rd_base_addr_remainder = ddr_rd_base_addr_ff[REMAINDER_WIDTH-1:0]; 

always@(posedge sys_clk)begin
      if(ddr_wr_req || ddr_rd_req)begin          
         ddr_wr_data_num_ff   <= ddr_wr_data_num    ;
         ddr_rd_data_num_ff   <= ddr_rd_data_num    ; 
         ddr_wr_base_addr_ff  <= ddr_wr_base_addr   ;
         ddr_rd_base_addr_ff  <= ddr_rd_base_addr   ;
     end
     else begin         
        ddr_wr_data_num_ff   <= ddr_wr_data_num_ff    ;
        ddr_rd_data_num_ff   <= ddr_rd_data_num_ff    ;
        ddr_wr_base_addr_ff  <=  ddr_wr_base_addr_ff  ;
        ddr_rd_base_addr_ff  <=  ddr_rd_base_addr_ff  ;
     end
end

//always@(posedge sys_clk)begin
//      ddr_rd_req_d0 <= ddr_rd_req;
//end

always@(posedge sys_clk)begin
      ddr_wr_data_vld_d0     <= ddr_wr_data_vld       ;
      ddr_wr_data_vld_d1     <= ddr_wr_data_vld_d0    ;
      ddr_wr_data_d0         <= ddr_wr_data           ;
      ddr_wr_data_d1         <= ddr_wr_data_d0        ;
      wr_align_cnt_d0        <= wr_align_cnt          ;
      sp_cnt_d0              <= sp_cnt                ;
      end_sp_cnt_d0          <= end_sp_cnt            ;
      end_wr_data_num_cnt_d0 <= end_wr_data_num_cnt   ; 
      end_sp_cnt_d1          <= end_sp_cnt_d0         ;
      end_sp_cnt_d2          <= end_sp_cnt_d1         ;
      end_wr_data_num_cnt_d1 <= end_wr_data_num_cnt_d0;
      end_wr_data_num_cnt_d2 <= end_wr_data_num_cnt_d1;
      end_wr_align_cnt_d0    <= end_wr_align_cnt      ; 
      end_wr_align_cnt_d1    <= end_wr_align_cnt_d0   ; 
end

always@(posedge sys_clk)begin
      wr_fifo_wr_en <= end_sp_cnt_d1 || end_wr_data_num_cnt_d1 || (end_wr_align_cnt_d1 && (ddr_wr_base_addr_remainder != 'd0));
end

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          wr_data_num_cnt <= 'd0;
      end
      else if(end_wr_data_num_cnt)begin
          wr_data_num_cnt <= 'd0;
      end
      else if(add_wr_data_num_cnt)begin
          wr_data_num_cnt <= wr_data_num_cnt + 'd1;
      end
      else begin
          wr_data_num_cnt <= wr_data_num_cnt;
      end
end
assign add_wr_data_num_cnt = ddr_wr_data_vld_d0 && wr_align_flag;
assign end_wr_data_num_cnt = add_wr_data_num_cnt && (wr_data_num_cnt == wr_data_num_cnt_end - 'd1); 

always@(posedge sys_clk)begin
    if(ddr_wr_req && (ddr_wr_base_addr[REMAINDER_WIDTH-1:0] == 'd0))begin
      wr_data_num_cnt_end <= ddr_wr_data_num ;
    end
    else if(ddr_wr_req)begin
      wr_data_num_cnt_end <= ddr_wr_data_num - (ALIGN_CNT_END - ddr_wr_base_addr[REMAINDER_WIDTH-1:0]); 
    end
    else begin
      wr_data_num_cnt_end <= wr_data_num_cnt_end;
    end
end

always@(posedge sys_clk)begin
      if(end_wr_data_num_cnt && (sp_cnt == 'd0))begin
          app_wdf_mask_end <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}}};
      end
      else if(end_wr_data_num_cnt && (sp_cnt == 'd1))begin
          app_wdf_mask_end <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}}}; 
      end
      else if(end_wr_data_num_cnt && (sp_cnt == 'd2))begin
          app_wdf_mask_end <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}}}; 
      end
      else if(end_wr_data_num_cnt && (sp_cnt == 'd3))begin
          app_wdf_mask_end <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}}; 
      end
      else if(end_wr_data_num_cnt && (sp_cnt == 'd4))begin
          app_wdf_mask_end <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}}; 
      end
      else if(end_wr_data_num_cnt && (sp_cnt == 'd5))begin
          app_wdf_mask_end <= {{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}}; 
      end
      else if(end_wr_data_num_cnt && (sp_cnt == 'd6))begin
          app_wdf_mask_end <= {{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}}; 
      end
      else if(end_wr_data_num_cnt && (sp_cnt == 'd7))begin
          app_wdf_mask_end <= {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}}; 
      end
      else begin
          app_wdf_mask_end <= app_wdf_mask_end;
      end
end 

always@(posedge sys_clk)begin
      if(ddr_wr_base_addr_remainder == 'd0)begin
           app_wdf_mask_header_tmp0 <=  {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
      end
      else if(ddr_wr_base_addr_remainder == 'd1)begin
          app_wdf_mask_header_tmp0  <=  {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}}};
      end
      else if(ddr_wr_base_addr_remainder == 'd2)begin
          app_wdf_mask_header_tmp0  <=  {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}}};
      end
      else if(ddr_wr_base_addr_remainder == 'd3)begin
          app_wdf_mask_header_tmp0  <=  {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
      end
      else if(ddr_wr_base_addr_remainder == 'd4)begin
          app_wdf_mask_header_tmp0  <=  {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
      end
      else if(ddr_wr_base_addr_remainder == 'd5)begin
          app_wdf_mask_header_tmp0  <=  {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
      end
      else if(ddr_wr_base_addr_remainder == 'd6)begin
          app_wdf_mask_header_tmp0  <=  {{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
      end
      else if(ddr_wr_base_addr_remainder == 'd7)begin
          app_wdf_mask_header_tmp0  <=  {{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
      end
      else begin
          app_wdf_mask_header_tmp0  <= app_wdf_mask_header_tmp0 ;
      end    
end

always@(posedge sys_clk)begin   
      if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd0))begin
         case(ddr_wr_base_addr_remainder)
                'd0:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}}}   ;
                'd1:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b1}}}   ;
                'd2:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b1}},{4{1'b1}}}   ;
                'd3:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}}}   ;
                'd4:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}}   ;
                'd5:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}}   ;
                'd6:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}}   ;     
                'd7:app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}}   ;        
                default:app_wdf_mask_header_tmp1 <={{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd1))begin
         case(ddr_wr_base_addr_remainder)
                'd0:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}}};
                'd1:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b1}}};
                'd2:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}}};
                'd3:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
                'd4:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
                'd5:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
                'd6:app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};      
                default:app_wdf_mask_header_tmp1 <={{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd2))begin
         case(ddr_wr_base_addr_remainder)
                'd0:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
                'd1:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}}};
                'd2:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}}};
                'd3:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
                'd4:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
                'd5:app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};     
                default:app_wdf_mask_header_tmp1 <={{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd3))begin
         case(ddr_wr_base_addr_remainder)
                'd0:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
                'd1:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}}};
                'd2:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}}};
                'd3:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
                'd4:app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};    
                default:app_wdf_mask_header_tmp1 <={{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd4))begin
           case(ddr_wr_base_addr_remainder)
                'd0:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
                'd1:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}}};
                'd2:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}}};
                'd3:app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}},{4{1'b1}}};
                default:app_wdf_mask_header_tmp1 <={{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};    
           endcase             
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd5))begin
                case(ddr_wr_base_addr_remainder)
                'd0:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
                'd1:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}}};
                'd2:app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}},{4{1'b1}}};
                default:app_wdf_mask_header_tmp1 <={{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};    
                endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd6))begin
                case(ddr_wr_base_addr_remainder)
                'd0:app_wdf_mask_header_tmp1 <= {{4{1'b1}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
                'd1:app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b1}}};
                default:app_wdf_mask_header_tmp1 <={{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};    
                endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0)begin
                 app_wdf_mask_header_tmp1 <= {{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}},{4{1'b0}}};
      end
      else begin
                 app_wdf_mask_header_tmp1 <= app_wdf_mask_header_tmp1;
      end
end

assign app_wdf_mask_header = wr_align_flag?app_wdf_mask_header_tmp0:app_wdf_mask_header_tmp1;

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          sp_cnt <= 'd0;
      end
      else if(end_sp_cnt)begin
          sp_cnt <= 'd0;
      end
      else if(add_sp_cnt)begin
          sp_cnt <= sp_cnt + 'd1;
      end
      else begin
          sp_cnt <= sp_cnt;
      end
end
assign add_sp_cnt = ddr_wr_data_vld_d0 && wr_align_flag;
assign end_sp_cnt = (add_sp_cnt && (sp_cnt == SP_CNT_END - 'd1)) || end_wr_data_num_cnt;

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          wr_align_cnt <= 'd0;
      end
      else if(end_wr_align_cnt)begin
          wr_align_cnt <= 'd0;
      end
      else if(add_wr_align_cnt)begin
          wr_align_cnt <= wr_align_cnt + 'd1; 
      end
      else begin
          wr_align_cnt <= wr_align_cnt;
      end
end
assign add_wr_align_cnt = ddr_wr_data_vld_d0 && (wr_align_flag == 'd0);
assign end_wr_align_cnt = add_wr_align_cnt && ((wr_align_cnt == (ALIGN_CNT_END - 'd1 - ddr_wr_base_addr_remainder))||(wr_align_cnt == ddr_wr_data_num_ff - 'd1));

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          wr_align_flag <= 'd0;
      end
      else if(ddr_wr_done || (wr_align_cnt == ddr_wr_data_num_ff - 'd1))begin
          wr_align_flag <= 'd0;
      end
      else if(end_wr_align_cnt || (ddr_wr_req && (ddr_wr_base_addr[REMAINDER_WIDTH-1:0] == 'd0)))begin
          wr_align_flag <= 'd1;  
      end
      else begin
          wr_align_flag <= wr_align_flag;
      end
end

always@(posedge sys_clk)begin
      if(ddr_wr_data_vld_d0)begin
         wr_fifo_din_tmp_ualign <= {ddr_wr_data_d0,wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:32]};
      end
      else begin
         wr_fifo_din_tmp_ualign <= wr_fifo_din_tmp_ualign;
      end
end

always@(posedge sys_clk)begin  
      if(ddr_wr_data_vld_d0 && (wr_align_flag || (ddr_wr_base_addr_remainder == 'd0)))begin
          wr_fifo_din_tmp_align <= {ddr_wr_data_d0,wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:32]}; 
      end
      else begin
          wr_fifo_din_tmp_align <= wr_fifo_din_tmp_align;
      end
end

always@(posedge sys_clk)begin
      if(end_wr_align_cnt_d0 &&  (ddr_wr_base_addr_remainder == 'd1) )begin
          wr_fifo_din_tmp0 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:32],32'b0};
      end
      else if(end_wr_align_cnt_d0 &&  (ddr_wr_base_addr_remainder == 'd2))begin
          wr_fifo_din_tmp0 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:64],{2{32'b0}}};
      end
      else if(end_wr_align_cnt_d0 &&  (ddr_wr_base_addr_remainder == 'd3))begin
          wr_fifo_din_tmp0 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:96],{3{32'b0}}};
      end
      else if(end_wr_align_cnt_d0 &&  (ddr_wr_base_addr_remainder == 'd4))begin
          wr_fifo_din_tmp0 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:128],{4{32'b0}}};
      end
      else if(end_wr_align_cnt_d0 &&  (ddr_wr_base_addr_remainder == 'd5))begin
          wr_fifo_din_tmp0 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:160],{5{32'b0}}}; 
      end
      else if(end_wr_align_cnt_d0 &&  (ddr_wr_base_addr_remainder == 'd6))begin
          wr_fifo_din_tmp0 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192],{6{32'b0}}}; 
      end
      else if(end_wr_align_cnt_d0 && (ddr_wr_base_addr_remainder == 'd7))begin
         wr_fifo_din_tmp0 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{7{32'b0}}};
      end
      else begin
         wr_fifo_din_tmp0 <= wr_fifo_din_tmp0;
      end
 end

always@(posedge sys_clk)begin   
      if(end_wr_data_num_cnt_d0 &&  (sp_cnt_d0 == 'd0))begin
         wr_fifo_din_tmp1 <= {{7{32'b0}},wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:224]};
      end
      else if(end_wr_data_num_cnt_d0 &&  (sp_cnt_d0 == 'd1))begin
         wr_fifo_din_tmp1 <= {{6{32'b0}},wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:192]};
      end
      else if(end_wr_data_num_cnt_d0 &&  (sp_cnt_d0 == 'd2))begin
         wr_fifo_din_tmp1 <= {{5{32'b0}},wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:160]};
      end
      else if(end_wr_data_num_cnt_d0 &&  (sp_cnt_d0 == 'd3))begin
         wr_fifo_din_tmp1 <= {{4{32'b0}},wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:128]};
      end
      else if(end_wr_data_num_cnt_d0 &&  (sp_cnt_d0 == 'd4))begin
         wr_fifo_din_tmp1 <= {{3{32'b0}},wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:96]};
      end
      else if(end_wr_data_num_cnt_d0 &&  (sp_cnt_d0 == 'd5))begin
         wr_fifo_din_tmp1 <= {{2{32'b0}},wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:64]};
      end
      else if(end_wr_data_num_cnt_d0 &&  (sp_cnt_d0 == 'd6))begin
         wr_fifo_din_tmp1 <= {{1{32'b0}},wr_fifo_din_tmp_align[APP_DATA_WIDTH-1:32]};
      end
      else if(end_wr_data_num_cnt_d0)begin
         wr_fifo_din_tmp1 <= wr_fifo_din_tmp_align;
      end
      else begin
         wr_fifo_din_tmp1 <= wr_fifo_din_tmp1;
      end
end

always@(posedge sys_clk)begin
   if(end_sp_cnt_d0)begin
       wr_fifo_din_tmp2 <= wr_fifo_din_tmp_align;
   end
   else begin
       wr_fifo_din_tmp2 <= wr_fifo_din_tmp2;
   end
end

always@(posedge sys_clk)begin   
      if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd0))begin
         case(ddr_wr_base_addr_remainder)
                'd0:wr_fifo_din_tmp3 <= {{7{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224]           };
                'd1:wr_fifo_din_tmp3 <= {{6{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{1{32'b0}}};
                'd2:wr_fifo_din_tmp3 <= {{5{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{2{32'b0}}};
                'd3:wr_fifo_din_tmp3 <= {{4{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{3{32'b0}}};
                'd4:wr_fifo_din_tmp3 <= {{3{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{4{32'b0}}};
                'd5:wr_fifo_din_tmp3 <= {{2{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{5{32'b0}}};
                'd6:wr_fifo_din_tmp3 <= {{1{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{6{32'b0}}};      
                'd7:wr_fifo_din_tmp3 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:224],{7{32'b0}}}           ;        
                default:wr_fifo_din_tmp3 <={8{32'b0}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd1))begin
         case(ddr_wr_base_addr_remainder)
                'd0:wr_fifo_din_tmp3 <= {{6{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192]           };
                'd1:wr_fifo_din_tmp3 <= {{5{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192],{1{32'b0}}};
                'd2:wr_fifo_din_tmp3 <= {{4{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192],{2{32'b0}}};
                'd3:wr_fifo_din_tmp3 <= {{3{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192],{3{32'b0}}};
                'd4:wr_fifo_din_tmp3 <= {{2{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192],{4{32'b0}}};
                'd5:wr_fifo_din_tmp3 <= {{1{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192],{5{32'b0}}};
                'd6:wr_fifo_din_tmp3 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:192],{6{32'b0}}};      
                default:wr_fifo_din_tmp3 <={8{32'b0}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd2))begin
         case(ddr_wr_base_addr_remainder)
                'd0:wr_fifo_din_tmp3 <= {{5{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:160]           };
                'd1:wr_fifo_din_tmp3 <= {{4{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:160],{1{32'b0}}};
                'd2:wr_fifo_din_tmp3 <= {{3{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:160],{2{32'b0}}};
                'd3:wr_fifo_din_tmp3 <= {{2{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:160],{3{32'b0}}};
                'd4:wr_fifo_din_tmp3 <= {{1{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:160],{4{32'b0}}};
                'd5:wr_fifo_din_tmp3 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:160],{5{32'b0}}};     
                default:wr_fifo_din_tmp3 <={8{32'b0}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd3))begin
         case(ddr_wr_base_addr_remainder)
                'd0:wr_fifo_din_tmp3 <= {{4{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:128]           };
                'd1:wr_fifo_din_tmp3 <= {{3{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:128],{1{32'b0}}};
                'd2:wr_fifo_din_tmp3 <= {{2{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:128],{2{32'b0}}};
                'd3:wr_fifo_din_tmp3 <= {{1{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:128],{3{32'b0}}};
                'd4:wr_fifo_din_tmp3 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:128],{4{32'b0}}};    
                default:wr_fifo_din_tmp3 <={8{32'b0}};
         endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd4))begin
           case(ddr_wr_base_addr_remainder)
                'd0:wr_fifo_din_tmp3 <= {{3{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:96]           };
                'd1:wr_fifo_din_tmp3 <= {{2{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:96],{1{32'b0}}};
                'd2:wr_fifo_din_tmp3 <= {{1{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:96],{2{32'b0}}};
                'd3:wr_fifo_din_tmp3 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:96],{3{32'b0}}}           ;
                default:wr_fifo_din_tmp3 <={8{32'b0}};    
           endcase             
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd5))begin
                case(ddr_wr_base_addr_remainder)
                'd0:wr_fifo_din_tmp3 <= {{2{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:64]           };
                'd1:wr_fifo_din_tmp3 <= {{1{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:64],{1{32'b0}}};
                'd2:wr_fifo_din_tmp3 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:64],{2{32'b0}}};
                default:wr_fifo_din_tmp3 <={8{32'b0}};    
                endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0 && (wr_align_cnt_d0 == 'd6))begin
                case(ddr_wr_base_addr_remainder)
                'd0:wr_fifo_din_tmp3 <= {{1{32'b0}},wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:32]           };
                'd1:wr_fifo_din_tmp3 <= {wr_fifo_din_tmp_ualign[APP_DATA_WIDTH-1:32],{1{32'b0}}}           ;
                default:wr_fifo_din_tmp3 <={8{32'b0}};    
                endcase
      end
      else if((wr_align_flag == 'd0) &&  end_wr_align_cnt_d0)begin
                 wr_fifo_din_tmp3 <= wr_fifo_din_tmp_ualign;
      end
      else begin
                 wr_fifo_din_tmp3 <= wr_fifo_din_tmp3;
      end
end

always@(posedge sys_clk)begin  
      if(end_wr_align_cnt_d1 && (wr_align_flag == 'd0))begin 
         wr_fifo_din <= wr_fifo_din_tmp3;
      end
      else if(end_wr_align_cnt_d1 && wr_align_flag)begin
         wr_fifo_din <= wr_fifo_din_tmp0;
      end
      else if(end_wr_data_num_cnt_d1)begin
         wr_fifo_din <= wr_fifo_din_tmp1;  
      end
      else if(end_sp_cnt_d1)begin
         wr_fifo_din <= wr_fifo_din_tmp2;
      end
      else begin
         wr_fifo_din <= wr_fifo_din;
      end
end




always@(posedge ui_clk)begin
      if(!sys_rst_n)begin
          state_c <= WAIT_INIT;
      end
      else begin
          state_c <= state_n;
      end
end

always@(*)begin
      case(state_c)
           WAIT_INIT:begin
                     if(wait_init2idle_start)begin
                         state_n = IDLE;
                     end
                     else begin
                         state_n = state_c;
                     end
           end
           IDLE:begin
                    if(idle2write_start)begin
                        state_n = WRITE;
                    end
                    else if(idle2read_start)begin
                        state_n = READ;
                    end
                    else begin
                        state_n = state_c;
                    end
           end
           WRITE:begin
                    if(write2idle_start)begin
                        state_n = IDLE;
                    end
                    else begin
                        state_n = state_c;
                    end
           end
           READ:begin
                   if(read2idle_start)begin
                         state_n = IDLE;
                   end
                   else begin
                         state_n = state_c;
                   end
           end
           default:state_n = WAIT_INIT;
      endcase
end

assign wait_init2idle_start =  (state_c == WAIT_INIT) &&  init_calib_complete    ;
assign idle2write_start     =  (state_c == IDLE     ) &&  ddr_wr_req_sync        ; 
assign idle2read_start      =  (state_c == IDLE     ) &&  ddr_rd_req_sync        ;
assign write2idle_start     =  (state_c == WRITE    ) &&  end_wr_fifo_rdata_cnt  ;
assign read2idle_start      =  (state_c == READ     ) &&  end_rd_ddr_data_cnt    ;

assign app_en               =  ((((state_c == WRITE) && (wr_fifo_empty == 'd0)) || ((state_c == READ) && (rd_fifo_prog_full == 'd0))) &&  app_rdy)?1'b1:1'b0                ;
assign app_cmd              =  (state_c == WRITE)                                                                                                 ? 1'b0:1'b1               ; 
assign app_wdf_wren         =  (state_c == WRITE) && app_wdf_rdy && app_en                                                                        ? 1'b1:1'b0               ; 
assign app_wdf_end          =   app_wdf_wren                                                                                                                                ;
assign app_addr             =  (state_c == WRITE)                                                                                                 ? wr_app_addr:rd_app_addr ;
assign app_wdf_mask         =   (add_wr_fifo_rdata_cnt && (wr_fifo_rdata_cnt == 'd0)) ? app_wdf_mask_header : (end_wr_fifo_rdata_cnt ? app_wdf_mask_end :32'b0)             ;

assign ddr_wr_done          =   wr_done_shift_reg[SHIFT_REG_WIDTH-1];
assign ddr_rd_done          =   rd_done_shift_reg[SHIFT_REG_WIDTH-1];

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
         wr_done_shift_reg <= 'd0;
         rd_done_shift_reg <= 'd0;
      end
      else begin
          wr_done_shift_reg <= {wr_done_shift_reg[SHIFT_REG_WIDTH-2:0],write2idle_start      };
          rd_done_shift_reg <= {rd_done_shift_reg[SHIFT_REG_WIDTH-2:0],end_rd_fifo_rdata_cnt };
      end
end

xpm_cdc_pulse #(
      .DEST_SYNC_FF  (  4  ),   
      .INIT_SYNC_FF  (  0  ),   
      .REG_OUTPUT    (  0  ),     
      .RST_USED      (  1  ),       
      .SIM_ASSERT_CHK(  0  )  
   )
   u_xpm_cdc_pulse_0 (
      .dest_pulse( ddr_wr_req_sync  ),


      .dest_clk  ( ui_clk           ),   
      .dest_rst  ( ~sys_rst_n       ),   
      .src_clk   ( sys_clk          ),       
      .src_pulse ( ddr_wr_req       ),  

      .src_rst   (~sys_rst_n        )       
   );
   
   xpm_cdc_array_single #(
      .DEST_SYNC_FF    (  4   ),   
      .INIT_SYNC_FF    (  0   ),  
      .SIM_ASSERT_CHK  (  0   ), 
      .SRC_INPUT_REG   (  1   ), 
      .WIDTH           (DDR_AW)          
   )
   u_xpm_cdc_array_single_0 (
      .dest_out(ddr_wr_base_addr_sync), 

      .dest_clk(ui_clk               ), 
      .src_clk (sys_clk              ),   
      .src_in  (ddr_wr_base_addr     )     



   );

always@(posedge ui_clk)begin
      if(ddr_wr_req_sync)begin
          wr_app_addr <= {ddr_wr_base_addr[DDR_AW-1:DATA_FLOOR_WIDTH],3'b0};
      end
      else if(app_wdf_wren)begin
          wr_app_addr <= wr_app_addr + 'd8;
      end
      else begin
          wr_app_addr <= wr_app_addr; 
      end
end

xpm_cdc_pulse #(
      .DEST_SYNC_FF  (  4  ),   
      .INIT_SYNC_FF  (  0  ),   
      .REG_OUTPUT    (  0  ),     
      .RST_USED      (  1  ),       
      .SIM_ASSERT_CHK(  0  )  
   )
   u_xpm_cdc_pulse_1 (
      .dest_pulse( ddr_rd_req_sync  ),
      .dest_clk  ( ui_clk           ),   
      .dest_rst  ( ~sys_rst_n       ),   
      .src_clk   ( sys_clk          ),       
      .src_pulse ( ddr_rd_req       ),  
      .src_rst   (~sys_rst_n        )       
   );
   
   xpm_cdc_array_single #(
      .DEST_SYNC_FF    (  4   ),   
      .INIT_SYNC_FF    (  0   ),  
      .SIM_ASSERT_CHK  (  0   ), 
      .SRC_INPUT_REG   (  1   ), 
      .WIDTH           (DDR_AW)          
   )
   u_xpm_cdc_array_single_1 (
      .dest_out(ddr_rd_base_addr_sync), 
      .dest_clk(ui_clk               ), 
      .src_clk (sys_clk              ),   
      .src_in  (ddr_rd_base_addr     )     

   );

always@(posedge ui_clk)begin
      if(ddr_rd_req_sync)begin
          rd_app_addr <= {ddr_rd_base_addr_sync[DDR_AW-1:DATA_FLOOR_WIDTH],3'b0};
      end
      else if(app_en && app_cmd )begin
          rd_app_addr <= rd_app_addr + 'd8;  
      end
      else begin
          rd_app_addr <= rd_app_addr;  
      end
end

always@(posedge ui_clk)begin
      if(!sys_rst_n)begin
          wr_fifo_rdata_cnt <= 'd0;
      end 
      else if(end_wr_fifo_rdata_cnt)begin
          wr_fifo_rdata_cnt <= 'd0;
      end  
      else if(add_wr_fifo_rdata_cnt)begin
          wr_fifo_rdata_cnt <= wr_fifo_rdata_cnt + 'd1 ;
      end
      else begin
          wr_fifo_rdata_cnt <= wr_fifo_rdata_cnt;
      end
end
assign add_wr_fifo_rdata_cnt = app_wdf_wren;
assign end_wr_fifo_rdata_cnt = add_wr_fifo_rdata_cnt && (wr_fifo_rdata_cnt == wr_fifo_rdata_cnt_end - 'd1);

always@(posedge sys_clk)begin
       ddr_wr_data_num_tmp <= ddr_wr_data_num_ff + ddr_wr_base_addr_remainder;
end

always@(*)begin
      if(ddr_wr_data_num_tmp[2:0] == 'd0)begin
          wr_fifo_rdata_cnt_end = ddr_wr_data_num_tmp[DDR_AW-1:3];
      end
      else begin
          wr_fifo_rdata_cnt_end = ddr_wr_data_num_tmp[DDR_AW-1:3] + 'd1;
      end
end
                
xpm_fifo_async #(
      .CDC_SYNC_STAGES     (      2                     ),    // DECIMAL
      .DOUT_RESET_VALUE    (     "0"                    ),    // String
      .ECC_MODE            (    "no_ecc"               ),    // String
      .FIFO_MEMORY_TYPE    (    "auto"                 ),    // String
      .FIFO_READ_LATENCY   (      1                    ),   // DECIMAL
      .FIFO_WRITE_DEPTH    (      FIFO_DEPTH           ),   // DECIMAL
      .FULL_RESET_VALUE    (      0                    ),   // DECIMAL
      .PROG_EMPTY_THRESH   (      PROG_EMPTY_THRESH    ),    // DECIMAL
      .PROG_FULL_THRESH    (      PROG_FULL_THRESH     ),    // DECIMAL
      .RD_DATA_COUNT_WIDTH (      DATA_COUNT_WIDTH     ),   // DECIMAL
      .READ_DATA_WIDTH     (      DATA_WIDTH           ),   // DECIMAL
      .READ_MODE           (     "fwft"               ),  // String
      .RELATED_CLOCKS      (       0                  ),  // DECIMAL
      .USE_ADV_FEATURES    (     "0707"               ), // String
      .WAKEUP_TIME         (       0                  ), // DECIMAL
      .WRITE_DATA_WIDTH    (       DATA_WIDTH         ), // DECIMAL
      .WR_DATA_COUNT_WIDTH (       DATA_COUNT_WIDTH   )    // DECIMAL
   )
u_xpm_fifo_async_wr     (
      .almost_empty     (                                        ),   
      .almost_full      (                                        ),                    
      .data_valid       (                                        ),                                  
      .dbiterr          (                                        ),                                     
      .dout             ( app_wdf_data                           ),                                     
      .empty            ( wr_fifo_empty                          ),                                    
      .full             (                                        ),                                      
      .overflow         (                                        ),                            
      .prog_empty       (                                         ),                        
      .prog_full        ( wr_fifo_prog_full                       ),                           
      .rd_data_count    (                                         ),                     
      .rd_rst_busy      (                                         ),                     
      .sbiterr          (                                          ),                       
      .underflow        (                                           ),                          
      .wr_ack           (                                          ),                                
      .wr_data_count    (                                          ),                       
      .wr_rst_busy      (                                          ),                          
      .din              ( wr_fifo_din                              ),                                        
      .injectdbiterr    (                                          ),                            
      .injectsbiterr    (                                          ),                             
      .rd_clk           ( ui_clk                                   ),                                      
      .rd_en            ( app_wdf_wren                             ),                                    
      .rst              ( ~sys_rst_n                               ),                                          
      .sleep            (                                          ),                                         
      .wr_clk           (  sys_clk                                 ),                                   
      .wr_en            (  wr_fifo_wr_en                           )                
   );  
   
   
xpm_fifo_async #(
      .CDC_SYNC_STAGES     (      2                     ),    // DECIMAL
      .DOUT_RESET_VALUE    (     "0"                    ),    // String
      .ECC_MODE            (    "no_ecc"               ),    // String
      .FIFO_MEMORY_TYPE    (    "auto"                 ),    // String
      .FIFO_READ_LATENCY   (      1                    ),   // DECIMAL
      .FIFO_WRITE_DEPTH    (      FIFO_DEPTH           ),   // DECIMAL
      .FULL_RESET_VALUE    (      0                    ),   // DECIMAL
      .PROG_EMPTY_THRESH   (      PROG_EMPTY_THRESH    ),    // DECIMAL
      .PROG_FULL_THRESH    (      PROG_FULL_THRESH     ),    // DECIMAL
      .RD_DATA_COUNT_WIDTH (      DATA_COUNT_WIDTH     ),   // DECIMAL
      .READ_DATA_WIDTH     (      DDR_DW               ),   // DECIMAL
      .READ_MODE           (     "fwft"               ),  // String
      .RELATED_CLOCKS      (       0                  ),  // DECIMAL
      .USE_ADV_FEATURES    (     "0707"               ), // String
      .WAKEUP_TIME         (       0                  ), // DECIMAL
      .WRITE_DATA_WIDTH    (       DATA_WIDTH         ), // DECIMAL
      .WR_DATA_COUNT_WIDTH (       DATA_COUNT_WIDTH   )    // DECIMAL
   )
u_xpm_fifo_async_rd     (
      .almost_empty     (                                 ),                    
      .almost_full      (                                 ),                   
      .data_valid       (                                 ),                                  
      .dbiterr          (                                 ),                                     
      .dout             (  rd_fifo_dout                   ),                                     
      .empty            (  rd_fifo_empty                  ),                                  
      .full             (                                 ),                                      
      .overflow         (                                 ),                             
      .prog_empty       (                                 ),                        
      .prog_full        ( rd_fifo_prog_full               ),                         
      .rd_data_count    (                                 ),                    
      .rd_rst_busy      (                                 ),                    
      .sbiterr          (                                 ),                       
      .underflow        (                                 ),                         
      .wr_ack           (                                 ),                                
      .wr_data_count    (                                 ),                      
      .wr_rst_busy      (                                 ),                         
      .din              (  app_rd_data                    ),                                       
      .injectdbiterr    (                                 ),                            
      .injectsbiterr    (                                 ),                             
      .rd_clk           (  sys_clk                        ),                                   
      .rd_en            (  rd_fifo_rd_en                  ),                                   
      .rst              ((~sys_rst_n) || add_wait_cnt     ),                                          
      .sleep            (                                 ),                                        
      .wr_clk           (  ui_clk                         ),                                 
      .wr_en            (  app_rd_data_valid              )                                    
   );
   
assign rd_fifo_rd_en = (rd_fifo_empty == 'd0);
always@(posedge ui_clk)begin  
       if(!sys_rst_n)begin
           rd_ddr_data_cnt <= 'd0;  
       end 
       else if(end_rd_ddr_data_cnt)begin
           rd_ddr_data_cnt <= 'd0;
       end
       else if(add_rd_ddr_data_cnt)begin
           rd_ddr_data_cnt <= rd_ddr_data_cnt + 'd1;
       end
       else begin
          rd_ddr_data_cnt <= rd_ddr_data_cnt;
       end
end 
assign add_rd_ddr_data_cnt = app_en && app_cmd;
assign end_rd_ddr_data_cnt = add_rd_ddr_data_cnt && (rd_ddr_data_cnt == rd_ddr_data_cnt_end - 'd1);

always@(posedge sys_clk)begin
      ddr_rd_data_num_tmp <= ddr_rd_data_num_ff + ddr_rd_base_addr_remainder;
end

always@(*)begin
      if(ddr_rd_data_num_tmp[2:0] == 'd0)begin
          rd_ddr_data_cnt_end = ddr_rd_data_num_tmp[DDR_AW-1:3];
      end
      else begin
          rd_ddr_data_cnt_end = ddr_rd_data_num_tmp[DDR_AW-1:3] + 'd1;
      end
end  



//always@(posedge sys_clk)begin
//      if(!sys_rst_n)begin
//          spt_cnt <= 'd0;
//      end
//      else if(end_spt_cnt)begin
//          spt_cnt <= 'd0;
//      end
//      else if(add_spt_cnt)begin
//          spt_cnt <= spt_cnt + 'd1;
//      end
//      else begin
//          spt_cnt <= spt_cnt;
//      end
//end
//assign add_spt_cnt = (rd_fifo_empty == 'd0)                                                 ;
//assign end_spt_cnt = (add_spt_cnt && (spt_cnt == SP_CNT_END - 'd1)) || end_rd_fifo_rdata_cnt; 

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          rd_fifo_rdata_cnt <= 'd0;
      end 
      else if(end_rd_fifo_rdata_cnt || ddr_rd_req)begin
          rd_fifo_rdata_cnt <= 'd0;
      end  
      else if(add_rd_fifo_rdata_cnt)begin
          rd_fifo_rdata_cnt <= rd_fifo_rdata_cnt + 'd1 ;
      end
      else begin
          rd_fifo_rdata_cnt <= rd_fifo_rdata_cnt;
      end
end
assign add_rd_fifo_rdata_cnt = rd_fifo_rd_en && (flag_add_wait == 'd0)                                                                  ;
assign end_rd_fifo_rdata_cnt = add_rd_fifo_rdata_cnt && (rd_fifo_rdata_cnt ==  (ddr_rd_data_num_ff + ddr_rd_base_addr_remainder - 'd1)) ;




always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          rd_align_cnt <= 'd0;
      end
      else if(end_rd_align_cnt)begin
          rd_align_cnt <= 'd0;
      end
      else if(add_rd_align_cnt)begin
          rd_align_cnt <= rd_align_cnt + 'd1; 
      end
      else begin
          rd_align_cnt <= rd_align_cnt;
      end
end
assign add_rd_align_cnt = rd_fifo_rd_en && (rd_align_flag == 'd0) && (flag_add_wait == 'd0);
assign end_rd_align_cnt = add_rd_align_cnt && (rd_align_cnt == ddr_rd_base_addr_remainder - 'd1);

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
           flag_add_wait <= 'd0;
      end
      else if(end_wait_cnt)begin
            flag_add_wait <= 'd0;
      end
      else if(end_rd_fifo_rdata_cnt)begin
            flag_add_wait <= 'd1;
      end
      else  begin
            flag_add_wait <= flag_add_wait;
      end
end

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          wait_cnt <= 'd0;
      end
      else if(end_wait_cnt)begin
          wait_cnt <= 'd0;
      end
      else if(add_wait_cnt)begin
          wait_cnt <= wait_cnt + 'd1; 
      end
      else begin
          wait_cnt <= wait_cnt;
      end
end
assign add_wait_cnt = flag_add_wait ;
assign end_wait_cnt = add_wait_cnt && (wait_cnt == WAIT_CNT_END - 'd1);



always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          rd_align_flag <= 'd0;
      end
      else if(end_rd_fifo_rdata_cnt)begin
           rd_align_flag <= 'd0;
      end
      else if(end_rd_align_cnt || (ddr_rd_req && (ddr_rd_base_addr[REMAINDER_WIDTH-1:0] == 'd0)))begin
          rd_align_flag <= 'd1;
      end
      else begin
          rd_align_flag <= rd_align_flag;
      end
end

always@(posedge sys_clk)begin
       ddr_rd_data <= rd_fifo_dout;
end   

always@(posedge sys_clk)begin
      ddr_rd_data_vld <= rd_fifo_rd_en && rd_align_flag;
end      

endmodule
