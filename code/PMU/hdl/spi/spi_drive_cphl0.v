//閫傜敤浜? SPI CPOL =0, CPHL = 0;
//           CPOL =1, CPHL = 0;
module spi_drive_cphl0#(
    parameter  DIVIDE          =16'd2 ,  
    parameter  DATA_WITH       =29    ,   
    parameter  CPOL            =1'b0  ,  
    parameter  READ_DATA_WITH  =29    ,   
    parameter  WAIT_TIME       =20        
)
(
    input  rst_n                            ,   
    input  clk                              ,   
    input  wr_req                           ,   
    input  rd_req                           ,   
    input  [DATA_WITH-1:0]   data           , 
    output     wr_done                      , 
    output     rd_done                      , 
    output reg ready                        ,  
    output reg sync                         ,   
    output reg sclk                         ,   
    output reg sdi                          ,   
    input  sdo                              ,   
    input  sdo_b                            ,   
    output reg [READ_DATA_WITH-1:0]rd_data  ,   
    output reg [READ_DATA_WITH-1:0]rd_data_b,   
    output reg rd_data_vld                      
);

reg     flag_add_wr ;
reg     flag_add_rd ;
reg     [15:0]cnt0  ;
wire    add_cnt0    ;
wire    end_cnt0    ;
reg     [15:0]cnt1  ;
wire    add_cnt1    ;
wire    end_cnt1    ;
reg     [15:0]x     ;

always@(*)begin                          //本模块准备好信号
  if(flag_add_wr||flag_add_rd)begin
    ready=1'b0;
  end
  else begin
    ready=1'b1;
  end
end

always@(posedge clk)begin  //spi总线处于写阶段标志信号
  if(!rst_n)begin
    flag_add_wr<=1'b0;
  end
  else if(wr_req&&ready)begin
    flag_add_wr<=1'b1;
  end
  else if(end_cnt1)begin
    flag_add_wr<=1'b0;
  end
  else begin
    flag_add_wr<=flag_add_wr;
  end
end

always@(posedge clk)begin  //spi总线处于读阶段标志信号
  if(!rst_n)begin
    flag_add_rd<=1'b0;
  end
  else if(rd_req&&ready&&(wr_req==0))begin
    flag_add_rd<=1'b1;
  end
  else if(end_cnt1)begin
    flag_add_rd<=1'b0;
  end
  else begin
    flag_add_rd<=flag_add_rd;
  end
end

reg     flag_add_wr_d1 = 'd0 ;
reg     flag_add_rd_d1 = 'd0 ;

always @(posedge clk) 
begin
  flag_add_wr_d1 <= flag_add_wr ;
  flag_add_rd_d1 <= flag_add_rd ;  
end

assign wr_done = flag_add_wr_d1 && (!flag_add_wr);
assign rd_done = flag_add_rd_d1 && (!flag_add_rd);
 
 always@(posedge clk)begin  //对系统时钟进行分频计数
 if(!rst_n)begin
   cnt0<=1'b0;
 end
 else if(add_cnt0)begin
   if(end_cnt0)begin
      cnt0<=16'd0;
   end
   else begin
      cnt0<=cnt0+1;
   end
 end
 else begin
      cnt0<=cnt0;
 end
end

assign add_cnt0 = flag_add_wr||flag_add_rd;
assign end_cnt0 = add_cnt0&&(cnt0==DIVIDE-1);

always@(posedge clk)begin 
  if(!rst_n)begin
    sync<=1'b1;
  end
  else if(flag_add_rd&&(cnt1==DATA_WITH-1)&&end_cnt0)begin
    sync<=1'b1;          
  end
  else if(flag_add_rd&&(cnt1==DATA_WITH+WAIT_TIME-1)&&end_cnt0)begin
    sync<=1'b0;
  end
  else if((wr_req&&ready)||(rd_req&&ready))begin
    sync<=1'b0;
  end
  else if(end_cnt1)begin
    sync<=1'b1;
  end
  else begin
    sync<=sync;
  end
end

always@(posedge clk)begin
  if(!rst_n)begin
    sclk<=CPOL;
  end
  //else if(cnt1==DATA_WITH+WAIT_TIME-1&&end_cnt0)begin
  //    sclk<=~sclk;
  // end
  else if((flag_add_rd&&((cnt1>DATA_WITH-1)&&(cnt1<=DATA_WITH+WAIT_TIME-1)||((cnt1==DATA_WITH-1)&&end_cnt0)))||end_cnt1)begin
    sclk<=CPOL;
  end
  else if(((flag_add_rd||flag_add_wr)&&(end_cnt0||(cnt0==DIVIDE/2-1))&&(end_cnt1==0)))begin
    sclk<=~sclk;
  end
  else begin
    sclk<=sclk;
  end
  //else begin
  //    sclk<=CPOL;
  //end
end


always@(posedge clk)begin   //对SCLK的时钟周期个数进行计数
  if(!rst_n)begin
    cnt1<=16'd0;
  end
  else if(add_cnt1)begin
  if(end_cnt1)begin
    cnt1<=16'd0;
  end
  else begin
    cnt1<=cnt1+1'b1;
  end
  end 
  else begin
    cnt1<=cnt1;
  end
end

assign add_cnt1=end_cnt0;
assign end_cnt1=add_cnt1&&(cnt1==x-1);

always@(*)begin          //读写阶段计数的个数设置             
  if(flag_add_rd)begin
    x = DATA_WITH + READ_DATA_WITH +WAIT_TIME;
  end
  else begin
    x = DATA_WITH;
  end
end

always@(posedge clk)begin 
  if(!rst_n)begin
    sdi<=1'b1;
  end
  else if((wr_req&&ready)||(rd_req&&ready))begin
    sdi<=data[DATA_WITH-1];
  end
  else if((flag_add_wr||flag_add_rd)&&end_cnt0&&(cnt1<DATA_WITH-1))begin
    sdi<=data[DATA_WITH-2-cnt1];
  end
  else begin
    sdi<=sdi;
  end
end

always@(posedge clk)begin
  if(!rst_n)begin
    rd_data<=0;
  end
  else if((flag_add_wr||flag_add_rd)&&(cnt0==DIVIDE/2-1))begin
    rd_data<={rd_data[READ_DATA_WITH-2:0],sdo};
  end
  else begin
    rd_data<=rd_data;
  end
end

always@(posedge clk)begin
  if(!rst_n)begin
    rd_data_b<=0;
  end
  else if((flag_add_wr||flag_add_rd)&&(cnt0==DIVIDE/2-1))begin
    rd_data_b<={rd_data_b[READ_DATA_WITH-2:0],sdo_b};
  end
  else begin
    rd_data_b<=rd_data_b;
  end
end  

always@(posedge clk)begin
  if(!rst_n)begin
    rd_data_vld<=1'b0;
  end
  else if(flag_add_rd&&end_cnt1)begin
    rd_data_vld<=1'b1;
  end
  else begin
    rd_data_vld<=1'b0;
  end
end
endmodule

