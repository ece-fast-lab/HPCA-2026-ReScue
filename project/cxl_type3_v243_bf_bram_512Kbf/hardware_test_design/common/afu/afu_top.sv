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
  localparam FIFO_DEPTH = 64;  // Number of elements in the FIFO
  localparam FIFO_ADDR_WIDTH = $clog2(FIFO_DEPTH);
  localparam AFU_AXI_MAX_ID_W = 8;

  //OoO Logic
  mc_axi_if_pkg::t_to_mc_axi4    [MC_CHANNEL-1:0] cxlip2iafu_to_mc_axi4_sync, cxlip2iafu_to_mc_axi4_out, cxlip2iafu_to_mc_axi4_pre;
  mc_axi_if_pkg::t_from_mc_axi4  [MC_CHANNEL-1:0] mc2iafu_from_mc_axi4_sync, mc2iafu_from_mc_axi4_out;

/*  Type Definition */
  typedef enum logic {  //CMD type
      RD    = 1'b0, 
      WR    = 1'b1
  } cmd_t;

  typedef struct packed {// Define the queue type
      logic [MC_AXI_ADDR_BW-1:0]              addr;
      logic [AFU_AXI_MAX_ID_W-1:0]                id;
      logic [AFU_AXI_MAX_ID_W-1:0]                wid;
      logic [AFU_AXI_MAX_DATA_WIDTH-1:0]              wdata;
      logic [AFU_AXI_MAX_DATA_WIDTH/8-1:0]            wstrb;
      t_axi4_wuser             		 	                  wuser;  
      cmd_t                                           cmd;
  } queue_item_t;

  //cmd_t cxlip2iafu_to_mc_axi4_sync_cmd[i], cxlip2iafu_to_mc_axi4_out_cmd[i];
  // Registers for managing FIFO pointers and addresses
  logic [FIFO_ADDR_WIDTH:0] wr_ptr_reg[MC_CHANNEL-1:0], wr_ptr_next[MC_CHANNEL-1:0];
  logic [FIFO_ADDR_WIDTH:0] rd_ptr_reg[MC_CHANNEL-1:0], rd_ptr_next[MC_CHANNEL-1:0];
  logic [FIFO_ADDR_WIDTH:0] rd_dum_ptr_reg[MC_CHANNEL-1:0], rd_dum_ptr_next[MC_CHANNEL-1:0];
  // Incremented write pointer and FIFO status signals
  wire [FIFO_ADDR_WIDTH:0] wr_ptr_inc[MC_CHANNEL-1:0], wr_ptr_inc2[MC_CHANNEL-1:0], wr_ptr_inc3[MC_CHANNEL-1:0];
  wire fifo_full[MC_CHANNEL-1:0]; 
  wire fifo_almost_full[MC_CHANNEL-1:0], fifo_almost_full2[MC_CHANNEL-1:0], fifo_almost_full3[MC_CHANNEL-1:0];   
  wire fifo_empty[MC_CHANNEL-1:0];
  wire fifo_empty_feed[MC_CHANNEL-1:0];

  // Control signals for FIFO write and read operations
  logic write_rd[MC_CHANNEL-1:0], write_wr[MC_CHANNEL-1:0];
  
  logic read_block[MC_CHANNEL-1:0], fifo_cmd[MC_CHANNEL-1:0];
 
  // Command queue for storing read and write commands
  queue_item_t  cmd_queue[MC_CHANNEL-1:0][FIFO_DEPTH-1:0];  // Dummy READ CMD fifo : return data is in-order
  queue_item_t  cmd_queue_pre[MC_CHANNEL-1:0], cmd_queue_buf[MC_CHANNEL-1:0];

  // Word Repair Fault
  wire ar_valid[MC_CHANNEL-1:0];
  wire aw_valid[MC_CHANNEL-1:0];
  //Bloom Filter Registers for Word repair
  logic bloom_ar_is_faulty    [MC_CHANNEL-1:0];
  logic bloom_aw_is_faulty    [MC_CHANNEL-1:0];

  logic ar_fault_valid    [MC_CHANNEL-1:0];
  logic aw_fault_valid    [MC_CHANNEL-1:0];

  logic ar_bf_result    [MC_CHANNEL-1:0];
  logic aw_bf_result    [MC_CHANNEL-1:0];

  logic [AFU_AXI_MAX_ID_W-1:0] arid_bf    [MC_CHANNEL-1:0];
  logic [AFU_AXI_MAX_ID_W-1:0] awid_bf    [MC_CHANNEL-1:0];

  logic bf_rd_match_sync    [MC_CHANNEL-1:0];
  logic bf_rd_match_out    [MC_CHANNEL-1:0];
  logic bf_rd_match_pre    [MC_CHANNEL-1:0];
  logic bf_wr_match_sync    [MC_CHANNEL-1:0];
  logic bf_wr_match_out    [MC_CHANNEL-1:0];
  logic bf_wr_match_pre    [MC_CHANNEL-1:0];

  logic arvalid_bf    [MC_CHANNEL-1:0];
  logic awvalid_bf    [MC_CHANNEL-1:0];

  logic cxlip2iafu_to_mc_axi4_sync_bf   [MC_CHANNEL-1:0];
  logic cxlip2iafu_to_mc_axi4_out_bf   [MC_CHANNEL-1:0];
  logic cxlip2iafu_to_mc_axi4_pre_bf   [MC_CHANNEL-1:0];

  logic check_buffer [MC_CHANNEL-1:0];

  logic channel [MC_CHANNEL-1:0];
  
  assign channel[1] = 1'b1;
  assign channel[0] = 1'b0;
  //Word repair
  // [33:7], Channel [6]
  //Row repair
  // {[33:16].[8:7]}, Channel [6]

  // BG : [8:7], BA : [17:16], ROW : [33:18], COL : [15:9]
  // ROW addr : addr[33:16],addr[8:7]

  initial begin // Initial block to reset FIFO pointers and addresses at start
    for (int i = 0; i < MC_CHANNEL; i++) begin
      wr_ptr_reg[i] = {FIFO_ADDR_WIDTH+1{1'b0}};
      rd_ptr_reg[i] = {FIFO_ADDR_WIDTH+1{1'b0}};
      rd_dum_ptr_reg[i] = {FIFO_ADDR_WIDTH+1{1'b0}};
    end
  end
  // Generate Bloom Filter for Word repair
  generate
    for (genvar i = 0; i < MC_CHANNEL; i++) begin : gen_bloom_filter
        // bloom_filter #(
        //     .FILTER_SIZE(8192)  //2^13=8192, 2^15=32768, 2^16=65536, 2^17=131072
        // ) bf_word (
        bloom_filter bf_word (            
            .clk(afu_clk),
            .rst_n(afu_rstn),
            .csr_data(afu_data), 
            .addr_ar(cxlip2iafu_to_mc_axi4[i].araddr[33:7]),
            .addr_aw(cxlip2iafu_to_mc_axi4[i].awaddr[33:7]),  
            .channel(channel[i]),
            .ch_rd(cxlip2iafu_to_mc_axi4[i].araddr[6]),
            .ch_wr(cxlip2iafu_to_mc_axi4[i].awaddr[6]),
            .ar_is_faulty(bloom_ar_is_faulty[i]),
            .aw_is_faulty(bloom_aw_is_faulty[i]),
            .arid(cxlip2iafu_to_mc_axi4[i].arid),
            .awid(cxlip2iafu_to_mc_axi4[i].awid),
            .arvalid(ar_valid[i]),
            .awvalid(aw_valid[i]),
            .arid_bf(arid_bf[i]),
            .awid_bf(awid_bf[i]),
            .arvalid_bf(arvalid_bf[i]),
            .awvalid_bf(awvalid_bf[i])

        );
    end
  endgenerate

  // Generate block for per-channel logic, including fault detection and FIFO management
  generate
  for (genvar i = 0; i < MC_CHANNEL; i++) begin  : gen_ctrl_assign// Both arvalid and awvalid are not '1' at the same time.
    //Logic for Word repair
    //assign ar_fault[i] = bloom_ar_is_faulty[i] && (cxlip2iafu_to_mc_axi4[i].arvalid == 1'b1) && (mc2iafu_from_mc_axi4_sync[i].arready ==1'b1);
    //assign aw_fault[i] = bloom_aw_is_faulty[i] && (cxlip2iafu_to_mc_axi4[i].awvalid == 1'b1) && (mc2iafu_from_mc_axi4_sync[i].arready ==1'b1);
    assign ar_valid[i] = (cxlip2iafu_to_mc_axi4[i].arvalid == 1'b1) && (mc2iafu_from_mc_axi4_sync[i].arready ==1'b1);
    assign aw_valid[i] = (cxlip2iafu_to_mc_axi4[i].awvalid == 1'b1) && (mc2iafu_from_mc_axi4_sync[i].arready ==1'b1);

    // Flags for fifo full and empty, full when first MSB different but rest same, empty when pointers match exactly
    assign fifo_full[i] = ((wr_ptr_reg[i][FIFO_ADDR_WIDTH] != rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH]) &&
              (wr_ptr_reg[i][FIFO_ADDR_WIDTH-1:0] == rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]));
    assign wr_ptr_inc[i] = wr_ptr_reg[i] + 5'd1; // Increment write pointer
    
    assign wr_ptr_inc2[i] = wr_ptr_reg[i] + 5'd2; // Increment write pointer
    assign wr_ptr_inc3[i] = wr_ptr_reg[i] + 5'd3; // Increment write pointer
    
    assign fifo_almost_full[i] = ((wr_ptr_inc[i][FIFO_ADDR_WIDTH] != rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH]) &&
                              (wr_ptr_inc[i][FIFO_ADDR_WIDTH-1:0] == rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]));
    
    assign fifo_almost_full2[i] = ((wr_ptr_inc2[i][FIFO_ADDR_WIDTH] != rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH]) &&
                              (wr_ptr_inc2[i][FIFO_ADDR_WIDTH-1:0] == rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]));     

    assign fifo_almost_full3[i] = ((wr_ptr_inc3[i][FIFO_ADDR_WIDTH] != rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH]) &&
                              (wr_ptr_inc3[i][FIFO_ADDR_WIDTH-1:0] == rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]));       

    assign fifo_empty[i] = (wr_ptr_reg[i] == rd_dum_ptr_reg[i]);
    assign fifo_empty_feed[i] = (wr_ptr_reg[i] == rd_ptr_reg[i]);

    assign ar_bf_result[i] = (bloom_ar_is_faulty[i]||check_buffer[i]) && arvalid_bf[i];
    assign aw_bf_result[i] = bloom_aw_is_faulty[i] && awvalid_bf[i];

    assign bf_wr_match_sync[i] = (awid_bf[i]==cxlip2iafu_to_mc_axi4_sync[i].awid)&&(awvalid_bf[i])&&(cxlip2iafu_to_mc_axi4_sync_bf[i]==1'b0)&&cxlip2iafu_to_mc_axi4_sync[i].awvalid;
    assign bf_wr_match_out[i] = (awid_bf[i]==cxlip2iafu_to_mc_axi4_out[i].awid)&&(awvalid_bf[i])&&(cxlip2iafu_to_mc_axi4_out_bf[i]==1'b0)&&cxlip2iafu_to_mc_axi4_out[i].awvalid;
    assign bf_wr_match_pre[i] = (awid_bf[i]==cxlip2iafu_to_mc_axi4_pre[i].awid)&&(awvalid_bf[i])&&(cxlip2iafu_to_mc_axi4_pre_bf[i]==1'b0)&&cxlip2iafu_to_mc_axi4_pre[i].awvalid;

    assign bf_rd_match_sync[i] = (arid_bf[i]==cxlip2iafu_to_mc_axi4_sync[i].arid)&&(arvalid_bf[i])&&(cxlip2iafu_to_mc_axi4_sync_bf[i]==1'b0)&&cxlip2iafu_to_mc_axi4_sync[i].arvalid;
    assign bf_rd_match_out[i] = (arid_bf[i]==cxlip2iafu_to_mc_axi4_out[i].arid)&&(arvalid_bf[i])&&(cxlip2iafu_to_mc_axi4_out_bf[i]==1'b0)&&cxlip2iafu_to_mc_axi4_out[i].arvalid;
    assign bf_rd_match_pre[i] = (arid_bf[i]==cxlip2iafu_to_mc_axi4_pre[i].arid)&&(arvalid_bf[i])&&(cxlip2iafu_to_mc_axi4_pre_bf[i]==1'b0)&&cxlip2iafu_to_mc_axi4_pre[i].arvalid;
    

  end
  endgenerate


  // Logic for writing to the FIFO
    always_comb begin 
        for (int i=0; i < MC_CHANNEL; i++) begin
            wr_ptr_next[i] = wr_ptr_reg[i];
            write_rd[i] = 1'b0;
            write_wr[i] = 1'b0;
            // Check for address fault and ensure FIFO is not full before writing
            if (!fifo_full[i]) begin   //fifo_almost_full?
                if (ar_valid[i]) begin
                        write_rd[i] = 1'b1;
                        write_wr[i] = 1'b0;
                end else if (aw_valid[i]) begin
                        write_rd[i] = 1'b0;
                        write_wr[i] = 1'b1;
                end else begin
                        write_rd[i] = 1'b0;
                        write_wr[i] = 1'b0;                
                end
            end
            if (!fifo_full[i]) begin   //fifo_almost_full?
                if (ar_bf_result[i] || aw_bf_result[i] ) begin
                    wr_ptr_next[i] = wr_ptr_reg[i] + 5'd1;
                end else begin
                    wr_ptr_next[i] = wr_ptr_reg[i];
                end
            end


        end
    end

// always_comb begin 
//     for (int i = 0; i < MC_CHANNEL; i++) begin
//         check_buffer[i] = 1'b0;  // Initialize check_buffer
//         if (cmd_queue_buf[i].cmd == RD) begin  // Check if the command is a read (RD)
//             for (int j = 0; j < FIFO_DEPTH; j++) begin  // Loop through the command queue
//                 if (cmd_queue_buf[i].id == cmd_queue[i][j].id) begin  // Check if the IDs match
//                     check_buffer[i] = 1'b1;  // Set flag if a match is found
//                     break;  // Exit the inner loop if a match is found
//                 end
//             end
//         end
//     end
// end

always_comb begin
    for (int i = 0; i < MC_CHANNEL; i++) begin
        check_buffer[i] = 1'b0;  // Initialize check_buffer

        // Proceed only if FIFO is not empty
        if (!fifo_empty[i] && cmd_queue_buf[i].cmd == RD) begin  // Check if the command is a read (RD)
            // Get the read and write pointers (lower bits for indexing)
            int read_ptr = rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0];
            int write_ptr = wr_ptr_reg[i][FIFO_ADDR_WIDTH-1:0];

            // Loop over the entire FIFO depth
            for (int j = 0; j < FIFO_DEPTH; j++) begin
                // Determine if the current index 'j' is within the valid range
                logic valid_entry;

                if (fifo_full[i]) begin
                    valid_entry = 1'b1;  // All entries are valid when FIFO is full
                end else if (read_ptr <= write_ptr) begin
                    // No wraparound
                    valid_entry = (j >= read_ptr) && (j < write_ptr);
                end else begin
                    // Wraparound case
                    valid_entry = (j >= read_ptr) || (j < write_ptr);
                end

                if (valid_entry) begin
                    // Check if the IDs match
                    if (cmd_queue_buf[i].addr == cmd_queue[i][j].addr) begin
                        check_buffer[i] = 1'b1;  // Set flag if a match is found
                        break;  // Exit the loop early
                    end
                end
            end
        end
    end
end







  // FIFO write operations and command queue updates
  always @(posedge afu_clk) begin
      for (int i=0; i < MC_CHANNEL; i++) begin
          if (~afu_rstn) begin  // On reset, initialize write pointers and addresses
              wr_ptr_reg[i] <= {FIFO_ADDR_WIDTH+1{1'b0}};
          end else begin        // update write pointers and queue items

                wr_ptr_reg[i] <= wr_ptr_next[i];
                cmd_queue_pre[i] <= '0;

                if (write_rd[i]) begin   // Store read command details in the command queue based on the write address pointer
                        cmd_queue_pre[i].addr   <= cxlip2iafu_to_mc_axi4[i].araddr;
                        cmd_queue_pre[i].id     <= cxlip2iafu_to_mc_axi4[i].arid;
                        cmd_queue_pre[i].wid     <= '0;
                        cmd_queue_pre[i].wdata  <= {AFU_AXI_MAX_DATA_WIDTH{1'b0}};
                        cmd_queue_pre[i].wstrb  <= {AFU_AXI_MAX_DATA_WIDTH/8{1'b0}};
                        cmd_queue_pre[i].wuser  <= t_axi4_wuser'(1'b0);
                        cmd_queue_pre[i].cmd    <= RD;
                end else if (write_wr[i]) begin
                        cmd_queue_pre[i].addr   <= cxlip2iafu_to_mc_axi4[i].awaddr;
                        cmd_queue_pre[i].id     <= '0;
                        cmd_queue_pre[i].wid     <= cxlip2iafu_to_mc_axi4[i].awid;
                        cmd_queue_pre[i].wdata  <= cxlip2iafu_to_mc_axi4[i].wdata;
                        cmd_queue_pre[i].wstrb  <=  cxlip2iafu_to_mc_axi4[i].wstrb;
                        cmd_queue_pre[i].wuser  <= cxlip2iafu_to_mc_axi4[i].wuser;
                        cmd_queue_pre[i].cmd    <= WR;
                end

                cmd_queue_buf[i] <= cmd_queue_pre[i];

                if (!fifo_full[i]) begin   //fifo_almost_full?
                    if (ar_bf_result[i] || aw_bf_result[i] ) begin
                        cmd_queue[i][wr_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]] <= cmd_queue_buf[i];
                    end
                end
                


          end
      end
  end

  // Logic for reading from the FIFO
  always_comb begin
      for (int i=0; i < MC_CHANNEL; i++) begin
          read_block[i] = 1'b0;                 // Default to not reading
          fifo_cmd[i] = 1'b0;
          rd_ptr_next[i] = rd_ptr_reg[i];
          rd_dum_ptr_next[i] = rd_dum_ptr_reg[i];
          // Check if the memory controller is ready to accept a read address and FIFO is not empty
          if (!fifo_empty_feed[i]) begin
              // Proceed with read operation if the read ID matches and data is valid
              if ((mc2iafu_from_mc_axi4[i].rvalid ==1'b1) && (mc2iafu_from_mc_axi4[i].rlast ==1'b1)) begin  // if receive faulty addr data 
                  read_block[i] = 1'b1;
                  rd_ptr_next[i] = rd_ptr_reg[i] + 1'b1;
              end
          end
          if (!fifo_empty[i]) begin
              // Proceed with read operation if the read ID matches and data is valid
              if (rd_ptr_next[i] != rd_dum_ptr_reg[i]) begin  // if receive faulty addr data 
                  fifo_cmd[i] = 1'b1;
                  if (mc2iafu_from_mc_axi4[i].arready) begin
                      rd_dum_ptr_next[i] = rd_dum_ptr_reg[i] + 1'b1;
                  end
              end
          end

      end
  end

  always_ff @(posedge afu_clk) begin
      if (~afu_rstn) begin
        for (int i=0; i < MC_CHANNEL; i++) begin
          cxlip2iafu_to_mc_axi4_pre[i] <= '0; // 1ck delay for SRAM bloomfilter
          cxlip2iafu_to_mc_axi4_sync[i] <= '0; // reset values
          mc2iafu_from_mc_axi4_sync[i] <= '0; // reset values
          cxlip2iafu_to_mc_axi4_out[i] <= '0; // reset values
          mc2iafu_from_mc_axi4_out[i] <= '0; // reset values
          cxlip2iafu_to_mc_axi4_sync_bf[i] <= 1'b0;
          cxlip2iafu_to_mc_axi4_out_bf[i] <= 1'b0;
          cxlip2iafu_to_mc_axi4_pre_bf[i] <= 1'b0;
          rd_ptr_reg[i] <= {FIFO_ADDR_WIDTH+1{1'b0}};
          rd_dum_ptr_reg[i] <= {FIFO_ADDR_WIDTH+1{1'b0}};

        end
      end else begin
        for (int i=0; i < MC_CHANNEL; i++) begin
            rd_ptr_reg[i] <= rd_ptr_next[i];
            rd_dum_ptr_reg[i] <= rd_dum_ptr_next[i];
          // AW Channel
            if (fifo_cmd[i] || fifo_full[i]|| fifo_almost_full[i] || fifo_almost_full2[i] || fifo_almost_full3[i]|| !mc2iafu_from_mc_axi4[i].arready) begin
                    //AW, W Channel
                    //cxlip2iafu_to_mc_axi4_sync[i].awvalid <= cxlip2iafu_to_mc_axi4_sync[i].awvalid;
                    cxlip2iafu_to_mc_axi4_sync[i].awvalid <= bf_wr_match_sync[i] ? (bloom_aw_is_faulty[i] ? 1'b0 : 1'b1): cxlip2iafu_to_mc_axi4_sync[i].awvalid;
                    cxlip2iafu_to_mc_axi4_sync[i].awid <= cxlip2iafu_to_mc_axi4_sync[i].awid;
                    cxlip2iafu_to_mc_axi4_sync[i].awaddr <= cxlip2iafu_to_mc_axi4_sync[i].awaddr;          
                    cxlip2iafu_to_mc_axi4_sync[i].wdata <= cxlip2iafu_to_mc_axi4_sync[i].wdata;
                    cxlip2iafu_to_mc_axi4_sync[i].wstrb <= cxlip2iafu_to_mc_axi4_sync[i].wstrb;
                    cxlip2iafu_to_mc_axi4_sync[i].wuser <= cxlip2iafu_to_mc_axi4_sync[i].wuser;  
                    //AR channel
                    //cxlip2iafu_to_mc_axi4_sync[i].arvalid <= cxlip2iafu_to_mc_axi4_sync[i].arvalid;
                    cxlip2iafu_to_mc_axi4_sync[i].arvalid <= bf_wr_match_sync[i] ?  (bloom_aw_is_faulty[i] ? 1'b1 : 1'b0): cxlip2iafu_to_mc_axi4_sync[i].arvalid;
                    cxlip2iafu_to_mc_axi4_sync[i].arid <=  bf_wr_match_sync[i] ?    (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_sync[i].awid : cxlip2iafu_to_mc_axi4_sync[i].arid): cxlip2iafu_to_mc_axi4_sync[i].arid;
                    cxlip2iafu_to_mc_axi4_sync[i].araddr <=  bf_wr_match_sync[i] ?  (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_sync[i].awaddr : cxlip2iafu_to_mc_axi4_sync[i].araddr): cxlip2iafu_to_mc_axi4_sync[i].araddr;
                    // Added for SRAM BF + id compare

                    if (bf_rd_match_sync[i] || bf_wr_match_sync[i]) begin
                        cxlip2iafu_to_mc_axi4_sync[i].arprot <= t_axi4_prot_encoding'({1'b0, 1'b0 , ar_bf_result[i]||aw_bf_result[i]});
                    end else begin
                        cxlip2iafu_to_mc_axi4_sync[i].arprot <= cxlip2iafu_to_mc_axi4_sync[i].arprot;
                    end

                    cxlip2iafu_to_mc_axi4_sync_bf[i] <= bf_rd_match_sync[i] || bf_wr_match_sync[i] ? 1'b1 : cxlip2iafu_to_mc_axi4_sync_bf[i];

            end else begin
                    // AW, W Channel
                    if (mc2iafu_from_mc_axi4_sync[i].arready == 1'b0) begin
                        //cxlip2iafu_to_mc_axi4_sync[i].awvalid <= cxlip2iafu_to_mc_axi4_out[i].awvalid;
                        cxlip2iafu_to_mc_axi4_sync[i].awvalid <= bf_wr_match_out[i] ? (bloom_aw_is_faulty[i] ? 1'b0 : 1'b1): cxlip2iafu_to_mc_axi4_out[i].awvalid;
                        cxlip2iafu_to_mc_axi4_sync[i].awid <= cxlip2iafu_to_mc_axi4_out[i].awid;
                        cxlip2iafu_to_mc_axi4_sync[i].awaddr <= cxlip2iafu_to_mc_axi4_out[i].awaddr;
                        cxlip2iafu_to_mc_axi4_sync[i].wdata <= cxlip2iafu_to_mc_axi4_out[i].wdata;
                        cxlip2iafu_to_mc_axi4_sync[i].wstrb <= cxlip2iafu_to_mc_axi4_out[i].wstrb;
                        cxlip2iafu_to_mc_axi4_sync[i].wuser <= cxlip2iafu_to_mc_axi4_out[i].wuser;

                        //cxlip2iafu_to_mc_axi4_sync[i].arvalid <= cxlip2iafu_to_mc_axi4_out[i].arvalid;
                        cxlip2iafu_to_mc_axi4_sync[i].arvalid <= bf_wr_match_out[i] ?   (bloom_aw_is_faulty[i] ? 1'b1 : 1'b0): cxlip2iafu_to_mc_axi4_out[i].arvalid;
                        cxlip2iafu_to_mc_axi4_sync[i].arid <= bf_wr_match_out[i] ?      (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_out[i].awid : cxlip2iafu_to_mc_axi4_out[i].arid): cxlip2iafu_to_mc_axi4_out[i].arid;
                        cxlip2iafu_to_mc_axi4_sync[i].araddr <= bf_wr_match_out[i] ?    (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_out[i].awaddr : cxlip2iafu_to_mc_axi4_out[i].araddr): cxlip2iafu_to_mc_axi4_out[i].araddr;   
                        if (bf_rd_match_out[i] || bf_wr_match_out[i]) begin
                            cxlip2iafu_to_mc_axi4_sync[i].arprot <= t_axi4_prot_encoding'({1'b0, 1'b0 , ar_bf_result[i]||aw_bf_result[i]});
                        end else begin
                            cxlip2iafu_to_mc_axi4_sync[i].arprot <= cxlip2iafu_to_mc_axi4_out[i].arprot;
                        end
                        cxlip2iafu_to_mc_axi4_sync_bf[i] <= bf_rd_match_out[i] || bf_wr_match_out[i] ? 1'b1 : cxlip2iafu_to_mc_axi4_out_bf[i];

                    end else begin
                        cxlip2iafu_to_mc_axi4_sync[i].awvalid <= bf_wr_match_pre[i] ? (bloom_aw_is_faulty[i] ? 1'b0 : 1'b1): cxlip2iafu_to_mc_axi4_pre[i].awvalid;
                        cxlip2iafu_to_mc_axi4_sync[i].awid <= cxlip2iafu_to_mc_axi4_pre[i].awid;
                        cxlip2iafu_to_mc_axi4_sync[i].awaddr <= cxlip2iafu_to_mc_axi4_pre[i].awaddr;        
                        cxlip2iafu_to_mc_axi4_sync[i].wdata <= cxlip2iafu_to_mc_axi4_pre[i].wdata;
                        cxlip2iafu_to_mc_axi4_sync[i].wstrb <= cxlip2iafu_to_mc_axi4_pre[i].wstrb;
                        cxlip2iafu_to_mc_axi4_sync[i].wuser <= cxlip2iafu_to_mc_axi4_pre[i].wuser;

                        cxlip2iafu_to_mc_axi4_sync[i].arvalid <= bf_wr_match_pre[i] ?   (bloom_aw_is_faulty[i] ? 1'b1 : 1'b0): cxlip2iafu_to_mc_axi4_pre[i].arvalid;
                        cxlip2iafu_to_mc_axi4_sync[i].arid <= bf_wr_match_pre[i] ?      (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_pre[i].awid : cxlip2iafu_to_mc_axi4_pre[i].arid): cxlip2iafu_to_mc_axi4_pre[i].arid;
                        cxlip2iafu_to_mc_axi4_sync[i].araddr <= bf_wr_match_pre[i] ?    (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_pre[i].awaddr : cxlip2iafu_to_mc_axi4_pre[i].araddr): cxlip2iafu_to_mc_axi4_pre[i].araddr;   
                        // In this case, Compare at output assign step
                        if (bf_rd_match_pre[i] || bf_wr_match_pre[i]) begin
                            cxlip2iafu_to_mc_axi4_sync[i].arprot <= t_axi4_prot_encoding'({1'b0, 1'b0 , ar_bf_result[i]||aw_bf_result[i]});
                        end else begin
                            cxlip2iafu_to_mc_axi4_sync[i].arprot <= cxlip2iafu_to_mc_axi4_pre[i].arprot;
                        end
                        cxlip2iafu_to_mc_axi4_sync_bf[i] <= bf_rd_match_pre[i] || bf_wr_match_pre[i] ? 1'b1 : cxlip2iafu_to_mc_axi4_pre_bf[i];
     
                    end
            end

            if (!mc2iafu_from_mc_axi4_sync[i].arready) begin
                    //AW, W Channel
                    cxlip2iafu_to_mc_axi4_pre[i].awvalid <= bf_wr_match_pre[i] ? (bloom_aw_is_faulty[i] ? 1'b0 : 1'b1): cxlip2iafu_to_mc_axi4_pre[i].awvalid;
                    cxlip2iafu_to_mc_axi4_pre[i].awid <= cxlip2iafu_to_mc_axi4_pre[i].awid;
                    cxlip2iafu_to_mc_axi4_pre[i].awaddr <= cxlip2iafu_to_mc_axi4_pre[i].awaddr;          
                    cxlip2iafu_to_mc_axi4_pre[i].wdata <= cxlip2iafu_to_mc_axi4_pre[i].wdata;
                    cxlip2iafu_to_mc_axi4_pre[i].wstrb <= cxlip2iafu_to_mc_axi4_pre[i].wstrb;
                    cxlip2iafu_to_mc_axi4_pre[i].wuser <= cxlip2iafu_to_mc_axi4_pre[i].wuser;  
                    //AR channel
                    cxlip2iafu_to_mc_axi4_pre[i].arvalid <= bf_wr_match_pre[i] ?    (bloom_aw_is_faulty[i] ? 1'b1 : 1'b0): cxlip2iafu_to_mc_axi4_pre[i].arvalid;
                    cxlip2iafu_to_mc_axi4_pre[i].arid <= bf_wr_match_pre[i] ?       (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_pre[i].awid : cxlip2iafu_to_mc_axi4_pre[i].arid): cxlip2iafu_to_mc_axi4_pre[i].arid;
                    cxlip2iafu_to_mc_axi4_pre[i].araddr <= bf_wr_match_pre[i] ?     (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_pre[i].awaddr : cxlip2iafu_to_mc_axi4_pre[i].araddr): cxlip2iafu_to_mc_axi4_pre[i].araddr;

                    if (bf_rd_match_pre[i] || bf_wr_match_pre[i]) begin
                            cxlip2iafu_to_mc_axi4_pre[i].arprot <= t_axi4_prot_encoding'({1'b0, 1'b0 , ar_bf_result[i]||aw_bf_result[i]});
                    end else begin
                        cxlip2iafu_to_mc_axi4_pre[i].arprot <= cxlip2iafu_to_mc_axi4_pre[i].arprot;
                    end

                    cxlip2iafu_to_mc_axi4_pre_bf[i] <= bf_rd_match_pre[i] || bf_wr_match_pre[i] ? 1'b1 : cxlip2iafu_to_mc_axi4_pre_bf[i];

            end else begin
                    cxlip2iafu_to_mc_axi4_pre[i].awvalid <= cxlip2iafu_to_mc_axi4[i].awvalid;
                    cxlip2iafu_to_mc_axi4_pre[i].awid <= cxlip2iafu_to_mc_axi4[i].awid;
                    cxlip2iafu_to_mc_axi4_pre[i].awaddr <= cxlip2iafu_to_mc_axi4[i].awaddr;
                    cxlip2iafu_to_mc_axi4_pre[i].wdata <= cxlip2iafu_to_mc_axi4[i].wdata;
                    cxlip2iafu_to_mc_axi4_pre[i].wstrb <= cxlip2iafu_to_mc_axi4[i].wstrb;
                    cxlip2iafu_to_mc_axi4_pre[i].wuser <= cxlip2iafu_to_mc_axi4[i].wuser;

                    cxlip2iafu_to_mc_axi4_pre[i].arvalid <= cxlip2iafu_to_mc_axi4[i].arvalid;
                    cxlip2iafu_to_mc_axi4_pre[i].arid <=  cxlip2iafu_to_mc_axi4[i].arid;
                    cxlip2iafu_to_mc_axi4_pre[i].araddr <= cxlip2iafu_to_mc_axi4[i].araddr;
                    // In this case, Compare at sync register step
                    cxlip2iafu_to_mc_axi4_pre[i].arprot <= t_axi4_prot_encoding'({1'b0, 1'b0, 1'b0});
                    cxlip2iafu_to_mc_axi4_pre_bf[i] <= 1'b0;
            end


        if (mc2iafu_from_mc_axi4_sync[i].arready == 1'b1) begin
                    //AW, W Channel
                    cxlip2iafu_to_mc_axi4_out[i].awvalid <= bf_wr_match_pre[i] ? (bloom_aw_is_faulty[i] ? 1'b0 : 1'b1): cxlip2iafu_to_mc_axi4_pre[i].awvalid;
                    cxlip2iafu_to_mc_axi4_out[i].awid <= cxlip2iafu_to_mc_axi4_pre[i].awid;
                    cxlip2iafu_to_mc_axi4_out[i].awaddr <= cxlip2iafu_to_mc_axi4_pre[i].awaddr;          
                    cxlip2iafu_to_mc_axi4_out[i].wdata <= cxlip2iafu_to_mc_axi4_pre[i].wdata;
                    cxlip2iafu_to_mc_axi4_out[i].wstrb <= cxlip2iafu_to_mc_axi4_pre[i].wstrb;
                    cxlip2iafu_to_mc_axi4_out[i].wuser <= cxlip2iafu_to_mc_axi4_pre[i].wuser;  
                    //AR channel
                    cxlip2iafu_to_mc_axi4_out[i].arvalid <= bf_wr_match_pre[i] ?    (bloom_aw_is_faulty[i] ? 1'b1 : 1'b0): cxlip2iafu_to_mc_axi4_pre[i].arvalid;
                    cxlip2iafu_to_mc_axi4_out[i].arid <= bf_wr_match_pre[i] ?       (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_pre[i].awid : cxlip2iafu_to_mc_axi4_pre[i].arid): cxlip2iafu_to_mc_axi4_pre[i].arid;
                    cxlip2iafu_to_mc_axi4_out[i].araddr <= bf_wr_match_pre[i] ?     (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_pre[i].awaddr : cxlip2iafu_to_mc_axi4_pre[i].araddr): cxlip2iafu_to_mc_axi4_pre[i].araddr;

                    if (bf_rd_match_pre[i] || bf_wr_match_pre[i]) begin
                            cxlip2iafu_to_mc_axi4_out[i].arprot <= t_axi4_prot_encoding'({1'b0, 1'b0 , ar_bf_result[i]||aw_bf_result[i]});
                    end else begin
                        cxlip2iafu_to_mc_axi4_out[i].arprot <= cxlip2iafu_to_mc_axi4_pre[i].arprot;
                    end

                    cxlip2iafu_to_mc_axi4_out_bf[i] <= bf_rd_match_pre[i] || bf_wr_match_pre[i] ? 1'b1 : cxlip2iafu_to_mc_axi4_pre_bf[i];

        end else begin
                //cxlip2iafu_to_mc_axi4_out[i].awvalid <= cxlip2iafu_to_mc_axi4_out[i].awvalid;
                cxlip2iafu_to_mc_axi4_out[i].awvalid <= bf_wr_match_out[i] ? (bloom_aw_is_faulty[i] ? 1'b0 : 1'b1): cxlip2iafu_to_mc_axi4_out[i].awvalid;
                cxlip2iafu_to_mc_axi4_out[i].awid <= cxlip2iafu_to_mc_axi4_out[i].awid;
                cxlip2iafu_to_mc_axi4_out[i].awaddr <= cxlip2iafu_to_mc_axi4_out[i].awaddr;      
                cxlip2iafu_to_mc_axi4_out[i].wdata <= cxlip2iafu_to_mc_axi4_out[i].wdata;
                cxlip2iafu_to_mc_axi4_out[i].wstrb <= cxlip2iafu_to_mc_axi4_out[i].wstrb;
                cxlip2iafu_to_mc_axi4_out[i].wuser <= cxlip2iafu_to_mc_axi4_out[i].wuser;  

                //cxlip2iafu_to_mc_axi4_out[i].arvalid <= cxlip2iafu_to_mc_axi4_out[i].arvalid;
                cxlip2iafu_to_mc_axi4_out[i].arvalid <= bf_wr_match_out[i] ?    (bloom_aw_is_faulty[i] ? 1'b1 : 1'b0): cxlip2iafu_to_mc_axi4_out[i].arvalid;
                cxlip2iafu_to_mc_axi4_out[i].arid <= bf_wr_match_out[i] ?       (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_out[i].awid : cxlip2iafu_to_mc_axi4_out[i].arid): cxlip2iafu_to_mc_axi4_out[i].arid;
                cxlip2iafu_to_mc_axi4_out[i].araddr <= bf_wr_match_out[i] ?     (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_out[i].awaddr : cxlip2iafu_to_mc_axi4_out[i].araddr): cxlip2iafu_to_mc_axi4_out[i].araddr;    
                                
                if (bf_rd_match_out[i] || bf_wr_match_out[i]) begin
                    cxlip2iafu_to_mc_axi4_out[i].arprot <= t_axi4_prot_encoding'({1'b0, 1'b0 , ar_bf_result[i]||aw_bf_result[i]});
                end else begin
                    cxlip2iafu_to_mc_axi4_out[i].arprot <= cxlip2iafu_to_mc_axi4_out[i].arprot;
                end
                cxlip2iafu_to_mc_axi4_out_bf[i] <= bf_rd_match_out[i] || bf_wr_match_out[i] ? 1'b1 : cxlip2iafu_to_mc_axi4_out_bf[i];

        end

          //mc2iafu_from_mc_axi4_sync[j] <= mc2iafu_from_mc_axi4[j];
          // B Channel
        mc2iafu_from_mc_axi4_sync[i].bid <= mc2iafu_from_mc_axi4[i].bid;
        mc2iafu_from_mc_axi4_sync[i].bvalid <= mc2iafu_from_mc_axi4[i].bvalid;

          // AR, AW Channel
        if (mc2iafu_from_mc_axi4[i].arready == 1'b1) begin 
                if ( fifo_cmd[i] || fifo_full[i] || fifo_almost_full[i] || fifo_almost_full2[i]  || fifo_almost_full3[i]) begin
                        mc2iafu_from_mc_axi4_sync[i].arready <= 1'b0;
                        mc2iafu_from_mc_axi4_sync[i].awready <= 1'b0;
                end else begin
                        mc2iafu_from_mc_axi4_sync[i].arready <= mc2iafu_from_mc_axi4[i].arready;
                        mc2iafu_from_mc_axi4_sync[i].awready <= mc2iafu_from_mc_axi4[i].arready;
                end
        end else begin
                mc2iafu_from_mc_axi4_sync[i].arready <= 1'b0;
                mc2iafu_from_mc_axi4_sync[i].awready <= 1'b0;
        end

        // R Channel
        mc2iafu_from_mc_axi4_sync[i].rid <= mc2iafu_from_mc_axi4[i].rid;
        mc2iafu_from_mc_axi4_sync[i].rdata <= mc2iafu_from_mc_axi4[i].rdata;

        // Since rlast == rvalid, rlast is used for metadata of dummy RD for WR CMD (MC2afu)
        //mc2iafu_from_mc_axi4_sync[i].rlast <= mc2iafu_from_mc_axi4[i].rlast;
        /*  will be modified                                                      */

        mc2iafu_from_mc_axi4_sync[i].ruser <= mc2iafu_from_mc_axi4[i].ruser;

        if (read_block[i]) begin
            mc2iafu_from_mc_axi4_sync[i].rvalid <= 1'b0;

        end else begin
            mc2iafu_from_mc_axi4_sync[i].rvalid <= mc2iafu_from_mc_axi4[i].rvalid;
        end

      end
    end
  end


    generate
      for (genvar i = 0; i < MC_CHANNEL; i++) begin : gen_assign
      // AW Channel
      assign iafu2mc_to_mc_axi4[i].awid    = fifo_cmd[i]  ? cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].wid : cxlip2iafu_to_mc_axi4_sync[i].awid;
      assign iafu2mc_to_mc_axi4[i].awaddr  = fifo_cmd[i]  ? cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].addr: cxlip2iafu_to_mc_axi4_sync[i].awaddr;
      
      //assign iafu2mc_to_mc_axi4[i].awvalid = mc2iafu_from_mc_axi4[i].arready && fifo_cmd[i] ? ( cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].cmd == WR ? 1'b1 : 1'b0) : (!mc2iafu_from_mc_axi4[i].arready || fifo_full[i] || fifo_almost_full[i]) ? 1'b0 : cxlip2iafu_to_mc_axi4_sync[i].awvalid;
      assign iafu2mc_to_mc_axi4[i].awvalid = (mc2iafu_from_mc_axi4[i].arready && fifo_cmd[i]) ? (cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].cmd == WR ? 1'b1 : 1'b0) : (!mc2iafu_from_mc_axi4[i].arready || fifo_full[i] || fifo_almost_full[i]|| fifo_almost_full2[i] || fifo_almost_full3[i]) ? 1'b0 : (bf_wr_match_sync[i] ? (bloom_aw_is_faulty[i] ? 1'b0 : 1'b1): cxlip2iafu_to_mc_axi4_sync[i].awvalid);

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
      // wid (write data id) : Not implemented in AXI4.
      assign iafu2mc_to_mc_axi4[i].wdata   = fifo_cmd[i]  ? cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].wdata : cxlip2iafu_to_mc_axi4_sync[i].wdata;
      assign iafu2mc_to_mc_axi4[i].wstrb   = fifo_cmd[i]  ? cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].wstrb : cxlip2iafu_to_mc_axi4_sync[i].wstrb;
      assign iafu2mc_to_mc_axi4[i].wuser   = fifo_cmd[i]  ? cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].wuser : cxlip2iafu_to_mc_axi4_sync[i].wuser;

      assign iafu2mc_to_mc_axi4[i].wlast   = 1'b0;
      assign iafu2mc_to_mc_axi4[i].wvalid  = 1'b0;      
      // B Channel
      assign iafu2mc_to_mc_axi4[i].bready  = 1'b1; // IP ready to accept write response
      // AR Channel
      assign iafu2mc_to_mc_axi4[i].arid    = fifo_cmd[i]  ? cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].id :  (bf_wr_match_sync[i] ? (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_sync[i].awid : cxlip2iafu_to_mc_axi4_sync[i].arid): cxlip2iafu_to_mc_axi4_sync[i].arid);
      assign iafu2mc_to_mc_axi4[i].araddr  = fifo_cmd[i]  ? cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].addr: (bf_wr_match_sync[i] ? (bloom_aw_is_faulty[i] ? cxlip2iafu_to_mc_axi4_sync[i].awaddr : cxlip2iafu_to_mc_axi4_sync[i].araddr): cxlip2iafu_to_mc_axi4_sync[i].araddr);

      //assign iafu2mc_to_mc_axi4[i].arvalid = mc2iafu_from_mc_axi4[i].arready && fifo_cmd[i] ? (cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].cmd == RD ? 1'b1 : 1'b0) : (!mc2iafu_from_mc_axi4[i].arready || fifo_full[i] || fifo_almost_full[i]) ? 1'b0 : cxlip2iafu_to_mc_axi4_sync[i].arvalid;
      assign iafu2mc_to_mc_axi4[i].arvalid = (mc2iafu_from_mc_axi4[i].arready && fifo_cmd[i]) ? (cmd_queue[i][rd_dum_ptr_reg[i][FIFO_ADDR_WIDTH-1:0]].cmd == RD ? 1'b1 : 1'b0) : (!mc2iafu_from_mc_axi4[i].arready || fifo_full[i] || fifo_almost_full[i]|| fifo_almost_full2[i] || fifo_almost_full3[i]) ? 1'b0 : (bf_wr_match_sync[i] ? (bloom_aw_is_faulty[i] ? 1'b1 : 1'b0): cxlip2iafu_to_mc_axi4_sync[i].arvalid);
      
      assign iafu2mc_to_mc_axi4[i].arlen   = 10'd0;
      assign iafu2mc_to_mc_axi4[i].arsize  = t_axi4_burst_size_encoding'(3'b110);
      assign iafu2mc_to_mc_axi4[i].arburst = t_axi4_burst_encoding'(2'b00);

      //CXL IP does not use this signal, arprot is used for metadata of dummy RD for WR CMD (afu2MC)
      //assign iafu2mc_to_mc_axi4[i].arprot  = t_axi4_prot_encoding'(3'b000);
      //assign iafu2mc_to_mc_axi4[i].arprot = cxlip2iafu_to_mc_axi4_sync[i].arprot;
      assign iafu2mc_to_mc_axi4[i].arprot = fifo_cmd[i] ? t_axi4_prot_encoding'(3'b000) : ((bf_rd_match_sync[i] || bf_wr_match_sync[i]) ? t_axi4_prot_encoding'({1'b0, 1'b0 , ar_bf_result[i]||aw_bf_result[i]}): cxlip2iafu_to_mc_axi4_sync[i].arprot);
      //assign iafu2mc_to_mc_axi4[i].arprot = fifo_cmd[i] ? t_axi4_prot_encoding'(3'b000) : (cxlip2iafu_to_mc_axi4_sync_bf[i]==1'b0 ? t_axi4_prot_encoding'({aw_rbf_result[i], ar_rbf_result[i] , ar_bf_result[i]||aw_bf_result[i]}) : cxlip2iafu_to_mc_axi4_sync[i].arprot);

      assign iafu2mc_to_mc_axi4[i].arqos   = t_axi4_qos_encoding'(4'b0000);
      assign iafu2mc_to_mc_axi4[i].arcache = t_axi4_arcache_encoding'(4'b0000);
      assign iafu2mc_to_mc_axi4[i].arlock  = t_axi4_lock_encoding'(2'b00);
      assign iafu2mc_to_mc_axi4[i].arregion= 4'b0000;
      assign iafu2mc_to_mc_axi4[i].aruser  = t_axi4_aruser'(1'b0);
      // R Channel
      assign iafu2mc_to_mc_axi4[i].rready  = 1'b1; // IP ready to accept read data
      // AW Channel      
      assign iafu2cxlip_from_mc_axi4[i].awready = mc2iafu_from_mc_axi4_sync[i].awready;  // HDM ready to accept write address
      // W Channel 
      assign iafu2cxlip_from_mc_axi4[i].wready  = mc2iafu_from_mc_axi4_sync[i].awready;   // HDM ready to accept write data indicator
      // B Channel
      assign iafu2cxlip_from_mc_axi4[i].bid     = mc2iafu_from_mc_axi4_sync[i].bid;
      assign iafu2cxlip_from_mc_axi4[i].bvalid  = mc2iafu_from_mc_axi4_sync[i].bvalid;

      assign iafu2cxlip_from_mc_axi4[i].bresp   = t_axi4_resp_encoding'(2'b00);      
      assign iafu2cxlip_from_mc_axi4[i].buser   = 1'b0;
      // AR Channel
      assign iafu2cxlip_from_mc_axi4[i].arready = mc2iafu_from_mc_axi4_sync[i].arready;  //HDM ready to accept read address
      // R Channel
      assign iafu2cxlip_from_mc_axi4[i].rid     = mc2iafu_from_mc_axi4_sync[i].rid;
      assign iafu2cxlip_from_mc_axi4[i].rdata   = mc2iafu_from_mc_axi4_sync[i].rdata;
      assign iafu2cxlip_from_mc_axi4[i].rvalid  = mc2iafu_from_mc_axi4_sync[i].rvalid;
      assign iafu2cxlip_from_mc_axi4[i].rlast   = mc2iafu_from_mc_axi4_sync[i].rvalid;
      assign iafu2cxlip_from_mc_axi4[i].ruser   = mc2iafu_from_mc_axi4_sync[i].ruser;

      assign iafu2cxlip_from_mc_axi4[i].rresp   = t_axi4_resp_encoding'(2'b00);      

      end
    endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "H5Me4muwCdD0wBXpIwtSHqPANYFBkFppw7IUkQY+I8Y1cqEvwrQMxWqFMKwLm7G0oFI/8qM3gg9Ahkl/UuJRsLliGlwrzfpbgyM86R6Oz+qDL3K9O8Cc5Du/d7O8jr9kfynJFusl+KRffoROdl/hjYcFVztTZhZpmGHP5EapDR6DhG5+wyFFiSW/nl+Sd3PVKcYLM0BKR+BADBGrQc8x46ziuT5BxFLwpeqcvs+Mz8EwfWzxUMaLpABbguB+pM2xGHa0rGNji+wxwz2f7U0UFNG/Cg8+gsnN4Sx5hCThb4sSUpSzkwN1HIHy5ZcU4pReSv5+DrUqpqN6S7JvaX3JZE8EIcbi3PFUd50ZY+1fAO/UpMiDyHUk1vPjrCbMYRPOiQZCh7geQmpbZbRypFN5SpligDHf+ysJ09uvgUYb1RUaBR3p/NrQ+j9ww8dbrZOI49bfqNsMHRI6QFVkSRWHEaG2N1/rCmYRXdtAvAOmiyKHFwXFy35X6/4QVQI4FGVJfyNTctNuX1sfs2ukDmITFOSae7BcHBKZhbrS7dZwFtKpxotOCMgMfzc0UWnd/OMBDX/pLqeog0nr/XiizzahMsg/h3XPSLS6xYdkgtKReiy7JClQlUhapHQE2rQforFrFPjmvv5mdSy/61yRlUsU1aNXcrTcqsFJGlkFh1aD8IPfJWYjP976Gr+EfA7WncdpyfL6NXUubgDJGdzFoyhov+HJ3FMoG6D9v1QiiD4Wd3uz5lbR8mDzcx5XdxxR3PzMCxs9GFmxB19qMMINY9l+35ikTgKiam0NGqok0zGsT+aACOVVsSoy9V301MsKc8ZKgaKU4awWceqdumXqdO7WyhbmohIXQ1H1q3A/sRuqv0spiLHOIqPesjndTUGwiNKTOLMOXStNDhVLtUkvmFgZVANgzmKMAftGDKevYC/I7f+LCCnujIovSReBdFSXCRrdMdOl4iw/r667uBILSfHEwc+xe/+o/D9ydGrr10yCSlFEfxo1r+rOwhqKB6RzhWqx"
`endif