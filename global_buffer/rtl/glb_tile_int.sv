/*=============================================================================
** Module: glb_tile.sv
** Description:
**              Global Buffer Tile
** Author: Taeyoung Kong
** Change history: 01/08/2020 - Implement first version of global buffer tile
**===========================================================================*/
import global_buffer_pkg::*;

module glb_tile_int (
    input  logic                            clk,
    input  logic                            stall,
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

    // stream data
    input  logic [CGRA_DATA_WIDTH-1:0]      stream_data_f2g [CGRA_PER_GLB],
    input  logic [0:0]                      stream_data_valid_f2g [CGRA_PER_GLB],
    output logic [CGRA_DATA_WIDTH-1:0]      stream_data_g2f [CGRA_PER_GLB],
    output logic [0:0]                      stream_data_valid_g2f [CGRA_PER_GLB],

    // Config
    cfg_ifc.master                          if_cfg_est_m,
    cfg_ifc.slave                           if_cfg_wst_s,

    // SRAM Config
    cfg_ifc.master                          if_sram_cfg_est_m,
    cfg_ifc.slave                           if_sram_cfg_wst_s,

    // trigger
    input  logic                            strm_start_pulse,
    input  logic                            pc_start_pulse,

    // interrupt
    output logic [2:0]                      interrupt_pulse,

    // parallel configuration
    input  cgra_cfg_t                       cgra_cfg_jtag_wsti,
    output cgra_cfg_t                       cgra_cfg_jtag_esto,
    input  cgra_cfg_t                       cgra_cfg_pc_wsti,
    output cgra_cfg_t                       cgra_cfg_pc_esto,
    output cgra_cfg_t                       cgra_cfg_g2f [CGRA_PER_GLB]
);

//============================================================================//
// Internal Logic
//============================================================================//
packet_t                strm_packet_r2c;
packet_t                strm_packet_c2r;
wr_packet_t             proc_wr_packet_r2c;
rdrq_packet_t           proc_rdrq_packet_r2c;
rdrs_packet_t           proc_rdrs_packet_c2r;

logic                   stream_f2g_done_pulse;
logic                   stream_g2f_done_pulse;
logic                   pc_done_pulse;

logic                   cfg_store_dma_invalidate_pulse [QUEUE_DEPTH];
logic                   cfg_load_dma_invalidate_pulse [QUEUE_DEPTH];

cgra_cfg_t              cgra_cfg_c2sw;

//============================================================================//
// Configuration registers
//============================================================================//
logic [CGRA_PER_GLB-1:0]    cfg_strm_g2f_mux;
logic [CGRA_PER_GLB-1:0]    cfg_strm_f2g_mux;
logic                       cfg_tile_is_start;
logic                       cfg_tile_is_end;
logic                       cfg_store_dma_on;
logic                       cfg_store_dma_auto_on;
dma_st_header_t             cfg_store_dma_header [QUEUE_DEPTH];
logic                       cfg_load_dma_on;
logic                       cfg_load_dma_auto_on;
dma_ld_header_t             cfg_load_dma_header [QUEUE_DEPTH];
logic                       cfg_pc_dma_on;
dma_pc_header_t             cfg_pc_dma_header;

//============================================================================//
// pipeline registers for stall
//============================================================================//
logic stall_d1, clk_en;
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        stall_d1 <= 0;
    end
    else begin
        stall_d1 <= stall;
    end
end
assign clk_en = !stall_d1;

//============================================================================//
// pipeline registers for start_pulse
//============================================================================//
logic strm_start_pulse_d1, strm_start_pulse_int;
logic pc_start_pulse_d1, pc_start_pulse_int;
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        strm_start_pulse_d1 <= 0;
        pc_start_pulse_d1 <= 0;
    end
    else begin
        strm_start_pulse_d1 <= strm_start_pulse;
        pc_start_pulse_d1 <= pc_start_pulse;
    end
end
assign strm_start_pulse_int = strm_start_pulse_d1;
assign pc_start_pulse_int = pc_start_pulse_d1;

//============================================================================//
// pipeline registers for interrupt
//============================================================================//
logic [2:0] interrupt_pulse_int, interrupt_pulse_int_d1;
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        interrupt_pulse_int_d1 <= '0;
    end
    else begin
        interrupt_pulse_int_d1 <= interrupt_pulse_int;
    end
end
assign interrupt_pulse = interrupt_pulse_int_d1;

//============================================================================//
// Configuration Controller
//============================================================================//
glb_tile_cfg glb_tile_cfg (.*);

//============================================================================//
// Global Buffer Core
//============================================================================//
glb_core glb_core (
    .interrupt_pulse    (interrupt_pulse_int),
    .strm_start_pulse   (strm_start_pulse_int),
    .pc_start_pulse     (pc_start_pulse_int),
    .*);

//============================================================================//
// CGRA configuration switch
//============================================================================//
glb_tile_cgra_cfg_switch glb_tile_cgra_cfg_switch (.*);

endmodule
