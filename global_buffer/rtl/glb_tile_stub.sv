import global_buffer_pkg::*;

module glb_tile (
    input  logic                            clk,
    input  logic                            clk_en,
    input  logic                            reset,
    input  logic [TILE_SEL_ADDR_WIDTH-1:0]  glb_tile_id,

    // processor packet
    input  packet_t                         proc_packet_w2e_wsti,
    output packet_t                         proc_packet_e2w_wsto,
    input  packet_t                         proc_packet_e2w_esti,
    output packet_t                         proc_packet_w2e_esto,

    // stream packet
    input  packet_t                         strm_packet_w2e_wsti,
    output packet_t                         strm_packet_e2w_wsto,
    input  packet_t                         strm_packet_e2w_esti,
    output packet_t                         strm_packet_w2e_esto,

    // stream data f2g
    input  logic [CGRA_DATA_WIDTH-1:0]      stream_data_f2g [CGRA_PER_GLB],
    input  logic [0:0]                      stream_data_valid_f2g [CGRA_PER_GLB],
    // stream data g2f
    output logic [CGRA_DATA_WIDTH-1:0]      stream_data_g2f [CGRA_PER_GLB],
    output logic [0:0]                      stream_data_valid_g2f [CGRA_PER_GLB],

    // Config
    // cfg_ifc.master                          if_cfg_est_m,
    output logic                            if_cfg_est_m_wr_en,
    output logic                            if_cfg_est_m_wr_clk_en,
    output logic [AXI_ADDR_WIDTH-1:0]       if_cfg_est_m_wr_addr,
    output logic [AXI_DATA_WIDTH-1:0]       if_cfg_est_m_wr_data,
    output logic                            if_cfg_est_m_rd_en,
    output logic                            if_cfg_est_m_rd_clk_en,
    output logic [AXI_ADDR_WIDTH-1:0]       if_cfg_est_m_rd_addr,
    input  logic [AXI_DATA_WIDTH-1:0]       if_cfg_est_m_rd_data,
    input  logic                            if_cfg_est_m_rd_data_valid,

    // cfg_ifc.slave                           if_cfg_wst_s,
    input  logic                            if_cfg_wst_s_wr_en,
    input  logic                            if_cfg_wst_s_wr_clk_en,
    input  logic [AXI_ADDR_WIDTH-1:0]       if_cfg_wst_s_wr_addr,
    input  logic [AXI_DATA_WIDTH-1:0]       if_cfg_wst_s_wr_data,
    input  logic                            if_cfg_wst_s_rd_en,
    input  logic                            if_cfg_wst_s_rd_clk_en,
    input  logic [AXI_ADDR_WIDTH-1:0]       if_cfg_wst_s_rd_addr,
    output logic [AXI_DATA_WIDTH-1:0]       if_cfg_wst_s_rd_data,
    output logic                            if_cfg_wst_s_rd_data_valid,

    // SRAM Config
    // cfg_ifc.master                          if_sram_cfg_est_m,
    output logic                            if_sram_cfg_est_m_wr_en,
    output logic                            if_sram_cfg_est_m_wr_clk_en,
    output logic [GLB_ADDR_WIDTH-1:0]       if_sram_cfg_est_m_wr_addr,
    output logic [CGRA_CFG_DATA_WIDTH-1:0]  if_sram_cfg_est_m_wr_data,
    output logic                            if_sram_cfg_est_m_rd_en,
    output logic                            if_sram_cfg_est_m_rd_clk_en,
    output logic [GLB_ADDR_WIDTH-1:0]       if_sram_cfg_est_m_rd_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]  if_sram_cfg_est_m_rd_data,
    input  logic                            if_sram_cfg_est_m_rd_data_valid,

    // cfg_ifc.slave                           if_sram_cfg_wst_s,
    input  logic                            if_sram_cfg_wst_s_wr_en,
    input  logic                            if_sram_cfg_wst_s_wr_clk_en,
    input  logic [GLB_ADDR_WIDTH-1:0]       if_sram_cfg_wst_s_wr_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]  if_sram_cfg_wst_s_wr_data,
    input  logic                            if_sram_cfg_wst_s_rd_en,
    input  logic                            if_sram_cfg_wst_s_rd_clk_en,
    input  logic [GLB_ADDR_WIDTH-1:0]       if_sram_cfg_wst_s_rd_addr,
    output logic [CGRA_CFG_DATA_WIDTH-1:0]  if_sram_cfg_wst_s_rd_data,
    output logic                            if_sram_cfg_wst_s_rd_data_valid,

    // trigger
    input  logic [NUM_GLB_TILES-1:0]        strm_start_pulse_wsti,
    output logic [NUM_GLB_TILES-1:0]        strm_start_pulse_esto,
    input  logic [NUM_GLB_TILES-1:0]        pc_start_pulse_wsti,
    output logic [NUM_GLB_TILES-1:0]        pc_start_pulse_esto,

    // interrupt
    input  logic [3*NUM_GLB_TILES-1:0]      interrupt_pulse_esti,
    output logic [3*NUM_GLB_TILES-1:0]      interrupt_pulse_wsto,

    // parallel configuration
    input  cgra_cfg_t                       cgra_cfg_jtag_wsti,
    output cgra_cfg_t                       cgra_cfg_jtag_esto,
    input  cgra_cfg_t                       cgra_cfg_pc_wsti,
    output cgra_cfg_t                       cgra_cfg_pc_esto,
    output logic [0:0]                      cgra_cfg_g2f_cfg_wr_en [CGRA_PER_GLB],
    output logic [0:0]                      cgra_cfg_g2f_cfg_rd_en [CGRA_PER_GLB],
    output logic [CGRA_CFG_ADDR_WIDTH-1:0]  cgra_cfg_g2f_cfg_addr [CGRA_PER_GLB],
    output logic [CGRA_CFG_DATA_WIDTH-1:0]  cgra_cfg_g2f_cfg_data [CGRA_PER_GLB]
);
endmodule
