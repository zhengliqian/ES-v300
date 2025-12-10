`timescale 1ns / 1ps

module tb_alpg_data_prase();

// 时钟和复位信号
reg         clk;
reg         rst;
reg         base_rate_clk;

// 控制信号
reg         alpg_start;
reg         alpg_done;
reg         init_start;

// 模式功能数据接口
reg  [5*32-1:0] pat_func_data;  // PROTCL_LEN * GT_LANE_DW
reg         pat_func_data_vld;

// DDR 数据接口
reg  [7:0]  pm_data;
reg  [7:0]  dum_data;

// 配置信号
reg  [8:0]  cfg_alpg_fmt_c0;
reg  [8:0]  cfg_alpg_fmt_c1;
reg  [8:0]  cfg_alpg_fmt_d0;
reg  [22*8-1:0] cfg_alpg_rate_bus;
reg  [22*8-1:0] cfg_alpg_aclk1_bus;
reg  [22*8-1:0] cfg_alpg_cclk1_bus;
reg  [22*8-1:0] cfg_alpg_bclk1_bus;
reg  [22*8-1:0] cfg_alpg_aclk2_bus;
reg  [22*8-1:0] cfg_alpg_bclk2_bus;
reg  [22*8-1:0] cfg_alpg_cclk2_bus;
reg  [22*8-1:0] cfg_alpg_aclk3_bus;
reg  [22*8-1:0] cfg_alpg_bclk3_bus;
reg  [22*8-1:0] cfg_alpg_cclk3_bus;
reg  [22*8-1:0] cfg_alpg_dre_r_bus;
reg  [22*8-1:0] cfg_alpg_dre_f_bus;
reg  [22*8-1:0] cfg_alpg_strb_bus;
reg  [7:0]  cfg_alpg_msktb;
reg  [14:0] cfg_alpg_x;
reg  [12:0] cfg_alpg_y;
reg  [10:0] cfg_alpg_z;
reg  [31:0] cfg_alpg_tp;
reg         cfg_alpg_me;
reg  [21:0] cfg_alpg_psta;
reg  [22:0] cfg_alpg_msta;
reg  [32*32-1:0] cfg_alpg_tph_bus;
reg  [32*16-1:0] cfg_alpg_dreg_bus;
reg  [23*8-1:0] cfg_alpg_qreg_bus;
reg  [22*8-1:0] cfg_alpg_preg_bus;
reg  [24*8-1:0] cfg_alpg_ash_bus;
reg  [24*8-1:0] cfg_alpg_asl_bus;

// 输出信号
wire        init_done;
wire        alpg_dps_start;
wire        pat_data_parse_vld;
wire [21:0] pattern_data_rate;
wire [21:0] pattern_a_clk_drv0;
wire [21:0] pattern_b_clk_drv0;
wire [21:0] pattern_c_clk_drv0;
wire [21:0] pattern_a_clk_drv1;
wire [21:0] pattern_b_clk_drv1;
wire [21:0] pattern_c_clk_drv1;
wire [21:0] pattern_a_clk_io;
wire [21:0] pattern_b_clk_io;
wire [21:0] pattern_c_clk_io;
wire [21:0] pattern_drv_r;
wire [21:0] pattern_drv_f;
wire [21:0] pattern_strb;
wire        pattern_ck;
wire        pattern_we;
wire [3:0]  pattern_cmd;
wire        pattern_me;
wire [7:0]  pattern_msktb;
wire [7:0]  d_reg;
wire        pattern_dio;

// 实例化被测模块
alpg_data_prase uut (
    .clk                 (clk),
    .rst                 (rst),
    .alpg_start          (alpg_start),
    .alpg_done           (alpg_done),
    .base_rate_clk       (base_rate_clk),
    .init_start          (init_start),
    .init_done           (init_done),
    .pat_func_data       (pat_func_data),
    .pat_func_data_vld   (pat_func_data_vld),
    .pm_addr             (),  // 输出，在测试中监控
    .pm_data             (pm_data),
    .dum_addr            (),  // 输出，在测试中监控
    .dum_data            (dum_data),
    .cfg_alpg_fmt_c0     (cfg_alpg_fmt_c0),
    .cfg_alpg_fmt_c1     (cfg_alpg_fmt_c1),
    .cfg_alpg_fmt_d0     (cfg_alpg_fmt_d0),
    .cfg_alpg_rate_bus   (cfg_alpg_rate_bus),
    .cfg_alpg_aclk1_bus  (cfg_alpg_aclk1_bus),
    .cfg_alpg_cclk1_bus  (cfg_alpg_cclk1_bus),
    .cfg_alpg_bclk1_bus  (cfg_alpg_bclk1_bus),
    .cfg_alpg_aclk2_bus  (cfg_alpg_aclk2_bus),
    .cfg_alpg_bclk2_bus  (cfg_alpg_bclk2_bus),
    .cfg_alpg_cclk2_bus  (cfg_alpg_cclk2_bus),
    .cfg_alpg_aclk3_bus  (cfg_alpg_aclk3_bus),
    .cfg_alpg_bclk3_bus  (cfg_alpg_bclk3_bus),
    .cfg_alpg_cclk3_bus  (cfg_alpg_cclk3_bus),
    .cfg_alpg_dre_r_bus  (cfg_alpg_dre_r_bus),
    .cfg_alpg_dre_f_bus  (cfg_alpg_dre_f_bus),
    .cfg_alpg_strb_bus   (cfg_alpg_strb_bus),
    .cfg_alpg_msktb      (cfg_alpg_msktb),
    .cfg_alpg_x          (cfg_alpg_x),
    .cfg_alpg_y          (cfg_alpg_y),
    .cfg_alpg_z          (cfg_alpg_z),
    .cfg_alpg_tp         (cfg_alpg_tp),
    .cfg_alpg_me         (cfg_alpg_me),
    .cfg_alpg_psta       (cfg_alpg_psta),
    .cfg_alpg_msta       (cfg_alpg_msta),
    .cfg_alpg_tph_bus    (cfg_alpg_tph_bus),
    .cfg_alpg_dreg_bus   (cfg_alpg_dreg_bus),
    .cfg_alpg_qreg_bus   (cfg_alpg_qreg_bus),
    .cfg_alpg_preg_bus   (cfg_alpg_preg_bus),
    .cfg_alpg_ash_bus    (cfg_alpg_ash_bus),
    .cfg_alpg_asl_bus    (cfg_alpg_asl_bus),
    .alpg_dps_start      (alpg_dps_start),
    .pat_data_parse_vld  (pat_data_parse_vld),
    .pattern_data_rate   (pattern_data_rate),
    .pattern_a_clk_drv0  (pattern_a_clk_drv0),
    .pattern_b_clk_drv0  (pattern_b_clk_drv0),
    .pattern_c_clk_drv0  (pattern_c_clk_drv0),
    .pattern_a_clk_drv1  (pattern_a_clk_drv1),
    .pattern_b_clk_drv1  (pattern_b_clk_drv1),
    .pattern_c_clk_drv1  (pattern_c_clk_drv1),
    .pattern_a_clk_io    (pattern_a_clk_io),
    .pattern_b_clk_io    (pattern_b_clk_io),
    .pattern_c_clk_io    (pattern_c_clk_io),
    .pattern_drv_r       (pattern_drv_r),
    .pattern_drv_f       (pattern_drv_f),
    .pattern_strb        (pattern_strb),
    .ck_out              (pattern_ck),
    .we_out              (pattern_we),
    .pattern_cmd         (pattern_cmd),
    .pattern_me          (pattern_me),
    .pattern_msktb       (pattern_msktb),
    .d_reg               (d_reg),
    .pattern_dio         (pattern_dio)
);

// 时钟生成：200MHz，周期5ns
always #2.5 clk = ~clk;

// 基础速率时钟生成：50MHz，周期20ns
always #10 base_rate_clk = ~base_rate_clk;

// 测试序列
initial begin
    // 初始化所有信号
    initialize_signals();
    
    // 应用复位
    apply_reset();
    
    $display("=== ALPG数据解析模块测试开始 ===");
    $display("时间: %0t ns", $time);
    
    // 测试用例1：初始化测试
    $display("\n--- 测试用例1: 初始化测试 ---");
    test_initialization();
    
    // 测试用例2：数据解析测试
    $display("\n--- 测试用例2: 数据解析测试 ---");
    test_data_parsing();
    
//    // 测试用例3：时序配置测试
//    $display("\n--- 测试用例3: 时序配置测试 ---");
//    test_timing_config();
    
//    // 测试用例4：DDR访问测试
//    $display("\n--- 测试用例4: DDR访问测试 ---");
//    test_ddr_access();
    
//    // 测试用例5：运算操作测试
//    $display("\n--- 测试用例5: 运算操作测试 ---");
//    test_operation();
    
    #100;
    $display("\n=== 所有测试完成 ===");
    $finish;
end

// 初始化所有信号
task initialize_signals;
begin
    clk = 0;
    rst = 0;
    base_rate_clk = 0;
    alpg_start = 0;
    alpg_done = 0;
    init_start = 0;
    pat_func_data = 0;
    pat_func_data_vld = 0;
    pm_data = 8'hAA;
    dum_data = 8'h55;
    
    // 初始化配置信号
    cfg_alpg_fmt_c0 = 9'h106;
    cfg_alpg_fmt_c1 = 9'h3;
    cfg_alpg_fmt_d0 = 9'hd0;
    
    // 初始化时序总线
    cfg_alpg_rate_bus  = {22'd300, 22'd400, 22'd500, 22'd600, 22'd700, 22'd800,22'd100, 22'd100};
    cfg_alpg_aclk1_bus = { 22'd30, 22'd40, 22'd50, 22'd60, 22'd70, 22'd80,22'd0, 22'd0};
    cfg_alpg_cclk1_bus = { 22'd31, 22'd41, 22'd51, 22'd61, 22'd71, 22'd81,22'd45, 22'd0};
    cfg_alpg_bclk1_bus = { 22'd32, 22'd42, 22'd52, 22'd62, 22'd72, 22'd82,22'd95, 22'd50};
    cfg_alpg_aclk2_bus = { 22'd33, 22'd43, 22'd53, 22'd63, 22'd73, 22'd83,22'd45, 22'd0};
    cfg_alpg_bclk2_bus = { 22'd34, 22'd44, 22'd54, 22'd64, 22'd74, 22'd84,22'd0, 22'd0};
    cfg_alpg_cclk2_bus = { 22'd35, 22'd45, 22'd55, 22'd65, 22'd75, 22'd85,22'd25, 22'd50};
    cfg_alpg_aclk3_bus = { 22'd36, 22'd46, 22'd56, 22'd66, 22'd76, 22'd86,22'd25, 22'd0};
    cfg_alpg_bclk3_bus = { 22'd37, 22'd47, 22'd57, 22'd67, 22'd77, 22'd87,22'd0, 22'd0};
    cfg_alpg_cclk3_bus = { 22'd38, 22'd48, 22'd58, 22'd68, 22'd78, 22'd88,22'd25, 22'd50};
    cfg_alpg_dre_r_bus = { 22'd7, 22'd8, 22'd9, 22'd10, 22'd11, 22'd12,22'd0, 22'd0};
    cfg_alpg_dre_f_bus = { 22'd6, 22'd7, 22'd8, 22'd9, 22'd10, 22'd11 ,22'd0, 22'd0};
    cfg_alpg_strb_bus  = { 22'd4, 22'd5, 22'd6, 22'd7, 22'd8, 22'd9,22'd90, 22'd150};
    
    cfg_alpg_msktb = 8'hFF;
    cfg_alpg_x = 15'd100;
    cfg_alpg_y = 13'd50;
//    cfg_alpg_z = 11'd25;
        cfg_alpg_z = 11'd0;

    cfg_alpg_tp = 32'h60;
    cfg_alpg_me = 1'b1;
    cfg_alpg_psta = 22'h333333;
    cfg_alpg_msta = 23'h444444;
    
    // 初始化寄存器总线
    cfg_alpg_tph_bus = {32'h11111111, 32'h22222222, 32'h33333333, 32'h44444444, 32'h55555555, 32'h66666666, 32'h77777777, 32'h88888888,
                       32'h99999999, 32'haaaaaaaa, 32'hbbbbbbbb, 32'hcccccccc, 32'hdddddddd, 32'heeeeeeee, 32'hffffffff, 32'h01234567,
                       32'h89abcdef, 32'hfedcba98, 32'h76543210, 32'h13579bdf, 32'h2468ace0, 32'h98765432, 32'habcdef01, 32'h11223344,
                       32'h55667788, 32'h99aabbcc, 32'hdddeeeff, 32'h0f0f0f0f, 32'hf0f0f0f0, 32'h55555555, 32'haaaaaaaa, 32'h000000ea};
    
    cfg_alpg_dreg_bus = {32'h10000001, 32'h20000002, 32'h30000003, 32'h40000004, 32'h50000005, 32'h60000006, 32'h70000007, 32'h80000008,
                        32'h90000009, 32'ha000000a, 32'hb000000b, 32'hc000000c, 32'hd000000d, 32'he000000e, 32'hf000000f, 32'h01010101};
    
    cfg_alpg_qreg_bus = {23'h111111, 23'h222222, 23'h333333, 23'h444444, 23'h555555, 23'h666666, 23'h777777, 23'h888888};
    
    cfg_alpg_preg_bus = {22'h11111, 22'h22222, 22'h33333, 22'h44444, 22'h55555, 22'h66666, 22'h77777, 22'h88888};
    
    cfg_alpg_ash_bus = {24'h111111, 24'h222222, 24'h333333, 24'h444444, 24'h555555, 24'h666666, 24'h777777, 24'h888888};
    
    cfg_alpg_asl_bus = {24'h999999, 24'haaaaaa, 24'hbbbbbb, 24'hcccccc, 24'hdddddd, 24'heeeeee, 24'hffffff, 24'h012345};
end
endtask

// 应用复位
task apply_reset;
begin
    $display("时间 %0t: 应用复位", $time);
    rst = 1;
    #100;
    rst = 0;
    #50;
end
endtask

// 初始化测试
task test_initialization;
begin
    $display("时间 %0t: 开始初始化测试", $time);
    
    // 启动初始化
    init_start = 1;
    #10;
    init_start = 0;
    
    // 等待初始化完成
    wait(init_done == 1);
    $display("时间 %0t: 初始化完成", $time);
    
    #50;
end
endtask

// 数据解析测试
task test_data_parsing;
begin
    $display("时间 %0t: 开始数据解析测试", $time);
    
    // 构造测试数据
    // 根据协议格式构造 pat_func_data
    // 位域: [PC_BIT][CTRL_BIT][CMD_BIT][TSN_BIT][WE_BIT][CK_BIT]...[寄存器数据]
//    pat_func_data = {
//        14'h0000,           // PC_BIT
//        7'h00,              // CTRL_BIT  
//        4'h0,               // CMD_BIT - 命令
//        3'h0,               // TSN_BIT - 时序编号
//        1'b0,               // WE_BIT - 写使能
//        1'b0,               // CK_BIT - 时钟
//        4'b0100,            // MUX_DW - 多路选择
//        9'b000000000,       // OPR_DW*REG_NUM - 操作码总线
//        21'd6,             // REG_SEL_DW - 寄存器A0地址
//        21'd0,             // REG_SEL_DW - 寄存器A1地址  
//        21'd0,             // REG_SEL_DW - 寄存器A2地址
//        32'd56,       // REG_DW - 寄存器B0数据
//        32'h87654321,       // REG_DW - 寄存器B1数据
//        32'hABCDEF01        // REG_DW - 寄存器B2数据
// pat_func_data = 'h00e4_0000_0000_0000_0000_0000_0000_0000_0000_0000 ;
//         pat_func_data = 'h0038_1009_0000_8000_0000_0008_0000_0000_0000_0000;
//         pat_func_data = 'h005c_1008_8000_9400_0000_0060_0000_0005_0000_0000;
//         pat_func_data = 'h0064_008c_0000_4000_0000_0000_0000_0000_0000_0000;
//         pat_func_data = 'h005c_1008_8100_8280_0000_00d1_0000_0001_0000_0000;
         pat_func_data = 'h0130_0010_0000_0000_0000_0000_0000_0000_0000_0000;

//    };
 
    // 发送有效数据
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    // 等待数据解析完成
    #50;
//     pat_func_data = 'h0068_008c_0000_4000_0000_0001_0000_0000_0000_0000;
 pat_func_data = 'h005c_1008_8100_8280_0000_00d1_0000_0001_0000_0000;
//    };
    
    // 发送有效数据
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    // 等待数据解析完成
    #50;
     pat_func_data = 'h006c_008c_0000_4000_0000_0000_0000_0000_0000_0000;

//    };
    
    // 发送有效数据
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    // 等待数据解析完成
    #50;
     pat_func_data = 'h0070_008c_0000_4000_0000_0000_0000_0000_0000_0000;

//    };
    
    // 发送有效数据
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    // 等待数据解析完成
    #50;
     pat_func_data = 'h0074_008f_0000_4000_0000_0002_0000_0000_0000_0000;

//    };
    
    // 发送有效数据
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    // 等待数据解析完成
    #400;
     pat_func_data = 'h0078_000c_0000_0000_0000_0000_0000_0000_0000_0000;

//    };
    
    // 发送有效数据
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    // 等待数据解析完成
    #50;
    // 验证输出信号
    if (pat_data_parse_vld) 
        $display("时间 %0t: 数据解析有效信号确认", $time);
    else
        $display("时间 %0t: 错误: 数据解析有效信号未置位", $time);
        
    #50;
end
endtask

// 时序配置测试
integer tsn;

task test_timing_config;
begin
    $display("时间 %0t: 开始时序配置测试", $time);
    // 测试不同的时序编号
//    for (tsn = 0; tsn < 8; tsn = tsn + 1) begin
        $display("时间 %0t: 测试时序编号 %0d", $time, tsn);
        
        // 构造带有时序编号的数据
//        pat_func_data = {
//            14'h0000,           // PC_BIT
//            7'h00,              // CTRL_BIT  
//            4'h2,               // CMD_BIT
//            tsn[2:0],           // TSN_BIT - 时序编号
//            1'b0,               // WE_BIT
//            1'b1,               // CK_BIT
//            4'b0101,            // MUX_DW
//            9'b101010101,       // OPR_DW*REG_NUM
//            21'd5,              // REG_SEL_DW
//            21'd6,              // REG_SEL_DW  
//            21'd7,              // REG_SEL_DW
//            32'h11111111,       // REG_DW
//            32'h22222222,       // REG_DW
//            32'h33333333        // REG_DW
//        };
//        pat_func_data = 'h00e8_0001_0001_8000_0000_0038_0000_0000_0000_0000;
//        pat_func_data = 'h00f4_008c_0000_4000_0000_0001_0000_0000_0000_0000;
        pat_func_data = 'h003c_008f_0000_4000_0000_0002_0000_0000_0000_0000;
//        pat_func_data = 'h0038_1009_0000_8000_0000_0008_0000_0000_0000_0000;

        pat_func_data_vld = 1;
        #5;
        pat_func_data_vld = 0;
        
        #20; // 等待时序配置更新
//    end
    
    #50;
end
endtask

// DDR访问测试
task test_ddr_access;
begin
    $display("时间 %0t: 开始DDR访问测试", $time);
    
    // 构造DDR访问命令的数据
    pat_func_data = {
        14'h0000,           // PC_BIT
        7'h00,              // CTRL_BIT  
        4'h4,               // CMD_BIT - DDR访问命令
        3'h1,               // TSN_BIT
        1'b1,               // WE_BIT
        1'b0,               // CK_BIT
        4'b1100,            // MUX_DW
        9'b010101010,       // OPR_DW*REG_NUM
        21'd6,              // REG_SEL_DW - dum_addr寄存器
        21'd7,              // REG_SEL_DW - pm_addr寄存器  
        21'd8,              // REG_SEL_DW
        32'h1000,           // REG_DW - 地址数据
        32'h2000,           // REG_DW
        32'h3000            // REG_DW
    };
    
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    #50;
    
    // 模拟DDR数据返回
    pm_data = 8'hDE;
    dum_data = 8'hAD;
    
    #50;
end
endtask

// 运算操作测试
task test_operation;
begin
    $display("时间 %0t: 开始运算操作测试", $time);
    
    // 测试不同的运算操作
    pat_func_data = {
        14'h0000,           // PC_BIT
        7'h00,              // CTRL_BIT  
        4'h3,               // CMD_BIT
        3'h2,               // TSN_BIT
        1'b0,               // WE_BIT
        1'b1,               // CK_BIT
        4'b1111,            // MUX_DW
        9'b001100110,       // OPR_DW*REG_NUM - 操作码: 加、减、移位
        21'd15,             // REG_SEL_DW
        21'd16,             // REG_SEL_DW  
        21'd17,             // REG_SEL_DW
        32'h0000000A,       // REG_DW - 操作数B0
        32'h00000005,       // REG_DW - 操作数B1
        32'h00000002        // REG_DW - 操作数B2
    };
    
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    #100; // 等待运算完成
    
    // 测试DIO生成
    $display("时间 %0t: 测试DIO数据生成", $time);
    
    pat_func_data = {
        14'h0000,           // PC_BIT
        7'h00,              // CTRL_BIT  
        4'h1,               // CMD_BIT - DIO命令
        3'h0,               // TSN_BIT
        1'b1,               // WE_BIT
        1'b0,               // CK_BIT
        4'b0000,            // MUX_DW
        9'b000000000,       // OPR_DW*REG_NUM
        21'd1,              // REG_SEL_DW - 选择寄存器1
        21'd0,              // REG_SEL_DW  
        21'd0,              // REG_SEL_DW
        32'h000000AA,       // REG_DW - DIO数据
        32'h00000000,       // REG_DW
        32'h00000000        // REG_DW
    };
    
    pat_func_data_vld = 1;
    #5;
    pat_func_data_vld = 0;
    
    #200; // 观察DIO输出
end
endtask

//// 监控信号变化
//always @(posedge clk) begin
//    // 监控状态机状态变化
//    if (uut.crt_st !== $past(uut.crt_st)) 
//        $display("时间 %0t: [状态机] 状态变化: %h -> %h", $time, $past(uut.crt_st), uut.crt_st);
    
//    // 监控初始化完成
//    if (init_done && $past(!init_done))
//        $display("时间 %0t: [初始化] 完成信号置位", $time);
    
//    // 监控数据解析有效
//    if (pat_data_parse_vld && $past(!pat_data_parse_vld))
//        $display("时间 %0t: [数据解析] 有效信号置位", $time);
    
//    // 监控DPS启动
//    if (alpg_dps_start && $past(!alpg_dps_start))
//        $display("时间 %0t: [DPS] 启动信号置位", $time);
//end

//// 简单的 $past 函数模拟
//function automatic reg [3:0] $past(reg [3:0] signal);
//    $past = signal;
//endfunction

// 波形保存
initial begin
    $dumpfile("tb_alpg_data_prase.vcd");
    $dumpvars(0, tb_alpg_data_prase);
end

// 超时保护
initial begin
    #1000000; // 1ms 超时
    $display("错误: 仿真超时!");
    $finish;
end

endmodule
