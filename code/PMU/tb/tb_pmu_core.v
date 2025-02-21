`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2024-08-29
// Module Name           : tb_pmu_core
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

module tb_pmu_core();

// Parameters
localparam  PMU_TIME_DW     = 15;
localparam  PMU_TEST_NUM_DW = 16;
localparam  SYS_MOD_DW      = 3 ;
localparam  PMU_MOD_DW      = 3 ;
localparam  PMU_VLU_DW      = 3 ;
localparam  PMU_VI_DW       = 26;
localparam  CH_NUM          = 4 ;
localparam  SMP_DW          = 16;
localparam  AXIS_FIFO_DW    = 32;
localparam  MA_RESULT_DW    = 26;
localparam  AD5522_DFX_DW   = 2 ;
localparam  PMU_SMP_WAIT_DW = 16;

//Ports
reg                       clk              ;
reg                       rst              ;
reg [PMU_TIME_DW-1:0]     cfg_pmu_time     ;
reg [PMU_SMP_WAIT_DW-1:0] cfg_pmu_smp_wait_time;
reg [PMU_TEST_NUM_DW-1:0] cfg_pmu_test_num ;
reg [CH_NUM-1:0]          cfg_pmu_ch_en    ;
reg [SYS_MOD_DW-1:0]      cfg_sys_work_mode;
reg [PMU_MOD_DW-1:0]      cfg_pmu_test_mode;
reg [PMU_VLU_DW-1:0]      cfg_pmu_cur_value;
reg [PMU_VI_DW-1:0]       cfg_pmu_vol_value;
reg [CH_NUM-1:0]          cfg_pmu_cmp_en   ;
reg                       cfg_pmu_cmp_type ;
reg [PMU_VI_DW-1:0]       cfg_pmu_cmp_h    ;
reg [PMU_VI_DW-1:0]       cfg_pmu_cmp_l    ;
reg [CH_NUM-1:0]          cfg_pmu_clamp_en ;
reg [PMU_VI_DW-1:0]       cfg_pmu_clamp_h  ;
reg [PMU_VI_DW-1:0]       cfg_pmu_clamp_l  ;
reg [PMU_VI_DW-1:0]       cfg_pmu_vchk     ;
reg [PMU_VI_DW-1:0]       cfg_pmu_ichk     ;
reg                       cfg_pmu_mean_en  ;
reg                       pmu_work_start   ;
wire                      pmu_busy         ;
reg                       pmu_rd_start     ='d0;
reg                       ad5522_warn_clear;
wire                      pmu_drv_done     ;
reg [SMP_DW-1:0]          pmu_smp_dataa    = 'd0;
reg [SMP_DW-1:0]          pmu_smp_datab    = 'd0;
reg                       pmu_smp_data_vld = 'd0;
wire [AXIS_FIFO_DW-1:0]   pl_rd_data       ;
wire                      pl_rd_data_vld   ;
wire                      pl_rd_en         ;
wire                      packet_done      ;
wire                      pmu_pck_start    ;
wire                      pmu_spi_clk      ;
wire                      pmu_spi_csn      ;
reg                       pmu_spi_sdi      = 'd0;
wire                      pmu_spi_sdo      ;
wire                      pmu_spi_lvds     ;
reg                       pmu_busyn        ='d1;
reg                       pmu_cgalm        ;
reg                       pmu_tmpn         ;
wire                      pmu_rstn         ;
wire [AD5522_DFX_DW-1:0]  dfx_ad5522_warn  ;
reg  [1:0]                cfg_data_type = 'd1;

pmu_core # (
  .PMU_TIME_DW    (PMU_TIME_DW    ),
  .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW),
  .DATA_TYPE_WIDTH(2),
  .SYS_MOD_DW     (SYS_MOD_DW     ),
  .PMU_MOD_DW     (PMU_MOD_DW     ),
  .PMU_VLU_DW     (PMU_VLU_DW     ),
  .PMU_VI_DW      (PMU_VI_DW      ),
  .CH_NUM         (CH_NUM         ),
  .SMP_DW         (SMP_DW         ),
  .AXIS_FIFO_DW   (AXIS_FIFO_DW   ),
  .MA_RESULT_DW   (MA_RESULT_DW   ),
  .PMU_SMP_WAIT_DW(PMU_SMP_WAIT_DW),
  .AD5522_DFX_DW  (AD5522_DFX_DW  )
)
pmu_core_inst (
  .clk              (clk              ),
  .rst              (rst              ),
  .cfg_pmu_time     (cfg_pmu_time     ),
  .cfg_pmu_smp_wait_time(cfg_pmu_smp_wait_time),
  .cfg_pmu_test_num (cfg_pmu_test_num ),
  .cfg_pmu_ch_en    (cfg_pmu_ch_en    ),
  .cfg_sys_work_mode(cfg_sys_work_mode),
  .cfg_pmu_test_mode(cfg_pmu_test_mode),
  .cfg_pmu_cur_value(cfg_pmu_cur_value),
  //.cfg_pmu_vol_value(cfg_pmu_vol_value),
  .cfg_pmu_ch0_value(cfg_pmu_vol_value),
  .cfg_pmu_ch1_value(cfg_pmu_vol_value),
  .cfg_pmu_ch2_value(cfg_pmu_vol_value),
  .cfg_pmu_ch3_value(cfg_pmu_vol_value),  
  .cfg_pmu_cmp_en   (cfg_pmu_cmp_en   ),
  .cfg_pmu_cmp_type (cfg_pmu_cmp_type ),
  .cfg_pmu_cmp_h    (cfg_pmu_cmp_h    ),
  .cfg_pmu_cmp_l    (cfg_pmu_cmp_l    ),
  .cfg_pmu_clamp_en (cfg_pmu_clamp_en ),
  .cfg_pmu_clamp_h  (cfg_pmu_clamp_h  ),
  .cfg_pmu_clamp_l  (cfg_pmu_clamp_l  ),
  .cfg_pmu_vchk     (cfg_pmu_vchk     ),
  .cfg_pmu_ichk     (cfg_pmu_ichk     ),
  .cfg_pmu_store_en  (cfg_pmu_mean_en  ),
  .cfg_data_type    (cfg_data_type    ),     // I , DATA_TYPE_WIDTH bit 
  .cfg_pmu_close_time('d100),
  .cfg_pmu_cmp_orgh ('d1  ),    // I , PMU_VI_DW bit
  .cfg_pmu_cmp_orgl ('d0  ),    // I , PMU_VI_DW bit
  .pmu_work_start   (pmu_work_start   ),
  .pmu_busy         (pmu_busy         ),
  .pmu_rd_start     (pmu_rd_start     ),
  .ad5522_warn_clear(ad5522_warn_clear),
  //.pmu_drv_done     (pmu_drv_done     ),
  .adc_ready        ('d1              ),
  .pmu_smp_start    (pmu_smp_start    ),
  .pmu_smp_dataa    (pmu_smp_dataa    ),
  .pmu_smp_datab    (pmu_smp_datab    ),
  .pmu_smp_data_vld (pmu_smp_data_vld ),
  .pl_rd_data       (pl_rd_data       ),
  .pl_rd_data_vld   (pl_rd_data_vld   ),
  .pl_rd_en         (pl_rd_en         ),
  .pmu_pck_start    (pmu_pck_start    ),
  .packet_done      (packet_done      ),
  .pmu_spi_clk      (pmu_spi_clk      ),
  .pmu_spi_csn      (pmu_spi_csn      ),
  .pmu_spi_sdi      (pmu_spi_sdi      ),
  .pmu_spi_sdo      (pmu_spi_sdo      ),
  .pmu_spi_lvds     (pmu_spi_lvds     ),
  .pmu_busyn        (pmu_busyn        ),
  .pmu_cgalm        (pmu_cgalm        ),
  .pmu_tmpn         (pmu_tmpn         ),
  .pmu_rstn         (pmu_rstn         ),
  .dfx_ad5522_warn  (dfx_ad5522_warn  )
);


  localparam  DATA_TYPE_WIDTH = 2;

  reg  [PMU_TEST_NUM_DW-1:0] cfg_data_num = 'd0;
  wire [AXIS_FIFO_DW-1:0]    axis_fifo_wr_data;
  wire                       axis_fifo_last;
  wire                       axis_fifo_valid;

  axis_data_fifo_ctrl # (
    .DW             (AXIS_FIFO_DW   ),
    .DATA_TYPE_WIDTH(DATA_TYPE_WIDTH),
    .PMU_TEST_NUM_DW(PMU_TEST_NUM_DW)
  )
  axis_data_fifo_ctrl_inst (
    .clk              (clk              ),
    .rst              (rst              ),
    .packet_start     (pmu_pck_start     ),
    .packet_done      (packet_done      ),
    .data_type        ('d0        ),
    .cfg_data_num     (cfg_data_num     ),
    .axis_fifo_wr_data(axis_fifo_wr_data),
    .axis_fifo_last   (axis_fifo_last   ),
    .axis_fifo_ready  ('d1  ),
    .axis_fifo_valid  (axis_fifo_valid  ),
    .pl_rd_data       (pl_rd_data       ),
    .pl_rd_data_vld   (pl_rd_data_vld   ),
    .pl_rd_en         (pl_rd_en         )
  );

  always @(posedge clk) 
  begin
    if(cfg_data_type == 'd0)
    begin
      cfg_data_num <= CH_NUM; 
    end
    else
    begin
      cfg_data_num <= cfg_pmu_test_num << 2;  
    end    
  end

//===========================clk & rst gen======================
initial 
begin
  clk = 'd0;  
  forever #5  clk = ! clk ;
end

initial 
begin
  rst = 'd0;  
end

initial 
begin
    cfg_pmu_time      = 'd0;
    cfg_pmu_test_num  = 'd0;
    cfg_pmu_ch_en     = 'd0;
    cfg_sys_work_mode = 'd0;
    cfg_pmu_test_mode = 'd0;
    cfg_pmu_cur_value = 'd0;
    cfg_pmu_vol_value = 'd0;
    cfg_pmu_cmp_en    = 'd0;
    cfg_pmu_cmp_type  = 'd0;
    cfg_pmu_cmp_h     = 'd0;
    cfg_pmu_cmp_l     = 'd0;
    cfg_pmu_clamp_en  = 'd0;
    cfg_pmu_clamp_h   = 'd0;
    cfg_pmu_clamp_l   = 'd0;
    cfg_pmu_vchk      = 'd0;
    cfg_pmu_ichk      = 'd0;
    cfg_pmu_mean_en   = 'd0;
    pmu_work_start    = 'd0;
    cfg_pmu_smp_wait_time = 'd0;
    //set cfg
    #10 cfg_pmu_time      = 'd10;     //10us
    #10 cfg_pmu_smp_wait_time = 'd500;
    #10 cfg_pmu_test_num  = 'd10;
    #10 cfg_pmu_ch_en     = 4'b0001;
    #10 cfg_pmu_test_mode = 'd0;
    #10 cfg_pmu_cur_value = 'd4;
    #10 cfg_pmu_vol_value = 'd5000000;
    #10 cfg_pmu_mean_en   = 'd0;
    #10 cfg_pmu_clamp_en  = 'd1;
    #10 cfg_pmu_clamp_h   = 'h2dc6c0;
    #10 cfg_pmu_clamp_l   = 'h3ff8ad0;
    #10 cfg_pmu_cmp_en    = 'd1;
    #10 cfg_pmu_cmp_type  = 'd1;
    #10 cfg_pmu_cmp_h     = 'h2dc6c0;
    #10 cfg_pmu_cmp_l     = 'h1e8480;
    #10 cfg_data_type     = 'd0     ;
    //start
    #15 pmu_work_start    = 'd1;
    #10 pmu_work_start    = 'd0;
    //#7930 rst              = 'd1;
    //#10 rst               = 'd0;
    //    pmu_busyn         = 'd0;
    //#100 pmu_busyn        = 'd1;    
    //#100 pmu_work_start   = 'd1;
    //#10 pmu_work_start    = 'd0;
    //#10   cfg_data_type   = 'd0;
   // #9000 pmu_rd_start    = 'd1;
   // #10 pmu_rd_start    = 'd0;
end

always @(posedge clk) 
begin
  pmu_spi_sdi <= pmu_spi_sdo;
end
//initial 
//begin
//    pmu_smp_dataa    <= 'd0;
//    pmu_smp_datab    <= 'd0;
//    pmu_smp_data_vld <= 'd0;
//end

reg[3:0] smp_cnt = 'd0;

reg pmu_drv_done_d1 = 'd0;
reg pmu_drv_done_d2 = 'd0;
reg pmu_drv_done_d3 = 'd0;

always @(posedge clk) 
begin
  pmu_drv_done_d3 <= pmu_drv_done_d2;
  pmu_drv_done_d2 <= pmu_drv_done_d1;
  pmu_drv_done_d1 <= pmu_smp_start;
end

reg smp_flag = 'd0;
reg [3:0] wait_cnt = 'd0;

always @(posedge clk) 
begin
  if((smp_cnt == 'd7) || rst)
  begin
    smp_flag <= 'd0;
  end
  else if(pmu_drv_done_d3)
  begin
    smp_flag <= 'd1;
  end  
  else
  begin
    smp_flag <= smp_flag;
  end  
end

always @(posedge clk) 
begin
  if(!smp_flag)
  begin
    wait_cnt = 'd0;
  end
  else
  begin
    wait_cnt <= wait_cnt + 'd1;
  end  
end

always @(posedge clk) 
begin
  if(wait_cnt == 'hf)
  begin
    pmu_smp_data_vld <= 'd1;
  end  
  else
  begin
    pmu_smp_data_vld <= 'd0;
  end  
end

always @(posedge clk) 
begin
  if(smp_cnt == 'd7)
  begin
    smp_cnt <= 'd0;
  end
  else if(pmu_smp_data_vld)
  begin
    smp_cnt <= smp_cnt + 'd1;
  end  
  else
  begin
    smp_cnt <= smp_cnt;
  end  
end

reg [3:0] frm_cnt = 'd0;

always @(posedge clk) 
begin
  if(smp_cnt == 'd7)
  begin
    frm_cnt <= frm_cnt + 'd1;
  end  
  else
  begin
    frm_cnt <= frm_cnt;
  end  
end

always @(posedge clk) 
begin
  if(pmu_smp_data_vld)  
  begin
    pmu_smp_dataa <= smp_cnt + frm_cnt - 'd4;
    //pmu_smp_dataa <= 'd14619;
    //pmu_smp_datab <= smp_cnt + frm_cnt -'d4;
    pmu_smp_datab <= 'd9096;
  end
  else
  begin
    pmu_smp_dataa <= pmu_smp_dataa;
    pmu_smp_datab <= pmu_smp_datab;
  end  
end

//gen rd_start
reg rd_rdy = 'd0;
reg pmu_work_busy_d1 = 'd0;
wire pmu_work_busy_f;

always @(posedge clk) 
begin
  pmu_work_busy_d1 <= pmu_busy;    
end

assign pmu_work_busy_f = pmu_work_busy_d1 && (!pmu_busy);

always @(posedge clk) 
begin
  if(pmu_work_busy_f)
  begin
    rd_rdy <= 'd0;
  end
  else if(pmu_work_start)  
  begin
    rd_rdy <= 'd1;
  end
  else
  begin
    rd_rdy <= rd_rdy;
  end  
end

always @(posedge clk) 
begin
    pmu_rd_start <= rd_rdy && pmu_work_busy_f;
end

reg pmu_spi_csn_d1 = 'd0;
wire pmu_spi_csn_r;

always @(posedge clk) 
begin
  pmu_spi_csn_d1 <= pmu_spi_csn;
end

assign pmu_spi_csn_r = (!pmu_spi_csn) && pmu_spi_csn_d1;

reg [15:0] busy_cnt = 'd0;

always @(posedge clk) 
begin
  if(pmu_spi_csn_r)
  begin
    pmu_busyn <= 'd0;
  end
  else if(busy_cnt == 'd999)
  begin
    pmu_busyn <= 'd1;
  end  
  else
  begin
    pmu_busyn <= pmu_busyn;
  end  

end

always @(posedge clk) 
begin
  if(!pmu_busyn)
  begin
    busy_cnt <= busy_cnt + 'd1;
  end
  else
  begin
    busy_cnt <= 'd0;
  end  
end

endmodule