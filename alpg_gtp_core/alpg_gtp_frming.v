`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-17
// Module Name           : alpg_gtp_frming
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

module alpg_gtp_frming
#(
  parameter TX_DW       = 32       ,
  parameter TX_NUM_DW   = 16       ,
  parameter TX_BYTE_NUM = TX_DW/8
)
(
  input                           clk                      ,
  input                           rst                      ,
  input                           tx_pck_start             ,
  input                           tx_pck_suspend           ,          //from zynq,if zynq ddr is busy,suspend = 1,alpg suspend send data  
  output reg                      tx_packet_done     = 'd0 ,
  input      [TX_NUM_DW-1:0]      cfg_tx_data_num          ,
  input      [TX_DW-1:0]          tx_data                  ,
  input                           tx_data_vld              ,
  output reg                      tx_packet_data_vld = 'd0 ,
  output reg [TX_DW-1:0]          tx_packet_data     = 'd0 ,
  output reg [TX_BYTE_NUM-1:0]    tx_charisk         = 'd0
);

localparam ST_DW = 4;

localparam IDLE         	       = 0;
localparam WAIT         	       = 1;
localparam SEND_BYTE_ALIG        = 2;
localparam SEND_CHANNEL_BOND  	 = 3;
localparam SEND_FRM_HEAD         = 4;
localparam SEND_DATA             = 5;
localparam SEND_FRM_END          = 6;
localparam SEND_WAIT             = 7;
localparam SEND_SUSPEND          = 8;

(*mark_debug="true"*)(*keep="true"*)reg [ST_DW-1:0]        crt_st = IDLE;
reg [ST_DW-1:0]        nxt_st = IDLE;
(*mark_debug="true"*)(*keep="true"*)reg [TX_NUM_DW-1:0]    tx_data_cnt = 'd0;
reg                    tx_pck_suspend_d1 = 'd0;
reg                    tx_pck_suspend_d2 = 'd0;
reg                    tx_data_vld_d1    = 'd0;
reg                    tx_data_vld_d2    = 'd0;
reg                    tx_data_vld_d3    = 'd0;
reg                    tx_data_vld_d4    = 'd0;
reg [TX_DW-1:0]        tx_data_d1        = 'd0;
reg [TX_DW-1:0]        tx_data_d2        = 'd0;
reg [TX_DW-1:0]        tx_data_d3        = 'd0;
reg [TX_DW-1:0]        tx_data_d4        = 'd0;

//======================== FRM ST ==========================//
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

always@(*)
begin
  case(crt_st)
  	IDLE:
  	begin
  	  if(tx_pck_start)
        begin
          nxt_st = WAIT;
        end
  	  else
        begin
  	      nxt_st = IDLE;
        end
  	end
    WAIT:
    begin
      if(tx_data_vld)
      begin
        nxt_st = SEND_BYTE_ALIG; 
      end
      else
      begin
        nxt_st = WAIT;
      end
    end
  	SEND_BYTE_ALIG:
  	begin
  	  nxt_st = SEND_CHANNEL_BOND;	
  	end
  	SEND_CHANNEL_BOND:
  	begin
      nxt_st = SEND_FRM_HEAD; 
  	end
  	SEND_FRM_HEAD:
  	begin
      nxt_st = SEND_DATA;
  	end    
  	SEND_DATA:
    begin
      if(tx_data_cnt == (cfg_tx_data_num - 1'd1))
      begin
        nxt_st = SEND_FRM_END;
      end
      else if(!tx_data_vld_d3)
      begin
        nxt_st = SEND_WAIT;
      end
      else if(tx_pck_suspend_d2)
      begin
        nxt_st = SEND_SUSPEND;  
      end
      else
      begin
        nxt_st = SEND_DATA;
      end  
    end
    SEND_FRM_END:
    begin
      nxt_st = IDLE;  
    end
    SEND_WAIT:
    begin
      if(tx_data_vld_d3)  
      begin
        nxt_st = SEND_DATA;
      end
      else
      begin
        nxt_st = SEND_WAIT;
      end  
    end
    SEND_SUSPEND:
    begin
      if(!tx_pck_suspend_d2)  
      begin
        nxt_st = SEND_DATA;
      end
      else
      begin
        nxt_st = SEND_SUSPEND;
      end  
    end
  	default:
    begin
      nxt_st = IDLE;
    end
  endcase
end

//======================== DATA CTRL ==========================//
always @(posedge clk) 
begin
    tx_pck_suspend_d1 <= tx_pck_suspend    ;
    tx_pck_suspend_d2 <= tx_pck_suspend_d1 ;  
    tx_data_vld_d1    <= tx_data_vld       ;
    tx_data_vld_d2    <= tx_data_vld_d1    ;
    tx_data_vld_d3    <= tx_data_vld_d2    ;
    tx_data_vld_d4    <= tx_data_vld_d3    ;
    tx_data_d1        <= tx_data           ;
    tx_data_d2        <= tx_data_d1        ;
    tx_data_d3        <= tx_data_d2        ;  
    tx_data_d4        <= tx_data_d3        ;  
end

always @(posedge clk) 
begin
  if(rst || tx_pck_start)  
  begin
    tx_data_cnt <= 'd0;
  end
  else if(crt_st == SEND_DATA)
  begin
    tx_data_cnt <= tx_data_cnt + 'd1;
  end  
  else
  begin
    tx_data_cnt <= tx_data_cnt;
  end  
end

always @(posedge clk) 
begin
  case(crt_st)
    IDLE:
    begin
      //tx_packet_data <= 'h1c1c1c1c;
      tx_packet_data <= 'hbcbcbcbc;
    end 
    WAIT:
    begin
      //tx_packet_data <= 'h1c1c1c1c;
      tx_packet_data <= 'hbcbcbcbc;
    end       	
    SEND_BYTE_ALIG:  
    begin
      //tx_packet_data <= 'hbcbcbcbc; 
      tx_packet_data <= 'h1c1c1c1c;  
    end 
    SEND_CHANNEL_BOND:
    begin
      tx_packet_data <= 'h3c3c3c3c; 
    end
    SEND_FRM_HEAD:
    begin
      tx_packet_data <= 'h55aa55aa;
    end    
    SEND_DATA:
    begin
      tx_packet_data <= tx_data_d4;
    end        
    SEND_FRM_END:
    begin
      tx_packet_data <= 'hbfbfbfbf;        
    end     
    SEND_SUSPEND:
    begin
      tx_packet_data <= 'hbcbcbcbc;  
    end  
    default:
    begin
      tx_packet_data <= 'hbcbcbcbc;  
    end  
  endcase     
end

always @(posedge clk) 
begin
  tx_packet_data_vld <= (crt_st == SEND_DATA);
end

always @(posedge clk) 
begin
  if((crt_st >= SEND_FRM_HEAD) && (crt_st <= SEND_FRM_END))
  begin
    tx_charisk <= 'h0;
  end  
  else
  begin
    tx_charisk <= 'hf;
  end  
end

always @(posedge clk) 
begin
  tx_packet_done <= (crt_st == SEND_FRM_END) && (nxt_st == IDLE);
end

endmodule 
