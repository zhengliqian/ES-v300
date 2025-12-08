
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-25
// Module Name           : alpg_pat_task
// Project Name          : 
// Target Devices        : 
// Tool Versions         : Vivado 2020.2
// Description           : 1.store pattern func in bram;
//                         
// 
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
// Additional Comments   :
//                        1.GT TR:lane2:0_0|0_2|0_4|1_1|2_3....
//                                lane3:0_1|0_3|1_0|1_2|2_4....
//                                             store   store
//                        2.run mode:
//                          1)dum mode:no fbc cnt,if used MR,store FSR into DUM;
//                                                if used MR R,store FSR into DUM && get MFLG into reg;
//                          2)fbc mode: fbc cnt,if used MR,fbc_cnt +1,but can't store FBC into DUM,but dum addr +1;
//                                              if used MR R,fbc_cnt +1, and store FBC into DUM;
//////////////////////////////////////////////////////////////////////////////////
module alpg_pat_task 
#(
    parameter GT_LANE_DW        = 32             ,
    parameter PROTCL_LEN        = 5              ,
    parameter PC_DW             = 14             ,
    parameter DATA_TYPE_DW      = 2              ,
    parameter IDX_DW            = 33             ,
    parameter REG_NUM           = 16             ,
    parameter RATE_DW           = 22             ,
    parameter AS_DW             = 24             ,
    parameter AFM_DW            = 24             ,
    parameter AFM_NUM           = 6              
) 
(
    input                                clk                   ,            //@200M
    (*mark_debug="true"*)(*keep="true"*)input                                rst                   ,
    input                                gt_clk                ,            //@50M
    //CFG     
    (*mark_debug="true"*)(*keep="true"*)input  [DATA_TYPE_DW-1:0]            cfg_alpg_data_type    ,            //2:pattern func
    (*mark_debug="true"*)(*keep="true"*)input  [PC_DW-1:0]                   cfg_alpg_start_pc     ,
    input  [REG_NUM-1:0]                 cfg_alpg_cflg         ,
    (*mark_debug="true"*)(*keep="true"*)input  [IDX_DW*REG_NUM-1:0]          cfg_alpg_indx_bus     ,
    //GT     
    (*mark_debug="true"*)(*keep="true"*)input                                rx_data_sof           ,
    (*mark_debug="true"*)(*keep="true"*)input                                rx_data_eof           ,
    (*mark_debug="true"*)(*keep="true"*)input  [GT_LANE_DW-1:0]              gt_rx_data2           ,
    (*mark_debug="true"*)(*keep="true"*)input  [GT_LANE_DW-1:0]              gt_rx_data3           ,
    (*mark_debug="true"*)(*keep="true"*)input                                gt_rx_data_vld        ,
    //cmd     
    input                                alpg_start            ,
    input                                alpg_restart          ,
    input                                alpg_stop             ,
    //from data_proce     
    input                                mflg_reg              ,
    //from timing_gen      
    input                                clk_base              ,
    //output to param_proce
    (*mark_debug="true"*)(*keep="true"*)output [PROTCL_LEN * GT_LANE_DW-1:0] pat_func_data         ,
    (*mark_debug="true"*)(*keep="true"*)output                               pat_func_data_vld     ,                       
    //DFX
    output                               dfx_pattern_func      
);
localparam MATCH_WAIT_TIME = 3000/5;  //3us
localparam WAIT_CNT_DW     = $clog2(MATCH_WAIT_TIME)+1 ;

localparam PC_BIT   = 14 ;
localparam CTRL_BIT = 7  ;
localparam CMD_BIT  = 4  ;
localparam TSN_BIT  = 3  ;
localparam WE_BIT   = 1  ;
localparam CK_BIT   = 1  ;
localparam CMD_DW   = 4  ;

localparam RD_DLY           = 2                        ;
localparam BRAM_DEP         = 8192                     ;
localparam BRAM_AW          = $clog2(BRAM_DEP)+1       ;
localparam BRAM_DW          = PROTCL_LEN * GT_LANE_DW  ;
localparam BRAM_SIAZE       = BRAM_DEP * BRAM_DW       ;
localparam DATA_CNT_DW      = 3                        ;

