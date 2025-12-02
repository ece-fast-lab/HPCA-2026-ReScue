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
    // Bloom Filter Control Port
    input  logic [63:0] afu_data
);

/*  PPR Local Param */
  localparam MC_AXI_ADDR_BW    = 52; // addr  - using bits 51:6 of 64-bits, also grabbing the lower 6 bits?
  localparam FIFO_DEPTH = 512;  // Number of elements in the FIFO 25ns x 128
  localparam FIFO_ADDR_WIDTH = $clog2(FIFO_DEPTH);
  localparam ID_BITS = 8; // useful ID bits
  localparam ID_AMT = 256; // # Valid IDs
  localparam MC_AXI_RRC_ID_BW   =  12;
  localparam logic [53:0] QUEUE_UPDATE_MAGIC = 54'b101000110101110010100011010111001010001101011100111000;
  /*  Type Definition */
  typedef enum logic {  //CMD type
      RD    = 1'b0, 
      WR    = 1'b1
  } cmd_t;

  typedef struct packed {// Define the queue type
      logic [MC_AXI_ADDR_BW-1:0]              addr;
      logic [AFU_AXI_MAX_ID_WIDTH-1:0]                id;
      logic [AFU_AXI_MAX_ID_WIDTH-1:0]                wid;
      logic [AFU_AXI_MAX_DATA_WIDTH-1:0]              wdata;
      logic [AFU_AXI_MAX_DATA_WIDTH/8-1:0]            wstrb;
      t_axi4_wuser             		 	                  wuser;  
      cmd_t                                           cmd;
      logic                                           valid;
  } queue_item_t;

  // Command queue for storing read and write commands
  queue_item_t  cmd_queue[MC_CHANNEL-1:0][FIFO_DEPTH-1:0];  // Dummy READ CMD fifo : return data is in-order

  logic ar_valid[MC_CHANNEL-1:0];
  logic aw_valid[MC_CHANNEL-1:0];

  // logic [MC_CHANNEL-1:0][MC_AXI_RRC_ID_BW-1:0] id_tracker_r;
  // logic [MC_CHANNEL-1:0][ID_AMT-1:0] queue_tracker_r;
  logic nstall[MC_CHANNEL-1:0], tag_conflict_r[MC_CHANNEL-1:0], tag_conflict_w[MC_CHANNEL-1:0];

  logic [MC_CHANNEL-1:0][ID_AMT-1:0] queue_tracker_r, queue_tracker_w;
  logic ready[MC_CHANNEL-1:0];
  logic [MC_CHANNEL-1:0][ID_BITS-1:0] queue_cnt_w;
  logic [9:0] queue_max;

  // Generate block for per-channel logic, including fault detection and FIFO management
  generate
  for (genvar i = 0; i < MC_CHANNEL; i++) begin // Both arvalid and awvalid are not '1' at the same time.
    assign ready[i] = mc2iafu_from_mc_axi4[i].arready && mc2iafu_from_mc_axi4[i].awready;
    assign ar_valid[i] = cxlip2iafu_to_mc_axi4[i].arvalid && ready[i] && nstall[i];
    assign aw_valid[i] = cxlip2iafu_to_mc_axi4[i].awvalid && ready[i] && nstall[i];
    assign tag_conflict_r[i]     = cxlip2iafu_to_mc_axi4[i].arvalid && queue_tracker_r[i][cxlip2iafu_to_mc_axi4[i].arid[ID_BITS-1:0]];
    assign tag_conflict_w[i]     = cxlip2iafu_to_mc_axi4[i].awvalid && (queue_cnt_w[i] > queue_max);
    assign nstall[i] = !tag_conflict_r[i] && !tag_conflict_w[i];
    //assign nstall[i] = 1'b1;
  end
  endgenerate

  always @(posedge afu_clk) begin
            if (!afu_rstn) begin
                queue_max <= 10'd256; // Default queue max size
            end else begin
                if ((afu_data[63:10]==QUEUE_UPDATE_MAGIC) ) begin
                    queue_max <= afu_data[9:0];
                end else begin
                    queue_max <= queue_max;
                end

            end
    end



  always @(posedge afu_clk) begin
      for (int i=0; i < MC_CHANNEL; i++) begin
          if (~afu_rstn) begin  // On reset, initialize write pointers and addresses
                    queue_tracker_r[i]	  <= '0;
                    queue_tracker_w[i]	  <= '0;
                    queue_cnt_w[i]     <= '0;
          end else begin        // update write pointers and queue items
                    logic delta_plus = 0;
                    logic delta_minus = 0;

                    if (ar_valid[i]) begin
                    queue_tracker_r[i][cxlip2iafu_to_mc_axi4[i].arid[ID_BITS-1:0]] <= 1'b1;
                    end
                    if (iafu2cxlip_from_mc_axi4[i].rvalid) begin
                    queue_tracker_r[i][iafu2cxlip_from_mc_axi4[i].rid[ID_BITS-1:0]] <= 1'b0;
                    end
                    if (aw_valid[i]) begin
                    queue_tracker_w[i][cxlip2iafu_to_mc_axi4[i].awid[ID_BITS-1:0]] <= 1'b1;
                    delta_plus = 1;
                    end
                    if (iafu2cxlip_from_mc_axi4[i].bvalid) begin
                    queue_tracker_w[i][iafu2cxlip_from_mc_axi4[i].bid[ID_BITS-1:0]] <= 1'b0;
                    delta_minus = 1;
                    end

                    // Handle write queue tracking and count delta
 
                 // Apply delta updates at the end of the cycle
                  queue_cnt_w[i] <= queue_cnt_w[i] + delta_plus - delta_minus;


          end
      end
  end


  // FIFO write operations and command queue updates
  always @(posedge afu_clk) begin
      for (int i=0; i < MC_CHANNEL; i++) begin
          if (~afu_rstn) begin  // On reset, initialize write pointers and addresses
                    cmd_queue[i][0].valid    <= 1'b0;
          end else begin        // update write pointers and queue items
            if (ready[i] && nstall[i]) begin
              if (ar_valid[i]) begin   // Store read command details in the command queue based on the write address pointer
                    cmd_queue[i][0].addr   <= cxlip2iafu_to_mc_axi4[i].araddr;
                    cmd_queue[i][0].id     <= cxlip2iafu_to_mc_axi4[i].arid;
                    cmd_queue[i][0].wid     <= '0;
                    cmd_queue[i][0].wdata  <= {AFU_AXI_MAX_DATA_WIDTH{1'b0}};
                    cmd_queue[i][0].wstrb  <= {AFU_AXI_MAX_DATA_WIDTH/8{1'b0}};
                    cmd_queue[i][0].wuser  <= t_axi4_wuser'(1'b0);
                    cmd_queue[i][0].cmd    <= RD;
                    cmd_queue[i][0].valid    <= 1'b1;
              end else if (aw_valid[i]) begin
                    cmd_queue[i][0].addr   <= cxlip2iafu_to_mc_axi4[i].awaddr;
                    cmd_queue[i][0].id     <= '0;
                    cmd_queue[i][0].wid     <= cxlip2iafu_to_mc_axi4[i].awid;
                    cmd_queue[i][0].wdata  <= cxlip2iafu_to_mc_axi4[i].wdata;
                    cmd_queue[i][0].wstrb  <=  cxlip2iafu_to_mc_axi4[i].wstrb;
                    cmd_queue[i][0].wuser  <= cxlip2iafu_to_mc_axi4[i].wuser;
                    cmd_queue[i][0].cmd    <= WR;
                    cmd_queue[i][0].valid    <= 1'b1;
              end else begin
                    cmd_queue[i][0].valid    <= 1'b0;
              end
            end else if (ready[i] && !nstall[i]) begin
              cmd_queue[i][0].valid    <= 1'b0;
            end else begin
              cmd_queue[i][0] <= cmd_queue[i][0];
            end

          end
      end
  end

  // FIFO write operations and command queue updates
  always @(posedge afu_clk) begin
      for (int i=0; i < MC_CHANNEL; i++) begin
        for (int j=0; j < FIFO_DEPTH-1 ; j++)
          if (~afu_rstn) begin  // On reset, initialize write pointers and addresses
              cmd_queue[i][j+1].valid    <= 1'b0;
          end else begin        // update write pointers and queue items
            if (ready[i]) begin
              cmd_queue[i][j+1]   <= cmd_queue[i][j];
            end else begin
              cmd_queue[i][j+1] <= cmd_queue[i][j+1];
            end

          end
      end
  end

    generate
      for (genvar i = 0; i < MC_CHANNEL; i++) begin : gen_assign

        // FIFO Control

        // AW Channel
        assign iafu2mc_to_mc_axi4[i].awid    = cmd_queue[i][FIFO_DEPTH-1].wid;
        assign iafu2mc_to_mc_axi4[i].awaddr  = cmd_queue[i][FIFO_DEPTH-1].addr;
        assign iafu2mc_to_mc_axi4[i].awvalid = (cmd_queue[i][FIFO_DEPTH-1].cmd == WR ? cmd_queue[i][FIFO_DEPTH-1].valid : 1'b0) && ready[i];//&& nstall[i];
        // W Channel
        // wid (write data id) : Not implemented in AXI4.
        assign iafu2mc_to_mc_axi4[i].wdata   = cmd_queue[i][FIFO_DEPTH-1].wdata;
        assign iafu2mc_to_mc_axi4[i].wstrb   = cmd_queue[i][FIFO_DEPTH-1].wstrb;
        assign iafu2mc_to_mc_axi4[i].wuser   = cmd_queue[i][FIFO_DEPTH-1].wuser;

        // AR Channel
        assign iafu2mc_to_mc_axi4[i].arid    = cmd_queue[i][FIFO_DEPTH-1].id;
        assign iafu2mc_to_mc_axi4[i].araddr  = cmd_queue[i][FIFO_DEPTH-1].addr;
        assign iafu2mc_to_mc_axi4[i].arvalid = (cmd_queue[i][FIFO_DEPTH-1].cmd == RD ? cmd_queue[i][FIFO_DEPTH-1].valid : 1'b0) && ready[i];//&& nstall[i];

        // AW Channel      
        assign iafu2cxlip_from_mc_axi4[i].awready = ready[i] && nstall[i];  // HDM ready to accept write address  
        // W Channel 
        assign iafu2cxlip_from_mc_axi4[i].wready  = ready[i] && nstall[i];   // HDM ready to accept write data indicator
        // AR Channel
        assign iafu2cxlip_from_mc_axi4[i].arready = ready[i] && nstall[i];  //HDM ready to accept read address


        // Static Values //
        // AW Channel
        assign iafu2mc_to_mc_axi4[i].awlen   = 10'd0;
        assign iafu2mc_to_mc_axi4[i].awsize  = t_axi4_burst_size_encoding'(3'b110);
        assign iafu2mc_to_mc_axi4[i].awburst = t_axi4_burst_encoding'(2'b00);
        assign iafu2mc_to_mc_axi4[i].awprot  = t_axi4_prot_encoding'(3'b000);
        assign iafu2mc_to_mc_axi4[i].awqos   = t_axi4_qos_encoding'(4'b0000);
        assign iafu2mc_to_mc_axi4[i].awcache = t_axi4_awcache_encoding'(4'b0000);
        assign iafu2mc_to_mc_axi4[i].awlock  = t_axi4_lock_encoding'(2'b00);
        assign iafu2mc_to_mc_axi4[i].awregion= 4'b0000;
        assign iafu2mc_to_mc_axi4[i].awuser  = t_axi4_awuser'(1'b0);
        // W Channel
        assign iafu2mc_to_mc_axi4[i].wlast   = 1'b0;
        assign iafu2mc_to_mc_axi4[i].wvalid  = 1'b0;      
        // B Channel
        assign iafu2mc_to_mc_axi4[i].bready  = 1'b1; // IP ready to accept write response
        // AR Channel
        assign iafu2mc_to_mc_axi4[i].arlen   = 10'd0;
        assign iafu2mc_to_mc_axi4[i].arsize  = t_axi4_burst_size_encoding'(3'b110);
        assign iafu2mc_to_mc_axi4[i].arburst = t_axi4_burst_encoding'(2'b00);
        assign iafu2mc_to_mc_axi4[i].arprot = t_axi4_prot_encoding'(3'b000);
        assign iafu2mc_to_mc_axi4[i].arqos   = t_axi4_qos_encoding'(4'b0000);
        assign iafu2mc_to_mc_axi4[i].arcache = t_axi4_arcache_encoding'(4'b0000);
        assign iafu2mc_to_mc_axi4[i].arlock  = t_axi4_lock_encoding'(2'b00);
        assign iafu2mc_to_mc_axi4[i].arregion= 4'b0000;
        assign iafu2mc_to_mc_axi4[i].aruser  = t_axi4_aruser'(1'b0);
        // R Channel
        assign iafu2mc_to_mc_axi4[i].rready  = 1'b1; // IP ready to accept read data
        // B Channel
        assign iafu2cxlip_from_mc_axi4[i].bid     = mc2iafu_from_mc_axi4[i].bid;
        assign iafu2cxlip_from_mc_axi4[i].bvalid  = mc2iafu_from_mc_axi4[i].bvalid;
        assign iafu2cxlip_from_mc_axi4[i].bresp   = t_axi4_resp_encoding'(2'b00);      
        assign iafu2cxlip_from_mc_axi4[i].buser   = 1'b0;  
        // R Channel
        assign iafu2cxlip_from_mc_axi4[i].rid     = mc2iafu_from_mc_axi4[i].rid;
        assign iafu2cxlip_from_mc_axi4[i].rdata   = mc2iafu_from_mc_axi4[i].rdata;
        assign iafu2cxlip_from_mc_axi4[i].rvalid  = mc2iafu_from_mc_axi4[i].rvalid;
        assign iafu2cxlip_from_mc_axi4[i].rlast   = mc2iafu_from_mc_axi4[i].rvalid;
        assign iafu2cxlip_from_mc_axi4[i].ruser   = mc2iafu_from_mc_axi4[i].ruser;
        assign iafu2cxlip_from_mc_axi4[i].rresp   = t_axi4_resp_encoding'(2'b00);      

      end
    endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "H5Me4muwCdD0wBXpIwtSHqPANYFBkFppw7IUkQY+I8Y1cqEvwrQMxWqFMKwLm7G0oFI/8qM3gg9Ahkl/UuJRsLliGlwrzfpbgyM86R6Oz+qDL3K9O8Cc5Du/d7O8jr9kfynJFusl+KRffoROdl/hjYcFVztTZhZpmGHP5EapDR6DhG5+wyFFiSW/nl+Sd3PVKcYLM0BKR+BADBGrQc8x46ziuT5BxFLwpeqcvs+Mz8EwfWzxUMaLpABbguB+pM2xGHa0rGNji+wxwz2f7U0UFNG/Cg8+gsnN4Sx5hCThb4sSUpSzkwN1HIHy5ZcU4pReSv5+DrUqpqN6S7JvaX3JZE8EIcbi3PFUd50ZY+1fAO/UpMiDyHUk1vPjrCbMYRPOiQZCh7geQmpbZbRypFN5SpligDHf+ysJ09uvgUYb1RUaBR3p/NrQ+j9ww8dbrZOI49bfqNsMHRI6QFVkSRWHEaG2N1/rCmYRXdtAvAOmiyKHFwXFy35X6/4QVQI4FGVJfyNTctNuX1sfs2ukDmITFOSae7BcHBKZhbrS7dZwFtKpxotOCMgMfzc0UWnd/OMBDX/pLqeog0nr/XiizzahMsg/h3XPSLS6xYdkgtKReiy7JClQlUhapHQE2rQforFrFPjmvv5mdSy/61yRlUsU1aNXcrTcqsFJGlkFh1aD8IPfJWYjP976Gr+EfA7WncdpyfL6NXUubgDJGdzFoyhov+HJ3FMoG6D9v1QiiD4Wd3uz5lbR8mDzcx5XdxxR3PzMCxs9GFmxB19qMMINY9l+35ikTgKiam0NGqok0zGsT+aACOVVsSoy9V301MsKc8ZKgaKU4awWceqdumXqdO7WyhbmohIXQ1H1q3A/sRuqv0spiLHOIqPesjndTUGwiNKTOLMOXStNDhVLtUkvmFgZVANgzmKMAftGDKevYC/I7f+LCCnujIovSReBdFSXCRrdMdOl4iw/r667uBILSfHEwc+xe/+o/D9ydGrr10yCSlFEfxo1r+rOwhqKB6RzhWqx"
`endif