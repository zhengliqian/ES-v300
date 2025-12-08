`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-09
// Module Name           : alpg_data_cmp
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
module alpg_data_cmp
#(
    parameter BYTE_DW    = 8 ,
    parameter MOD_DW     = 2 , 
    parameter MSKTB_DW   = 8 ,
    parameter CMD_DW     = 4 ,
    parameter FBC_SUM_DW = 17,
    parameter DDR_DW     = 8
)
(
    input                                clk                           ,            //@200M
    input                                rst                           , 
    input                                alpg_start                    ,
    //CFG
    input      [MOD_DW-1:0]              cfg_alpg_run_mod              ,   //0:DUM;1:FBC;2:AFM
    input      [MSKTB_DW-1:0]            cfg_alpg_msktb                ,
    input                                cfg_alpg_me                   ,
    //TIMING
    input                                strb_pluse                    ,
    input                                base_rate_clk                 ,
    //PAT FUNC
    input                                pat_data_parse_vld            ,   
    input      [BYTE_DW-1:0]             d_reg                         ,
    input      [CMD_DW-1:0]              pattern_cmd                   ,
    input                                pattern_me                    ,
    input      [MSKTB_DW-1:0]            pattern_msktb                 ,
    //DDR DATA
    input      [DDR_DW-1:0]              dum_data                      ,
    //DUT din
    input                                dut_din                       ,
    //CMP DATA
    output reg                           mflg_out          = 'd0       ,
    output reg [FBC_SUM_DW-1:0]          fbc_cnt           = 'd0       ,
    output reg [BYTE_DW-1:0]             fsr_out           = 'd0    
);

wire [BYTE_DW-1:0] exp_data ;

assign exp_data = (pattern_cmd == 'd7) ? dum_data : d_reg;

reg                pat_msktb_serial   = 'd0;
reg [MSKTB_DW-1:0] pat_msktb_shift    = 'd0;
reg                base_rate_clk_d1   = 'd0;
wire               base_rate_clk_r         ;
reg                base_rate_clk_r_d1 = 'd0;
reg                base_rate_clk_r_d2 = 'd0;

always @(posedge clk) 
begin
  base_rate_clk_d1   <= base_rate_clk      ;
  pat_msktb_serial   <= pat_msktb_shift[0] ;
  base_rate_clk_r_d1 <= base_rate_clk_r    ;
  base_rate_clk_r_d2 <= base_rate_clk_r_d1 ;
end

assign base_rate_clk_r = base_rate_clk && (!base_rate_clk_d1);

always @(posedge clk) 
begin
  if(pat_data_parse_vld)
  begin
    pat_msktb_shift <= pattern_msktb;
  end
  else if(base_rate_clk_r)  
  begin
    pat_msktb_shift <= {1'b0,pat_msktb_shift[MSKTB_DW-1:1]};
  end
  else
  begin
    pat_msktb_shift <= pat_msktb_shift;
  end  
end

reg  match_flag = 'd0;
reg  mflag_flag = 'd0;
reg  fsr_flag   = 'd0;
reg  fbc_flag   = 'd0;
wire cmp_flag        ;

always @(posedge clk) 
begin
  match_flag <= (pattern_cmd == 'd4) && pattern_me && (!pat_msktb_serial);
  mflag_flag <= match_flag || (pattern_cmd == 'd3) || (pattern_cmd == 'd6) || (pattern_cmd == 'd7);
  fsr_flag   <= (pattern_cmd == 'd5) || (pattern_cmd == 'd6);
  fbc_flag   <= ((pattern_cmd == 'd3) && (cfg_alpg_run_mod == 'd1)) || (pattern_cmd == 'd4);
end

assign cmp_flag = mflag_flag || fsr_flag || fbc_flag;

reg [BYTE_DW-1:0] exp_data_shift = 'd0 ;
reg [BYTE_DW-1:0] bit_cnt        = 'd0 ;

always @(posedge clk) 
begin
  if(alpg_start || (!cmp_flag))
  begin
    bit_cnt <= 'd0;
  end
  else if(base_rate_clk_r) 
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
  if(mflag_flag && base_rate_clk_r) 
  begin
    if(bit_cnt == 'd0)
    begin
      exp_data_shift <= exp_data;  
    end
    else
    begin
      exp_data_shift <= {1'b0,exp_data_shift[BYTE_DW-1:1]};
    end    
  end 
  else
  begin
    exp_data_shift <= exp_data_shift;
  end  
end

reg cmp_rslt = 'd0;

always @(posedge clk) 
begin
  if(cmp_flag && base_rate_clk_r_d1)
  begin
    cmp_rslt <= (dut_din == exp_data_shift[0]);
  end  
  else
  begin
    cmp_rslt <= 'd0;
  end  
end

always @(posedge clk) 
begin
  mflg_out <= mflag_flag && cmp_rslt; 
end

always @(posedge clk) 
begin
  if(!fsr_flag)
  begin
    fsr_out <= 'd0;
  end
  else if(base_rate_clk_r_d2)
  begin
    fsr_out <= {cmp_rslt,fsr_out[BYTE_DW-1:1]};
  end  
  else
  begin
    fsr_out <= fsr_out;
  end  
end

always @(posedge clk) 
begin
  if(alpg_start || (pattern_cmd > 'd7))
  begin
    fbc_cnt <= 'd0;
  end
  else if(fbc_flag && (!cmp_rslt))
  begin
    fbc_cnt <= fbc_cnt + 'd1;
  end  
  else
  begin
    fbc_cnt <= fbc_cnt;
  end   
end

endmodule