localparam IDX_DEP = 3 ;
localparam SUB_DEP = 2 ;

localparam ST_DW = 5;

localparam RD_IDLE        = 0  ;
localparam RD_FRIST       = 1  ;
localparam JMP_PC         = 2  ;  //NOP,JMP
localparam JMP_SUB0       = 3  ;  //JSR,FLGL(IF MFLG = 0),JNCn(if CFLGn = 1)
localparam JMP_SUB1       = 4  ;  //JSR,FLGL(IF MFLG = 0),JNCn(if CFLGn = 1)
localparam INDX_JMP_SUB0  = 5  ;  //JNIn,FLGLn(if MFLG = 0)
localparam INDX_JMP_SUB1  = 6  ;  //JNIn,FLGLn(if MFLG = 0)
localparam JMP_NXT_PC     = 7  ;
localparam RTN            = 8  ;
localparam ERR_STOP       = 9  ;
localparam STOP           = 10 ;
//=======================================================
//store pattern func data in bram @gt clk(50M)
//=======================================================
(*mark_debug="true"*)(*keep="true"*)reg                    pattern_wr_en       = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg  [BRAM_AW-1:0]     pattern_wr_addr     = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg  [BRAM_DW-1:0]     pattern_wr_data     = 'd0 ;
(*mark_debug="true"*)(*keep="true"*)reg                    pattern_store_flag  = 'd0 ;

