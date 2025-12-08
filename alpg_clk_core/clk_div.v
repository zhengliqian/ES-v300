`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-18
// Module Name           : clk_div
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
module clk_div 
#(
    parameter DIV_DW = 20
) (
    input                  clk     ,
    input                  rst     ,
    input [DIV_DW-1:0]     cfg_div ,
    input                  div_flag,
    output                 div_clk
);
    
reg [DIV_DW-1:0] pos_cnt = 'd0;
reg [DIV_DW-1:0] neg_cnt = 'd0;
reg [DIV_DW-1:0] cfg_div_pos = 'd0;
reg [DIV_DW-1:0] cfg_div_neg = 'd0;

always @(posedge clk) 
begin
  cfg_div_pos <= cfg_div;
  cfg_div_neg <= cfg_div;
end

always @(posedge clk) 
begin
  if (pos_cnt == cfg_div_pos - 'd1) 
  begin
    pos_cnt <= 'd0;
  end
  else if(div_flag)
  begin
    pos_cnt <= pos_cnt + 'd1;
  end  
  else
  begin
    pos_cnt <= 'd0;
  end  
end

always @(negedge clk) 
begin
  if (neg_cnt == cfg_div_neg - 'd1) 
  begin
    neg_cnt <= 'd0;
  end
  else if(div_flag)
  begin
    neg_cnt <= neg_cnt + 'd1;
  end  
  else
  begin
    neg_cnt <= 'd0;
  end  
end

reg clk_pos = 'd0;
reg clk_neg = 'd0;

always @(posedge clk) 
begin
  if((pos_cnt == ((cfg_div_pos - 'd1) >> 1)) || (pos_cnt == (cfg_div_pos - 'd1)))  
  begin
    clk_pos <= ~clk_pos;
  end
  else
  begin
    clk_pos <= clk_pos;
  end  
end

always @(negedge clk) 
begin
  if((neg_cnt == ((cfg_div_neg - 'd1) >> 1)) || (neg_cnt == (cfg_div_neg - 'd1)))  
  begin
    clk_neg <= ~clk_neg;
  end
  else
  begin
    clk_neg <= clk_neg;
  end  
end

reg div_clk_sel = 'd0;

always @(posedge clk) 
begin
  div_clk_sel <= cfg_div[0];
end

assign div_clk = div_clk_sel ? (clk_pos & clk_neg) : clk_pos;

endmodule
