`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-07-15
// Module Name           : alpg_data_gen
// Project Name          : 
// Target Devices        : 
// Tool Versions         : Vivado 2020.2
// Description           : 
// 
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
// Additional Comments   : can gen drv,IO pin data gen need & drven
// 
//////////////////////////////////////////////////////////////////////////////////
module alpg_data_gen 
#(
    parameter FMT_NUM           = 9   ,
    parameter PE_DUT            = 16             
) 
(
    input                                clk                           ,            //@200M
    input                                rst                           , 
    input                                alpg_work_busy                ,
    //CFG
    input  [FMT_NUM-1:0]                 alpg_fmt                      ,  
    //pattern data
    input                                pattern_data                  ,
    //pattern timing
    input                                pat_a_clk                     ,
    input                                pat_b_clk                     ,
    input                                pat_c_clk                     ,
    input                                pat_drv_en                    ,
    //output pin
    output [PE_DUT-1:0]                  pat_dout_bus                   
);

reg  pat_a_clk_d1 = 'd0 ;
reg  pat_b_clk_d1 = 'd0 ;
reg  pat_c_clk_d1 = 'd0 ;
wire pat_a_clk_r        ;
wire pat_b_clk_r        ;
wire pat_c_clk_r        ;
reg  pat_dout     = 'd0 ;

always @(posedge clk) 
begin
  pat_a_clk_d1 <= pat_a_clk;
  pat_b_clk_d1 <= pat_b_clk;
  pat_c_clk_d1 <= pat_c_clk;
end

assign pat_a_clk_r = (!pat_a_clk_d1) && pat_a_clk;
assign pat_b_clk_r = (!pat_b_clk_d1) && pat_b_clk;
assign pat_c_clk_r = (!pat_c_clk_d1) && pat_c_clk;

always @(posedge clk) 
begin
  if(!alpg_work_busy)
  begin
    pat_dout <= alpg_fmt[9];
  end
  else if(pat_drv_en)
  begin
    case(alpg_fmt)
      'd0:
      begin
        if(pat_a_clk_r)
        begin
          pat_dout <= pattern_data ;  
        end
        else
        begin
          pat_dout <= pat_dout;
        end    
      end
      'd1:
      begin
        if(pat_b_clk_r)
        begin
          pat_dout <= pattern_data ;  
        end
        else
        begin
          pat_dout <= pat_dout;
        end
      end
      'd2:
      begin
        if(pat_c_clk_r)
        begin
          pat_dout <= pattern_data ;  
        end
        else
        begin
          pat_dout <= pat_dout;
        end
      end
      'd3:
      begin
        if(pat_b_clk_r)
        begin
          pat_dout <= pattern_data ;  
        end
        else if(pat_c_clk_r)
        begin
          pat_dout <= 'd0;
        end
        else
        begin
          pat_dout <= pat_dout;
        end
      end
      'd4:
      begin
        pat_dout <= 'd0;
      end
      'd5:
      begin
        pat_dout <= 'd1;
      end
      'd6:
      begin
        if(pat_a_clk_r)
        begin
          pat_dout <= ~pattern_data ;  
        end
        else
        begin
          pat_dout <= pat_dout;
        end  
      end
      'd7:
      begin
        if(pat_b_clk_r)
        begin
          pat_dout <= ~pattern_data ;  
        end
        else
        begin
          pat_dout <= pat_dout;
        end 
      end
      'd8:
      begin
        if(pat_c_clk_r)
        begin
          pat_dout <= ~pattern_data ;  
        end
        else
        begin
          pat_dout <= pat_dout;
        end 
      end
      'd9:
      begin
        if(pat_b_clk_r)
        begin
          pat_dout <= ~pattern_data ;  
        end
        else if(pat_c_clk_r)
        begin
          pat_dout <= 'd1;
        end
        else
        begin
          pat_dout <= pat_dout;
        end
      end 
      default: 
      begin
        pat_dout <= alpg_fmt[9];
      end
    endcase
  end
  else
  begin
    pat_dout <= alpg_fmt[9];
  end
end

assign pat_dout_bus = {PE_DUT{pat_dout}};

endmodule