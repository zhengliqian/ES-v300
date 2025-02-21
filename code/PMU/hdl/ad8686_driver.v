`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/29 09:12:05
// Design Name: 
// Module Name: ad8686_driver
// Project Name: 
// Target Devices: 
// Tool Versions: vivado 2020.2
// Description:本模块主要实现驱动ads8686s芯片，对ads8686s实现复位和转换的数据回读，对ads8686s的驱动模式选择的是硬件串行模式， 
//             回读方式采用的是序列突发的方式
// Dependencies: 
// 
// Revision:2024/9/5
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ad8686_driver #(
                       parameter DIVIDE        =    4'd2        ,//分频系数，产生SCLK        
                       parameter WAIT_CNT_WIDTH=    5'd20       ,//设置复位等待和接收数据个数的位宽
                       parameter FULL_RST_NUM  =    20'd800000  ,//完全复位需要的SCLK时钟个数
                       parameter PART_RST_NUM  =    4'd8        ,//部分复位需要的SCLK时钟个数
                       parameter CONV_HTIME    =    3'd6         //CONVST转信号高电平脉冲持续时间（最少50ns）
                       )
               (
               input             sys_rst_n                        ,//      统复位
               input             sys_clk                          ,//      统时钟
               (*mark_debug="true"*)(*keep="true"*)input             req_convst                       ,//      求ADS8686S芯片开始转换模拟数据
               (*mark_debug="true"*)(*keep="true"*)input             req_rst_ad8686                   ,//      求复位ADS8686S(部分复位or完全复位待定)
               (*mark_debug="true"*)(*keep="true"*)output reg[15:0]  cha_rdata                        ,//      读到的通道a的数据 
               (*mark_debug="true"*)(*keep="true"*)output reg[15:0]  chb_rdata                        ,//      读到的通道b的数据 
               (*mark_debug="true"*)(*keep="true"*)output reg        ch_rdata_vld                     ,//      读到的通道数据有效信号
               (*mark_debug="true"*)(*keep="true"*)output reg        ready                            ,//      模块处于空闲状态信号
               (*mark_debug="true"*)(*keep="true"*)output reg        init_device_done                 ,//      ADS8686S初始化完毕
               (*mark_debug="true"*)(*keep="true"*)output reg        rst_device_done                  ,//      ADS8686S复位完毕
               //ADS8686S芯片接                                    //      
               (*mark_debug="true"*)(*keep="true"*)input              ad8686_busy                     ,//      ADS8686S处于工作状态指示信号
               (*mark_debug="true"*)(*keep="true"*)input              ad8686_db11_sdob                ,//      SDOB串行数据输入引脚
               (*mark_debug="true"*)(*keep="true"*)input              ad8686_db12_sdoa                ,//      SDOA串行数据输入引脚
               output wire        ad8686_refsel                   ,//      芯片的参考基准选择信号(完全复位时锁存)
               output reg         ad8686_reset_n                  ,//      芯片的复位信号
               output wire        ad8686_seqen                    ,//      序列发生器的控制信号(完全复位时锁存)
               output wire[1:0]   ad8686_rangesel                 ,//      选择硬件或软件的模式运行(完全复位时锁存)
               output wire        ad8686_ser_byte_par             ,//      选择串行/字节/并行接口(完全复位时锁存)
               output wire        ad8686_db0                      ,//      硬件串行时直接接低电平
               output wire        ad8686_db1                      ,//      硬件串行时直接接低电平
               output wire        ad8686_db2                      ,//      硬件串行时直接接低电平
               output wire        ad8686_db3                      ,//      硬件串行时直接接低电平
               output wire        ad8686_db4_ser1w                ,//      选择SDOA输出还是SDOA和SDOB同时输出(完全复位时锁存)
               output wire        ad8686_db5_crcen                ,//      CRC校验功能使能(完全复位时锁存)
               output wire        ad8686_db6                      ,//      硬件串行时直接接低电平
               output wire        ad8686_db7                      ,//      硬件串行时直接接低电平
               output wire        ad8686_db8                      ,//      硬件串行时直接接低电平
               output wire        ad8686_db9_bytesel              ,//      字节接口模式/串行接口模式选择（完全复位时锁存)
               output wire        ad8686_db10_sdi                 ,//      硬件串行时直接接低电平
               output wire        ad8686_db13_os0                 ,//      过采样选择位0 (完全复位时锁存)
               output wire        ad8686_db14_os1                 ,//      过采样选择位1(完全复位时锁存)
               output wire        ad8686_db15_os2                 ,//      过采样选择位2(完全复位时锁存)
               output wire        ad8686_wr_burst                 ,//      启用或者禁用突发模式(完全复位时锁存)
               (*mark_debug="true"*)(*keep="true"*)output reg         ad8686_sclk_rd                  ,//      对ADS8686S进行访问的同步时钟
               (*mark_debug="true"*)(*keep="true"*)output reg         ad8686_cs_n                     ,//      片选信号
               output wire[2:0]   ad8686_chsel                    ,//      为下一次转换选择通道
               (*mark_debug="true"*)(*keep="true"*)output reg         ad8686_convst                    //      启动一次转换
                    );

localparam  INIT_AD8686 = 3'b000;
localparam  IDLE        = 3'b001;
localparam  RST_AD8686  = 3'b010;
localparam  READ        = 3'b100;

(*mark_debug="true"*)(*keep="true"*)reg  [2:0]state_c                    ;
reg  [2:0]state_n                    ;

wire init_ad86862idle_start          ;
wire idle2rst_ad8686_start           ;
wire idle2read_start                 ; 
wire rst_ad86862idle_start           ;
wire read2idle_start                 ; 

(*mark_debug="true"*)(*keep="true"*)reg [3:0]div_cnt                     ;
wire add_div_cnt                     ;
wire end_div_cnt                     ;

(*mark_debug="true"*)(*keep="true"*)reg [WAIT_CNT_WIDTH-1:0]wait_data_cnt;
wire add_wait_data_cnt               ;
wire end_wait_data_cnt               ;
reg [WAIT_CNT_WIDTH-1:0]variable     ;

(*mark_debug="true"*)(*keep="true"*)reg [3:0]rdch_conv_cnt               ;
wire add_rdch_conv_cnt               ;
wire end_rdch_conv_cnt               ;

reg flag_conv                        ;
reg [3:0]rdch_conv_variable          ;

reg ad8686_busy_ff0                  ;
reg ad8686_busy_ff1                  ;
reg ad8686_busy_ff2                  ;

reg flag_rd                          ;

//ila_0  u_ila_0(
//	.clk(sys_clk), // input wire clk
//	.probe0(ch0_rdata), // input wire [15:0]  probe0  
//	.probe1(ch1_rdata), // input wire [15:0]  probe1 
//	.probe2(ch_data_vld), // input wire [0:0]  probe2 
//	.probe3(state_c), // input wire [2:0]  probe3 
//	.probe4(div_cnt), // input wire [3:0]  probe4 
//	.probe5(wait_data_cnt), // input wire [19:0]  probe5 
//	.probe6(rdch_conv_cnt), // input wire [3:0]  probe6 
//	.probe7(ad8686_db11_sdob), // input wire [0:0]  probe7 
//	.probe8(ad8686_db12_sdoa), // input wire [0:0]  probe8 
//	.probe9(ad8686_convst), // input wire [0:0]  probe9 
//	.probe10(ad8686_sclk_rd), // input wire [0:0]  probe10 
//	.probe11(ad8686_cs_n) // input wire [0:0]  probe11
//);

always@(posedge sys_clk)begin  //分频计数器
      if(!sys_rst_n)begin
          div_cnt <= 4'd0;
      end
      else if(add_div_cnt)begin
           if(end_div_cnt)begin
              div_cnt <= 4'd0;
           end
           else begin
              div_cnt <= div_cnt + 1;
           end
      end
      else begin
           div_cnt <= div_cnt;
      end
end
assign add_div_cnt = 1;
assign end_div_cnt = add_div_cnt && (div_cnt == DIVIDE-1);

always@(posedge sys_clk)begin  //复位等待和回读数据个数的复用计数器
      if(!sys_rst_n)begin
         wait_data_cnt <= 0;   
      end
      else if(add_wait_data_cnt)begin
           if(end_wait_data_cnt)begin
              wait_data_cnt <= 0; 
           end
           else begin
              wait_data_cnt <= wait_data_cnt + 1'b1;
           end
      end
      else begin
              wait_data_cnt <= wait_data_cnt;
      end
end
assign add_wait_data_cnt = (( state_c == INIT_AD8686 )||(state_c == RST_AD8686) || (ad8686_cs_n==0) ) && end_div_cnt;
assign end_wait_data_cnt = add_wait_data_cnt && (wait_data_cnt == variable-1);

always@(*)begin
      if(state_c == INIT_AD8686)begin
           variable = FULL_RST_NUM;
      end
      else if(state_c == RST_AD8686)begin
           variable = PART_RST_NUM;  
      end
      else begin
           variable = 20'd16;
      end
end 

always@(posedge sys_clk)begin      //回读的通道计数器
      if(!sys_rst_n)begin
          rdch_conv_cnt<=4'd0; 
      end
      else if(add_rdch_conv_cnt)begin
           if(end_rdch_conv_cnt)begin
              rdch_conv_cnt<=4'd0;
           end
           else begin
             rdch_conv_cnt<=rdch_conv_cnt+1;
           end
      end
      else begin
            rdch_conv_cnt <= rdch_conv_cnt; 
      end
end
assign add_rdch_conv_cnt=(flag_conv) || ((state_c == READ) && end_wait_data_cnt);
assign end_rdch_conv_cnt= add_rdch_conv_cnt && (rdch_conv_cnt == rdch_conv_variable-1);  

always@(*)begin
       if(flag_conv)begin
          rdch_conv_variable = CONV_HTIME; 
       end
       else begin
          rdch_conv_variable = 4'd8;
       end
end

always@(posedge sys_clk)begin     
      if(!sys_rst_n)begin
          state_c <= INIT_AD8686;
      end
      else begin
          state_c <= state_n;
      end
end

always@(*)begin      
       case(state_c)
            INIT_AD8686:begin
                        if(init_ad86862idle_start)begin
                           state_n = IDLE;
                        end
                        else begin
                           state_n = state_c;
                        end
            end
            IDLE       :begin
                        if(idle2rst_ad8686_start)begin
                           state_n = RST_AD8686;
                        end
                        else if(idle2read_start)begin
                           state_n = READ;
                        end
                        else begin
                           state_n = state_c;
                        end
            end
            RST_AD8686  :begin
                         if(rst_ad86862idle_start)begin
                            state_n = IDLE;
                         end
                         else begin
                            state_n = state_c;
                         end
            end
            READ        :begin
                         if(read2idle_start)begin
                            state_n = IDLE;
                         end
                         else begin
                            state_n = state_c;
                         end
            end
            default:state_n = INIT_AD8686;   
       endcase
end

assign init_ad86862idle_start   = (state_c == INIT_AD8686) && end_wait_data_cnt                  ;
assign idle2rst_ad8686_start    = (state_c == IDLE       ) && req_rst_ad8686                     ;
assign idle2read_start          = (state_c == IDLE       ) && req_convst                         ; 
assign rst_ad86862idle_start    = (state_c == RST_AD8686 ) && end_wait_data_cnt                  ;
assign read2idle_start          = (state_c == READ       ) && end_rdch_conv_cnt && (flag_conv==0);

always@(posedge sys_clk)begin   //初始化完成指示信号
      if(!sys_rst_n)begin
         init_device_done <= 1'b0;
      end
      else if(init_ad86862idle_start)begin
         init_device_done <= 1'b1;
      end
      else begin
         init_device_done <= init_device_done;
      end
end

always@(posedge sys_clk)begin   //部分复位完成指示信号
      if(!sys_rst_n)begin
         rst_device_done <= 1'b0;
      end
      else if(rst_ad86862idle_start)begin
         rst_device_done <= 1'b1;
      end
      else begin
         rst_device_done <= 1'b0;
      end
end

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
         ad8686_reset_n <= 1'b0;
      end
      else if(((state_c == INIT_AD8686) && (wait_data_cnt == FULL_RST_NUM/16-1)) || (( state_c == RST_AD8686) && (wait_data_cnt == (PART_RST_NUM/8)*5)) ) begin
        ad8686_reset_n <=  1'b1;
      end
      else if( idle2rst_ad8686_start)begin
        ad8686_reset_n <= 1'b0;
      end  
      else begin
        ad8686_reset_n <= ad8686_reset_n;
      end 
end


assign     ad8686_refsel           =       1'b0  ;             //      芯片的参考基准选择信号(完全复位时锁存)
assign     ad8686_seqen            =       1'b1  ;             //      序列发生器的控制信号(完全复位时锁存)
assign     ad8686_rangesel         =       2'b11 ;             //      选择硬件或软件的模式运行(完全复位时锁存)
assign     ad8686_ser_byte_par     =       1'b1  ;             //      选择串行/字节/并行接口(完全复位时锁存)
assign     ad8686_db0              =       1'b0  ;             //      硬件串行时直接接低电平
assign     ad8686_db1              =       1'b0  ;             //      硬件串行时直接接低电平
assign     ad8686_db2              =       1'b0  ;            //      硬件串行时直接接低电平
assign     ad8686_db3              =       1'b0  ;             //      硬件串行时直接接低电平
assign     ad8686_db4_ser1w        =       1'b1  ;             //      选择SDOA输出还是SDOA和SDOB同时输出(完全复位时锁存)
assign     ad8686_db5_crcen        =       1'b0  ;            //      CRC校验功能使能(完全复位时锁存)
assign     ad8686_db6              =       1'b0  ;             //      硬件串行时直接接低电平
assign     ad8686_db7              =       1'b0  ;            //      硬件串行时直接接低电平
assign     ad8686_db8              =       1'b0  ;            //      硬件串行时直接接低电平
assign     ad8686_db9_bytesel      =       1'b0  ;            //      字节接口模式/串行接口模式选择（完全复位时锁存)
assign     ad8686_db10_sdi         =       1'b0  ;            //      硬件串行时直接接低电平
assign     ad8686_db13_os0         =       1'b0  ;             //      过采样选择位0 (完全复位时锁存)
assign     ad8686_db14_os1         =       1'b0  ;             //      过采样选择位1(完全复位时锁存)
assign     ad8686_db15_os2         =       1'b0  ;             //      过采样选择位2(完全复位时锁存)
assign     ad8686_wr_burst         =       1'b1  ;             //      启用或者禁用突发模式(完全复位时锁存)
assign     ad8686_chsel            =       3'b111;             //      为下一次转换选择通道    

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          ad8686_sclk_rd <= 1'b1;
      end
      else if((div_cnt == DIVIDE/2-1) || (end_div_cnt) )begin
          ad8686_sclk_rd <= ~ad8686_sclk_rd; 
      end
      else begin
         ad8686_sclk_rd <=  ad8686_sclk_rd;
      end   
end

always@(posedge sys_clk)begin //req_convst需要持续50ns  
      if(!sys_rst_n)begin
           flag_conv<=1'b0;
      end
      else if(idle2read_start)begin
          flag_conv<=1'b1;
      end
      else if(end_rdch_conv_cnt)begin
          flag_conv<=1'b0;
      end
      else begin
          flag_conv<=flag_conv;
      end
end


always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
         ad8686_convst <= 1'b0;
      end
      else if( idle2read_start  )begin
        ad8686_convst <= 1'b1;
      end
      else if( flag_conv && end_rdch_conv_cnt )begin
        ad8686_convst <= 1'b0;
      end
      else begin
        ad8686_convst <= ad8686_convst;
      end
end

always@(posedge sys_clk)begin   //异步信号同步化
      if(!sys_rst_n)begin
         ad8686_busy_ff0 <= 1'b0;
         ad8686_busy_ff1 <= 1'b0;
         ad8686_busy_ff2 <= 1'b0;
      end
      else begin
         ad8686_busy_ff0 <= ad8686_busy;
         ad8686_busy_ff1 <= ad8686_busy_ff0;
         ad8686_busy_ff2 <= ad8686_busy_ff1; 
      end
end

always@(posedge sys_clk)begin //检测ad8686_busy的下降沿
      if(!sys_rst_n)begin
         flag_rd <= 1'b0; 
      end
      else if(wait_data_cnt)begin
        flag_rd <= 1'b0; 
      end
      else if((state_c==READ) && ~ad8686_busy_ff1 &&  ad8686_busy_ff2)begin
        flag_rd <= 1'b1;
      end 
end

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
         ad8686_cs_n <= 1'b1;
      end
      else if(flag_rd && end_div_cnt)begin
         ad8686_cs_n <= 1'b0;
      end
      else if(read2idle_start)begin
         ad8686_cs_n <= 1'b1;
      end
end

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
          cha_rdata <= 16'd0;
          chb_rdata <= 16'd0;
      end
     // else if(div_cnt == DIVIDE/2-1) begin
      else if(end_div_cnt) begin                   //2024-9-12 sclk_r
         cha_rdata <= {cha_rdata[14:0] , ad8686_db12_sdoa};
         chb_rdata <= {chb_rdata[14:0] , ad8686_db11_sdob};  
      end
      else begin
         cha_rdata <= cha_rdata;
         chb_rdata <= chb_rdata;
      end
end

always@(posedge sys_clk)begin
      if(!sys_rst_n)begin
           ch_rdata_vld <= 1'b0;
      end
      else if((ad8686_cs_n == 0) && add_rdch_conv_cnt)begin
           ch_rdata_vld <= 1'b1;
      end
      else begin
           ch_rdata_vld <= 1'b0;
      end
end

always@(*)begin
        if(state_c == IDLE)begin
            ready = 1'b1;
        end
        else begin
            ready = 1'b0;
        end
end

endmodule
