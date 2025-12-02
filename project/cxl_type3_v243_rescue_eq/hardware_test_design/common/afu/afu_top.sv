`include "cxl_typ3ddr_ed_defines.svh.iv"
import cxlip_top_pkg::*;
import afu_axi_if_pkg::*;

module afu_top(
    
    input  logic                                             afu_clk,
    input  logic                                             afu_rstn,
     // April 2023 - Supporting out of order responses with AXI4
    input mc_axi_if_pkg::t_to_mc_axi4    [MC_CHANNEL-1:0] cxlip2iafu_to_mc_axi4,
    output mc_axi_if_pkg::t_to_mc_axi4   [MC_CHANNEL-1:0] iafu2mc_to_mc_axi4 ,
    input mc_axi_if_pkg::t_from_mc_axi4  [MC_CHANNEL-1:0] mc2iafu_from_mc_axi4,
    output mc_axi_if_pkg::t_from_mc_axi4 [MC_CHANNEL-1:0] iafu2cxlip_from_mc_axi4,
    // Delay Control Port
    input  logic [63:0] afu_data
);

/*  PPR Local Param */
  localparam MC_AXI_ADDR_BW    = 52; // addr  - using bits 51:6 of 64-bits, also grabbing the lower 6 bits?
  localparam MC_AXI_RRC_ID_BW   =  8; // rid
  localparam MC_AXI_RRC_DATA_BW = 512; // rdata

  localparam FIFO_DEPTH = 64; // FIFO depth for read response queu
  localparam FIFO_ADDR_W = $clog2(FIFO_DEPTH);

  localparam DELAY_CNT_BITS = 7; // Min Dealy 127 counter = 127 * 2.5ns = 317.5ns
  localparam MAX_CNT = 127; // Min Dealy 127 counter = 127 * 2.5ns = 317.5ns
  localparam ID_BITS = 8; // useful ID bits
  localparam ID_AMT = 256; // # Valid IDs
  localparam logic [56:0] QUEUE_UPDATE_MAGIC = 57'b101000110101110010100011010111001010001101011100111000101;

  typedef struct packed {

	logic poison;
  } t_rd_rsp_user;

  typedef struct packed {// Define the queue type
      logic [MC_AXI_RRC_ID_BW-1:0]                  arid;
      logic [MC_AXI_RRC_DATA_BW-1:0]                rdata;
      logic                                         arvalid;
	  logic                                         rvalid;
	  t_rd_rsp_user                                 ruser;
      logic [DELAY_CNT_BITS-1:0]                    delay_cnt; // Delay counter for response    
  } queue_ritem_t;

// Command queue for storing read commands
  queue_ritem_t  resp_rqueue[MC_CHANNEL-1:0][FIFO_DEPTH-1:0];
  logic  [FIFO_ADDR_W:0] wr_ptr [MC_CHANNEL-1:0];
  logic  [FIFO_ADDR_W:0] rd_ptr [MC_CHANNEL-1:0];
  logic  [FIFO_ADDR_W:0] rd_mc_ptr [MC_CHANNEL-1:0];

  logic  fifo_full[MC_CHANNEL-1:0];
  logic  fifo_empty[MC_CHANNEL-1:0];

//   logic  rd_fire[MC_CHANNEL-1:0];
//   logic  wr_fire[MC_CHANNEL-1:0];
  logic ar_valid[MC_CHANNEL-1:0]; //wr_fire
  logic resp_out[MC_CHANNEL-1:0]; //rd_fire

  logic [ID_BITS:0] fifo_cnt[MC_CHANNEL-1:0];

  logic [DELAY_CNT_BITS-1:0] cnt_min;

    // # of Min Delay for Response Queue

    generate
        for (genvar i = 0; i < MC_CHANNEL; i++) begin // Both arvalid and awvalid are not '1' at the same time.
            assign ar_valid[i] = cxlip2iafu_to_mc_axi4[i].arvalid && mc2iafu_from_mc_axi4[i].arready && ~fifo_full[i];
            assign resp_out[i] = ~fifo_empty[i] && resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].rvalid && (resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].delay_cnt >= cnt_min);
            assign fifo_full[i] = ((wr_ptr[i][FIFO_ADDR_W] ^ rd_ptr[i][FIFO_ADDR_W]) && (wr_ptr[i][FIFO_ADDR_W-1:0] == rd_ptr[i][FIFO_ADDR_W-1:0]));
            assign fifo_empty[i] = (wr_ptr[i] == rd_ptr[i]);
        end
    endgenerate   

    always_ff @(posedge afu_clk) begin
        if (!afu_rstn) cnt_min <= 7'd32;
        else if (afu_data[63:7] == QUEUE_UPDATE_MAGIC) cnt_min <= afu_data[6:0];
    end


    always_ff @(posedge afu_clk) begin
        for (int i = 0; i < MC_CHANNEL; i++) begin
            if (!afu_rstn) begin
            wr_ptr[i] <= '0;
            rd_ptr[i] <= '0;
            rd_mc_ptr[i] <= '0;
            for (int j = 0; j < FIFO_DEPTH; j++) begin
                resp_rqueue[i][j] <= '0;
            end
            end else begin

            // Write side (AR channel)
            if (ar_valid[i]) begin
                resp_rqueue[i][wr_ptr[i][FIFO_ADDR_W-1:0]].arvalid <= 1'b1;
                resp_rqueue[i][wr_ptr[i][FIFO_ADDR_W-1:0]].rvalid <= 1'b0;
                resp_rqueue[i][wr_ptr[i][FIFO_ADDR_W-1:0]].arid   <= cxlip2iafu_to_mc_axi4[i].arid;
                resp_rqueue[i][wr_ptr[i][FIFO_ADDR_W-1:0]].delay_cnt <= '0;
                wr_ptr[i] <= wr_ptr[i] + 1;
            end

            // MC response (assumed in-order) //rd_mc_ptr[ch][FIFO_ADDR_W-1:0];
            if (mc2iafu_from_mc_axi4[i].rvalid) begin
                resp_rqueue[i][rd_mc_ptr[i][FIFO_ADDR_W-1:0]].rvalid <= 1'b1;
                resp_rqueue[i][rd_mc_ptr[i][FIFO_ADDR_W-1:0]].rdata  <= mc2iafu_from_mc_axi4[i].rdata;
                resp_rqueue[i][rd_mc_ptr[i][FIFO_ADDR_W-1:0]].ruser  <= mc2iafu_from_mc_axi4[i].ruser;
                rd_mc_ptr[i] <= rd_mc_ptr[i] + 1;
            end

            // Delay counter update
            for (int j = 0; j < FIFO_DEPTH; j++) begin
                if (resp_rqueue[i][j].arvalid && resp_rqueue[i][j].delay_cnt < MAX_CNT)
                resp_rqueue[i][j].delay_cnt <= resp_rqueue[i][j].delay_cnt + 1;
            end

            // Read side (if delay met)
            if (resp_out[i]) begin
                resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].arvalid <= 1'b0;
                resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].rvalid  <= 1'b0;
                resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].delay_cnt <= '0;
                rd_ptr[i] <= rd_ptr[i] + 1;
            end
    end
  end
end


generate
  for (genvar i = 0; i < MC_CHANNEL; i++) begin : gen_assign

    // AW Channel
    assign iafu2mc_to_mc_axi4[i].awid    = cxlip2iafu_to_mc_axi4[i].awid;
    assign iafu2mc_to_mc_axi4[i].awaddr  = cxlip2iafu_to_mc_axi4[i].awaddr;
    
    assign iafu2mc_to_mc_axi4[i].awvalid = cxlip2iafu_to_mc_axi4[i].awvalid && ~fifo_full[i]; ///

    assign iafu2mc_to_mc_axi4[i].awlen   = cxlip2iafu_to_mc_axi4[i].awlen;
    assign iafu2mc_to_mc_axi4[i].awsize  = cxlip2iafu_to_mc_axi4[i].awsize;
    assign iafu2mc_to_mc_axi4[i].awburst = cxlip2iafu_to_mc_axi4[i].awburst;
    assign iafu2mc_to_mc_axi4[i].awprot  = cxlip2iafu_to_mc_axi4[i].awprot;
    assign iafu2mc_to_mc_axi4[i].awqos   = cxlip2iafu_to_mc_axi4[i].awqos;
    assign iafu2mc_to_mc_axi4[i].awcache = cxlip2iafu_to_mc_axi4[i].awcache;
    assign iafu2mc_to_mc_axi4[i].awlock  = cxlip2iafu_to_mc_axi4[i].awlock;
    assign iafu2mc_to_mc_axi4[i].awregion= cxlip2iafu_to_mc_axi4[i].awregion;
    assign iafu2mc_to_mc_axi4[i].awuser  = cxlip2iafu_to_mc_axi4[i].awuser;

    // W Channel
    // wid (write data id) : Not implemented in AXI4.
    assign iafu2mc_to_mc_axi4[i].wdata   = cxlip2iafu_to_mc_axi4[i].wdata;
    assign iafu2mc_to_mc_axi4[i].wstrb   = cxlip2iafu_to_mc_axi4[i].wstrb;
    assign iafu2mc_to_mc_axi4[i].wuser   = cxlip2iafu_to_mc_axi4[i].wuser;

    assign iafu2mc_to_mc_axi4[i].wlast   = cxlip2iafu_to_mc_axi4[i].wlast;
    assign iafu2mc_to_mc_axi4[i].wvalid  = cxlip2iafu_to_mc_axi4[i].wvalid && ~fifo_full[i]; ///
    // B Channel
    assign iafu2mc_to_mc_axi4[i].bready  = cxlip2iafu_to_mc_axi4[i].bready; // IP ready to accept write response
    // AR Channel
    assign iafu2mc_to_mc_axi4[i].arid    = cxlip2iafu_to_mc_axi4[i].arid;
    assign iafu2mc_to_mc_axi4[i].araddr  = cxlip2iafu_to_mc_axi4[i].araddr;

    assign iafu2mc_to_mc_axi4[i].arvalid = cxlip2iafu_to_mc_axi4[i].arvalid && ~fifo_full[i];
    
    assign iafu2mc_to_mc_axi4[i].arlen   = cxlip2iafu_to_mc_axi4[i].arlen;
    assign iafu2mc_to_mc_axi4[i].arsize  = cxlip2iafu_to_mc_axi4[i].arsize;
    assign iafu2mc_to_mc_axi4[i].arburst = cxlip2iafu_to_mc_axi4[i].arburst;

    //assign iafu2mc_to_mc_axi4[i].arprot = cxlip2iafu_to_mc_axi4[i].arprot;
    assign iafu2mc_to_mc_axi4[i].arprot = t_axi4_prot_encoding'({3'b000});

    assign iafu2mc_to_mc_axi4[i].arqos   = cxlip2iafu_to_mc_axi4[i].arqos;
    assign iafu2mc_to_mc_axi4[i].arcache = cxlip2iafu_to_mc_axi4[i].arcache;
    assign iafu2mc_to_mc_axi4[i].arlock  = cxlip2iafu_to_mc_axi4[i].arlock;
    assign iafu2mc_to_mc_axi4[i].arregion= cxlip2iafu_to_mc_axi4[i].arregion;
    assign iafu2mc_to_mc_axi4[i].aruser  = cxlip2iafu_to_mc_axi4[i].aruser;
    // R Channel
    assign iafu2mc_to_mc_axi4[i].rready  = cxlip2iafu_to_mc_axi4[i].rready; // IP ready to accept read data 

	 
    //assign iafu2cxlip_from_mc_axi4[i] = mc2iafu_from_mc_axi4[i];


    // AW Channel      
    assign iafu2cxlip_from_mc_axi4[i].awready = mc2iafu_from_mc_axi4[i].awready && ~fifo_full[i];  // HDM ready to accept write address  
    // W Channel 
    assign iafu2cxlip_from_mc_axi4[i].wready  = mc2iafu_from_mc_axi4[i].wready && ~fifo_full[i];   // HDM ready to accept write data indicator
    // AR Channel
    assign iafu2cxlip_from_mc_axi4[i].arready = mc2iafu_from_mc_axi4[i].arready && ~fifo_full[i];  //HDM ready to accept read address
    // B Channel
    assign iafu2cxlip_from_mc_axi4[i].bid     = mc2iafu_from_mc_axi4[i].bid;
    assign iafu2cxlip_from_mc_axi4[i].bvalid  = mc2iafu_from_mc_axi4[i].bvalid;
    // R Channel
    assign iafu2cxlip_from_mc_axi4[i].rid     = resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].arid;
    assign iafu2cxlip_from_mc_axi4[i].rdata   = resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].rdata;
    assign iafu2cxlip_from_mc_axi4[i].rvalid  = resp_out[i];
    assign iafu2cxlip_from_mc_axi4[i].rlast   = resp_out[i];
    assign iafu2cxlip_from_mc_axi4[i].ruser   = resp_rqueue[i][rd_ptr[i][FIFO_ADDR_W-1:0]].ruser;
    
    // Static Values //
    assign iafu2cxlip_from_mc_axi4[i].bresp   = t_axi4_resp_encoding'(2'b00);      
    assign iafu2cxlip_from_mc_axi4[i].buser   = 1'b0;  
    assign iafu2cxlip_from_mc_axi4[i].rresp   = t_axi4_resp_encoding'(2'b00);      

  end
endgenerate

endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "H5Me4muwCdD0wBXpIwtSHqPANYFBkFppw7IUkQY+I8Y1cqEvwrQMxWqFMKwLm7G0oFI/8qM3gg9Ahkl/UuJRsLliGlwrzfpbgyM86R6Oz+qDL3K9O8Cc5Du/d7O8jr9kfynJFusl+KRffoROdl/hjYcFVztTZhZpmGHP5EapDR6DhG5+wyFFiSW/nl+Sd3PVKcYLM0BKR+BADBGrQc8x46ziuT5BxFLwpeqcvs+Mz8EwfWzxUMaLpABbguB+pM2xGHa0rGNji+wxwz2f7U0UFNG/Cg8+gsnN4Sx5hCThb4sSUpSzkwN1HIHy5ZcU4pReSv5+DrUqpqN6S7JvaX3JZE8EIcbi3PFUd50ZY+1fAO/UpMiDyHUk1vPjrCbMYRPOiQZCh7geQmpbZbRypFN5SpligDHf+ysJ09uvgUYb1RUaBR3p/NrQ+j9ww8dbrZOI49bfqNsMHRI6QFVkSRWHEaG2N1/rCmYRXdtAvAOmiyKHFwXFy35X6/4QVQI4FGVJfyNTctNuX1sfs2ukDmITFOSae7BcHBKZhbrS7dZwFtKpxotOCMgMfzc0UWnd/OMBDX/pLqeog0nr/XiizzahMsg/h3XPSLS6xYdkgtKReiy7JClQlUhapHQE2rQforFrFPjmvv5mdSy/61yRlUsU1aNXcrTcqsFJGlkFh1aD8IPfJWYjP976Gr+EfA7WncdpyfL6NXUubgDJGdzFoyhov+HJ3FMoG6D9v1QiiD4Wd3uz5lbR8mDzcx5XdxxR3PzMCxs9GFmxB19qMMINY9l+35ikTgKiam0NGqok0zGsT+aACOVVsSoy9V301MsKc8ZKgaKU4awWceqdumXqdO7WyhbmohIXQ1H1q3A/sRuqv0spiLHOIqPesjndTUGwiNKTOLMOXStNDhVLtUkvmFgZVANgzmKMAftGDKevYC/I7f+LCCnujIovSReBdFSXCRrdMdOl4iw/r667uBILSfHEwc+xe/+o/D9ydGrr10yCSlFEfxo1r+rOwhqKB6RzhWqx"
`endif