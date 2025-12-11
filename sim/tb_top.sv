`timescale 1ns/1ps

module tb_top();

// 
parameter CFG_AW            = 32;
parameter CFG_DW            = 32;
parameter DATA_NUM_DW       = 32;   
parameter DDR_AW            = 29;   
parameter DATA_TYPE_DW      = 2;
parameter MEM_COPR_DW       = 2;
parameter PC_DW             = 14;
parameter FBC_SUM_DW        = PC_DW + 3;
parameter DUT_NUM           = 16;
parameter MOD_DW            = 2; 
parameter MSKTB_DW          = 8;
parameter X_AW              = 15;
parameter Y_AW              = 13;
parameter Z_AW              = 11;
parameter TP_DW             = 32;
parameter MSTA_DW           = 23;
parameter PSTA_DW           = 22;
parameter AS_NUM            = 8;
parameter FMT_NUM           = 9;
parameter INDX_DW           = 32;
parameter REG_NUM0          = 8;
parameter REG_NUM1          = 16;
parameter REG_NUM2          = 32;
parameter REG_DW            = 32;
parameter RATE_DW           = 22;
parameter AS_DW             = 24;
parameter AFM_DW            = 24;
parameter AFM_NUM           = 6;
parameter GT_LANE_DW        = 32;
parameter PROTCL_LEN        = 5;
parameter IDX_DW            = 32;
parameter REG_NUM           = 16;
parameter PRE_PAT_TIME      = 10;
parameter PRE_PAT_CNT       = 50;

// 
reg sys_clk;
reg sys_rst;
reg gt_usrclk;

// 
reg alpg_work_busy;
wire alpg_cfg_send_start;
reg [CFG_AW-1:0] gtx_cfg_addr;
reg [CFG_DW-1:0] gtx_cfg_data;
reg gtx_cfg_vld;

// 
wire [CFG_AW-1:0] gtp_cfg_addr;
wire [CFG_DW-1:0] gtp_cfg_data;
wire              alpg_wr_start;
wire              alpg_rd_start;
wire              alpg_mem_rst;
wire              alpg_mem_copy;
wire              alpg_start;
wire              alpg_restart;
wire              alpg_stop;

wire [DDR_AW-1:0]       cfg_alpg_base_addr;
wire [DATA_NUM_DW-1:0]  cfg_alpg_data_num;
wire [DATA_TYPE_DW-1:0] cfg_alpg_data_type;
wire [MEM_COPR_DW-1:0]  cfg_alpg_mem_copr;
wire [DDR_AW-1:0]       cfg_alpg_addr_d0;
wire [DDR_AW-1:0]       cfg_alpg_addr_d1;
wire [DDR_AW-1:0]       cfg_alpg_addr_p;
wire [DATA_NUM_DW-1:0]  cfg_alpg_mem_size;
wire [PC_DW-1:0]        alpg_start_pc;
wire [MOD_DW-1:0]       cfg_alpg_run_mod;
wire [MOD_DW-1:0]       cfg_alpg_idx_mod;
wire [MSKTB_DW-1:0]     cfg_alpg_msktb;
wire [X_AW-1:0]         cfg_alpg_x;
wire [Y_AW-1:0]         cfg_alpg_y;
wire [Z_AW-1:0]         cfg_alpg_z;
wire [X_AW-1:0]         cfg_alpg_x_max;
wire [Y_AW-1:0]         cfg_alpg_y_max;
wire [Z_AW-1:0]         cfg_alpg_z_max;
wire [TP_DW-1:0]        cfg_alpg_tp;
wire [REG_NUM1-1:0]     cfg_alpg_cflg;
wire                    cfg_alpg_me;
wire [PSTA_DW-1:0]      cfg_alpg_psta;
wire [MSTA_DW-1:0]      cfg_alpg_msta;
wire [FMT_NUM-1:0]      cfg_alpg_fmt_c0;
wire [FMT_NUM-1:0]      cfg_alpg_fmt_c1;
wire [FMT_NUM-1:0]      cfg_alpg_fmt_d0;

// 
reg [PC_DW-1:0] alpg_end_pc;
reg [FBC_SUM_DW*DUT_NUM-1:0] alpg_fbc_dut_bus;
reg alpg_fsr;
reg alpg_mflg;

// CFG
wire [IDX_DW*REG_NUM-1:0] cfg_alpg_indx_bus;

// GT
reg                    rx_data_sof;
reg                    rx_data_eof;
reg [GT_LANE_DW-1:0]   gt_rx_data2;
reg [GT_LANE_DW-1:0]   gt_rx_data3;
reg                    gt_rx_data_vld;

// 
reg                    mflg_reg;
reg                    clk_base;
reg [159:0] mem [0:170];
reg [13:0] pattern_wr_addr;
reg pattern_wr_en;
reg  [159:0]     pattern_wr_data;
// 
wire                   [PROTCL_LEN * GT_LANE_DW-1:0]pat_func_data              ;
wire                                    pat_func_data_vld          ;
wire                                    dfx_pattern_func           ;
wire                   [TP_DW*REG_NUM2-1:0]cfg_alpg_tph_bus           ;
wire                   [TP_DW*REG_NUM1-1:0]cfg_alpg_dreg_bus          ;
wire                   [MSTA_DW*REG_NUM0-1:0]cfg_alpg_qreg_bus          ;
wire                   [PSTA_DW*REG_NUM0-1:0]cfg_alpg_preg_bus          ;
wire                   [AS_DW*REG_NUM0-1:0]cfg_alpg_ash_bus           ;
wire                   [AS_DW*REG_NUM0-1:0]cfg_alpg_asl_bus           ;
wire                   [PC_DW-1:0]      cfg_alpg_bar               ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_rate_bus          ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_aclk1_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_aclk2_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_aclk3_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_bclk1_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_bclk2_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_bclk3_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_cclk1_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_cclk2_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_cclk3_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_dre_r_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_dre_f_bus         ;
wire                   [RATE_DW*REG_NUM0-1:0]cfg_alpg_strb_bus          ;
wire                   [AFM_DW*AFM_NUM-1:0]cfg_alpg_afm_bus           ;
//
localparam ADDR_ALPG_WR_START = 'h0414;
localparam ADDR_ALPG_RD_START = 'h0418;
localparam ADDR_ALPG_BASE_ADD = 'h041c;
localparam ADDR_ALPG_DATA_NUM = 'h0420;
localparam ADDR_ALPG_DATA_TYPE= 'h0424;
localparam ADDR_ALPG_MEM_RST  = 'h0428;
localparam ADDR_ALPG_MEM_COPY = 'h042c;
localparam ADDR_ALPG_MEM_COPR = 'h0430;
localparam ADDR_ALPG_ADDR_D0  = 'h0434;
localparam ADDR_ALPG_ADDR_D1  = 'h0438;
localparam ADDR_ALPG_ADDR_P   = 'h043c;
localparam ADDR_ALPG_MEM_SIZE = 'h0440;
localparam ADDR_ALPG_START    = 'h0444;
localparam ADDR_ALPG_RESTART  = 'h0448;
localparam ADDR_ALPG_STOP     = 'h044c;
localparam ADDR_ALPG_START_PC = 'h0450;
localparam ADDR_ALPG_RUN_MOD  = 'h04a0;
localparam ADDR_ALPG_IDX_MOD  = 'h04a4;
localparam ADDR_ALPG_MSKSTB   = 'h04a8;
localparam ADDR_ALPG_X        = 'h04ac;
localparam ADDR_ALPG_Y        = 'h04b0;
localparam ADDR_ALPG_Z        = 'h04b4;
localparam ADDR_ALPG_XMAX     = 'h04b8;
localparam ADDR_ALPG_YMAX     = 'h04bc;
localparam ADDR_ALPG_ZMAX     = 'h04c0;
localparam ADDR_ALPG_TP       = 'h04c4;
localparam ADDR_ALPG_CFLAG    = 'h04c8;
localparam ADDR_ALPG_ME       = 'h04cc;
localparam ADDR_ALPG_PSTA     = 'h04d0;
localparam ADDR_ALPG_MSTA     = 'h04d4;
localparam ADDR_ALPG_FMT_C0   = 'h04e0;
localparam ADDR_ALPG_FMT_C1   = 'h04e4;
localparam ADDR_ALPG_FMT_D0   = 'h04e8;

// 
always #2.5 sys_clk     = ~sys_clk    ;     // 200MHz
always #10   gt_usrclk   = ~gt_usrclk  ;     // 50MHz
always #25  clk_base    = ~clk_base   ;     // 20MHz
wire init_start;
wire init_done ;
reg read_finish;
wire [1:0]pre_type;
wire[  31:0]         pattern_rd_data_cnt    ;
wire[  31:0]         pattern_rd_cnt         ;

// 
alpg_cfg_core # (
  .CFG_AW        (CFG_AW         ),
  .CFG_DW        (CFG_DW         ),
  .DATA_NUM_DW   (DATA_NUM_DW    ),
  .DDR_AW        (DDR_AW         ),
  .DATA_TYPE_DW  (DATA_TYPE_DW   ),
  .MEM_COPR_DW   (MEM_COPR_DW    ),
  .PC_DW         (PC_DW          ),
  .FBC_SUM_DW    (FBC_SUM_DW     ),
  .DUT_NUM       (DUT_NUM        ),
  .MOD_DW        (MOD_DW         ),
  .MSKTB_DW      (MSKTB_DW       ),
  .X_AW          (X_AW           ),
  .Y_AW          (Y_AW           ),
  .Z_AW          (Z_AW           ),
  .TP_DW         (TP_DW          ),
  .MSTA_DW       (MSTA_DW        ),
  .PSTA_DW       (PSTA_DW        ),
  .AS_NUM        (AS_NUM         ),
  .FMT_NUM       (FMT_NUM        ),
  .INDX_DW       (INDX_DW        ),
  .REG_NUM0      (REG_NUM0       ),
  .REG_NUM1      (REG_NUM1       ),
  .REG_NUM2      (REG_NUM2       ),
  .REG_DW        (REG_DW         ),
  .RATE_DW       (RATE_DW        ),
  .AS_DW         (AS_DW          ),
  .AFM_DW        (AFM_DW         ),
  .AFM_NUM       (AFM_NUM        )
)
alpg_cfg_core_inst (
  .clk                   (sys_clk                    ),
  .rst                   (sys_rst                    ),
  .alpg_work_busy        (alpg_work_busy             ),
  .alpg_cfg_send_start   (alpg_cfg_send_start        ),
  .gt_clk                (gt_usrclk                  ),
  .gtx_cfg_addr          (gtx_cfg_addr               ),
  .gtx_cfg_data          (gtx_cfg_data               ),
  .gtx_cfg_vld           (gtx_cfg_vld                ),
  .gtp_cfg_addr          (gtp_cfg_addr               ),
  .gtp_cfg_data          (gtp_cfg_data               ),
  .alpg_wr_start         (alpg_wr_start              ),
  .alpg_rd_start         (alpg_rd_start              ),
  .alpg_mem_rst          (alpg_mem_rst               ),
  .alpg_mem_copy         (alpg_mem_copy              ),
  .alpg_start            (alpg_start                 ),
  .alpg_restart          (alpg_restart               ),
  .alpg_stop             (alpg_stop                  ),
  .cfg_alpg_base_addr    (cfg_alpg_base_addr         ),
  .cfg_alpg_data_num     (cfg_alpg_data_num          ),
  .cfg_alpg_data_type    (cfg_alpg_data_type         ),
  .cfg_alpg_mem_copr     (cfg_alpg_mem_copr          ),
  .cfg_alpg_addr_d0      (cfg_alpg_addr_d0           ),
  .cfg_alpg_addr_d1      (cfg_alpg_addr_d1           ),
  .cfg_alpg_addr_p       (cfg_alpg_addr_p            ),
  .cfg_alpg_mem_size     (cfg_alpg_mem_size          ),
  .alpg_start_pc         (alpg_start_pc              ),
  .cfg_alpg_run_mod      (cfg_alpg_run_mod           ),
  .cfg_alpg_idx_mod      (cfg_alpg_idx_mod           ),
  .cfg_alpg_msktb        (cfg_alpg_msktb             ),
  .cfg_alpg_x            (cfg_alpg_x                 ),
  .cfg_alpg_y            (cfg_alpg_y                 ),
  .cfg_alpg_z            (cfg_alpg_z                 ),
  .cfg_alpg_x_max        (cfg_alpg_x_max             ),
  .cfg_alpg_y_max        (cfg_alpg_y_max             ),
  .cfg_alpg_z_max        (cfg_alpg_z_max             ),
  .cfg_alpg_tp           (cfg_alpg_tp                ),
  .cfg_alpg_cflg         (cfg_alpg_cflg              ),
  .cfg_alpg_me           (cfg_alpg_me                ),
  .cfg_alpg_psta         (cfg_alpg_psta              ),
  .cfg_alpg_msta         (cfg_alpg_msta              ),
  .cfg_alpg_indx_bus     (cfg_alpg_indx_bus          ),
  .cfg_alpg_tph_bus      (cfg_alpg_tph_bus           ),
  .cfg_alpg_dreg_bus     (cfg_alpg_dreg_bus          ),
  .cfg_alpg_qreg_bus     (cfg_alpg_qreg_bus          ),
  .cfg_alpg_preg_bus     (cfg_alpg_preg_bus          ),
  .cfg_alpg_ash_bus      (cfg_alpg_ash_bus           ),
  .cfg_alpg_asl_bus      (cfg_alpg_asl_bus           ),
  .cfg_alpg_bar          (cfg_alpg_bar               ),
  .cfg_alpg_fmt_c0       (cfg_alpg_fmt_c0            ),
  .cfg_alpg_fmt_c1       (cfg_alpg_fmt_c1            ),
  .cfg_alpg_fmt_d0       (cfg_alpg_fmt_d0            ),
  .cfg_alpg_rate_bus     (cfg_alpg_rate_bus          ),
  .cfg_alpg_aclk1_bus    (cfg_alpg_aclk1_bus         ),
  .cfg_alpg_aclk2_bus    (cfg_alpg_aclk2_bus         ),
  .cfg_alpg_aclk3_bus    (cfg_alpg_aclk3_bus         ),
  .cfg_alpg_bclk1_bus    (cfg_alpg_bclk1_bus         ),
  .cfg_alpg_bclk2_bus    (cfg_alpg_bclk2_bus         ),
  .cfg_alpg_bclk3_bus    (cfg_alpg_bclk3_bus         ),
  .cfg_alpg_cclk1_bus    (cfg_alpg_cclk1_bus         ),
  .cfg_alpg_cclk2_bus    (cfg_alpg_cclk2_bus         ),
  .cfg_alpg_cclk3_bus    (cfg_alpg_cclk3_bus         ),
  .cfg_alpg_dre_r_bus    (cfg_alpg_dre_r_bus         ),
  .cfg_alpg_dre_f_bus    (cfg_alpg_dre_f_bus         ),
  .cfg_alpg_strb_bus     (cfg_alpg_strb_bus          ),
  .cfg_alpg_afm_bus      (cfg_alpg_afm_bus           ),
  .alpg_end_pc           (alpg_end_pc                ),
  .alpg_fbc_dut_bus      (alpg_fbc_dut_bus           ),
  .alpg_fsr              (alpg_fsr                   ),
  .alpg_mflg             (alpg_mflg                  )
);


integer i;
/********************************read patten**********************************/
//ĺĺ§ĺĺĺ­?
task PAT_LOAD;
    $readmemh("../examples/12-10-1/converted.log",mem);
    pattern_wr_addr = 0;
    pattern_wr_en = 0;
    #1000;
    for(i=0;i<170;i=i+1)begin
        @(posedge gt_usrclk);
        pattern_wr_data = mem[i]; 
        pattern_wr_en = 1;
        pattern_wr_addr = i;
    end
    #10;
    pattern_wr_en = 0;
    $display("load patten completed.");
endtask
/********************************read patten end**********************************/

// 
task write_cfg_reg;
    input [31:0] addr;
    input [31:0] data;
    begin
        @(posedge gt_usrclk);
        gtx_cfg_addr = addr;
        gtx_cfg_data = data;
        gtx_cfg_vld = 1'b1;
        @(posedge gt_usrclk);
        gtx_cfg_vld = 1'b0;
        #20; // 
    end
endtask

// 
task send_command;
    input [31:0] cmd_addr;
    begin
        write_cfg_reg(cmd_addr, 32'h1);
    end
endtask

// integer i;
initial begin
    read_finish ='d0;
    wait(tb_top.alpg_pat_pre_inst.alpg_pat_pre_task_inst.pattern_rd_data_cnt=='d1000);
    #1000;
    read_finish ='d1;
end

// 
initial begin
    // 
    sys_clk = 0;
    clk_base = 0;
    gt_usrclk = 0;
    sys_rst = 1;
    gtx_cfg_addr = 0;
    gtx_cfg_data = 0;
    gtx_cfg_vld = 0;
    alpg_end_pc = 0;
    alpg_fbc_dut_bus = 0;
    alpg_fsr = 0;
    alpg_mflg = 0;
    rx_data_sof = 0;
    rx_data_eof = 0;
    gt_rx_data2 = 0;
    gt_rx_data3 = 0;
    gt_rx_data_vld = 0;
    mflg_reg = 0;
    alpg_work_busy = 0;

    // 
    #100;
    sys_rst = 0;
    #300;
    
    $display("=== ALPG  ===");
    
    // 
    $display("1: ");
    write_cfg_reg(ADDR_ALPG_BASE_ADD, 32'h1000_0000);
    write_cfg_reg(ADDR_ALPG_DATA_NUM, 32'h0001_0000);
    write_cfg_reg(ADDR_ALPG_DATA_TYPE, 32'h2);
    write_cfg_reg(ADDR_ALPG_MEM_COPR, 32'h2);
    write_cfg_reg(ADDR_ALPG_ADDR_D0, 32'h2000_0000);
    write_cfg_reg(ADDR_ALPG_ADDR_D1, 32'h3000_0000);
    write_cfg_reg(ADDR_ALPG_ADDR_P, 32'h4000_0000);
    write_cfg_reg(ADDR_ALPG_MEM_SIZE, 32'h0000_1000);
    
    // 
    $display("2: ");
    write_cfg_reg(ADDR_ALPG_START_PC, 32'h0078);
    write_cfg_reg(ADDR_ALPG_RUN_MOD, 32'h1);
    write_cfg_reg(ADDR_ALPG_IDX_MOD, 32'h0);
    write_cfg_reg(ADDR_ALPG_MSKSTB, 32'hFF);
    write_cfg_reg(ADDR_ALPG_X, 32'h100);
    write_cfg_reg(ADDR_ALPG_Y, 32'h200);
    write_cfg_reg(ADDR_ALPG_Z, 32'h300);
    write_cfg_reg(ADDR_ALPG_XMAX, 32'h400);
    write_cfg_reg(ADDR_ALPG_YMAX, 32'h500);
    write_cfg_reg(ADDR_ALPG_ZMAX, 32'h600);
    write_cfg_reg(ADDR_ALPG_TP, 32'h1234_5678);
    write_cfg_reg(ADDR_ALPG_CFLAG, 32'hFFFF);
    write_cfg_reg(ADDR_ALPG_ME, 32'h1);
    write_cfg_reg(ADDR_ALPG_PSTA, 32'h3F_FFFF);
    write_cfg_reg(ADDR_ALPG_MSTA, 32'h7F_FFFF);
    
    // 
    $display("3: ");
    write_cfg_reg(ADDR_ALPG_FMT_C0, 32'h1FF);
    write_cfg_reg(ADDR_ALPG_FMT_C1, 32'h0FF);
    write_cfg_reg(ADDR_ALPG_FMT_D0, 32'h1AA);

    // GT
    // generate_gt_data_stream(10); // 10
    
    // 
    #500;
    
    $display("Test Case 1 completed.");

    // 
    $display("4: ");
    #100;
    PAT_LOAD;
    send_command(ADDR_ALPG_START);
    // send_command(ADDR_ALPG_WR_START);
    
    //// 
    //#200;
    //alpg_end_pc = 14'h03FF; // PC
    //
    ////    
    //for ( i = 0; i < DUT_NUM; i = i+1) begin
    //    alpg_fbc_dut_bus[i*FBC_SUM_DW +: FBC_SUM_DW] = i + 1;
    //end
    //
    //alpg_fsr = 1'b1;
    //alpg_mflg = 1'b0;
    //
    //// 5
    //$display("5: ");
    //send_command(ADDR_ALPG_RD_START);
    //
    ////
    //#100;
    //alpg_cfg_send_start = 1'b1;
    //#20;
    //alpg_cfg_send_start = 1'b0;
    //
    //// 6
    //$display("6: ");
    //send_command(ADDR_ALPG_WR_START);
    //send_command(ADDR_ALPG_MEM_RST);
    //send_command(ADDR_ALPG_MEM_COPY);
    //send_command(ADDR_ALPG_RESTART);
    //send_command(ADDR_ALPG_STOP);
    //
    //// ×´ĚŹ
    //#500;
    //alpg_work_busy = 0;
    
    // É˛
    //#1000;
    //$display("=== ALPG ĂşÄˇ ===");
    //$finish;
end

// 
initial begin
    $timeformat(-9, 3, " ns", 10);
    
    // 
    forever begin
        @(posedge alpg_wr_start) 
            $display("[%t]  alpg_wr_start ", $time);
        @(posedge alpg_rd_start) 
            $display("[%t]  alpg_rd_start ", $time);
        @(posedge alpg_mem_rst) 
            $display("[%t]  alpg_mem_rst ", $time);
        @(posedge alpg_mem_copy) 
            $display("[%t]  alpg_mem_copy ", $time);
        @(posedge alpg_start) 
            $display("[%t]  alpg_start ", $time);
        @(posedge alpg_restart) 
            $display("[%t]  alpg_restart ", $time);
        @(posedge alpg_stop) 
            $display("[%t]  alpg_stop ", $time);
    end
end

// 
initial begin
    forever begin
        @(posedge sys_clk);
        if (gtp_cfg_addr != 0 && gtp_cfg_data != 'hbfbfbfbf) begin
            $display("[%t] : addr=0x%h, data=0x%h", $time, gtp_cfg_addr, gtp_cfg_data);
        end
    end
end

//// 
//initial begin
//    $dumpfile("tb_alpg_cfg_core.vcd");
//    $dumpvars(0, tb_alpg_cfg_core);
//end


//// 
//initial begin
//    // 
//    initialize();
//    
//    // 
//    reset_system();
//    
//    // 
//    configure_module();
//    
//    // 1: 
//    test_case1();
//    
//    // 2: 
//    test_case2();
//    
//    // 3: 
//    test_case3();
//    
//    // 
//    #1000;
//    $display("Simulation completed successfully!");
//    $finish;
//end







//// 1: 
//task test_case1;
//begin
//    $display("Starting Test Case 1: Normal operation");
//    
//    // 
//    alpg_start = 1;
//    #20;
//    alpg_start = 0;
//    
//    // GT
//    generate_gt_data_stream(10); // 10
//    
//    // 
//    #500;
//    
//    $display("Test Case 1 completed.");
//end
//endtask
//
//// 2: 
//task test_case2;
//begin
//    $display("Starting Test Case 2: Restart test");
//    
//    // 
//    alpg_restart = 1;
//    #20;
//    alpg_restart = 0;
//    
//    // GT
//    generate_gt_data_stream(5); // 5
//    
//    // 
//    #300;
//    
//    $display("Test Case 2 completed.");
//end
//endtask
//
//// 3: 
//task test_case3;
//begin
//    $display("Starting Test Case 3: Invalid data test");
//    
//    // 
//    cfg_alpg_data_type = 2'b11; // 
//    
//    // 
//    generate_gt_data_stream(3);
//    
//    #200;
//    
//    //
//    cfg_alpg_data_type = 2'b10;
//    
//    $display("Test Case 3 completed.");
//end
//endtask

// GT
task generate_gt_data_stream;
input integer num_packets;
integer pkt, i;
begin
    for (pkt = 0; pkt < num_packets; pkt = pkt + 1) begin
        // 
        @(posedge gt_usrclk);
        rx_data_sof = 1;
        #8
        rx_data_sof = 0;
        #16
        gt_rx_data_vld = 1;
        gt_rx_data2 = 32'h0 + pkt;
        gt_rx_data3 = 32'h2 + pkt;
        
        
        for (i = 1; i < 8; i = i + 1) begin
            @(posedge gt_usrclk);
            //rx_data_sof = 0;
            gt_rx_data2 = gt_rx_data2 + 1;
            gt_rx_data3 = gt_rx_data3 + 1;
        end
        
        
        @(posedge gt_usrclk);
        rx_data_eof = 1;
        gt_rx_data2 = 32'hFFFF_FFFF;
        gt_rx_data3 = 32'hAAAA_AAAA;
        
        @(posedge gt_usrclk);
        rx_data_sof = 0;
        rx_data_eof = 0;
        gt_rx_data_vld = 0;
        
        // 
        repeat(5) @(posedge gt_usrclk);
    end
end
endtask

// 
always @(posedge sys_clk) begin
    if (pat_func_data_vld) begin
        $display("Time %0t: pat_func_data_vld detected, data = %h", 
                 $time, pat_func_data);
    end
end

// DFX
always @(posedge dfx_pattern_func) begin
    $display("Time %0t: dfx_pattern_func asserted", $time);
end

// VCD
initial begin
    $dumpfile("alpg_pat_task.vcd");
    $dumpvars(0, tb_top);
end

// 
initial begin
    #1000000;
    $display("Simulation timeout!");
    $finish;
end

endmodule
