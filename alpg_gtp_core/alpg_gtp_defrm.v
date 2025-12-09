`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-17
// Module Name           : alpg_gtp_defrm
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

module alpg_gtp_defrm
#(
    parameter RX_DW       = 32      ,
    parameter RX_NUM_DW   = 16      ,
    parameter RX_DFX_DW   = 4       ,
    parameter RX_BYTE_NUM = RX_DW/8
)
(
    input                                      rst                    ,
    input                                      clk                    ,
    (*mark_debug="true"*)(*keep="true"*)input                                      gt_tran_rdy            ,
    (*mark_debug="true"*)(*keep="true"*)input        [RX_NUM_DW-1:0]               cfg_rx_data_num        ,
    input        [RX_DW-1:0]                   rx_data                ,
    input        [RX_BYTE_NUM-1:0]             rx_charisk             ,
    (*mark_debug="true"*)(*keep="true"*)output reg   [RX_DW-1:0]                   rx_dfrm_data     = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg                                 rx_dfrm_data_vld = 'd0 ,
    output reg                                 rx_start         = 'd0 ,
    output reg                                 rx_done          = 'd0 ,
    output       [RX_DFX_DW-1:0]               dfx_rx_err          
);

localparam ST_DW     = 4;

localparam ALIG_IDLE        = 0;
localparam ALIG_WAIT        = 1;
localparam ALIG_START       = 2;
localparam ALIG_BYTE_SHIFT0 = 3;
localparam ALIG_BYTE_SHIFT1 = 4;
localparam ALIG_BYTE_SHIFT2 = 5;
localparam ALIG_BYTE_SHIFT3 = 6;

localparam RCV_IDLE = 0;
localparam RCV_HEAD = 1;
localparam RCV_DATA = 2;
localparam RCV_END  = 3;
localparam RCV_ERR  = 4;
//===========================================================//
//======================== BYTE ALIG ========================//
//===========================================================//
(*mark_debug="true"*)(*keep="true"*)reg [ST_DW-1:0]        alig_crt_st = ALIG_IDLE;
reg [ST_DW-1:0]        alig_nxt_st = ALIG_IDLE;

reg  [RX_DW-1:0]       rx_data_d1         = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [RX_DW-1:0]       rx_data_d2            = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [RX_DW-1:0]       rx_data_byte_alig     = 'd0;
(*mark_debug="true"*)(*keep="true"*)reg  [RX_BYTE_NUM-1:0] rx_charisk_byte_alig  = 'd0;
reg  [RX_BYTE_NUM-1:0] rx_charisk_d1      = 'd0;
reg  [RX_BYTE_NUM-1:0] rx_charisk_d2      = 'd0;

always @(posedge clk) 
begin
  rx_data_d1    <= rx_data       ;
  rx_data_d2    <= rx_data_d1    ;
  rx_charisk_d1 <= rx_charisk    ;
  rx_charisk_d2 <= rx_charisk_d1 ;
end

always @(posedge clk) 
begin
  if(rst || (!gt_tran_rdy))
  begin
    alig_crt_st <= ALIG_IDLE; 
  end  
  else
  begin
    alig_crt_st <= alig_nxt_st;
  end  
end

always @(*) 
begin
  case (alig_crt_st)
    ALIG_IDLE: 
    begin
      if(gt_tran_rdy)
      begin
        alig_nxt_st = ALIG_WAIT;
      end
      else
      begin
        alig_nxt_st = ALIG_IDLE;
      end
    end
    ALIG_WAIT:
    begin
      if((rx_charisk == 'hf) && (rx_data_d1 == 'hbcbcbcbc) && (rx_data != 'hbcbcbcbc))
      begin
        alig_nxt_st = ALIG_START;
      end
      else
      begin
        alig_nxt_st = ALIG_WAIT;
      end  
    end
    ALIG_START:
    begin
      if(rx_data_d1 == 'h1c1c1c1c)
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT0;
      end
      else if(rx_data_d1 == 'h1c1c1cbc)
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT1;
      end
      else if(rx_data_d1 == 'h1c1cbcbc)
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT2;
      end  
      else
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT3;
      end
    end
    ALIG_BYTE_SHIFT0:
    begin
      if(rx_done)
      begin
        alig_nxt_st = ALIG_IDLE;
      end
      else
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT0;
      end  
    end
    ALIG_BYTE_SHIFT1:
    begin
      if(rx_done)
      begin
        alig_nxt_st = ALIG_IDLE;
      end
      else
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT1;
      end      
    end
    ALIG_BYTE_SHIFT2:
    begin
      if(rx_done)
      begin
        alig_nxt_st = ALIG_IDLE;
      end
      else
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT2;
      end      
    end
    ALIG_BYTE_SHIFT3:
    begin
      if(rx_done)
      begin
        alig_nxt_st = ALIG_IDLE;
      end
      else
      begin
        alig_nxt_st = ALIG_BYTE_SHIFT3;
      end      
    end 
    default: 
    begin
      alig_nxt_st = ALIG_IDLE;
    end
  endcase
end

always @(posedge clk) 
begin
  case(alig_crt_st)
    ALIG_BYTE_SHIFT0:
    begin
      rx_data_byte_alig    <= rx_data_d1        ;   
      rx_charisk_byte_alig <= rx_charisk_d1;   
    end
    ALIG_BYTE_SHIFT1:      
    begin
      rx_data_byte_alig    <= {rx_data_d1[7:0],rx_data_d2[RX_DW-1:8]};   
      rx_charisk_byte_alig <= {rx_charisk_d1[0],rx_charisk_d2[RX_BYTE_NUM-1:1]};      
    end
    ALIG_BYTE_SHIFT2:
    begin
      rx_data_byte_alig    <= {rx_data_d1[15:0],rx_data_d2[RX_DW-1:16]};  
      rx_charisk_byte_alig <= {rx_charisk_d1[1:0],rx_charisk_d2[RX_BYTE_NUM-1:2]};                
    end
    ALIG_BYTE_SHIFT3:
    begin
      rx_data_byte_alig    <= {rx_data_d1[23:0],rx_data_d2[RX_DW-1:24]};   
      rx_charisk_byte_alig <= {rx_charisk_d1[2:0],rx_charisk_d2[RX_BYTE_NUM-1]};               
    end
    default: 
    begin
      rx_data_byte_alig <= rx_data_d1;
      rx_charisk_byte_alig <= rx_charisk_d1;   
    end
  endcase
end
//===========================================================//
//======================== DFRM ST ==========================//
//===========================================================//
(*mark_debug="true"*)(*keep="true"*)reg [ST_DW-1:0]        rcv_crt_st = RCV_IDLE;
reg [ST_DW-1:0]        rcv_nxt_st = RCV_IDLE;

always @(posedge clk) 
begin
  if(rst || (!gt_tran_rdy))
  begin
    rcv_crt_st <= RCV_IDLE; 
  end  
  else
  begin
    rcv_crt_st <= rcv_nxt_st;
  end  
end

always @(*) 
begin
  case (rcv_crt_st)
    RCV_IDLE: 
    begin
      if((rx_charisk_byte_alig == 'hf) && (rx_data_byte_alig == 'h3c3c3c3c)) 
      begin
        rcv_nxt_st = RCV_HEAD;
      end 
      else
      begin
        rcv_nxt_st = RCV_IDLE;
      end  
    end
    RCV_HEAD:
    begin
      if((rx_charisk_byte_alig == 'h0) && (rx_data_byte_alig == 'h55aa55aa))
      begin
        rcv_nxt_st = RCV_DATA;
      end
      else
      begin
        rcv_nxt_st = RCV_ERR;
      end
    end
    RCV_DATA:
    begin
      if((rx_charisk_byte_alig == 'h0) && (rx_data_byte_alig == 'hbfbfbfbf)) 
      begin
        rcv_nxt_st = RCV_END;
      end
      else
      begin
        rcv_nxt_st = RCV_DATA;
      end
    end
    RCV_END:
    begin
      rcv_nxt_st = RCV_IDLE;  
    end
    RCV_ERR:
    begin
      rcv_nxt_st = RCV_IDLE;  
    end
    default: 
    begin
      rcv_nxt_st = RCV_IDLE;        
    end
  endcase
end

//dfrm rx data
always @(posedge clk) 
begin
  if(rcv_crt_st == RCV_DATA)  
  begin
    rx_dfrm_data <= rx_data_byte_alig ;
  end
  else
  begin
    rx_dfrm_data <= rx_dfrm_data;
  end  
end

always @(posedge clk) 
begin
  rx_dfrm_data_vld <= ((rcv_crt_st == RCV_DATA) && (rx_charisk_byte_alig == 'h0));
end

always @(posedge clk) 
begin
  rx_start <= (rcv_crt_st == RCV_HEAD) && (rcv_nxt_st == RCV_DATA);
  rx_done  <= (rcv_crt_st == RCV_END) && (rcv_nxt_st == RCV_IDLE) ;  
end

//===========================================================//
//dfx
//===========================================================//
reg [RX_NUM_DW-1:0] rx_data_cnt     = 'd0;
reg                 dfx_rx_head_err = 'd0;
reg                 dfx_rx_num_err  = 'd0;

always @(posedge clk) 
begin
  if(rcv_crt_st == RCV_IDLE) 
  begin
    rx_data_cnt <= 'd0;
  end  
  else if(rx_charisk_byte_alig == 'h0)
  begin
    rx_data_cnt <= rx_data_cnt + 'd1;
  end
  else
  begin
    rx_data_cnt <= rx_data_cnt;
  end  
end

always @(posedge clk) 
begin
  if(rcv_crt_st == RCV_HEAD)
  begin
    dfx_rx_head_err <= 'd0;
  end
  else if(rcv_crt_st == RCV_ERR)
  begin
    dfx_rx_head_err <= 'd1;  
  end
  else
  begin
    dfx_rx_head_err <= dfx_rx_head_err;
  end  
end

always @(posedge clk) 
begin
  if(rcv_crt_st == RCV_HEAD)
  begin
    dfx_rx_num_err <= 'd0;
  end
  else if(rcv_crt_st == RCV_END)  
  begin
    dfx_rx_num_err <= (rx_data_cnt != cfg_rx_data_num);
  end
  else
  begin
    dfx_rx_num_err  <= dfx_rx_num_err;
  end  
end

assign dfx_rx_err = {2'd0,dfx_rx_num_err,dfx_rx_head_err};

endmodule 
