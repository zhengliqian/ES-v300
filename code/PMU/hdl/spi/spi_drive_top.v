module  spi_drive_top  #(
      parameter  DIVIDE          = 2    ,  //时钟的分频系数
      parameter  DATA_WITH       =29    ,  //发送数据的位宽
      parameter  CPOL            =1'b0  ,  //spi的时钟极性
      parameter  CPHL            =1'b1  ,  //spi的时钟相位
      parameter  READ_DATA_WITH  =29    ,  //读数据的位宽
      parameter  WAIT_TIME       =20       //读数据时两个阶段的等待时间（最小单位为SCLK的时钟周期）
) 
(
      input  rst_n                              ,   //系统复位信号
      input  clk                                ,   //系统时钟信号
      input  wr_req                             ,   //写请求信号
      input  rd_req                             ,   //读请求信号
      input  [DATA_WITH-1:0]   data             ,   //写入的数据
      output wire ready                         ,   //spi总线准备好信号
      output wire sync                          ,   //spi帧同步信号
      output wire sclk                          ,   //spi总线的时钟信号
      output wire sdi                           ,   //从器件输入数据的信号
      output wr_done                            ,
      output rd_done                            , 
      input  sdo                                 ,   //从从器件回读数据的信号
      input  sdo_b                               ,
      output wire [READ_DATA_WITH-1:0]rd_data    ,   //从从器件中读取的数据
      output wire [READ_DATA_WITH-1:0]rd_data_b  ,   
      output wire rd_data_vld                      //从从器件中读取的数据有效信号
);
                     
generate 
if(CPHL==0) begin
   spi_drive_cphl0 #(
                 .DIVIDE          ( DIVIDE          ),  
                 .DATA_WITH       ( DATA_WITH       ),  
                 .CPOL            (  CPOL           ),  
                 .READ_DATA_WITH  (  READ_DATA_WITH ),   
                 .WAIT_TIME       (  WAIT_TIME      ) 
                   )
   u_spi_drive_cphl0 (
                .rst_n    (   rst_n       )       ,   
                .clk      (   clk         )       ,  
                .wr_req   (  wr_req       )       ,  
                .rd_req   (  rd_req       )       ,   
                .data     (   data        )       ,   
                .ready    (  ready        )       ,  
                .wr_done  (  wr_done      )       ,
                .rd_done  (  rd_done      )       , 
                .sync     (  sync         )       , 
                .sclk     (  sclk         )       ,   
                .sdi      (   sdi         )       ,   
                .sdo      (   sdo         )       ,  
                .sdo_b    (   sdo_b       )       ,
                .rd_data  (   rd_data     )       ,   
                .rd_data_b(   rd_data_b   )       ,
                .rd_data_vld( rd_data_vld )           
       );
 end 
 else  begin    
  spi_drive_cphl1#(
               .DIVIDE          ( DIVIDE          ),  
               .DATA_WITH       ( DATA_WITH       ), 
               .CPOL            (  CPOL           ),  
               .READ_DATA_WITH  (  READ_DATA_WITH ),   
               .WAIT_TIME       (  WAIT_TIME      )
                )
   u_spi_drive_cphl1(
                .rst_n    (   rst_n       )       ,   
                .clk      (   clk         )       ,   
                .wr_req   (  wr_req       )       ,   
                .rd_req   (  rd_req       )       ,   
                .data     (   data        )       ,  
                .ready    (  ready        )       ,   
                .wr_done  (  wr_done      )       ,
                .rd_done  (  rd_done      )       , 
                .sync     (  sync         )       ,   
                .sclk     (  sclk         )       ,  
                .sdi      (  sdi          )       ,  
                .sdo      (  sdo          )       ,   
                .sdo_b    (  sdo_b        )       , 
                .rd_data  (  rd_data      )       ,   
                .rd_data_b(   rd_data_b   )       ,
                .rd_data_vld( rd_data_vld  )                
       );      
 end
endgenerate
endmodule