module  spi_drive_top  #(
      parameter  DIVIDE          = 2    ,  //ʱ�ӵķ�Ƶϵ��
      parameter  DATA_WITH       =29    ,  //�������ݵ�λ��
      parameter  CPOL            =1'b0  ,  //spi��ʱ�Ӽ���
      parameter  CPHL            =1'b1  ,  //spi��ʱ����λ
      parameter  READ_DATA_WITH  =29    ,  //�����ݵ�λ��
      parameter  WAIT_TIME       =20       //������ʱ�����׶εĵȴ�ʱ�䣨��С��λΪSCLK��ʱ�����ڣ�
) 
(
      input  rst_n                              ,   //ϵͳ��λ�ź�
      input  clk                                ,   //ϵͳʱ���ź�
      input  wr_req                             ,   //д�����ź�
      input  rd_req                             ,   //�������ź�
      input  [DATA_WITH-1:0]   data             ,   //д�������
      output wire ready                         ,   //spi����׼�����ź�
      output wire sync                          ,   //spi֡ͬ���ź�
      output wire sclk                          ,   //spi���ߵ�ʱ���ź�
      output wire sdi                           ,   //�������������ݵ��ź�
      output wr_done                            ,
      output rd_done                            , 
      input  sdo                                 ,   //�Ӵ������ض����ݵ��ź�
      input  sdo_b                               ,
      output wire [READ_DATA_WITH-1:0]rd_data    ,   //�Ӵ������ж�ȡ������
      output wire [READ_DATA_WITH-1:0]rd_data_b  ,   
      output wire rd_data_vld                      //�Ӵ������ж�ȡ��������Ч�ź�
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