always @(posedge gt_clk) 
begin
  if(rst || rx_data_eof)
  begin
    pattern_store_flag <= 'd0;
  end 
  else if(rx_data_sof && (cfg_alpg_data_type == 'd2))           //zynq send pattern func data,begin store
  begin
    pattern_store_flag <= 'd1;
  end
  else 
  begin
    pattern_store_flag <= pattern_store_flag;
  end  
end

(*mark_debug="true"*)(*keep="true"*)reg [DATA_CNT_DW-1:0] gt_rx_data_cnt = 'd0;

always @(posedge gt_clk) 
begin
  if(rst || ((gt_rx_data_cnt == PROTCL_LEN-1) && gt_rx_data_vld) || rx_data_sof)                   //pattern data is 5*32bit,GT data is 32bit
  begin
    gt_rx_data_cnt <= 'd0;
  end
  else if(gt_rx_data_vld && pattern_store_flag)
  begin
    gt_rx_data_cnt <= gt_rx_data_cnt + 'd1;
  end
  else
  begin
    gt_rx_data_cnt <= gt_rx_data_cnt;
  end
end
//------------------------------------------------------
//GT TR:lane2:0_0|0_2|0_4|1_1|1_3....
//      lane3:0_1|0_3|1_0|1_2|1_4....
//                   store   store
//------------------------------------------------------
always @(posedge gt_clk) 
begin
  pattern_wr_en <= ((gt_rx_data_cnt == PROTCL_LEN/2) || (gt_rx_data_cnt == PROTCL_LEN-1)) && gt_rx_data_vld; 
end

always @(posedge gt_clk) 
begin
  if(rx_data_sof)
  begin
    pattern_wr_addr <= 'd0;
  end  
  else if(pattern_wr_en)
  begin
    pattern_wr_addr <= pattern_wr_addr + 'd1;
  end
  else
  begin
    pattern_wr_addr <= pattern_wr_addr;
  end
end

reg  [GT_LANE_DW-1:0] gt_rx_data2_d1 = 'd0;
reg  [GT_LANE_DW-1:0] gt_rx_data2_d2 = 'd0;
reg  [GT_LANE_DW-1:0] gt_rx_data3_d1 = 'd0;
reg  [GT_LANE_DW-1:0] gt_rx_data3_d2 = 'd0;
(*mark_debug="true"*)(*keep="true"*)wire [BRAM_DW-1:0]    gt_wr_data_a        ;
(*mark_debug="true"*)(*keep="true"*)wire [BRAM_DW-1:0]    gt_wr_data_b        ;

always @(posedge gt_clk) 
begin
  if(gt_rx_data_vld)
  begin
    gt_rx_data2_d1 <= gt_rx_data2    ;
    gt_rx_data2_d2 <= gt_rx_data2_d1 ;
    gt_rx_data3_d1 <= gt_rx_data3    ;
    gt_rx_data3_d2 <= gt_rx_data3_d1 ; 
  end
  else 
  begin
    gt_rx_data2_d1 <= gt_rx_data2_d1 ;
    gt_rx_data2_d2 <= gt_rx_data2_d2 ;
    gt_rx_data3_d2 <= gt_rx_data3_d2 ;
  end
end

assign gt_wr_data_a = {gt_rx_data2_d2,gt_rx_data3_d2,gt_rx_data2_d1,gt_rx_data3_d1,gt_rx_data2};
assign gt_wr_data_b = {gt_rx_data3_d2,gt_rx_data2_d1,gt_rx_data3_d1,gt_rx_data2,gt_rx_data3};

always @(posedge gt_clk) 
begin
  if(pattern_wr_addr[0])
  begin
    pattern_wr_data <= gt_wr_data_b;  
  end
  else
  begin
    pattern_wr_data <= gt_wr_data_a;
  end
end
//=======================================================
//read pattern func data in bram @clk(200M)
//=======================================================
(*mark_debug="true"*)(*keep="true"*)reg  [BRAM_AW-1:0]     pattern_rd_addr     = 'd0    ;
(*mark_debug="true"*)(*keep="true"*)reg                    pattern_rd_en       = 'd0    ;
(*mark_debug="true"*)(*keep="true"*)wire [BRAM_DW-1:0]     pattern_rd_data              ;
(*mark_debug="true"*)(*keep="true"*)reg                    pattern_rd_data_vld = 'd0    ;
reg                    pattern_rd_data_vld_d1 = 'd0    ;
reg                    pattern_rd_data_vld_d2 = 'd0    ;

always @(posedge clk) 
begin
  pattern_rd_data_vld_d1 <= pattern_rd_data_vld    ;
  pattern_rd_data_vld_d2 <= pattern_rd_data_vld_d1 ;
end

(*mark_debug="true"*)(*keep="true"*)wire [CTRL_BIT-1:0]    patter_ctrl_reg              ;
//(*mark_debug="true"*)(*keep="true"*)wire [PC_BIT-1:0]      pc_reg                       ;
(*mark_debug="true"*)(*keep="true"*)reg  [PC_BIT-1:0]      pc_reg          = 'd0        ;
(*mark_debug="true"*)(*keep="true"*)wire [IDX_DW-1:0]      indx_reg                     ;
(*mark_debug="true"*)(*keep="true"*)wire                   bit_reg                      ;
(*mark_debug="true"*)(*keep="true"*)wire [CMD_DW-1:0]      cmd_reg                      ;
reg  [CTRL_BIT-1:0]    patter_ctrl_reg_d1 = 'd0    ;

assign patter_ctrl_reg = pattern_rd_data[BRAM_DW-PC_BIT-1:BRAM_DW-PC_BIT-CTRL_BIT]                   ;
//assign pc_reg          = alpg_start ? cfg_alpg_start_pc : pattern_rd_data[BRAM_DW-1:BRAM_DW-PC_BIT]  ;
assign indx_reg        = pattern_rd_data[BRAM_DW-PC_BIT-1:BRAM_DW-PC_BIT-CTRL_BIT] - 'd6             ;
assign bit_reg         = pattern_rd_data[BRAM_DW-PC_BIT-CTRL_BIT-CMD_BIT-TSN_BIT-WE_BIT-CK_BIT-1]    ;
assign cmd_reg         = pattern_rd_data[BRAM_DW-PC_BIT-CTRL_BIT-1:BRAM_DW-PC_BIT-CTRL_BIT-CMD_BIT]  ;

always @(posedge clk) 
begin
  if(alpg_start || alpg_restart)
  begin
    pc_reg <= cfg_alpg_start_pc;
  end
  else if(pattern_rd_data_vld)
  begin
    pc_reg <= pattern_rd_data[BRAM_DW-1:BRAM_DW-PC_BIT];
  end
  else
  begin
    pc_reg <= pc_reg;
  end  
end

always @(posedge clk) 
begin
  patter_ctrl_reg_d1 <= patter_ctrl_reg;
end

(*mark_debug="true"*)(*keep="true"*)reg [IDX_DW-1:0]          cfg_alpg_indx_array[0:REG_NUM-1]       ;
(*mark_debug="true"*)(*keep="true"*)reg [IDX_DW*REG_NUM-1:0]  cfg_alpg_indx_bus_shift           = 'd0;

genvar j;

generate
  for (j = 0; j < REG_NUM; j = j + 1) 
  begin:u_cfg_idx_array
    always @(posedge clk) 
    begin
      if(rst)
    begin
      cfg_alpg_indx_array[j]  <= 'd0;
    end  
    else if(alpg_start)
    begin
      cfg_alpg_indx_array[j] <= cfg_alpg_indx_bus[IDX_DW*(j+1)-1:IDX_DW*j];
    end  
    else
    begin
      cfg_alpg_indx_array[j] <= cfg_alpg_indx_array[j];
    end
    end
  end
endgenerate

(*mark_debug="true"*)(*keep="true"*)reg flgl_select  = 'd0  ; 
(*mark_debug="true"*)(*keep="true"*)reg jnc_select   = 'd0  ; 
(*mark_debug="true"*)(*keep="true"*)reg jni_select   = 'd0  ;
(*mark_debug="true"*)(*keep="true"*)reg flgln_select = 'd0  ;
reg other_jmp_select = 'd0;
reg nop_selsect = 'd0;

always @(posedge clk) 
begin
  flgl_select  <= (patter_ctrl_reg == 'd4)                               ;
  jnc_select   <= (patter_ctrl_reg >='d38)                               ;
  jni_select   <= ((patter_ctrl_reg > 'd5) && (patter_ctrl_reg < 'd22))  ;
  flgln_select <= ((patter_ctrl_reg > 'd21) && (patter_ctrl_reg < 'd38)) ;  
  other_jmp_select <= (patter_ctrl_reg == 'd1) || (patter_ctrl_reg == 'd2) ;
  nop_selsect  <= (patter_ctrl_reg == 'd0);
end
//---------------rd_addr gen------------------
//JMP TO pc_reg
(*mark_debug="true"*)(*keep="true"*)reg                jmp_flag                 = 'd0  ;
(*mark_debug="true"*)(*keep="true"*)reg                flgl_jmp_flag            = 'd0  ;
(*mark_debug="true"*)(*keep="true"*)reg                jnc_jmp_flag             = 'd0  ;
(*mark_debug="true"*)(*keep="true"*)reg                jni_jmp_flag             = 'd0  ;
(*mark_debug="true"*)(*keep="true"*)reg                flgln_jmp_flag           = 'd0  ;
reg              other_jmp = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [IDX_DW-1:0]     idx_array[0:IDX_DEP-1]          ;
(*mark_debug="true"*)(*keep="true"*)reg [IDX_DW-1:0]     idx_cnt                  = 'd0  ;

always @(posedge clk) 
begin
  if(pattern_rd_data_vld_d2)
  begin
    flgl_jmp_flag   <= flgl_select && (!mflg_reg)                             ;
    jnc_jmp_flag    <= jnc_select && cfg_alpg_cflg[patter_ctrl_reg - 'd38]    ;
    jni_jmp_flag    <= jni_select && (idx_cnt < idx_array[0])                 ;
    flgln_jmp_flag  <= flgln_select && (!mflg_reg) && (idx_cnt < idx_array[0]);
    other_jmp       <= other_jmp_select ;
  end
  else
  begin
    flgl_jmp_flag  <= 'd0;
    jnc_jmp_flag   <= 'd0;
    jni_jmp_flag   <= 'd0;
    flgln_jmp_flag <= 'd0;
    other_jmp      <= 'd0;
  end
end

always @(posedge clk) 
begin
  jmp_flag <= flgl_jmp_flag || jnc_jmp_flag || jni_jmp_flag || flgln_jmp_flag || other_jmp;
end

//loop array gen 
integer i;

always @(posedge clk) 
begin
  for (i = 0; i < IDX_DEP; i = i + 1) 
  begin:u_indx_reg
    if(rst)
    begin
      idx_array[i] <= 'd0;
    end
    else if(pattern_rd_data_vld_d1 && jni_select && (idx_cnt == 'd0))
    begin
      idx_array[0] <= cfg_alpg_indx_array[patter_ctrl_reg_d1-'d6];
      idx_array[i+1] <= idx_array[i];
    end  
    else if(pattern_rd_data_vld_d1 && flgln_select && (idx_cnt == 'd0))
    begin
      idx_array[0] <= cfg_alpg_indx_array[patter_ctrl_reg_d1-'d22];
      idx_array[i+1] <= idx_array[i];
    end
    else if(pattern_rd_data_vld_d1 && (jni_select || flgln_select) && ((idx_cnt == idx_array[0]) && (idx_array[0] != 'd0)))
    begin
      idx_array[IDX_DEP-1] <= 'd0;
      idx_array[i] <= idx_array[i+1];
    end
    else
    begin
      idx_array[i] <= idx_array[i];
    end 
  end 
end

reg  jni_select_d1   = 'd0;
reg  flgln_select_d1 = 'd0;
wire jni_select_r  ;
wire flgln_select_r;

always @(posedge clk) 
begin
  jni_select_d1 <= jni_select;
  flgln_select_d1 <= flgln_select;
end

assign jni_select_r = jni_select && (!jni_select_d1);
assign flgln_select_r = flgln_select && (!flgln_select_d1);

always @(posedge clk) 
begin
  if(rst || ((idx_cnt == idx_array[0]) && pattern_rd_data_vld_d1))
  begin
    idx_cnt <= 'd0;
  end
  else if(jni_select_r || flgln_select_r)
  begin
    idx_cnt <= idx_cnt + 'd1;
  end
  else
  begin
    idx_cnt <= idx_cnt;
  end
end

//JMP TO crt_pc+1
(*mark_debug="true"*)(*keep="true"*)reg addr_flag        = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg flgl_addr_flag   = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg jnc_addr_flag    = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg jni_addr_flag    = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg flgln_addr_flag  = 'd0;
reg nop_addr_flag = 'd0;

always @(posedge clk) 
begin
  if(pattern_rd_data_vld_d1)
  begin
    flgl_addr_flag  <= flgl_select && mflg_reg;
    jnc_addr_flag   <= jnc_select && (!cfg_alpg_cflg[patter_ctrl_reg - 'd38]);  
    jni_addr_flag   <= jni_select && ((idx_cnt == idx_array[0]) && (idx_array[0] != 'd0)); 
    flgln_addr_flag <= flgln_select && mflg_reg;
    nop_addr_flag   <= nop_selsect;
  end
  else
  begin
    flgl_addr_flag  <= 'd0;
    jnc_addr_flag   <= 'd0;
    jni_addr_flag   <= 'd0;
    flgln_addr_flag <= 'd0;
    nop_addr_flag   <= 'd0;
  end
end

always @(posedge clk) 
begin
  addr_flag <= flgl_addr_flag || jnc_addr_flag || jni_addr_flag || flgln_addr_flag || alpg_restart ||nop_addr_flag;
end

//JMP TO sub_base + 1
reg rtn_flag = 'd0;

always @(posedge clk) 
begin
  rtn_flag <= pattern_rd_data_vld_d1 && (patter_ctrl_reg == 'd3);
end

//STOP
(*mark_debug="true"*)(*keep="true"*)reg stop_flag = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg err_stop  = 'd0;

always @(posedge clk) 
begin
  err_stop  <= flgln_select && ((idx_cnt == idx_array[0]) && (idx_array[0] != 'd0)) && (!mflg_reg);
  stop_flag <= pattern_rd_data_vld_d2 && err_stop ;
end

//rd_addr gen
(*mark_debug="true"*)(*keep="true"*)wire [ST_DW-1:0]  addr_st;
(*mark_debug="true"*)(*keep="true"*)reg  [PC_BIT-1:0] sub_pc_array[0:SUB_DEP-1];
(*mark_debug="true"*)(*keep="true"*)reg  [PC_BIT-1:0] rtn_pc_reg = 'd0;

assign addr_st = {stop_flag,rtn_flag,addr_flag,jmp_flag,alpg_start};

always @(posedge clk) 
begin
  case(addr_st)
  'b00001:
  begin
    pattern_rd_addr <= cfg_alpg_start_pc;
  end
  'b00010:
  begin
    pattern_rd_addr <= pc_reg;
  end
  'b00100:
  begin
    pattern_rd_addr <= pattern_rd_addr + 'd1;
  end
  'b01000:
  begin
    //pattern_rd_addr <= sub_pc_array[0] + 'd1;
    pattern_rd_addr <= rtn_pc_reg + 'd1;
  end
  'b10000:
  begin
    pattern_rd_addr <= pattern_rd_addr;
  end
  default:
  begin
    pattern_rd_addr <= pattern_rd_addr;
  end
  endcase    
end

integer x;

wire sub_flag;

assign sub_aflag = (patter_ctrl_reg == 'd2) || (patter_ctrl_reg == 'd4) || (patter_ctrl_reg > 'd5);

always @(posedge clk) 
begin
  for (x = 0; x < SUB_DEP; x = x + 1)
  begin:u_sub_pc_array
    if(rst || alpg_start || alpg_restart)
    begin
      sub_pc_array[x] <= 'd0;
    end
   // else if(pattern_rd_data_vld && (patter_ctrl_reg == 'd2))
    else if(pattern_rd_data_vld && sub_aflag)
    begin
      //sub_pc_array[0] <= pc_reg;
      sub_pc_array[0] <= pattern_rd_addr;
      sub_pc_array[x+1] <= sub_pc_array[x];
    end
    else if(pattern_rd_data_vld && (patter_ctrl_reg == 'd3))
    begin
      sub_pc_array[x] <= sub_pc_array[x+1]; 
    end
    else
    begin
      sub_pc_array[x] <= sub_pc_array[x];
    end
  end   
end

always @(posedge clk) 
begin
  if(pattern_rd_data_vld && (patter_ctrl_reg == 'd3))
  begin
    rtn_pc_reg <= sub_pc_array[0];
  end
  else
  begin
    rtn_pc_reg <= rtn_pc_reg;
  end  
end

//---------------rd_en gen------------------
reg                   clk_base_d1 = 'd0;
wire                  clk_base_f       ;
wire                  clk_base_r       ;
(*mark_debug="true"*)(*keep="true"*)reg [2:0]             bit_cnt             = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg [WAIT_CNT_DW-1:0] wait_cnt            = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg                   pattern_rd_flag    = 'd0;

assign clk_base_f = clk_base_d1 && (!clk_base);
assign clk_base_r = clk_base && (!clk_base_d1);

always @(posedge clk) 
begin
  clk_base_d1 <= clk_base;
end

always @(posedge clk) 
begin
  if((patter_ctrl_reg == 'd5) || alpg_stop)
  begin
    pattern_rd_flag <= 'd0;
  end
  else if(alpg_start || alpg_restart)
  begin
    pattern_rd_flag <= 'd1;
  end
  else
  begin
    pattern_rd_flag <= pattern_rd_flag;
  end  
end

always @(posedge clk) 
begin
  if(alpg_start || alpg_restart)
  begin
    pattern_rd_en <= 'd1;
  end
  else if(pattern_rd_flag)
  begin
    if(bit_reg)
    begin
      pattern_rd_en <= (clk_base_f && (bit_cnt == 'd8-1));
    end
    else if(cmd_reg == 'd3)
    begin
      pattern_rd_en <= (clk_base_f && (wait_cnt == MATCH_WAIT_TIME-1));
    end  
    else
    begin
      pattern_rd_en <= clk_base_f && (!bit_reg);
    end
  end
  else
  begin
    pattern_rd_en <= 'd0;
  end  
end

always @(posedge clk) 
begin
  if(!bit_reg)
  begin
    bit_cnt <= 'd0;
  end
  else if(clk_base_f)
  begin
    bit_cnt <= bit_cnt + 'd1;
  end
  else
  begin
    bit_cnt <= bit_cnt;
  end  
end

always @(posedge clk) 
begin
  if(cmd_reg == 'd3)
  begin
    wait_cnt <= wait_cnt + 'd1;
  end
  else
  begin   
    wait_cnt <= 'd0;
  end  
end
//---------------rd_data_vld gen------------------
reg pattern_rd_en_d1 = 'd0;

always @(posedge clk) 
begin
  pattern_rd_en_d1    <= pattern_rd_en    ;
  pattern_rd_data_vld <= pattern_rd_en_d1 ;
end

//---------------bram inst------------------\
xpm_memory_sdpram #(
  .ADDR_WIDTH_A            (BRAM_AW        ),      // DECIMAL
  .ADDR_WIDTH_B            (BRAM_AW        ),      // DECIMAL
  .AUTO_SLEEP_TIME         (0              ),      // DECIMAL
  .BYTE_WRITE_WIDTH_A      (BRAM_DW        ),      // DECIMAL
  .CASCADE_HEIGHT          (0              ),      // DECIMAL
  .CLOCKING_MODE           ("independent_clock" ),      // String
  .ECC_MODE                ("no_ecc"       ),      // String
  .MEMORY_INIT_FILE        ("none"         ),      // String
  .MEMORY_INIT_PARAM       ("0"            ),      // String
  .MEMORY_OPTIMIZATION     ("true"         ),      // String
  .MEMORY_PRIMITIVE        ("block"        ),      // String
  .MEMORY_SIZE             (BRAM_SIAZE     ),      // DECIMAL
  .MESSAGE_CONTROL         (0              ),      // DECIMAL
  .READ_DATA_WIDTH_B       (BRAM_DW        ),      // DECIMAL
  .READ_LATENCY_B          (RD_DLY         ),      // DECIMAL
  .READ_RESET_VALUE_B      ("0"            ),      // String
  .RST_MODE_A              ("SYNC"         ),      // String
  .RST_MODE_B              ("SYNC"         ),      // String
  .SIM_ASSERT_CHK          (0              ),      // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .USE_EMBEDDED_CONSTRAINT (0              ),      // DECIMAL
  .USE_MEM_INIT            (1              ),      // DECIMAL
  .WAKEUP_TIME             ("disable_sleep"),      // String
  .WRITE_DATA_WIDTH_A      (BRAM_DW        ),      // DECIMAL
  .WRITE_MODE_B            ("no_change"    )       // String
)
u_cfg_mem (
  .dbiterrb        (                   ),  // 1-bit output 
  .doutb           (pattern_rd_data    ),  // READ_DATA_WIDTH_B-bit output
  .sbiterrb        (                   ),  // 1-bit output 
  .addra           (pattern_wr_addr    ),  // ADDR_WIDTH_A-bit input 
  .addrb           (pattern_rd_addr    ),  // ADDR_WIDTH_B-bit input 
  .clka            (gt_clk             ),  // 1-bit input 
  .clkb            (clk                ),  // 1-bit input
  .dina            (pattern_wr_data    ),  // WRITE_DATA_WIDTH_A-bit input 
  .ena             (1'b1               ),  // 1-bit input 
  .enb             (pattern_rd_en      ),  // 1-bit input 
  .injectdbiterra  (1'b0               ),  // 1-bit input 
  .injectsbiterra  (1'b0               ),  // 1-bit input 
  .regceb          (1'b1               ),  // 1-bit input 
  .rstb            (rst                ),  // 1-bit input 
  .sleep           (1'b0               ),  // 1-bit input 
  .wea             (pattern_wr_en      )   // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input
);

assign pat_func_data     = pattern_rd_data ;
assign pat_func_data_vld = pattern_rd_data_vld ;

endmodule
