`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-23
// Module Name           : alpg_clk_gen
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
module alpg_clk_gen 
#(
    parameter TIMING_DW         = 22              
) 
(
    input                          sys_clk                   ,            
    input                          sys_rst                   ,            
    input                          clk_200M_45               ,            
    input                          clk_200M_90               ,            
    input                          clk_200M_135              , 
    input                          alpg_start                ,   
    input                          alpg_done                 ,        
    input                          pat_data_parse_vld        ,
    input      [TIMING_DW-1:0]     pattern_data_rate         ,
    input      [TIMING_DW-1:0]     pat_timing_cfg            ,
    input                          base_timing_flag          ,
    output reg                     pattern_clk         = 'dz  
);

localparam ST_DW = 4;

localparam IDLE         = 0 ;
localparam TIMING_FRSIT = 1 ;
localparam TIMING_NEXT  = 2 ;
localparam TIMING_END   = 3 ;
    
reg [ST_DW-1:0] crt_st = IDLE ;
reg [ST_DW-1:0] nxt_st = IDLE ;
reg             timing_dly_end = 'd0;

always @(posedge sys_clk) 
begin
  if(sys_rst)
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
      if(alpg_start)
      begin
        nxt_st = TIMING_FRSIT;
      end  
      else
      begin
        nxt_st = IDLE;
      end  
    end
    TIMING_FRSIT:
    begin
      if(pat_data_parse_vld && base_timing_flag)  
      begin
        nxt_st = TIMING_NEXT;
      end
      else if(timing_dly_end)
      begin
        nxt_st = TIMING_NEXT;
      end  
      else 
      begin
        nxt_st = TIMING_FRSIT;
      end
    end
    TIMING_NEXT:
    begin
      if(alpg_done)
      begin
        nxt_st = TIMING_END;
      end  
      else
      begin
        nxt_st = TIMING_NEXT;
      end  
    end
    TIMING_END:
    begin
      nxt_st = IDLE;  
    end
    default:
    begin
      nxt_st = IDLE;         
    end 
  endcase  
end

reg [TIMING_DW-1:0] pat_data_rate_lock    = 'd0;
reg [TIMING_DW-1:0] pat_timing_cfg_lock   = 'd0;
reg [TIMING_DW-1:0] pat_data_rate_lock_d1 = 'd0;
reg [TIMING_DW-1:0] pat_data_rate_lock_d2 = 'd0;
reg [TIMING_DW-1:0] base_crd_cnt          = 'd0;
reg [TIMING_DW-1:0] timing_dly_cnt        = 'd0;

always @(posedge sys_clk) 
begin
  if(((crt_st == TIMING_FRSIT) && pat_data_parse_vld) || (crt_st == TIMING_NEXT) && (base_crd_cnt == pat_data_rate_lock[TIMING_DW-3:0] - 'd1))
  begin
    pat_data_rate_lock  <= pattern_data_rate;
    pat_timing_cfg_lock <= pat_timing_cfg   ;
  end
  else
  begin
    pat_data_rate_lock  <= pat_data_rate_lock ;
    pat_timing_cfg_lock <= pat_timing_cfg_lock;
  end  
end

always @(posedge sys_clk) 
begin
  if (base_crd_cnt == pat_data_rate_lock_d2[TIMING_DW-3:0] - 'd1) 
  begin
    base_crd_cnt <= 'd0;
  end
  else if(crt_st == TIMING_NEXT)
  begin
    base_crd_cnt <= base_crd_cnt + 'd1;
  end  
  else
  begin
    base_crd_cnt <= 'd0;
  end  
end

reg timing_dly_flag = 'd0;

always @(posedge sys_clk) 
begin
  if((timing_dly_cnt == pat_timing_cfg[TIMING_DW-3:0] - 'd1) || sys_rst)   
  begin
    timing_dly_flag <= 'd0;
  end
  else if((crt_st == TIMING_FRSIT) && (!base_timing_flag))
  begin
    timing_dly_flag <= 'd1;
  end
  else
  begin
    timing_dly_flag <= timing_dly_flag;
  end  
end

always @(posedge sys_clk) 
begin
  if(timing_dly_flag)
  begin
    timing_dly_cnt <= timing_dly_cnt + 'd1;
  end  
  else
  begin
    timing_dly_cnt <= 'd0;
  end  
end

always @(posedge sys_clk) 
begin
  timing_dly_end <= pat_timing_cfg[TIMING_DW-3:0] - 'd2;
end

//base clk gen
wire base_crd_clk     ;
wire basef_crd_clk    ;
reg  div_flag    = 'd0;

always @(posedge sys_clk) 
begin
  div_flag <= (crt_st == TIMING_NEXT);
end

reg[TIMING_DW-3:0] base_cfg_div  = 'd0;
reg[TIMING_DW-3:0] basef_cfg_div = 'd0;

always @(posedge sys_clk) 
begin
  base_cfg_div  <= pat_data_rate_lock[TIMING_DW-3:0];
  basef_cfg_div <= pat_data_rate_lock[TIMING_DW-3:0];
end

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
base_clk_div (
  .clk     (sys_clk                               ),
  .rst     (sys_rst                               ),
  .cfg_div (base_cfg_div     ),
  .div_flag(div_flag                              ),
  .div_clk (base_crd_clk                          )
);

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
basef_clk_div (
  .clk     (~sys_clk                              ),
  .rst     (sys_rst                               ),
  .cfg_div (basef_cfg_div     ),
  .div_flag(div_flag                              ),
  .div_clk (basef_crd_clk                         )
);

always @(posedge sys_clk) 
begin
  pat_data_rate_lock_d1 <= pat_data_rate_lock   ;
  pat_data_rate_lock_d2 <= pat_data_rate_lock_d1;
end

//use in 1.25ns broadening
wire base45_crd_clk;
wire base45f_crd_clk;

reg[TIMING_DW-3:0] base45_cfg_div  = 'd0;
reg[TIMING_DW-3:0] base45f_cfg_div = 'd0;

always @(posedge sys_clk) 
begin
  base45_cfg_div  <= pat_data_rate_lock[TIMING_DW-3:0];
  base45f_cfg_div <= pat_data_rate_lock[TIMING_DW-3:0];
end

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
base45_clk_div (
  .clk     (clk_200M_45                        ),
  .rst     (sys_rst                            ),
  .cfg_div (base45_cfg_div  ),
  .div_flag(div_flag                           ),
  .div_clk (base45_crd_clk                     )
);

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
base45f_clk_div (
  .clk     (~clk_200M_45                       ),
  .rst     (sys_rst                            ),
  .cfg_div (base45f_cfg_div  ),
  .div_flag(div_flag                           ),
  .div_clk (base45f_crd_clk                    )
);

//use in 2.5ns broadening
wire base90_crd_clk ;
wire base90f_crd_clk;

reg[TIMING_DW-3:0] base90_cfg_div  = 'd0;
reg[TIMING_DW-3:0] base90f_cfg_div = 'd0;

always @(posedge sys_clk) 
begin
  base90_cfg_div  <= pat_data_rate_lock[TIMING_DW-3:0];
  base90f_cfg_div <= pat_data_rate_lock[TIMING_DW-3:0];
end

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
base90_clk_div (
  .clk     (clk_200M_90                        ),
  .rst     (sys_rst                            ),
  .cfg_div (base90_cfg_div  ),
  .div_flag(div_flag                           ),
  .div_clk (base90_crd_clk                     )
);

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
base90f_clk_div (
  .clk     (~clk_200M_90                       ),
  .rst     (sys_rst                            ),
  .cfg_div (base90f_cfg_div  ),
  .div_flag(div_flag                           ),
  .div_clk (base90f_crd_clk                    )
);

//use in 3.75ns broadening
wire base135_crd_clk ;
wire base135f_crd_clk;

reg[TIMING_DW-3:0] base135_cfg_div  = 'd0;
reg[TIMING_DW-3:0] base135f_cfg_div = 'd0;

always @(posedge sys_clk) 
begin
  base135_cfg_div  <= pat_data_rate_lock[TIMING_DW-3:0];
  base135f_cfg_div <= pat_data_rate_lock[TIMING_DW-3:0];
end

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
base135_clk_div (
  .clk     (clk_200M_135                       ),
  .rst     (sys_rst                            ),
  .cfg_div (base135_cfg_div  ),
  .div_flag(div_flag                           ),
  .div_clk (base135_crd_clk                    )
);

clk_div # (
  .DIV_DW(TIMING_DW-2)
)
base135f_clk_div (
  .clk     (~clk_200M_135                      ),
  .rst     (sys_rst                            ),
  .cfg_div (base135f_cfg_div  ),
  .div_flag(div_flag                           ),
  .div_clk (base135f_crd_clk                   )
);

reg base90f_crd_clk_d1;
reg base90_crd_clk_d1 ;
reg base45_crd_clk_d1 ;
reg base_crd_clk_d1   ;
reg basef_crd_clk_d1  ;

always @(negedge clk_200M_90) 
begin
  base90f_crd_clk_d1 <= base90f_crd_clk; 
  base90_crd_clk_d1  <= base90_crd_clk ; 
  base45_crd_clk_d1  <= base45_crd_clk ; 
  base_crd_clk_d1    <= base_crd_clk   ;
  basef_crd_clk_d1   <= basef_crd_clk  ;
end

//assign base_rate_clk = (pat_data_rate_lock[TIMING_DW-1:TIMING_DW-2] == 'd3) ? ((base_crd_clk | base45_crd_clk) || ((!base90_crd_clk) | (!base45_crd_clk))) :
//                       (pat_data_rate_lock[TIMING_DW-1:TIMING_DW-2] == 'd2) ? ((base_crd_clk | base90_crd_clk) || ((!base90_crd_clk) | (!basef_crd_clk))) :
//                       ((pat_data_rate_lock[TIMING_DW-1:TIMING_DW-2] == 'd1) ? ((base_crd_clk | base135_crd_clk) || ((!base135_crd_clk) | (!base90f_crd_clk_d1))) : base_crd_clk);

always @(*) 
begin
  case(pat_data_rate_lock_d2[TIMING_DW-1:TIMING_DW-2])
  'd0:
  begin
    if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd0)
    begin
      pattern_clk = base_crd_clk;
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd1)
    begin
      pattern_clk = base90_crd_clk;
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd2)
    begin
      pattern_clk = basef_crd_clk;
    end
    else
    begin
      pattern_clk = base90f_crd_clk;
    end    
  end
  'd1:
  begin
    if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd0)
    begin
      pattern_clk = (base_crd_clk || base45_crd_clk) || ((!base45_crd_clk) || (!base90_crd_clk));
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd1)
    begin
      pattern_clk = (base90_crd_clk || base135_crd_clk) || ((!base135_crd_clk) || (!basef_crd_clk));
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd2)
    begin
      pattern_clk = (basef_crd_clk || base45f_crd_clk) || ((!base45f_crd_clk) || (!base90f_crd_clk));
    end
    else
    begin
      pattern_clk = (base90f_crd_clk || base135f_crd_clk) || ((!base_crd_clk_d1) || (!base135f_crd_clk));
    end
  end
  'd2: 
  begin
    if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd0)
    begin
      pattern_clk = (base_crd_clk || base90_crd_clk) || ((!basef_crd_clk) || (!base90_crd_clk));
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd1)
    begin
      pattern_clk = (base90_crd_clk || basef_crd_clk) || ((!basef_crd_clk) || (!base90f_crd_clk));
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd2)
    begin
      pattern_clk = (basef_crd_clk || base90f_crd_clk) || ((!base90f_crd_clk) || (!base_crd_clk_d1));
    end
    else
    begin
      pattern_clk = (base90f_crd_clk || base_crd_clk_d1) || ((!base_crd_clk_d1) || (!base90_crd_clk));
    end
  end
  'd3:
  begin
    if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd0)
    begin
      pattern_clk = (base_crd_clk || base135_crd_clk) || ((!base135_crd_clk) || (!base90_crd_clk_d1));
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd1)
    begin
      pattern_clk = (base90_crd_clk || base45f_crd_clk) || ((!base45f_crd_clk) || (!base_crd_clk_d1));
    end
    else if(pat_timing_cfg_lock[TIMING_DW-1:TIMING_DW-2] == 'd2)
    begin
      pattern_clk = (basef_crd_clk || base135f_crd_clk) || ((!base135f_crd_clk) || (!base90_crd_clk_d1));
    end
    else
    begin
      pattern_clk = (base90f_crd_clk || base45_crd_clk_d1) || ((!base45_crd_clk_d1) || (!basef_crd_clk_d1));
    end
  end
  default:
  begin
    pattern_clk = pattern_clk;
  end
  endcase
end

endmodule
