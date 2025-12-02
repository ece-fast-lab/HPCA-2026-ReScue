// -----------------------------------------------------------------------------
// afu_top_fifo.sv  —  Compact FIFO‑based read‑delay queue (configurable depth)
// -----------------------------------------------------------------------------
//   • Replaces 256‑entry 2‑D array with single FIFO (default 64 entries)
//   • Guarantees a *minimum* delay (cnt_min) per read before response return
//   • Returns responses **in issue order** (simpler timing, far fewer resources)
//   • Full/Almost‑full back‑pressure on AR channel
// -----------------------------------------------------------------------------
`include "cxl_typ3ddr_ed_defines.svh.iv"
import cxlip_top_pkg::*;
import afu_axi_if_pkg::*;

module afu_top #(
    parameter MC_AXI_RRC_DATA_BW = 512,
    parameter MC_AXI_RRC_ID_BW   = 8,
    parameter FIFO_DEPTH         = 64,
    parameter FIFO_ADDR_W        = $clog2(FIFO_DEPTH),
    parameter DELAY_CNT_BITS     = 7,
    parameter DELAY_MAX          = 127,
    parameter logic [56:0] QUEUE_UPDATE_MAGIC = 57'h14DCA8D4E8D3A38
)(
    input  logic                                            afu_clk,
    input  logic                                            afu_rstn,

    // Request path
    input  mc_axi_if_pkg::t_to_mc_axi4 [MC_CHANNEL-1:0]     cxl2afu,
    output mc_axi_if_pkg::t_to_mc_axi4 [MC_CHANNEL-1:0]     afu2mc,

    // Response path from MC
    input  mc_axi_if_pkg::t_from_mc_axi4[MC_CHANNEL-1:0]    mc2afu,
    output mc_axi_if_pkg::t_from_mc_axi4[MC_CHANNEL-1:0]    afu2cxl,

    // Runtime control
    input  logic [63:0]                                     afu_data
);

// ────────── FIFO entry --------------------------------------------------------
typedef struct packed {
    logic                         arvalid;   // request issued
    logic                         rvalid;    // response arrived
    logic [MC_AXI_RRC_ID_BW-1:0]  arid;
    logic [MC_AXI_RRC_DATA_BW-1:0] rdata;
    t_rd_rsp_user                 ruser;
    logic [DELAY_CNT_BITS-1:0]    delay_cnt;
} fifo_t;

fifo_t fifo_q [MC_CHANNEL-1:0][FIFO_DEPTH-1:0];
logic  [FIFO_ADDR_W:0] wr_ptr [MC_CHANNEL-1:0];
logic  [FIFO_ADDR_W:0] rd_ptr [MC_CHANNEL-1:0];
logic  fifo_full   [MC_CHANNEL-1:0];
logic  fifo_empty  [MC_CHANNEL-1:0];
logic  rd_fire     [MC_CHANNEL-1:0];
logic  wr_fire     [MC_CHANNEL-1:0];
logic [DELAY_CNT_BITS-1:0] cnt_min;

// ────────── Counters & flags --------------------------------------------------
for (genvar ch=0; ch<MC_CHANNEL; ch++) begin: g_flag
    assign fifo_full [ch] = ( (wr_ptr[ch][FIFO_ADDR_W] ^ rd_ptr[ch][FIFO_ADDR_W]) &&
                              (wr_ptr[ch][FIFO_ADDR_W-1:0] == rd_ptr[ch][FIFO_ADDR_W-1:0]));
    assign fifo_empty[ch] = (wr_ptr[ch] == rd_ptr[ch]);
end

// ────────── Min‑delay CSR -----------------------------------------------------
always_ff @(posedge afu_clk or negedge afu_rstn) begin
    if (!afu_rstn) cnt_min <= 7'd32;
    else if (afu_data[63:7] == QUEUE_UPDATE_MAGIC) cnt_min <= afu_data[6:0];
end

// ────────── Write side (AR handshake) ----------------------------------------
for (genvar ch=0; ch<MC_CHANNEL; ch++) begin: g_write
    assign wr_fire[ch] = cxl2afu[ch].arvalid & afu2mc[ch].arready & ~fifo_full[ch];

    always_ff @(posedge afu_clk or negedge afu_rstn) begin
        if (!afu_rstn) wr_ptr[ch] <= '0;
        else if (wr_fire[ch]) begin
            fifo_q[ch][wr_ptr[ch][FIFO_ADDR_W-1:0]].arvalid <= 1'b1;
            fifo_q[ch][wr_ptr[ch][FIFO_ADDR_W-1:0]].rvalid <= 1'b0;
            fifo_q[ch][wr_ptr[ch][FIFO_ADDR_W-1:0]].arid   <= cxl2afu[ch].arid;
            fifo_q[ch][wr_ptr[ch][FIFO_ADDR_W-1:0]].delay_cnt<= '0;
            wr_ptr[ch] <= wr_ptr[ch] + 1'b1;
        end
    end
end

// ────────── Response capture --------------------------------------------------
for (genvar ch=0; ch<MC_CHANNEL; ch++) begin: g_rsp
    always_ff @(posedge afu_clk) begin
        if (mc2afu[ch].rvalid) begin
            fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].rvalid <= 1'b1; // relies on in‑order MC
            fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].rdata  <= mc2afu[ch].rdata;
            fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].ruser  <= mc2afu[ch].ruser;
        end
    end
end

// ────────── Delay counter increment ------------------------------------------
for (genvar ch=0; ch<MC_CHANNEL; ch++) begin: g_delay
    always_ff @(posedge afu_clk) begin
        if (!fifo_empty[ch])
            if (fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].arvalid &&
                fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].delay_cnt < DELAY_MAX)
                fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].delay_cnt <=
                    fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].delay_cnt + 1'b1;
    end
end

// ────────── Read side  --------------------------------------------------------
for (genvar ch=0; ch<MC_CHANNEL; ch++) begin: g_read
    assign rd_fire[ch] = ~fifo_empty[ch] &
                         fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].rvalid &
                         (fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].delay_cnt >= cnt_min) &
                         afu2cxl[ch].rready;

    always_ff @(posedge afu_clk or negedge afu_rstn) begin
        if (!afu_rstn) rd_ptr[ch] <= '0;
        else if (rd_fire[ch]) rd_ptr[ch] <= rd_ptr[ch] + 1'b1;
    end

    // Output assignments
    assign afu2cxl[ch].rvalid = rd_fire[ch];
    assign afu2cxl[ch].rdata  = fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].rdata;
    assign afu2cxl[ch].rid    = fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].arid;
    assign afu2cxl[ch].rlast  = rd_fire[ch];
    assign afu2cxl[ch].ruser  = fifo_q[ch][rd_ptr[ch][FIFO_ADDR_W-1:0]].ruser;
    assign afu2cxl[ch].rresp  = t_axi4_resp_encoding'(2'b00);
end

// ────────── Pass‑through for other channels & back‑pressure ------------------
assign afu2mc = cxl2afu;          // forward everything (AR/AW/W paths)
for (genvar ch=0; ch<MC_CHANNEL; ch++) begin: g_backpressure
    assign afu2mc[ch].arvalid = cxl2afu[ch].arvalid & ~fifo_full[ch];
end

assign afu2cxl = mc2afu;          // default → overwrite R above

endmodule