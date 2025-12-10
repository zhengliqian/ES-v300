`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-18
// Module Name           : alpg_ctrl_mst
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
module alpg_ctrl_mst 
(
    input                  clk                 ,              //200M
    input                  rst                 ,
    input                  alpg_start          ,
    input                  alpg_restart        ,
    input                  alpg_stop           ,
    output reg             alpg_work_busy = 'd0,
    (*mark_debug = "true"*)(*keep = "true"*)input                  alpg_done ,
    output reg             init_start     = 'd0,
    input                  init_done
);
    
localparam ST_DW = 4;

localparam IDLE  = 0 ;
localparam INIT  = 1 ;
localparam WORK  = 2 ;
localparam DONE  = 3 ;

(*mark_debug = "true"*)(*keep = "true"*)reg [ST_DW-1:0] crt_st = IDLE;
reg [ST_DW-1:0] nxt_st = IDLE;

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
  case(crt_st)
    IDLE:
    begin
      if(alpg_start || alpg_restart)
      begin
        nxt_st = INIT;
      end  
      else
      begin
        nxt_st = IDLE;
      end
    end
    INIT:
    begin
      if(init_done)
      begin
        nxt_st = WORK;
      end  
      else
      begin
        nxt_st = INIT;
      end
    end
    WORK:
    begin
      if(alpg_stop || alpg_done)
      begin
        nxt_st = DONE;
      end  
      else
      begin
        nxt_st = WORK;
      end
    end
    DONE:
    begin
      nxt_st = IDLE;  
    end 
    default: 
    begin
      nxt_st = IDLE;  
    end
  endcase   
end

always @(posedge clk) 
begin
  alpg_work_busy <= (crt_st != IDLE) ;
  init_start     <= (crt_st == IDLE) && (nxt_st == INIT);
end

endmodule
