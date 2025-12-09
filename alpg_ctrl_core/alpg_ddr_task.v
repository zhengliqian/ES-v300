`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-28
// Module Name           : alpg_ddr_task
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
module alpg_ddr_task 
#(
    parameter GT_DATA_LANE   = 2    ,
    parameter DATA_NUM_DW    = 32   ,
    parameter DATA_TYPE_DW   = 2    ,
    parameter MEM_COPR_DW    = 2    ,
    parameter DDR_DW         = 32   ,
    parameter DDR_AW         = 18                          
) 
(
    input                                       clk                        ,
    input                                       rst                        ,
    input                                       alpg_start                 ,
    input                                       alpg_restart               ,
    input                                       alpg_done                  ,
    input                                       alpg_stop                  ,
    //mem cmd    
    input                                       alpg_wr_start              , 
    input                                       alpg_rd_start              , 
    input                                       alpg_mem_rst               ,
    input                                       alpg_mem_copy              ,
    //CFG       
    input     [MEM_COPR_DW-1:0]                 cfg_alpg_mem_copr          ,
    input     [DDR_AW-1:0]                      cfg_alpg_addr_d0           ,
    input     [DDR_AW-1:0]                      cfg_alpg_addr_d1           ,
    input     [DDR_AW-1:0]                      cfg_alpg_addr_p            ,
    input     [DATA_NUM_DW-1:0]                 cfg_alpg_mem_size          ,
    //gt core intf         
    input                                       gt_clk                     ,
    input     [DDR_AW-1:0]                      cfg_alpg_base_addr         ,
    input     [DATA_NUM_DW-1:0]                 cfg_alpg_data_num          ,
    input     [DATA_TYPE_DW-1:0]                cfg_alpg_data_type         ,
    input                                       rx_data_sof                ,    
    input                                       rx_data_eof                ,    
    input     [DATA_NUM_DW-1:0]                 cfg_rx_data_num            ,
    input     [GT_DATA_LANE*DDR_DW-1:0]         rx_data_bus                ,
    input     [GT_DATA_LANE-1:0]                rx_data_vld_bus            ,
    output    [GT_DATA_LANE*DDR_DW-1:0]         tx_data_bus                , 
    output    [GT_DATA_LANE-1:0]                tx_data_vld_bus            , 
    //pat task intf
    input                                       pat_wr_req                 ,
    input      [DDR_AW-1:0]                     pat_wr_ddr_addr            ,
    input                                       pat_wr_ddr_addr_vld        ,
    input                                       pat_wr_ddr_addr_vld_last   ,                          
    input      [DDR_DW-1:0]                     pat_wr_ddr_data            ,
    input                                       pat_wr_ddr_data_vld        ,
    input                                       pat_rd_req                 ,
    input      [DDR_AW-1:0]                     pat_rd_ddr_addr            , 
    input                                       pat_rd_ddr_addr_vld        , 
    input                                       pat_rd_ddr_addr_vld_last   , 
    output     [DDR_DW-1:0]                     pat_rd_ddr_data            , 
    output                                      pat_rd_ddr_data_vld        , 
    //ddr core intf
    //output                                      ddr_rst                    ,
    //input                                       ddr_rst_done               ,
    input                                       ui_clk                     ,
    output reg [DDR_DW-1:0]                     ddr_wr_data          = 'd0 ,   //写数据
    output reg                                  ddr_wr_data_vld      = 'd0 ,   //写数据有效
    output reg [DDR_AW-1:0]                     ddr_wr_addr          = 'd0 ,   //写地址
    output reg                                  ddr_wr_addr_vld      = 'd0 ,   //写地址有效
    output reg                                  ddr_wr_addr_vld_last = 'd0 ,   //最后一个写地址
    input                                       ddr_rd_fifo_full           ,   //读满信号
    input                                       ddr_wr_done                ,   //本次写完
    output reg [DDR_AW-1:0]                     ddr_rd_addr          = 'd0 ,   //读地址
    output reg                                  ddr_rd_addr_vld      = 'd0 ,   //读地址有效
    output reg                                  ddr_rd_addr_vld_last = 'd0 ,   //最后一个读地址
    output                                      ddr_task_rdy               ,   //下游模块准备好信号
    input      [DDR_DW-1:0]                     ddr_rd_data                ,   //读取的数据
    input                                       ddr_rd_data_vld            ,   //读取的数据有效
    input                                       ddr_rd_done                    //本次读完
);

localparam ST_DW = 4;

localparam IDLE             = 0 ;
localparam MEM_RST          = 1 ;
localparam MEM_COPY_SEL     = 2 ;
localparam MEM_INIT_WR      = 3 ;
localparam MEM_RD2USER      = 4 ;
localparam MEM_WAIT_PAT_USE = 5 ;
localparam DUM2DUM          = 6 ;
localparam DUM2PM           = 7 ;
localparam PM2DUM           = 8 ;
localparam DUM_OR           = 9 ;
localparam PAT_RD           = 10;
localparam PAT_WR           = 11;
localparam MEM_OPR_END      = 12;

reg [ST_DW-1:0]       crt_st      = IDLE;
reg [ST_DW-1:0]       nxt_st      = IDLE;
reg [DATA_NUM_DW-1:0] wr_data_cnt = 'd0 ;

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
      if(alpg_mem_rst)
      begin
        nxt_st = MEM_RST;
      end
      else if(alpg_mem_copy)
      begin
        nxt_st = MEM_COPY_SEL;
      end
      else if(alpg_wr_start)
      begin
        nxt_st = MEM_INIT_WR;
      end
      else if(alpg_rd_start)
      begin
        nxt_st = MEM_RD2USER;
      end
      else if(alpg_start || alpg_restart)
      begin
        nxt_st = MEM_WAIT_PAT_USE;
      end
      else
      begin
        nxt_st = IDLE;
      end  
    end    
    MEM_RST:
    begin
      if(wr_data_cnt == (cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1))
      begin
        nxt_st = MEM_OPR_END;
      end
      else
      begin
        nxt_st = MEM_RST;
      end  
    end 
    MEM_COPY_SEL:
    begin
      if(cfg_alpg_mem_copr == 'd0)
      begin
        nxt_st = DUM2DUM;
      end 
      else if(cfg_alpg_mem_copr == 'd1)
      begin
        nxt_st = DUM_OR;
      end
      else if(cfg_alpg_mem_copr == 'd2)
      begin
        nxt_st = DUM2PM;
      end  
      else 
      begin
        nxt_st = PM2DUM;
      end
    end
    MEM_INIT_WR:
    begin
      if(wr_data_cnt == (cfg_alpg_data_num[DATA_NUM_DW:2] - 'd1))
      begin
        nxt_st = MEM_OPR_END;
      end
      else
      begin
        nxt_st = MEM_INIT_WR;
      end
    end     
    MEM_RD2USER:
    begin
      if(ddr_rd_done)
      begin
        nxt_st = IDLE;
      end
      else
      begin
        nxt_st = MEM_RD2USER;
      end
    end     
    MEM_WAIT_PAT_USE:
    begin
      if(pat_wr_req)
      begin
        nxt_st = PAT_WR;
      end
      else if(pat_rd_req)
      begin
        nxt_st = PAT_RD;
      end
      else if(alpg_done || alpg_stop)
      begin
        nxt_st = MEM_OPR_END;
      end  
      else
      begin
        nxt_st = MEM_WAIT_PAT_USE;
      end
    end
    DUM2DUM:
    begin
      if(wr_data_cnt == (cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1))
      begin
        nxt_st = MEM_OPR_END;
      end
      else
      begin
        nxt_st = DUM2DUM;
      end  
    end  
    DUM_OR:
    begin
      if(wr_data_cnt == (cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1))
      begin
        nxt_st = MEM_OPR_END;
      end
      else
      begin
        nxt_st = DUM_OR;
      end
    end  
    DUM2PM:
    begin
      if(wr_data_cnt == (cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1))
      begin
        nxt_st = MEM_OPR_END;
      end
      else
      begin
        nxt_st = DUM2PM;
      end
    end  
    PM2DUM:
    begin
      if(wr_data_cnt == (cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1))
      begin
        nxt_st = MEM_OPR_END;
      end
      else
      begin
        nxt_st = PM2DUM;
      end
    end
    PAT_RD:
    begin
      if(ddr_rd_done)
      begin
        nxt_st = MEM_WAIT_PAT_USE;
      end
      else 
      begin
        nxt_st = PAT_RD;
      end
    end
    PAT_WR:
    begin
      if(ddr_wr_done)
      begin
        nxt_st = MEM_WAIT_PAT_USE;
      end
      else 
      begin
        nxt_st = PAT_WR;
      end
    end
    MEM_OPR_END:
    begin
      nxt_st = IDLE;  
    end
    default: 
    begin
      nxt_st = IDLE;    
    end
  endcase  
end
                                                                                         
//========================ddr wr==============================//
//gen wr_ddr_addr 
reg [DDR_AW-1:0] ddr_rst_wr_addr     = 'd0;
reg              ddr_rst_wr_addr_vld = 'd0;

always @(posedge clk) 
begin
  if(alpg_mem_rst)
  begin
    ddr_rst_wr_addr <= cfg_alpg_addr_d0;
    ddr_rst_wr_addr_vld <= 'd1;
  end
  else if(crt_st == MEM_RST)
  begin
    ddr_rst_wr_addr <= ddr_rst_wr_addr + 'd1;
    ddr_rst_wr_addr_vld <= 'd1;
  end
  else
  begin
    ddr_rst_wr_addr <= ddr_rst_wr_addr;
    ddr_rst_wr_addr_vld <= 'd0;
  end
end

reg [DDR_AW-1:0] ddr_copy_wr_addr     = 'd0;
reg              ddr_copy_wr_addr_vld = 'd0;
reg              copy_or_data_vld     = 'd0;

always @(posedge clk) 
begin
  if(alpg_mem_copy)
  begin
    if((cfg_alpg_mem_copr == 'd0) || (cfg_alpg_mem_copr == 'd3))
    begin
      ddr_copy_wr_addr <= cfg_alpg_addr_d0;
    end
    else if(cfg_alpg_mem_copr == 'd2)
    begin
      ddr_copy_wr_addr <= cfg_alpg_addr_p;
    end
    else
    begin
      ddr_copy_wr_addr <= cfg_alpg_addr_d1;
    end

    ddr_copy_wr_addr_vld <= 'd1;
  end
  else if((crt_st > MEM_WAIT_PAT_USE) && (crt_st < PAT_RD) && copy_or_data_vld)
  begin
    ddr_copy_wr_addr <= ddr_copy_wr_addr + 'd1;
    ddr_copy_wr_addr_vld <= 'd1;
  end
  else
  begin
    ddr_copy_wr_addr <= ddr_copy_wr_addr;
    ddr_copy_wr_addr_vld <= 'd0;
  end
end

reg  [DDR_AW-1:0] ddr_init_wr_addr     = 'd0;
reg               ddr_init_wr_addr_vld = 'd0;
wire              init_data_vld             ;

always @(posedge clk) 
begin
  if(alpg_wr_start)  
  begin
    ddr_init_wr_addr     <= cfg_alpg_base_addr;
    ddr_init_wr_addr_vld <= 'd1;
  end
  else if(crt_st == MEM_INIT_WR && init_data_vld)
  begin
    ddr_init_wr_addr     <= ddr_init_wr_addr + 'd1;
    ddr_init_wr_addr_vld <= 'd1;
  end
  else
  begin
    ddr_init_wr_addr     <= ddr_init_wr_addr;
    ddr_init_wr_addr_vld <= 'd0;
  end
end

always @(posedge clk) 
begin
  if(crt_st == MEM_OPR_END)
  begin
    wr_data_cnt = 'd0;
  end
  else if(ddr_rst_wr_addr_vld || ddr_copy_wr_addr_vld || ddr_init_wr_addr_vld)
  begin
    wr_data_cnt <= wr_data_cnt + 'd1;
  end
  else
  begin
    wr_data_cnt <= wr_data_cnt;
  end
end

always @(posedge clk) 
begin
  if(crt_st == PAT_WR)
  begin
    ddr_wr_addr <= pat_wr_ddr_addr;
    ddr_wr_addr_vld <= pat_wr_ddr_addr_vld;
  end
  else if(crt_st == MEM_RST)
  begin
    ddr_wr_addr <= ddr_rst_wr_addr;
    ddr_wr_addr_vld <= (wr_data_cnt[1:0] == 'd0);
  end
  else if((crt_st > MEM_WAIT_PAT_USE) && (crt_st < PAT_RD))
  begin
    ddr_wr_addr <= ddr_copy_wr_addr;
    ddr_wr_addr_vld <= (wr_data_cnt[1:0] == 'd0);
  end
  else if(crt_st == MEM_INIT_WR)
  begin
    ddr_wr_addr <= ddr_init_wr_addr;
    ddr_wr_addr_vld <= (wr_data_cnt[1:0] == 'd0);
  end
  else
  begin
    ddr_wr_addr <= ddr_wr_addr;
    ddr_wr_addr_vld <= 'd0;
  end
end

always @(posedge clk) 
begin
  if(crt_st == PAT_WR)
  begin
    ddr_wr_addr_vld_last <= pat_wr_ddr_addr_vld_last;
  end
  else
  begin
    ddr_wr_addr_vld_last <= (wr_data_cnt == cfg_alpg_mem_size[DATA_NUM_DW-1:2] - 'd4);
  end
end

//gen ddr_wr_data
wire [DDR_DW-1:0] init_data;
reg  [DDR_DW-1:0] copy_or_data = 'd0;

always @(posedge clk) 
begin
  case(crt_st)
  MEM_RST:
  begin
    ddr_wr_data     <= 'd0;
    ddr_wr_data_vld <= 'd1;
  end
  MEM_INIT_WR:
  begin
    ddr_wr_data     <= init_data;
    ddr_wr_addr_vld <= init_data_vld;
  end
  DUM2DUM:
  begin
    ddr_wr_data     <= ddr_rd_data;
    ddr_wr_addr_vld <= ddr_rd_data_vld;
  end
  DUM_OR:
  begin
    ddr_wr_data     <= copy_or_data;
    ddr_wr_addr_vld <= copy_or_data_vld;
  end 
  DUM2PM:
  begin
    ddr_wr_data     <= ddr_rd_data;
    ddr_wr_addr_vld <= ddr_rd_data_vld;
  end 
  PM2DUM:
  begin
    ddr_wr_data     <= ddr_rd_data;
    ddr_wr_addr_vld <= ddr_rd_data_vld;    
  end 
  PAT_WR:
  begin
    ddr_wr_data     <= pat_wr_ddr_data;
    ddr_wr_addr_vld <= pat_wr_ddr_data_vld;    
  end 
  endcase
end

//gen init_data:gt_clk -> sys_clk
localparam INIT_FIFO_DEPTH = 128;
localparam INIT_FIFO_CNT_DW = $clog2(INIT_FIFO_DEPTH) + 1;

wire init_fifo_empty; 
wire init_fifo_full ; 

xpm_fifo_async #(
      .CDC_SYNC_STAGES    (2                           ),           // DECIMAL
      .DOUT_RESET_VALUE   ("0"                         ),           // String
      .ECC_MODE           ("no_ecc"                    ),           // String
      .FIFO_MEMORY_TYPE   ("auto"                      ),           // String
      .FIFO_READ_LATENCY  (1                           ),           // DECIMAL
      .FIFO_WRITE_DEPTH   (INIT_FIFO_DEPTH             ),           // DECIMAL
      .FULL_RESET_VALUE   (0                           ),           // DECIMAL
      .PROG_EMPTY_THRESH  (10                          ),           // DECIMAL
      .PROG_FULL_THRESH   (10                          ),           // DECIMAL
      .RD_DATA_COUNT_WIDTH(INIT_FIFO_CNT_DW            ),           // DECIMAL
      .READ_DATA_WIDTH    (DDR_DW                      ),           // DECIMAL
      .READ_MODE          ("std"                       ),           // String
      .RELATED_CLOCKS     (0                           ),           // DECIMAL
      .SIM_ASSERT_CHK     (0                           ),           // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES   ("1717"                      ),           // String
      .WAKEUP_TIME        (0                           ),           // DECIMAL
      .WRITE_DATA_WIDTH   (GT_DATA_LANE*DDR_DW         ),           // DECIMAL
      .WR_DATA_COUNT_WIDTH(INIT_FIFO_CNT_DW            )            // DECIMAL
   )
   u_init_wr_ddr_fifo 
   (
      .almost_empty (                       ),                     // 1-bit output
      .almost_full  (                       ),                     // 1-bit output
      .data_valid   (init_data_vld          ),                     // 1-bit output
      .dbiterr      (                       ),                     // 1-bit output
      .dout         (init_data              ),                     // READ_DATA_WIDTH-bit output
      .empty        (init_fifo_empty        ),                     // 1-bit output
      .full         (init_fifo_full         ),                     // 1-bit output
      .overflow     (                       ),                     // 1-bit output
      .prog_empty   (                       ),                     // 1-bit output
      .prog_full    (                       ),                     // 1-bit output
      .rd_data_count(                       ),                     // RD_DATA_COUNT_WIDTH-bit output
      .rd_rst_busy  (                       ),                     // 1-bit output
      .sbiterr      (                       ),                     // 1-bit output
      .underflow    (                       ),                     // 1-bit output
      .wr_ack       (                       ),                     // 1-bit output
      .wr_data_count(                       ),                     // WR_DATA_COUNT_WIDTH-bit output
      .wr_rst_busy  (                       ),                     // 1-bit output
      .din          (rx_data_bus            ),                     // WRITE_DATA_WIDTH-bit input
      .injectdbiterr(1'b0                   ),                     // 1-bit input
      .injectsbiterr(1'b0                   ),                     // 1-bit input
      .rd_clk       (clk                    ),                     // 1-bit input
      .rd_en        (~init_fifo_empty       ),                     // 1-bit input
      .rst          (rst                    ),                     // 1-bit input
      .sleep        (1'b0                   ),                     // 1-bit input
      .wr_clk       (gt_clk                 ),                     // 1-bit input
      .wr_en        (rx_data_vld_bus[0]     )                      // 1-bit input
   );

//========================ddr rd==============================//
reg  [DDR_AW-1:0] usr_rd_addr     = 'd0;
reg               usr_rd_addr_vld = 'd0;

always @(posedge clk) 
begin
  if(alpg_rd_start)  
  begin
    usr_rd_addr     <= cfg_alpg_base_addr;
    usr_rd_addr_vld <= 'd1;
  end
  else if(crt_st == MEM_RD2USER && (!ddr_rd_fifo_full))
  begin
    usr_rd_addr     <= usr_rd_addr + 'd1;
    usr_rd_addr_vld <= 'd1;
  end
  else
  begin
    usr_rd_addr     <= usr_rd_addr;
    usr_rd_addr_vld <= 'd0;
  end
end

reg [DDR_AW-1:0] ddr_copy_rd_addr     = 'd0;
reg              ddr_copy_rd_addr_vld = 'd0;
   
always @(posedge clk) 
begin
  if(alpg_mem_copy)
  begin
    if((cfg_alpg_mem_copr == 'd0) || (cfg_alpg_mem_copr == 'd2))
    begin
      ddr_copy_rd_addr <= cfg_alpg_addr_d0;
    end
    else if(cfg_alpg_mem_copr == 'd3)
    begin
      ddr_copy_rd_addr <= cfg_alpg_addr_p;
    end
    else
    begin
      ddr_copy_rd_addr <= ddr_copy_rd_addr;
    end

    ddr_copy_rd_addr_vld <= 'd1;
  end
  else if((crt_st > MEM_WAIT_PAT_USE) && (crt_st < DUM_OR) && (!ddr_rd_fifo_full))
  begin
    ddr_copy_rd_addr <= ddr_copy_rd_addr + 'd1;
    ddr_copy_rd_addr_vld <= 'd1;
  end
  else
  begin
    ddr_copy_rd_addr <= ddr_copy_rd_addr;
    ddr_copy_rd_addr_vld <= 'd0;
  end
end

reg [DDR_AW-1:0]      ddr_copy_or_rd_addr0     = 'd0;
reg                   ddr_copy_or_rd_rdy0      = 'd1;
reg [DDR_AW-1:0]      ddr_copy_or_rd_addr1     = 'd0;
reg                   ddr_copy_or_rd_rdy1      = 'd0;
reg [DDR_AW-1:0]      ddr_copy_or_rd_addr      = 'd0;
reg                   ddr_copy_or_rd_addr_vld  = 'd0;

always @(posedge clk) 
begin
  if(alpg_mem_copy && (cfg_alpg_mem_copr == 'd1))
  begin
    ddr_copy_or_rd_addr0 <= cfg_alpg_addr_d0;
  end
  else if((crt_st == DUM_OR) && ddr_copy_or_rd_rdy0)
  begin
    ddr_copy_or_rd_addr0 <= ddr_copy_or_rd_addr0 + 'd1;
  end
  else
  begin
    ddr_copy_or_rd_addr0 <= ddr_copy_or_rd_addr0;
  end
end

always @(posedge clk) 
begin
  if(alpg_mem_copy && (cfg_alpg_mem_copr == 'd1))
  begin
    ddr_copy_or_rd_addr1 <= cfg_alpg_addr_d1;
  end
  else if((crt_st == DUM_OR) && ddr_copy_or_rd_rdy1)
  begin
    ddr_copy_or_rd_addr1 <= ddr_copy_or_rd_addr1 + 'd1;
  end
  else
  begin
    ddr_copy_or_rd_addr1 <= ddr_copy_or_rd_addr1;
  end
end

always @(posedge clk) 
begin
  if((ddr_copy_or_rd_addr0[6:0] == 'h7f) || (ddr_copy_or_rd_addr0 == cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1))
  begin
    ddr_copy_or_rd_rdy0 <= 'd0;
  end
  else if(alpg_mem_copy || (ddr_copy_or_rd_addr1[6:0] == 'h7f))
  begin
    ddr_copy_or_rd_rdy0 <= 'd1;
  end
  else
  begin
    ddr_copy_or_rd_rdy0 <= ddr_copy_or_rd_rdy0;
  end
end

always @(posedge clk) 
begin
  if(alpg_mem_copy ||(ddr_copy_or_rd_addr1[6:0] == 'h7f) || (ddr_copy_or_rd_addr1 == cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1))
  begin
    ddr_copy_or_rd_rdy1 <= 'd0;
  end
  else if((ddr_copy_or_rd_addr0 == cfg_alpg_mem_size[DATA_NUM_DW:2] - 'd1) || (ddr_copy_or_rd_addr0[6:0] == 'h7f))
  begin
    ddr_copy_or_rd_rdy1 <= 'd1;
  end
  else
  begin
    ddr_copy_or_rd_rdy1 <= ddr_copy_or_rd_rdy1;
  end
end

always @(posedge clk) 
begin
  if(ddr_copy_or_rd_rdy0)
  begin
    ddr_copy_or_rd_addr <= ddr_copy_or_rd_addr0;
  end
  else
  begin
    ddr_copy_or_rd_addr <= ddr_copy_or_rd_addr1;
  end
end

always @(posedge clk) 
begin
  ddr_copy_or_rd_addr_vld <= ddr_copy_or_rd_rdy0 || ddr_copy_or_rd_rdy1;
end

reg [DATA_NUM_DW-1:0] rd_data_cnt;


always @(posedge clk) 
begin
  if(crt_st == MEM_OPR_END)
  begin
    rd_data_cnt = 'd0;
  end
  else if(usr_rd_addr_vld || ddr_copy_rd_addr_vld || ddr_copy_or_rd_addr_vld)
  begin
    rd_data_cnt <= rd_data_cnt + 'd1;
  end
  else
  begin
    rd_data_cnt <= rd_data_cnt;
  end
end

always @(posedge clk) 
begin
  if(crt_st == PAT_RD)
  begin
    ddr_rd_addr <= pat_rd_ddr_addr;
    ddr_rd_addr_vld <= pat_rd_ddr_addr_vld;
  end
  else if(crt_st == MEM_RD2USER)
  begin
    ddr_rd_addr <= usr_rd_addr;
    ddr_rd_addr_vld <= (rd_data_cnt[1:0] == 'd0);
  end
  else if((crt_st > MEM_WAIT_PAT_USE) && (crt_st < DUM_OR))
  begin
    ddr_rd_addr <= ddr_copy_rd_addr;
    ddr_rd_addr_vld <= (rd_data_cnt[1:0] == 'd0);
  end
  else if(crt_st == DUM_OR)
  begin
    ddr_rd_addr <= ddr_copy_or_rd_addr;
    ddr_rd_addr_vld <= (rd_data_cnt[1:0] == 'd0);
  end
  else
  begin
    ddr_rd_addr <= ddr_rd_addr;
    ddr_rd_addr_vld <= 'd0;
  end
end

always @(posedge clk) 
begin
  if(crt_st == PAT_RD)
  begin
    ddr_rd_addr_vld_last <= pat_rd_ddr_addr_vld_last;
  end
  else
  begin
    ddr_rd_addr_vld_last <= (rd_data_cnt == cfg_alpg_mem_size[DATA_NUM_DW-1:2] - 'd4);
  end
end

wire usr_rd_fifo_empty; 
wire usr_rd_fifo_full ; 
wire usr_rd_fifo_pfull; 
wire usr_rd_data_vld  ;
reg [DDR_DW-1:0] ddr2usr_data  = 'd0;
reg              ddr2usr_wr_en = 'd0;

always @(posedge clk) 
begin
  if(crt_st == MEM_RD2USER)
  begin
    ddr2usr_data  <= ddr_rd_data;
    ddr2usr_wr_en <= ddr_rd_data_vld;
  end
  else
  begin
    ddr2usr_data  <= ddr2usr_data;
    ddr2usr_wr_en <= 'd0;
  end
end

xpm_fifo_async #(
      .CDC_SYNC_STAGES    (2                           ),           // DECIMAL
      .DOUT_RESET_VALUE   ("0"                         ),           // String
      .ECC_MODE           ("no_ecc"                    ),           // String
      .FIFO_MEMORY_TYPE   ("auto"                      ),           // String
      .FIFO_READ_LATENCY  (1                           ),           // DECIMAL
      .FIFO_WRITE_DEPTH   (INIT_FIFO_DEPTH             ),           // DECIMAL
      .FULL_RESET_VALUE   (0                           ),           // DECIMAL
      .PROG_EMPTY_THRESH  (10                          ),           // DECIMAL
      .PROG_FULL_THRESH   (10                          ),           // DECIMAL
      .RD_DATA_COUNT_WIDTH(INIT_FIFO_CNT_DW            ),           // DECIMAL
      .READ_DATA_WIDTH    (GT_DATA_LANE*DDR_DW         ),           // DECIMAL
      .READ_MODE          ("std"                       ),           // String
      .RELATED_CLOCKS     (0                           ),           // DECIMAL
      .SIM_ASSERT_CHK     (0                           ),           // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES   ("1717"                      ),           // String
      .WAKEUP_TIME        (0                           ),           // DECIMAL
      .WRITE_DATA_WIDTH   (DDR_DW                      ),           // DECIMAL
      .WR_DATA_COUNT_WIDTH(INIT_FIFO_CNT_DW            )            // DECIMAL
   )
   u_rd_ddr_fifo 
   (
      .almost_empty (                       ),                     // 1-bit output
      .almost_full  (                       ),                     // 1-bit output
      .data_valid   (usr_rd_data_vld        ),                     // 1-bit output
      .dbiterr      (                       ),                     // 1-bit output
      .dout         (tx_data_bus            ),                     // READ_DATA_WIDTH-bit output
      .empty        (usr_rd_fifo_empty      ),                     // 1-bit output
      .full         (usr_rd_fifo_full       ),                     // 1-bit output
      .overflow     (                       ),                     // 1-bit output
      .prog_empty   (                       ),                     // 1-bit output
      .prog_full    (usr_rd_fifo_pfull      ),                     // 1-bit output
      .rd_data_count(                       ),                     // RD_DATA_COUNT_WIDTH-bit output
      .rd_rst_busy  (                       ),                     // 1-bit output
      .sbiterr      (                       ),                     // 1-bit output
      .underflow    (                       ),                     // 1-bit output
      .wr_ack       (                       ),                     // 1-bit output
      .wr_data_count(                       ),                     // WR_DATA_COUNT_WIDTH-bit output
      .wr_rst_busy  (                       ),                     // 1-bit output
      .din          (ddr2usr_data           ),                     // WRITE_DATA_WIDTH-bit input
      .injectdbiterr(1'b0                   ),                     // 1-bit input
      .injectsbiterr(1'b0                   ),                     // 1-bit input
      .rd_clk       (gt_clk                 ),                     // 1-bit input
      .rd_en        (~usr_rd_fifo_empty     ),                     // 1-bit input
      .rst          (rst                    ),                     // 1-bit input
      .sleep        (1'b0                   ),                     // 1-bit input
      .wr_clk       (clk                    ),                     // 1-bit input
      .wr_en        (ddr2usr_wr_en          )                      // 1-bit input
   );

assign tx_data_vld_bus = {GT_DATA_LANE{usr_rd_data_vld}};
assign ddr_task_rdy    = ~usr_rd_fifo_pfull;

assign pat_rd_ddr_data = ddr_rd_data;
assign pat_rd_ddr_data_vld = (crt_st == PAT_RD) && ddr_rd_data_vld;
//====================ddr data copy or===========================//
localparam COPY_FIFO_DEPTH = 128;
localparam COPY_FIFO_CNT_DW = $clog2(INIT_FIFO_DEPTH) + 1;

wire              copy_fifo_empty0     ; 
wire              copy_fifo_full0      ; 
wire              copy_ddr_data_vld0   ;
wire [DDR_DW-1:0] copy_ddr_data0       ;
reg  [DDR_DW-1:0] copy_wr_data0   = 'd0;
reg               copy_fifo_rd_en = 'd0;
reg               copy_wr_en0     = 'd0;
wire              copy_fifo_empty1     ; 
wire              copy_fifo_full1      ; 
wire              copy_ddr_data_vld1   ;
wire [DDR_DW-1:0] copy_ddr_data1       ;
reg  [DDR_DW-1:0] copy_wr_data1   = 'd0;
reg               copy_wr_en1     = 'd0;

//copy fifo wr
reg [DATA_NUM_DW-1:0] wr_fifo_data_cnt = 'd0;
reg                   wr_fifo_rdy0     = 'd1;

always @(posedge clk) 
begin
  if(crt_st == IDLE)
  begin
    wr_fifo_data_cnt <= 'd0;
  end
  else if((crt_st == DUM_OR) && ddr_rd_data_vld)
  begin
    wr_fifo_data_cnt <= wr_fifo_data_cnt + 'd1;
  end
  else
  begin
    wr_fifo_data_cnt <= wr_fifo_data_cnt;
  end
end

always @(posedge clk) 
begin
  if((wr_fifo_data_cnt[6:0] == 'h7f) || (wr_fifo_data_cnt == cfg_alpg_mem_size[DATA_NUM_DW-1:2] - 'd1))
  begin
    wr_fifo_rdy0 <= ~wr_fifo_rdy0;
  end
  else
  begin
    wr_fifo_rdy0 <= wr_fifo_rdy0;
  end
end

always @(posedge clk) 
begin
  copy_wr_en0 <= wr_fifo_rdy0 && ddr_rd_data_vld;
  copy_wr_en1 <= (!wr_fifo_rdy0) && ddr_rd_data_vld;
end

always @(posedge clk) 
begin
  if(wr_fifo_rdy0 && ddr_rd_data_vld)
  begin
    copy_wr_data0 <= ddr_rd_data;
  end
  else
  begin
    copy_wr_data0 <= copy_wr_data0;
  end
end

always @(posedge clk) 
begin
  if((!wr_fifo_rdy0) && ddr_rd_data_vld)
  begin
    copy_wr_data1 <= ddr_rd_data;
  end
  else
  begin
    copy_wr_data1 <= copy_wr_data1;
  end
end
//copy fifo rd
always @(posedge clk) 
begin
  copy_fifo_rd_en <= (!copy_fifo_empty0) && (!copy_fifo_empty1);
end

always @(posedge clk)
begin
  copy_or_data <= copy_ddr_data0 | copy_ddr_data1;
  copy_or_data_vld <= copy_ddr_data_vld0;
end

xpm_fifo_sync #(
      .DOUT_RESET_VALUE   ("0"               ),           // String
      .ECC_MODE           ("no_ecc"          ),           // String
      .FIFO_MEMORY_TYPE   ("auto"            ),           // String
      .FIFO_READ_LATENCY  (1                 ),           // DECIMAL
      .FIFO_WRITE_DEPTH   (COPY_FIFO_DEPTH   ),           // DECIMAL
      .FULL_RESET_VALUE   (0                 ),           // DECIMAL
      .PROG_EMPTY_THRESH  (10                ),           // DECIMAL
      .PROG_FULL_THRESH   (10                ),           // DECIMAL
      .RD_DATA_COUNT_WIDTH(COPY_FIFO_CNT_DW  ),           // DECIMAL
      .READ_DATA_WIDTH    (DDR_DW            ),           // DECIMAL
      .READ_MODE          ("std"             ),           // String
      .SIM_ASSERT_CHK     (0                 ),           // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES   ("1717"            ),           // String
      .WAKEUP_TIME        (0                 ),           // DECIMAL
      .WRITE_DATA_WIDTH   (DDR_DW            ),           // DECIMAL
      .WR_DATA_COUNT_WIDTH(COPY_FIFO_CNT_DW  )            // DECIMAL
   )
   u_copy_wr_ddr_fifo0 
   (
      .almost_empty (                       ),                     // 1-bit output
      .almost_full  (                       ),                     // 1-bit output
      .data_valid   (copy_ddr_data_vld0     ),                     // 1-bit output
      .dbiterr      (                       ),                     // 1-bit output
      .dout         (copy_ddr_data0         ),                     // READ_DATA_WIDTH-bit output
      .empty        (copy_fifo_empty0       ),                     // 1-bit output
      .full         (copy_fifo_full0        ),                     // 1-bit output
      .overflow     (                       ),                     // 1-bit output
      .prog_empty   (                       ),                     // 1-bit output
      .prog_full    (                       ),                     // 1-bit output
      .rd_data_count(                       ),                     // RD_DATA_COUNT_WIDTH-bit output
      .rd_rst_busy  (                       ),                     // 1-bit output
      .sbiterr      (                       ),                     // 1-bit output
      .underflow    (                       ),                     // 1-bit output
      .wr_ack       (                       ),                     // 1-bit output
      .wr_data_count(                       ),                     // WR_DATA_COUNT_WIDTH-bit output
      .wr_rst_busy  (                       ),                     // 1-bit output
      .din          (copy_wr_data0          ),                     // WRITE_DATA_WIDTH-bit input
      .injectdbiterr(1'b0                   ),                     // 1-bit input
      .injectsbiterr(1'b0                   ),                     // 1-bit input
      .rd_en        (copy_fifo_rd_en        ),                     // 1-bit input
      .rst          (rst                    ),                     // 1-bit input
      .sleep        (1'b0                   ),                     // 1-bit input
      .wr_clk       (clk                    ),                     // 1-bit input
      .wr_en        (copy_wr_en0            )                      // 1-bit input
   );

xpm_fifo_sync #(
 .DOUT_RESET_VALUE   ("0"               ),           // String
 .ECC_MODE           ("no_ecc"          ),           // String
 .FIFO_MEMORY_TYPE   ("auto"            ),           // String
 .FIFO_READ_LATENCY  (1                 ),           // DECIMAL
 .FIFO_WRITE_DEPTH   (COPY_FIFO_DEPTH   ),           // DECIMAL
 .FULL_RESET_VALUE   (0                 ),           // DECIMAL
 .PROG_EMPTY_THRESH  (10                ),           // DECIMAL
 .PROG_FULL_THRESH   (10                ),           // DECIMAL
 .RD_DATA_COUNT_WIDTH(COPY_FIFO_CNT_DW  ),           // DECIMAL
 .READ_DATA_WIDTH    (DDR_DW            ),           // DECIMAL
 .READ_MODE          ("std"             ),           // String
 .SIM_ASSERT_CHK     (0                 ),           // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
 .USE_ADV_FEATURES   ("1717"            ),           // String
 .WAKEUP_TIME        (0                 ),           // DECIMAL
 .WRITE_DATA_WIDTH   (DDR_DW            ),           // DECIMAL
 .WR_DATA_COUNT_WIDTH(COPY_FIFO_CNT_DW  )            // DECIMAL
)
u_copy_wr_ddr_fifo1 
(
   .almost_empty (                       ),                     // 1-bit output
   .almost_full  (                       ),                     // 1-bit output
   .data_valid   (copy_ddr_data_vld1     ),                     // 1-bit output
   .dbiterr      (                       ),                     // 1-bit output
   .dout         (copy_ddr_data1         ),                     // READ_DATA_WIDTH-bit output
   .empty        (copy_fifo_empty1       ),                     // 1-bit output
   .full         (copy_fifo_full1        ),                     // 1-bit output
   .overflow     (                       ),                     // 1-bit output
   .prog_empty   (                       ),                     // 1-bit output
   .prog_full    (                       ),                     // 1-bit output
   .rd_data_count(                       ),                     // RD_DATA_COUNT_WIDTH-bit output
   .rd_rst_busy  (                       ),                     // 1-bit output
   .sbiterr      (                       ),                     // 1-bit output
   .underflow    (                       ),                     // 1-bit output
   .wr_ack       (                       ),                     // 1-bit output
   .wr_data_count(                       ),                     // WR_DATA_COUNT_WIDTH-bit output
   .wr_rst_busy  (                       ),                     // 1-bit output
   .din          (copy_wr_data1          ),                     // WRITE_DATA_WIDTH-bit input
   .injectdbiterr(1'b0                   ),                     // 1-bit input
   .injectsbiterr(1'b0                   ),                     // 1-bit input
   .rd_en        (copy_fifo_rd_en        ),                     // 1-bit input
   .rst          (rst                    ),                     // 1-bit input
   .sleep        (1'b0                   ),                     // 1-bit input
   .wr_clk       (clk                    ),                     // 1-bit input
   .wr_en        (copy_wr_en1            )                      // 1-bit input
);

endmodule
