`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : zhengliqian
// 
// Create Date           : 2024-08-27
// Module Name           : pmu_drv
// Project Name          : HV
// Target Devices        : xc7z015
// Tool Versions         : Vivado 2020.2
// Description           : 
//                         1.The AD5522 registers are read and written using the spi interface
//                         2.gen ad5522 DFX signal
// Dependencies          : 
// 
// Revision              :
//                        Revision v0.01 - File Created
// Additional Comments   :
//                        1.AD5522 rd cmp reg's mod is 01;
//                        2.SPI clk is 50M,sys_clk is 100M;
//////////////////////////////////////////////////////////////////////////////////
module pmu_drv
#(
    parameter PMU_CFG_DW      = 29 ,
    parameter SPI_DIV         = 2  ,
    parameter SPI_CPO         = 0  ,
    parameter SPI_CPH         = 1  ,
    parameter AD5522_DFX_DW   = 2
) 
(
    input                          clk                     ,
    input                          rst                     ,
    //cmd & data
    input                          pmu_cfg_rd_req          ,
    output                         pmu_cfg_rd_done         ,
    input                          pmu_cfg_wr_req          ,     
    output                         pmu_cfg_wr_done         ,
    input      [PMU_CFG_DW-1:0]    pmu_cfg_wr_data         ,
    output     [PMU_CFG_DW-1:0]    pmu_cmp_result          ,
    output                         pmu_cmp_result_vld      ,
    input                          ad5522_warn_clear       ,
    //pmu spi intf   
    (*mark_debug="true"*)(*keep="true"*)output                         pmu_spi_clk             ,
    (*mark_debug="true"*)(*keep="true"*)output                         pmu_spi_csn             ,
    (*mark_debug="true"*)(*keep="true"*)input                          pmu_spi_sdi             ,
    (*mark_debug="true"*)(*keep="true"*)output                         pmu_spi_sdo             ,
    (*mark_debug="true"*)(*keep="true"*)output                         pmu_spi_lvds            ,
    (*mark_debug="true"*)(*keep="true"*)input                          pmu_busyn               ,
    (*mark_debug="true"*)(*keep="true"*)input                          pmu_cgalm               ,
    (*mark_debug="true"*)(*keep="true"*)input                          pmu_tmpn                ,
    (*mark_debug="true"*)(*keep="true"*)output reg                     pmu_rstn          = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output                         pmu_loadn               ,
    (*mark_debug="true"*)(*keep="true"*)output reg                     ad5522_rst_busy   = 'd0 ,
    //DFX
    (*mark_debug="true"*)(*keep="true"*)output reg [AD5522_DFX_DW-1:0] dfx_ad5522_warn   = 'd0 ,
    (*mark_debug="true"*)(*keep="true"*)output reg                     dfx_cmp_err       = 'd0     
);

localparam PMU_RD_WAIT       = 21                        ;
localparam CMP_REG_MODE0_BIT = 22                        ;
localparam CMP_REG_MODE1_BIT = 23                        ;
localparam CMP_MODE          = 2'b01                     ;
localparam AD5522_RST_TIME   = 400                       ; //4us in 100M sys_clk
localparam RST_CNT_DW        = $clog2(AD5522_RST_TIME)+1 ;

assign pmu_spi_lvds = 'd0 ;  //use spi intf to cfg
assign pmu_loadn    = 'd0 ;  //cfg active after wr
//gen ad5522 rst
(*mark_debug="true"*)(*keep="true"*)reg [RST_CNT_DW-1:0] pmu_rst_cnt = 'd0;

wire pmu_rst;
reg pmu_rst_d1 = 'd0;
wire pmu_rst_r;

vio_0 u_pmu_rst (
  .clk(clk),                // input wire clk
  .probe_out0(pmu_rst)  // output wire [0 : 0] probe_out0
);

always @(posedge clk) 
begin
  pmu_rst_d1 <= pmu_rst;
end

assign pmu_rst_r = pmu_rst && (!pmu_rst_d1);

always @(posedge clk) 
begin
  if(rst || pmu_rst_r)
  begin
    pmu_rstn <= 'd0;
  end
  else if(pmu_rst_cnt == AD5522_RST_TIME-1)
  begin
    pmu_rstn <= 'd1;
  end  
  else
  begin
    pmu_rstn <= pmu_rstn;
  end  
end

always @(posedge clk) 
begin
  if(!pmu_rstn)
  begin
    pmu_rst_cnt <= pmu_rst_cnt + 'd1;
  end
  else
  begin
    pmu_rst_cnt <= 'd0;
  end  
end

//gen rst_busy
(*mark_debug="true"*)(*keep="true"*)reg  pmu_busyn_d1 = 'd0;
reg  pmu_busyn_d2 = 'd0;
reg  pmu_busyn_d3 = 'd0;
reg  pmu_busyn_d4 = 'd0;
(*mark_debug="true"*)(*keep="true"*)wire pmu_busyn_r       ;

always @(posedge clk) 
begin
  pmu_busyn_d1 <= pmu_busyn;
  pmu_busyn_d2 <= pmu_busyn_d1;
  pmu_busyn_d3 <= pmu_busyn_d2;
  pmu_busyn_d4 <= pmu_busyn_d3;
end

assign pmu_busyn_r = (!pmu_busyn_d4) && pmu_busyn_d3;

always @(posedge clk) 
begin
  if(rst)
  begin
    ad5522_rst_busy <= 'd1;
  end
  else if(pmu_busyn_r)
  begin
    ad5522_rst_busy <= 'd0;
  end
  else
  begin
    ad5522_rst_busy <= ad5522_rst_busy;
  end  
end

//=============================DFX==============================
always @(posedge clk) 
begin
  if(rst || pmu_cfg_rd_req)
  begin
    dfx_cmp_err <= 'd0;
  end  
  else if(pmu_cmp_result_vld && (pmu_cmp_result[CMP_REG_MODE1_BIT:CMP_REG_MODE0_BIT] != CMP_MODE))
  begin
    dfx_cmp_err <= 'd1;  
  end
  else
  begin
    dfx_cmp_err <= dfx_cmp_err;
  end   
end

//assign dfx_ad5522_warn = {~pmu_tmpn,~pmu_cgalm};

always @(posedge clk) 
begin
  if(ad5522_warn_clear)
  begin
    dfx_ad5522_warn <= 'd0;
  end
  else
  begin
    dfx_ad5522_warn <= (!pmu_tmpn) || (!pmu_cgalm);
  end  
end

//===============================spi intf========================
spi_drive_top #(
  .DIVIDE          (  SPI_DIV           ),
  .DATA_WITH       (  PMU_CFG_DW        ), 
  .CPOL            (  SPI_CPO           ), 
  .CPHL            (  SPI_CPH           ), 
  .READ_DATA_WITH  (  PMU_CFG_DW        ),    
  .WAIT_TIME       (  PMU_RD_WAIT       )
)
u_spi_drive_top(
  .rst_n           ( ~rst                  ),  //I,1 bit    
  .clk             ( clk                   ),  //I,1 bit    
  .wr_req          ( pmu_cfg_wr_req        ),  //I,1 bit    
  .rd_req          ( pmu_cfg_rd_req        ),  //I,1 bit    
  .data            ( pmu_cfg_wr_data       ),  //I,PMU_CFG_DW bit    
  .ready           ( spi_ready             ),  //O,1 bit   
  .wr_done         ( pmu_cfg_wr_done       ),  //O,1 bit
  .rd_done         ( pmu_cfg_rd_done       ),  //O,1 bit   
  .sync            ( pmu_spi_csn           ),  //O,1 bit    
  .sclk            ( pmu_spi_clk           ),  //O,1 bit    
  .sdi             ( pmu_spi_sdo           ),  //O,1 bit    
  .sdo             ( pmu_spi_sdi           ),  //I,1 bit    
  .sdo_b           ( 'd0                   ),  //I,1 bit   
  .rd_data         ( pmu_cmp_result        ),  //O,PMU_CFG_DW bit    
  .rd_data_b       (                       ),  //O,PMU_CFG_DW bit    
  .rd_data_vld     ( pmu_cmp_result_vld    )   //O,1 bit    
 );
    
endmodule