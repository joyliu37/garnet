/*=============================================================================
** Module: bank_controller.sv
** Description:
**              bank controller coordinates host-cgra read/write.
**              host read/write has priority
** Author: Taeyoung Kong
** Change history:  04/10/2019 - Implement first version of bank controller
**===========================================================================*/

module bank_controller #(
    parameter integer BANK_DATA_WIDTH = 64,
    parameter integer BANK_ADDR_WIDTH = 16
)
(
    input                           clk,
    input                           reset,

    // interface with host
    input                           host_wr_en,
    input   [BANK_ADDR_WIDTH-1:0]   host_wr_addr,
    input   [BANK_DATA_WIDTH-1:0]   host_wr_data,

    input                           host_rd_en,
    input   [BANK_ADDR_WIDTH-1:0]   host_rd_addr,
    output  [BANK_DATA_WIDTH-1:0]   host_rd_data,

    // interface with cgra
    input                           cgra_wr_en,
    input   [BANK_ADDR_WIDTH-1:0]   cgra_wr_addr,
    input   [BANK_DATA_WIDTH-1:0]   cgra_wr_data,

    input                           cgra_rd_en,
    input   [BANK_ADDR_WIDTH-1:0]   cgra_rd_addr,
    output  [BANK_DATA_WIDTH-1:0]   cgra_rd_data,

    // interface with cfg
    input                           cfg_rd_en,
    input   [BANK_ADDR_WIDTH-1:0]   cfg_rd_addr,
    output  [BANK_DATA_WIDTH-1:0]   cfg_rd_data,

    // interface with memory core
    output                          mem_rd_en,
    output                          mem_wr_en,

    output  [BANK_ADDR_WIDTH-1:0]   mem_addr,
    output  [BANK_DATA_WIDTH-1:0]   mem_data_in,
    input   [BANK_DATA_WIDTH-1:0]   mem_data_out
);

//===========================================================================//
// signal declaration
//===========================================================================//
reg cgra_rd_en_reg;
reg host_rd_en_reg;
reg cfg_rd_en_reg;
reg [BANK_DATA_WIDTH-1:0] cgra_rd_data_reg;
reg [BANK_DATA_WIDTH-1:0] host_rd_data_reg;
reg [BANK_DATA_WIDTH-1:0] cfg_rd_data_reg;

//===========================================================================//
// Set mem_wr_en and mem_data_in output
//===========================================================================//
always_comb begin
    if (host_wr_en) begin
        mem_wr_en = 1;
        mem_rd_en = 0;
        mem_data_in = host_wr_data;
        mem_addr = host_wr_addr;
    end
    else if (host_rd_en) begin
        mem_wr_en = 0;
        mem_rd_en = 1;
        mem_data_in = 0;
        mem_addr = host_rd_addr;
    end
    else if (cfg_rd_en) begin
        mem_wr_en = 0;
        mem_rd_en = 1;
        mem_data_in = 0;
        mem_addr = cfg_rd_addr;
    end
    else if (cgra_wr_en) begin
        mem_wr_en = 1;
        mem_rd_en = 0;
        mem_data_in = cgra_wr_data;
        mem_addr = cgra_wr_addr;
    end
    else if (cgra_rd_en) begin
        mem_wr_en = 0;
        mem_rd_en = 1;
        mem_data_in = 0;
        mem_addr = cgra_rd_addr;
    end
    else begin
        mem_wr_en = 0;
        mem_rd_en = 0;
        mem_data_in = 0;
        mem_addr = 0;
    end
end

//===========================================================================//
// rd_data output assignment
//===========================================================================//
always @(posedge clk or posedge reset) begin
    if (reset) begin
        host_rd_en_reg <= 0;
        cgra_rd_en_reg <= 0;
        cfg_rd_en_reg <= 0;

        host_rd_data_reg <= 0;
        cgra_rd_data_reg <= 0;
        cfg_rd_data_reg <= 0;
    end
    else begin
        host_rd_en_reg <= host_rd_en;
        cgra_rd_en_reg <= cgra_rd_en;
        cfg_rd_en_reg <= cfg_rd_en;
        host_rd_data_reg <= host_rd_data;
        cgra_rd_data_reg <= cgra_rd_data;
        cfg_rd_data_reg <= cfg_rd_data;
    end
end
assign host_rd_data = host_rd_en_reg ? mem_data_out : host_rd_data_reg;
assign cgra_rd_data = cgra_rd_en_reg ? mem_data_out : cgra_rd_data_reg;
assign cfg_rd_data = cfg_rd_en_reg ? mem_data_out : cfg_rd_data_reg;

endmodule
