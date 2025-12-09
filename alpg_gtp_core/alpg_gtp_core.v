`timescale 1ns / 1ps
`define DLY #1
//////////////////////////////////////////////////////////////////////////////////
// Company               : 
// Engineer              : 
// 
// Create Date           : 2025-06-16
// Module Name           : alpg_gtp_core
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

module alpg_gtp_core
#(
    parameter GT_LANE          =   4     ,
    parameter GT_LANE_DW       =   32    ,
    parameter DATA_NUM_DW      =   32    ,
    parameter GT_DFX_DW        =   4     
)
(
    input                               gt_ref_clkn     ,     //@125M
    input                               gt_ref_clkp     ,     //@125M
    input                               gt_sys_clk      ,     //@100M
    output                              gt_usrclk       ,     //@50M
    input                               sys_rst         ,
    (*mark_debug="true"*)(*keep="true"*)output                              gtp_rst_done    ,
    (*mark_debug="true"*)(*keep="true"*)input                               gtx_rst_done    ,
    //====================TX DATA@gt_tx_outclk2 = 50M====================
    input  [GT_LANE/2-1:0]              tx_pck_start    ,     
    input                               tx_pck_suspend  ,     
    output                              tx_pck_done     ,     
    input  [DATA_NUM_DW-1:0]            cfg_num_tx      ,     
    input  [DATA_NUM_DW-1:0]            cfg_tx_data_num ,     
    input  [GT_LANE*GT_LANE_DW-1:0]     tx_data_bus     ,     
    input  [GT_LANE-1:0]                tx_data_vld_bus ,     
    //====================RX DATA@gt_tx_outclk2 = 50M====================
    output                              rx_cfg_sof      ,
    output                              rx_cfg_eof      ,
    output                              rx_data_sof     ,
    output                              rx_data_eof     ,
    input  [DATA_NUM_DW-1:0]            cfg_num_rx      ,     
    input  [DATA_NUM_DW-1:0]            cfg_rx_data_num ,
    output [GT_LANE*GT_LANE_DW-1:0]     rx_data_bus     ,
    output [GT_LANE-1:0]                rx_data_vld_bus ,
    //=================================GT INTF============================
    input  [GT_LANE-1:0]                rxn_in          ,
    input  [GT_LANE-1:0]                rxp_in          ,
    output [GT_LANE-1:0]                txn_out         ,
    output [GT_LANE-1:0]                txp_out         ,
    //======================DFX@gt_tx_outclk2 = 125M======================
    output [GT_LANE*GT_DFX_DW-1:0]      dfx_rx_err_bus
);

localparam GT_BYTE_NUM = GT_LANE_DW/8;

(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE*GT_LANE_DW-1:0]       gt_tx_data_bus            ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0]                  gt_tx_data_vld_bus        ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE*GT_LANE_DW-1:0]       gt_rx_data_bus            ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0]                  gt_rx_data_vld_bus        ;
//8B/10B Decoder Ports
wire [GT_LANE*GT_BYTE_NUM-1:0]      gt_rx_chariscomma_bus     ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE*GT_BYTE_NUM-1:0]      gt_rx_charisk_bus         ;
wire [GT_LANE*GT_BYTE_NUM-1:0]      gt_rx_disperr_bus         ;
wire [GT_LANE*GT_BYTE_NUM-1:0]      gt_rx_notintable_bus      ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE*GT_BYTE_NUM-1:0]      gt_tx_charisk_bus         ;
//RX Byte and Word Alignment Ports
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0]                  gt_rx_byteisaligned_bus   ;
wire [GT_LANE-1:0]                  gt_rx_byterealign_bus     ;
wire [GT_LANE-1:0]                  gt_rx_mcommaalignen_bus   ;
wire [GT_LANE-1:0]                  gt_rx_pcommaalignen_bus   ;
//RX Channel Bonding Ports
wire [GT_LANE-1:0]                  gt_rx_chanbondseq_bus     ;
wire [GT_LANE-1:0]                  gt_rx_chbonden_bus        ;
wire [GT_LANE-1:0]                  gt_rx_chanisaligned_bus   ;
wire [GT_LANE-1:0]                  gt_rx_rxchanrealign_bus   ;
wire [GT_LANE-1:0]                  gt_rx_rxchbondo_bus       ;
wire [GT_BYTE_NUM-1:0]              gt_rxchbondo0             ;
wire [GT_BYTE_NUM-1:0]              gt_rxchbondo1             ;
wire [GT_BYTE_NUM-1:0]              gt_rxchbondo2             ;
wire [GT_BYTE_NUM-1:0]              gt_rxchbondo3             ;
//sys intf
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0]                  gt_rx_resetdone_bus       ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0]                  gt_tx_resetdone_bus       ;
wire [GT_LANE-1:0]                  gt_tx_fsm_reset_done_bus       ;
wire [GT_LANE-1:0]                  gt_rx_fsm_reset_done_bus       ;
wire [GT_LANE-1:0]                  gt_tx_mmcm_lock_bus       ;
wire [GT_LANE-1:0]                  gt_rx_mmcm_lock_bus       ;
wire [GT_LANE-1:0]                  gt_rx_clkcorcnt_bus       ;
//***********************************************************************//
//                                                                       //
//--------------------------- The GT Wrapper ----------------------------//
//                                                                       //
//***********************************************************************//

