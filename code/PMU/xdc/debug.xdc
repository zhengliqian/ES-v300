create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list instance_name/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ad8686_driver_inst/cha_rdata[0]} {ad8686_driver_inst/cha_rdata[1]} {ad8686_driver_inst/cha_rdata[2]} {ad8686_driver_inst/cha_rdata[3]} {ad8686_driver_inst/cha_rdata[4]} {ad8686_driver_inst/cha_rdata[5]} {ad8686_driver_inst/cha_rdata[6]} {ad8686_driver_inst/cha_rdata[7]} {ad8686_driver_inst/cha_rdata[8]} {ad8686_driver_inst/cha_rdata[9]} {ad8686_driver_inst/cha_rdata[10]} {ad8686_driver_inst/cha_rdata[11]} {ad8686_driver_inst/cha_rdata[12]} {ad8686_driver_inst/cha_rdata[13]} {ad8686_driver_inst/cha_rdata[14]} {ad8686_driver_inst/cha_rdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {ad8686_driver_inst/chb_rdata[0]} {ad8686_driver_inst/chb_rdata[1]} {ad8686_driver_inst/chb_rdata[2]} {ad8686_driver_inst/chb_rdata[3]} {ad8686_driver_inst/chb_rdata[4]} {ad8686_driver_inst/chb_rdata[5]} {ad8686_driver_inst/chb_rdata[6]} {ad8686_driver_inst/chb_rdata[7]} {ad8686_driver_inst/chb_rdata[8]} {ad8686_driver_inst/chb_rdata[9]} {ad8686_driver_inst/chb_rdata[10]} {ad8686_driver_inst/chb_rdata[11]} {ad8686_driver_inst/chb_rdata[12]} {ad8686_driver_inst/chb_rdata[13]} {ad8686_driver_inst/chb_rdata[14]} {ad8686_driver_inst/chb_rdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[0]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[1]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[2]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[3]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[4]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[5]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[6]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[7]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[8]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[9]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[10]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[11]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[12]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[13]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[14]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[15]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[16]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[17]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[18]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[19]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[20]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[21]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[22]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[23]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[24]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[25]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[26]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[27]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[28]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[29]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[30]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_time[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[0]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[1]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[2]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[3]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[4]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[5]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[6]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[7]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[8]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[9]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[10]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[11]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[12]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[13]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[14]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_time[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 20 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[0]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[1]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[2]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[3]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[4]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[5]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[6]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[7]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[8]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[9]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[10]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[11]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[12]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[13]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[14]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[15]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[16]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[17]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[18]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_100u_num[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 20 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[0]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[1]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[2]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[3]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[4]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[5]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[6]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[7]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[8]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[9]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[10]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[11]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[12]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[13]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[14]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[15]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[16]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[17]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[18]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_close_time[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[0]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[1]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[2]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[3]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[4]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[5]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[6]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[7]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[8]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[9]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[10]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[11]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[12]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[13]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[14]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_smp_wait_time[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/crt_st[0]} {pmu_core_inst/pmu_ctrl_mst_inst/crt_st[1]} {pmu_core_inst/pmu_ctrl_mst_inst/crt_st[2]} {pmu_core_inst/pmu_ctrl_mst_inst/crt_st[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 15 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[0]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[1]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[2]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[3]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[4]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[5]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[6]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[7]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[8]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[9]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[10]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[11]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[12]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[13]} {pmu_core_inst/pmu_ctrl_mst_inst/wait_smp_time[14]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 32 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[0]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[1]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[2]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[3]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[4]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[5]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[6]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[7]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[8]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[9]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[10]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[11]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[12]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[13]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[14]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[15]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[16]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[17]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[18]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[19]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[20]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[21]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[22]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[23]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[24]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[25]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[26]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[27]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[28]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[29]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[30]} {pmu_core_inst/pmu_ctrl_mst_inst/cfg_pmu_time[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[0]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[1]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[2]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[3]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[4]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[5]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[6]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[7]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[8]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[9]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[10]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[11]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[12]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[13]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[14]} {pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_cnt[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/crt_st[0]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/crt_st[1]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/crt_st[2]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/crt_st[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[0]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[1]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[2]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[3]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[4]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[5]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[6]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[7]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[8]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[9]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[10]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[11]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[12]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[13]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[14]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/drv_cnt[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {pmu_core_inst/pmu_data_pck_inst/wr_data[0]} {pmu_core_inst/pmu_data_pck_inst/wr_data[1]} {pmu_core_inst/pmu_data_pck_inst/wr_data[2]} {pmu_core_inst/pmu_data_pck_inst/wr_data[3]} {pmu_core_inst/pmu_data_pck_inst/wr_data[4]} {pmu_core_inst/pmu_data_pck_inst/wr_data[5]} {pmu_core_inst/pmu_data_pck_inst/wr_data[6]} {pmu_core_inst/pmu_data_pck_inst/wr_data[7]} {pmu_core_inst/pmu_data_pck_inst/wr_data[8]} {pmu_core_inst/pmu_data_pck_inst/wr_data[9]} {pmu_core_inst/pmu_data_pck_inst/wr_data[10]} {pmu_core_inst/pmu_data_pck_inst/wr_data[11]} {pmu_core_inst/pmu_data_pck_inst/wr_data[12]} {pmu_core_inst/pmu_data_pck_inst/wr_data[13]} {pmu_core_inst/pmu_data_pck_inst/wr_data[14]} {pmu_core_inst/pmu_data_pck_inst/wr_data[15]} {pmu_core_inst/pmu_data_pck_inst/wr_data[16]} {pmu_core_inst/pmu_data_pck_inst/wr_data[17]} {pmu_core_inst/pmu_data_pck_inst/wr_data[18]} {pmu_core_inst/pmu_data_pck_inst/wr_data[19]} {pmu_core_inst/pmu_data_pck_inst/wr_data[20]} {pmu_core_inst/pmu_data_pck_inst/wr_data[21]} {pmu_core_inst/pmu_data_pck_inst/wr_data[22]} {pmu_core_inst/pmu_data_pck_inst/wr_data[23]} {pmu_core_inst/pmu_data_pck_inst/wr_data[24]} {pmu_core_inst/pmu_data_pck_inst/wr_data[25]} {pmu_core_inst/pmu_data_pck_inst/wr_data[26]} {pmu_core_inst/pmu_data_pck_inst/wr_data[27]} {pmu_core_inst/pmu_data_pck_inst/wr_data[28]} {pmu_core_inst/pmu_data_pck_inst/wr_data[29]} {pmu_core_inst/pmu_data_pck_inst/wr_data[30]} {pmu_core_inst/pmu_data_pck_inst/wr_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 10 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[0]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[1]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[2]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[3]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[4]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[5]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[6]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[7]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[8]} {pmu_core_inst/pmu_drv_inst/pmu_rst_cnt[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 10 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[0]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[1]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[2]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[3]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[4]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[5]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[6]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[7]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[8]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/wait_time_cnt[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 29 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[0]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[1]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[2]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[3]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[4]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[5]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[6]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[7]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[8]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[9]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[10]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[11]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[12]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[13]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[14]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[15]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[16]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[17]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[18]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[19]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[20]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[21]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[22]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[23]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[24]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[25]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[26]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[27]} {pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_data[28]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 32 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {cfg_pmu_time[0]} {cfg_pmu_time[1]} {cfg_pmu_time[2]} {cfg_pmu_time[3]} {cfg_pmu_time[4]} {cfg_pmu_time[5]} {cfg_pmu_time[6]} {cfg_pmu_time[7]} {cfg_pmu_time[8]} {cfg_pmu_time[9]} {cfg_pmu_time[10]} {cfg_pmu_time[11]} {cfg_pmu_time[12]} {cfg_pmu_time[13]} {cfg_pmu_time[14]} {cfg_pmu_time[15]} {cfg_pmu_time[16]} {cfg_pmu_time[17]} {cfg_pmu_time[18]} {cfg_pmu_time[19]} {cfg_pmu_time[20]} {cfg_pmu_time[21]} {cfg_pmu_time[22]} {cfg_pmu_time[23]} {cfg_pmu_time[24]} {cfg_pmu_time[25]} {cfg_pmu_time[26]} {cfg_pmu_time[27]} {cfg_pmu_time[28]} {cfg_pmu_time[29]} {cfg_pmu_time[30]} {cfg_pmu_time[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 20 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {cfg_pmu_close_time[0]} {cfg_pmu_close_time[1]} {cfg_pmu_close_time[2]} {cfg_pmu_close_time[3]} {cfg_pmu_close_time[4]} {cfg_pmu_close_time[5]} {cfg_pmu_close_time[6]} {cfg_pmu_close_time[7]} {cfg_pmu_close_time[8]} {cfg_pmu_close_time[9]} {cfg_pmu_close_time[10]} {cfg_pmu_close_time[11]} {cfg_pmu_close_time[12]} {cfg_pmu_close_time[13]} {cfg_pmu_close_time[14]} {cfg_pmu_close_time[15]} {cfg_pmu_close_time[16]} {cfg_pmu_close_time[17]} {cfg_pmu_close_time[18]} {cfg_pmu_close_time[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list ad8686_driver_inst/ad8686_db11_sdob]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list ad8686_driver_inst/ad8686_db12_sdoa]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list ad8686_driver_inst/ad8686_sclk_rd]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/adc_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/cfg_wr_rdy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list ad8686_driver_inst/ch_rdata_vld]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_busyn]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_busyn_d1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_busyn_r]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_busyn_r]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_rd_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_rd_req]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list pmu_core_inst/pmu_task_inst/pmu_drv_task_inst/pmu_cfg_wr_req]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_cgalm]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_close]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_close_wait_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_drv_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_drv_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_pck_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_pck_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_rd_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_rstn]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_smp_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_spi_clk]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_spi_csn]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 1 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_spi_sdi]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_spi_sdo]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 1 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list pmu_core_inst/pmu_drv_inst/pmu_tmpn]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe50]
set_property port_width 1 [get_debug_ports u_ila_0/probe50]
connect_debug_port u_ila_0/probe50 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe51]
set_property port_width 1 [get_debug_ports u_ila_0/probe51]
connect_debug_port u_ila_0/probe51 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe52]
set_property port_width 1 [get_debug_ports u_ila_0/probe52]
connect_debug_port u_ila_0/probe52 [get_nets [list pmu_core_inst/pmu_ctrl_mst_inst/pmu_work_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe53]
set_property port_width 1 [get_debug_ports u_ila_0/probe53]
connect_debug_port u_ila_0/probe53 [get_nets [list time_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe54]
set_property port_width 1 [get_debug_ports u_ila_0/probe54]
connect_debug_port u_ila_0/probe54 [get_nets [list pmu_core_inst/pmu_data_pck_inst/wr_en]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list u_design_1_wrapper/design_1_i/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 32 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {ps_axi_bram_wrdata[0]} {ps_axi_bram_wrdata[1]} {ps_axi_bram_wrdata[2]} {ps_axi_bram_wrdata[3]} {ps_axi_bram_wrdata[4]} {ps_axi_bram_wrdata[5]} {ps_axi_bram_wrdata[6]} {ps_axi_bram_wrdata[7]} {ps_axi_bram_wrdata[8]} {ps_axi_bram_wrdata[9]} {ps_axi_bram_wrdata[10]} {ps_axi_bram_wrdata[11]} {ps_axi_bram_wrdata[12]} {ps_axi_bram_wrdata[13]} {ps_axi_bram_wrdata[14]} {ps_axi_bram_wrdata[15]} {ps_axi_bram_wrdata[16]} {ps_axi_bram_wrdata[17]} {ps_axi_bram_wrdata[18]} {ps_axi_bram_wrdata[19]} {ps_axi_bram_wrdata[20]} {ps_axi_bram_wrdata[21]} {ps_axi_bram_wrdata[22]} {ps_axi_bram_wrdata[23]} {ps_axi_bram_wrdata[24]} {ps_axi_bram_wrdata[25]} {ps_axi_bram_wrdata[26]} {ps_axi_bram_wrdata[27]} {ps_axi_bram_wrdata[28]} {ps_axi_bram_wrdata[29]} {ps_axi_bram_wrdata[30]} {ps_axi_bram_wrdata[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 4 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {ps_axi_bram_we[0]} {ps_axi_bram_we[1]} {ps_axi_bram_we[2]} {ps_axi_bram_we[3]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 14 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {ps_axi_bram_addr[2]} {ps_axi_bram_addr[3]} {ps_axi_bram_addr[4]} {ps_axi_bram_addr[5]} {ps_axi_bram_addr[6]} {ps_axi_bram_addr[7]} {ps_axi_bram_addr[8]} {ps_axi_bram_addr[9]} {ps_axi_bram_addr[10]} {ps_axi_bram_addr[11]} {ps_axi_bram_addr[12]} {ps_axi_bram_addr[13]} {ps_axi_bram_addr[14]} {ps_axi_bram_addr[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 32 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {ps_axi_bram_rddata[0]} {ps_axi_bram_rddata[1]} {ps_axi_bram_rddata[2]} {ps_axi_bram_rddata[3]} {ps_axi_bram_rddata[4]} {ps_axi_bram_rddata[5]} {ps_axi_bram_rddata[6]} {ps_axi_bram_rddata[7]} {ps_axi_bram_rddata[8]} {ps_axi_bram_rddata[9]} {ps_axi_bram_rddata[10]} {ps_axi_bram_rddata[11]} {ps_axi_bram_rddata[12]} {ps_axi_bram_rddata[13]} {ps_axi_bram_rddata[14]} {ps_axi_bram_rddata[15]} {ps_axi_bram_rddata[16]} {ps_axi_bram_rddata[17]} {ps_axi_bram_rddata[18]} {ps_axi_bram_rddata[19]} {ps_axi_bram_rddata[20]} {ps_axi_bram_rddata[21]} {ps_axi_bram_rddata[22]} {ps_axi_bram_rddata[23]} {ps_axi_bram_rddata[24]} {ps_axi_bram_rddata[25]} {ps_axi_bram_rddata[26]} {ps_axi_bram_rddata[27]} {ps_axi_bram_rddata[28]} {ps_axi_bram_rddata[29]} {ps_axi_bram_rddata[30]} {ps_axi_bram_rddata[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 1 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list ps_axi_bram_en]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ps_axi_bram_clk]