alpg_gtp alpg_gtp_support_i 
(
    .soft_reset_tx_in                                          (sys_rst                                                                     ),
    .soft_reset_rx_in                                          (sys_rst                                                                     ),
    .dont_reset_on_data_error_in                               (1'b1                                                                        ),
    .q0_clk1_gtrefclk_pad_n_in                                 (gt_ref_clkn                                                                 ),
    .q0_clk1_gtrefclk_pad_p_in                                 (gt_ref_clkp                                                                 ),
    .gt0_tx_mmcm_lock_out                                      (gt_tx_mmcm_lock_bus[0]                                                      ),
    .gt0_rx_mmcm_lock_out                                      (gt_rx_mmcm_lock_bus[0]                                                      ),
    .gt0_tx_fsm_reset_done_out                                 (gt_tx_fsm_reset_done_bus[0]                                                 ),
    .gt0_rx_fsm_reset_done_out                                 (gt_rx_fsm_reset_done_bus[0]                                                 ),
    .gt0_data_valid_in                                         (gt_tx_data_vld_bus[0]                                                       ),
    .gt1_tx_mmcm_lock_out                                      (gt_tx_mmcm_lock_bus[1]                                                      ),
    .gt1_rx_mmcm_lock_out                                      (gt_rx_mmcm_lock_bus[1]                                                      ),
    .gt1_tx_fsm_reset_done_out                                 (gt_tx_fsm_reset_done_bus[1]                                                 ),
    .gt1_rx_fsm_reset_done_out                                 (gt_rx_fsm_reset_done_bus[1]                                                 ),
    .gt1_data_valid_in                                         (gt_tx_data_vld_bus[1]                                                       ),
    .gt2_tx_mmcm_lock_out                                      (gt_tx_mmcm_lock_bus[2]                                                      ),
    .gt2_rx_mmcm_lock_out                                      (gt_rx_mmcm_lock_bus[2]                                                      ),
    .gt2_tx_fsm_reset_done_out                                 (gt_tx_fsm_reset_done_bus[2]                                                 ),
    .gt2_rx_fsm_reset_done_out                                 (gt_rx_fsm_reset_done_bus[2]                                                 ),
    .gt2_data_valid_in                                         (gt_tx_data_vld_bus[2]                                                       ),
    .gt3_tx_mmcm_lock_out                                      (gt_tx_mmcm_lock_bus[3]                                                      ),
    .gt3_rx_mmcm_lock_out                                      (gt_rx_mmcm_lock_bus[3]                                                      ),
    .gt3_tx_fsm_reset_done_out                                 (gt_tx_fsm_reset_done_bus[3]                                                 ),
    .gt3_rx_fsm_reset_done_out                                 (gt_rx_fsm_reset_done_bus[3]                                                 ),
    .gt3_data_valid_in                                         (gt_tx_data_vld_bus[3]                                                       ),

    .gt0_txusrclk_out                                          (gt0_txusrclk                                                                ),
    .gt0_txusrclk2_out                                         (gt0_txusrclk2                                                               ),
    .gt0_rxusrclk_out                                          (                                                                            ),
    .gt0_rxusrclk2_out                                         (                                                                            ),
    .gt1_txusrclk_out                                          (                                                                            ),
    .gt1_txusrclk2_out                                         (                                                                            ),
    .gt1_rxusrclk_out                                          (                                                                            ),
    .gt1_rxusrclk2_out                                         (                                                                            ),
    .gt2_txusrclk_out                                          (                                                                            ),
    .gt2_txusrclk2_out                                         (                                                                            ),
    .gt2_rxusrclk_out                                          (                                                                            ),
    .gt2_rxusrclk2_out                                         (                                                                            ),
    .gt3_txusrclk_out                                          (                                                                            ),
    .gt3_txusrclk2_out                                         (                                                                            ),
    .gt3_rxusrclk_out                                          (                                                                            ),
    .gt3_rxusrclk2_out                                         (                                                                            ),
    //_____________________________________________________________________
    //_____________________________________________________________________
    //GT0                                                      (X0Y0                     )
    //-------------------------- Channel - DRP Ports  --------------------------
    .gt0_drpaddr_in                                            (9'd0                                                                        ),
    .gt0_drpdi_in                                              (16'd0                                                                       ),
    .gt0_drpdo_out                                             (                                                                            ),
    .gt0_drpen_in                                              (1'b0                                                                        ),
    .gt0_drprdy_out                                            (                                                                            ),
    .gt0_drpwe_in                                              (1'b0                                                                        ),
    //------------------- RX Initialization and Reset Ports --------------------
    .gt0_eyescanreset_in                                       (1'b0                                                                        ),
    .gt0_rxuserrdy_in                                          (1'b1                                                                        ),
    //------------------------ RX Margin Analysis Ports ------------------------
    .gt0_eyescandataerror_out                                  (                                                                            ),
    .gt0_eyescantrigger_in                                     (1'b0                                                                        ),
    //----------------- Receive Ports - Clock Correction Ports -----------------
    .gt0_rxclkcorcnt_out                                       (gt_rx_clkcorcnt_bus[0]                                                      ),
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    .gt0_rxdata_out                                            (gt_rx_data_bus[GT_LANE_DW-1:0]                                              ),
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    .gt0_rxchariscomma_out                                     (gt_rx_chariscomma_bus[GT_BYTE_NUM-1:0]                                      ),
    .gt0_rxcharisk_out                                         (gt_rx_charisk_bus[GT_BYTE_NUM-1:0]                                          ),
    .gt0_rxdisperr_out                                         (gt_rx_disperr_bus[GT_BYTE_NUM-1:0]                                          ),
    .gt0_rxnotintable_out                                      (gt_rx_notintable_bus[GT_BYTE_NUM-1:0]                                       ),
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    .gt0_gtprxn_in                                             (rxn_in[0]                                                                   ),
    .gt0_gtprxp_in                                             (rxp_in[0]                                                                   ),
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    .gt0_rxbyteisaligned_out                                   (gt_rx_byteisaligned_bus[0]                                                  ),
    .gt0_rxbyterealign_out                                     (gt_rx_byterealign_bus[0]                                                    ),
    //---------------- Receive Ports - RX Channel Bonding Ports ----------------
    .gt0_rxchanbondseq_out                                     (gt_rx_chanbondseq_bus[0]                                                    ),
    .gt0_rxchbonden_in                                         (gt_rx_chbonden_bus[0]                                                       ),
    .gt0_rxchbondi_in                                          (4'd0                                                                        ),
    .gt0_rxchbondlevel_in                                      (3'b000                                                                      ),
    .gt0_rxchbondmaster_in                                     (1'b1                                                                        ),
    .gt0_rxchbondo_out                                         (gt0_rxchbondo                                                               ),
    .gt0_rxchbondslave_in                                      (1'b0                                                                        ),
    //--------------- Receive Ports - RX Channel Bonding Ports  ----------------
    .gt0_rxchanisaligned_out                                   (gt_rx_chanisaligned_bus[0]                                                  ),
    .gt0_rxchanrealign_out                                     (gt_rx_rxchanrealign_bus[0]                                                  ),
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE                      ) -----------
    .gt0_dmonitorout_out                                       (                                                                            ),
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    .gt0_rxlpmhfhold_in                                        (1'b0                                                                        ),
    .gt0_rxlpmlfhold_in                                        (1'b0                                                                        ),
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    .gt0_rxoutclkfabric_out                                    (                                                                            ),
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    .gt0_gtrxreset_in                                          (1'b0                                                                        ),
    .gt0_rxlpmreset_in                                         (1'b0                                                                        ),
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    .gt0_rxresetdone_out                                       (gt_rx_resetdone_bus[0]                                                      ),
    //------------------- TX Initialization and Reset Ports --------------------
    .gt0_gttxreset_in                                          (1'b0                                                                        ),
    .gt0_txuserrdy_in                                          (1'b1                                                                        ),
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    .gt0_txdata_in                                             (gt_tx_data_bus[GT_LANE_DW-1:0]                                              ),
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
    .gt0_txcharisk_in                                          (gt_tx_charisk_bus[GT_BYTE_NUM-1:0]                                          ),
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    .gt0_gtptxn_out                                            (txn_out[0]                                                                  ),
    .gt0_gtptxp_out                                            (txp_out[0]                                                                  ),
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    .gt0_txoutclkfabric_out                                    (                                                                            ),
    .gt0_txoutclkpcs_out                                       (                                                                            ),
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    .gt0_txresetdone_out                                       (gt_tx_resetdone_bus[0]                                                      ),
    //_____________________________________________________________________
    //_____________________________________________________________________
    //GT1                                                      (X0Y1                     )
    //-------------------------- Channel - DRP Ports  --------------------------
    .gt1_drpaddr_in                                            (9'd0                                                                        ),
    .gt1_drpdi_in                                              (16'd0                                                                       ),
    .gt1_drpdo_out                                             (                                                                            ),
    .gt1_drpen_in                                              (1'b0                                                                        ),
    .gt1_drprdy_out                                            (                                                                            ),
    .gt1_drpwe_in                                              (1'b0                                                                        ),
    //------------------- RX Initialization and Reset Ports --------------------
    .gt1_eyescanreset_in                                       (1'b0                                                                        ),
    .gt1_rxuserrdy_in                                          (1'b1                                                                        ),
    //------------------------ RX Margin Analysis Ports ------------------------
    .gt1_eyescandataerror_out                                  (                                                                            ),
    .gt1_eyescantrigger_in                                     (1'b0                                                                        ),
    //----------------- Receive Ports - Clock Correction Ports -----------------
    .gt1_rxclkcorcnt_out                                       (gt_rx_clkcorcnt_bus[1]                                                       ),
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    .gt1_rxdata_out                                            (gt_rx_data_bus[2*GT_LANE_DW-1:GT_LANE_DW]                                   ),
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    .gt1_rxchariscomma_out                                     (gt_rx_chariscomma_bus[2*GT_BYTE_NUM-1:GT_BYTE_NUM]                          ),
    .gt1_rxcharisk_out                                         (gt_rx_charisk_bus[2*GT_BYTE_NUM-1:GT_BYTE_NUM]                              ),
    .gt1_rxdisperr_out                                         (gt_rx_disperr_bus[2*GT_BYTE_NUM-1:GT_BYTE_NUM]                              ),
    .gt1_rxnotintable_out                                      (gt_rx_notintable_bus[2*GT_BYTE_NUM-1:GT_BYTE_NUM]                           ),
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    .gt1_gtprxn_in                                             (rxn_in[1]                                                                   ),
    .gt1_gtprxp_in                                             (rxp_in[1]                                                                   ),
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    .gt1_rxbyteisaligned_out                                   (gt_rx_byteisaligned_bus[1]                                                  ),
    .gt1_rxbyterealign_out                                     (gt_rx_byterealign_bus[1]                                                    ),
    //---------------- Receive Ports - RX Channel Bonding Ports ----------------
    .gt1_rxchanbondseq_out                                     (gt_rx_chanbondseq_bus[1]                                                    ),
    .gt1_rxchbonden_in                                         (gt_rx_chbonden_bus[1]                                                       ),
    .gt1_rxchbondi_in                                          (gt0_rxchbondo                                                               ),
    .gt1_rxchbondlevel_in                                      (3'b001                                                                      ),
    .gt1_rxchbondmaster_in                                     (1'b0                                                                        ),
    .gt1_rxchbondo_out                                         (gt1_rxchbondo                                                               ),
    .gt1_rxchbondslave_in                                      (1'b1                                                                        ),
    //--------------- Receive Ports - RX Channel Bonding Ports  ----------------
    .gt1_rxchanisaligned_out                                   (gt_rx_chanisaligned_bus[1]                                                  ),
    .gt1_rxchanrealign_out                                     (gt_rx_rxchanrealign_bus[1]                                                  ),
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE                      ) -----------
    .gt1_dmonitorout_out                                       (                                                                            ),
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    .gt1_rxlpmhfhold_in                                        (1'b0                                                                        ),
    .gt1_rxlpmlfhold_in                                        (1'b0                                                                        ),
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    .gt1_rxoutclkfabric_out                                    (                                                                            ),
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    .gt1_gtrxreset_in                                          (1'b0                                                                        ),
    .gt1_rxlpmreset_in                                         (1'b0                                                                        ),
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    .gt1_rxresetdone_out                                       (gt_rx_resetdone_bus[1]                                                      ),
    //------------------- TX Initialization and Reset Ports --------------------
    .gt1_gttxreset_in                                          (1'b0                                                                        ),
    .gt1_txuserrdy_in                                          (1'b1                                                                        ),
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    .gt1_txdata_in                                             (gt_tx_data_bus[2*GT_LANE_DW-1:GT_LANE_DW]                                   ),
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
    .gt1_txcharisk_in                                          (gt_tx_charisk_bus[2*GT_BYTE_NUM-1:GT_BYTE_NUM]                              ),
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    .gt1_gtptxn_out                                            (txn_out[1]                                                                  ),
    .gt1_gtptxp_out                                            (txp_out[1]                                                                  ),
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    .gt1_txoutclkfabric_out                                    (                                                                            ),
    .gt1_txoutclkpcs_out                                       (                                                                            ),
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    .gt1_txresetdone_out                                       (gt_tx_resetdone_bus[1]                                                      ),
    //_____________________________________________________________________
    //_____________________________________________________________________
    //GT2                                                      (X0Y2                     )
    //-------------------------- Channel - DRP Ports  --------------------------
    .gt2_drpaddr_in                                            (9'd0                                                                        ),
    .gt2_drpdi_in                                              (16'd0                                                                       ),
    .gt2_drpdo_out                                             (                                                                            ),
    .gt2_drpen_in                                              (1'b0                                                                        ),
    .gt2_drprdy_out                                            (                                                                            ),
    .gt2_drpwe_in                                              (1'b0                                                                        ),
    //------------------- RX Initialization and Reset Ports --------------------
    .gt2_eyescanreset_in                                       (1'b0                                                                        ),
    .gt2_rxuserrdy_in                                          (1'b1                                                                        ),
    //------------------------ RX Margin Analysis Ports ------------------------
    .gt2_eyescandataerror_out                                  (                                                                            ),
    .gt2_eyescantrigger_in                                     (1'b0                                                                        ),
    //----------------- Receive Ports - Clock Correction Ports -----------------
    .gt2_rxclkcorcnt_out                                       (gt_rx_clkcorcnt_bus[2]                                                     ),
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    .gt2_rxdata_out                                            (gt_rx_data_bus[(GT_LANE-1)*GT_LANE_DW-1:(GT_LANE-2)*GT_LANE_DW]             ),
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    .gt2_rxchariscomma_out                                     (gt_rx_chariscomma_bus[3*GT_BYTE_NUM-1:2*GT_BYTE_NUM]                        ),
    .gt2_rxcharisk_out                                         (gt_rx_charisk_bus[3*GT_BYTE_NUM-1:2*GT_BYTE_NUM]                            ),
    .gt2_rxdisperr_out                                         (gt_rx_disperr_bus[3*GT_BYTE_NUM-1:2*GT_BYTE_NUM]                            ),
    .gt2_rxnotintable_out                                      (gt_rx_notintable_bus[3*GT_BYTE_NUM-1:2*GT_BYTE_NUM]                         ),
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    .gt2_gtprxn_in                                             (rxn_in[2]                                                                   ),
    .gt2_gtprxp_in                                             (rxp_in[2]                                                                   ),
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    .gt2_rxbyteisaligned_out                                   (gt_rx_byteisaligned_bus[2]                                                  ),
    .gt2_rxbyterealign_out                                     (gt_rx_byterealign_bus[2]                                                    ),
    //---------------- Receive Ports - RX Channel Bonding Ports ----------------
    .gt2_rxchanbondseq_out                                     (gt_rx_chanbondseq_bus[2]                                                    ),
    .gt2_rxchbonden_in                                         (gt_rx_chbonden_bus[2]                                                       ),
    .gt2_rxchbondi_in                                          (4'd0                                                                        ),
    .gt2_rxchbondlevel_in                                      (3'b000                                                                      ),
    .gt2_rxchbondmaster_in                                     (1'b1                                                                        ),
    .gt2_rxchbondo_out                                         (gt2_rxchbondo_i                                                             ),
    .gt2_rxchbondslave_in                                      (1'b0                                                                        ),
    //--------------- Receive Ports - RX Channel Bonding Ports  ----------------
    .gt2_rxchanisaligned_out                                   (gt_rx_chanisaligned_bus[2]                                                  ),
    .gt2_rxchanrealign_out                                     (gt_rx_rxchanrealign_bus[2]                                                  ),
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE                      ) -----------
    .gt2_dmonitorout_out                                       (                                                                            ),
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    .gt2_rxlpmhfhold_in                                        (1'b0                                                                        ),
    .gt2_rxlpmlfhold_in                                        (1'b0                                                                        ),
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    .gt2_rxoutclkfabric_out                                    (                                                                            ),
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    .gt2_gtrxreset_in                                          (1'b0                                                                        ),
    .gt2_rxlpmreset_in                                         (1'b0                                                                        ),
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    .gt2_rxresetdone_out                                       (gt_rx_resetdone_bus[2]                                                      ),
    //------------------- TX Initialization and Reset Ports --------------------
    .gt2_gttxreset_in                                          (1'b0                                                                        ),
    .gt2_txuserrdy_in                                          (1'b1                                                                        ),
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    .gt2_txdata_in                                             (gt_tx_data_bus[3*GT_LANE_DW-1:2*GT_LANE_DW]                                 ),
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
    .gt2_txcharisk_in                                          (gt_tx_charisk_bus[3*GT_BYTE_NUM-1:2*GT_BYTE_NUM]                            ),
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    .gt2_gtptxn_out                                            (txn_out[2]                                                                  ),
    .gt2_gtptxp_out                                            (txp_out[2]                                                                  ),
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    .gt2_txoutclkfabric_out                                    (                                                                            ),
    .gt2_txoutclkpcs_out                                       (                                                                            ),
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    .gt2_txresetdone_out                                       (gt_tx_resetdone_bus[2]                                                      ),
    //_____________________________________________________________________
    //_____________________________________________________________________
    //GT3                                                      (X0Y3                     )
    //-------------------------- Channel - DRP Ports  --------------------------
    .gt3_drpaddr_in                                            (9'd0                                                                        ),
    .gt3_drpdi_in                                              (16'd0                                                                       ),
    .gt3_drpdo_out                                             (                                                                            ),
    .gt3_drpen_in                                              (1'b0                                                                        ),
    .gt3_drprdy_out                                            (                                                                            ),
    .gt3_drpwe_in                                              (1'b0                                                                        ),
    //------------------- RX Initialization and Reset Ports --------------------
    .gt3_eyescanreset_in                                       (1'b0                                                                        ),
    .gt3_rxuserrdy_in                                          (1'b1                                                                        ),
    //------------------------ RX Margin Analysis Ports ------------------------
    .gt3_eyescandataerror_out                                  (                                                                            ),
    .gt3_eyescantrigger_in                                     (1'b0                                                                        ),
    //----------------- Receive Ports - Clock Correction Ports -----------------
    .gt3_rxclkcorcnt_out                                       (gt_rx_clkcorcnt_bus[3]                                                    ),
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    .gt3_rxdata_out                                            (gt_rx_data_bus[GT_LANE*GT_LANE_DW-1:(GT_LANE-1)*GT_LANE_DW]                 ),
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    .gt3_rxchariscomma_out                                     (gt_rx_chariscomma_bus[GT_LANE*GT_BYTE_NUM-1:(GT_LANE-1)*GT_BYTE_NUM]        ),
    .gt3_rxcharisk_out                                         (gt_rx_charisk_bus[GT_LANE*GT_BYTE_NUM-1:(GT_LANE-1)*GT_BYTE_NUM]            ),
    .gt3_rxdisperr_out                                         (gt_rx_disperr_bus[GT_LANE*GT_BYTE_NUM-1:(GT_LANE-1)*GT_BYTE_NUM]            ),
    .gt3_rxnotintable_out                                      (gt_rx_notintable_bus[GT_LANE*GT_BYTE_NUM-1:(GT_LANE-1)*GT_BYTE_NUM]         ),
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    .gt3_gtprxn_in                                             (rxn_in[GT_LANE-1]                                                           ),
    .gt3_gtprxp_in                                             (rxp_in[GT_LANE-1]                                                           ),
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    .gt3_rxbyteisaligned_out                                   (gt_rx_byteisaligned_bus[GT_LANE-1]                                          ),
    .gt3_rxbyterealign_out                                     (gt_rx_byterealign_bus[GT_LANE-1]                                            ),
    //---------------- Receive Ports - RX Channel Bonding Ports ----------------
    .gt3_rxchanbondseq_out                                     (gt_rx_chanbondseq_bus[GT_LANE-1]                                            ),
    .gt3_rxchbonden_in                                         (gt_rx_chbonden_bus[GT_LANE-1]                                               ),
    .gt3_rxchbondi_in                                          (gt2_rxchbondo_i                                                             ),
    .gt3_rxchbondlevel_in                                      (3'b001                                                                      ),
    .gt3_rxchbondmaster_in                                     (1'b0                                                                        ),
    .gt3_rxchbondo_out                                         (gt3_rxchbondo_i                                                             ),
    .gt3_rxchbondslave_in                                      (1'b1                                                                        ),
    //--------------- Receive Ports - RX Channel Bonding Ports  ----------------
    .gt3_rxchanisaligned_out                                   (gt_rx_chanisaligned_bus[GT_LANE-1]                                          ),
    .gt3_rxchanrealign_out                                     (gt_rx_rxchanrealign_bus[GT_LANE-1]                                          ),
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE                      ) -----------
    .gt3_dmonitorout_out                                       (                                                                            ),
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    .gt3_rxlpmhfhold_in                                        (1'b0                                                                        ),
    .gt3_rxlpmlfhold_in                                        (1'b0                                                                        ),
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    .gt3_rxoutclkfabric_out                                    (                                                                            ),
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    .gt3_gtrxreset_in                                          (1'b0                                                                        ),
    .gt3_rxlpmreset_in                                         (1'b0                                                                        ),
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    .gt3_rxresetdone_out                                       (gt_rx_resetdone_bus[GT_LANE-1]                                              ),
    //------------------- TX Initialization and Reset Ports --------------------
    .gt3_gttxreset_in                                          (1'b0                                                                        ),
    .gt3_txuserrdy_in                                          (1'b1                                                                        ),
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    .gt3_txdata_in                                             (gt_tx_data_bus[GT_LANE*GT_LANE_DW-1:(GT_LANE-1)*GT_LANE_DW]                 ),
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
    .gt3_txcharisk_in                                          (gt_tx_charisk_bus[GT_LANE*GT_BYTE_NUM-1:(GT_LANE-1)*GT_BYTE_NUM]            ),
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    .gt3_gtptxn_out                                            (txn_out[GT_LANE-1]                                                          ),
    .gt3_gtptxp_out                                            (txp_out[GT_LANE-1]                                                          ),
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    .gt3_txoutclkfabric_out                                    (                                                                            ),
    .gt3_txoutclkpcs_out                                       (                                                                            ),
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    .gt3_txresetdone_out                                       (gt_tx_resetdone_bus[GT_LANE-1]                                              ),
//____________________________COMMON PORTS________________________________
    .gt0_pll0reset_out                                         (                                                                            ),
    .gt0_pll0outclk_out                                        (                                                                            ),
    .gt0_pll0outrefclk_out                                     (                                                                            ),
    .gt0_pll0lock_out                                          (                                                                            ),
    .gt0_pll0refclklost_out                                    (                                                                            ),    
    .gt0_pll1outclk_out                                        (                                                                            ),
    .gt0_pll1outrefclk_out                                     (                                                                            ),
    .sysclk_in                                                 (gt_sys_clk                                                                  )
);

assign gt_usrclk = gt0_txusrclk2;

//GT RST
assign gtp_rst_done = gt_tx_resetdone_bus[GT_LANE-1] & gt_tx_resetdone_bus[GT_LANE-2] & gt_tx_resetdone_bus[GT_LANE-3] & gt_tx_resetdone_bus[0] &
                     gt_rx_resetdone_bus[GT_LANE-1] & gt_rx_resetdone_bus[GT_LANE-2] & gt_rx_resetdone_bus[GT_LANE-3] & gt_rx_resetdone_bus[0] ;

//GT frming
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0] tx_packet_done_bus ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0] tx_packet_start_bus;
wire [DATA_NUM_DW*GT_LANE-1:0]     cfg_tx_data_num_bus ;
reg gt_tran_rdy = 'd0;

always @(posedge gt0_txusrclk2) 
begin
  gt_tran_rdy <= gtp_rst_done && gtx_rst_done;
end

genvar i;
generate
  for (i = 0; i < GT_LANE; i = i+1) 
  begin:u_gtp_fiming
    alpg_gtp_frming # (
      .TX_DW      (GT_LANE_DW   ),
      .TX_NUM_DW  (DATA_NUM_DW  )
    )
    alpg_gtp_frming_inst (
      .clk               (gt0_txusrclk2                                         ),
      .rst               (rst                                                   ),
      .tx_pck_start      (tx_packet_start_bus[i]                                ),
      .tx_pck_suspend    (tx_pck_suspend                                        ),
      .tx_packet_done    (tx_packet_done_bus[i]                                 ),
      .cfg_tx_data_num   (cfg_tx_data_num_bus[(i+1)*DATA_NUM_DW-1:i*DATA_NUM_DW]),
      .tx_data           (tx_data_bus[(i+1)*GT_LANE_DW-1:i*GT_LANE_DW]          ),
      .tx_data_vld       (tx_data_vld_bus[i]                                    ),
      .tx_packet_data_vld(gt_tx_data_vld_bus[i]                                 ),
      .tx_packet_data    (gt_tx_data_bus[(i+1)*GT_LANE_DW-1:i*GT_LANE_DW]       ),
      .tx_charisk        (gt_tx_charisk_bus[(i+1)*GT_BYTE_NUM-1:i*GT_BYTE_NUM]  )
    );
  end
endgenerate

assign tx_packet_start_bus = {{2{tx_pck_start[1]}},{2{tx_pck_start[0]}}};
assign tx_pck_done = tx_packet_done_bus[0] || tx_packet_done_bus[2];
assign cfg_tx_data_num_bus = {{2{cfg_tx_data_num}},{2{cfg_num_tx}}}    ;   //lane0/1 transmit cfg;lane2/3 transmit pattern data

//GT defrm
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0]                 rx_start_bus        ;
(*mark_debug="true"*)(*keep="true"*)wire [GT_LANE-1:0]                 rx_done_bus         ;
wire [DATA_NUM_DW*GT_LANE-1:0]     cfg_rx_data_num_bus ;

generate
  for (i = 0; i < GT_LANE; i = i+1) 
  begin:u_gtp_defrm
    alpg_gtp_defrm # (
      .RX_DW      (GT_LANE_DW   ),
      .RX_NUM_DW  (DATA_NUM_DW  ),
      .RX_DFX_DW  (GT_DFX_DW    )
    )
    alpg_gtp_defrm_inst (
      .rst             (rst                                                       ),
      .clk             (gt0_txusrclk2                                             ),
      .gt_tran_rdy     (gt_tran_rdy                                               ),
      .cfg_rx_data_num (cfg_rx_data_num_bus[(i+1)*DATA_NUM_DW-1:i*DATA_NUM_DW]    ),
      .rx_data         (gt_rx_data_bus[(i+1)*GT_LANE_DW-1:i*GT_LANE_DW]           ),
      .rx_charisk      (gt_rx_charisk_bus[(i+1)*GT_BYTE_NUM-1:i*GT_BYTE_NUM]      ),
      .rx_dfrm_data    (rx_data_bus[(i+1)*GT_LANE_DW-1:i*GT_LANE_DW]              ),
      .rx_dfrm_data_vld(rx_data_vld_bus[i]                                        ),
      .rx_start        (rx_start_bus[i]                                           ),
      .rx_done         (rx_done_bus[i]                                            ),
      .dfx_rx_err      (dfx_rx_err_bus[(i+1)*GT_DFX_DW-1:i*GT_DFX_DW]             )
    );
  end
endgenerate

assign cfg_rx_data_num_bus = {{2{cfg_rx_data_num}},{2{cfg_num_rx}}}    ;   //lane0/1 transmit cfg;lane2/3 transmit pattern data
assign rx_cfg_sof          = rx_start_bus[0]                        ;
assign rx_data_sof         = rx_start_bus[2]                        ;
assign rx_cfg_eof          = rx_done_bus[0]                         ;
assign rx_data_eof         = rx_done_bus[2]                         ;  

endmodule
