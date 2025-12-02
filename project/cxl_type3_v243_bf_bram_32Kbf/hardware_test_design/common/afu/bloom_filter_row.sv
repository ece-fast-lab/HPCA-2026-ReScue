import cxlip_top_pkg::*;
import afu_axi_if_pkg::*;

module bloom_filter_row #(
    parameter FILTER_SIZE=4096, //2^15=32768, 2^16=65536, 2^17=131072
    parameter NUM_HASH_STACK=2 //2^15=32768, 2^16=65536, 2^17=131072
    )(
    input logic clk,
    input logic rst_n,

    input logic [63:0] csr_data,  
    input logic [19:0] addr_ar_row,// ROW addr : addr[33:16],addr[8:7]
    input logic [19:0] addr_aw_row,  
    input logic channel,
    input logic ch_rd,
    input logic ch_wr,

    output logic ar_is_rfaulty,
    output logic aw_is_rfaulty,

    output logic ra_cache,

    input logic [AFU_AXI_MAX_ID_WIDTH-1:0] arid,
    input logic [AFU_AXI_MAX_ID_WIDTH-1:0] awid,
    input logic arvalid,
    input logic awvalid,

    output logic [AFU_AXI_MAX_ID_WIDTH-1:0] arid_bf,
    output logic [AFU_AXI_MAX_ID_WIDTH-1:0] awid_bf,
    output logic arvalid_bf,
    output logic awvalid_bf
    );

    localparam FILTER_LENGTH = $clog2(FILTER_SIZE);

    logic [FILTER_LENGTH-1:0] hash_addr_a [NUM_HASH_STACK-1:0], hash_addr_b [NUM_HASH_STACK-1:0]; //wire?
    //logic [FILTER_LENGTH-1:0] hash_wr_a [NUM_HASH_STACK-1:0], hash_wr_b [NUM_HASH_STACK-1:0]; //wire?
    logic [FILTER_LENGTH-1:0] hash_a_value [NUM_HASH_STACK-1:0], hash_b_value [NUM_HASH_STACK-1:0]; //wire?
    logic [FILTER_LENGTH-1:0] hash_a_rvalue [NUM_HASH_STACK-1:0], hash_b_rvalue [NUM_HASH_STACK-1:0]; //wire?
    logic [FILTER_LENGTH-1:0] hash_a_wvalue [NUM_HASH_STACK-1:0], hash_b_wvalue [NUM_HASH_STACK-1:0]; //wire?


    logic data_rd_a [NUM_HASH_STACK-1:0], data_rd_b [NUM_HASH_STACK-1:0]; //wire?
    //logic data_wr_a [NUM_HASH_STACK-1:0], data_wr_b [NUM_HASH_STACK-1:0]; //wire?

    logic is_present_rd_a [NUM_HASH_STACK-1:0], is_present_rd_b [NUM_HASH_STACK-1:0]; //wire?
    logic is_present_wr_a [NUM_HASH_STACK-1:0], is_present_wr_b [NUM_HASH_STACK-1:0]; //wire?

    logic [63:0] afu_data;
    logic [FILTER_LENGTH-1:0] cnt_reset;
    logic wren_a, wren_b;

    logic combined_rd_a, combined_rd_b, combined_wr_a, combined_wr_b;

    logic qa_common[NUM_HASH_STACK-1:0], qb_common[NUM_HASH_STACK-1:0];

    logic [AFU_AXI_MAX_ID_WIDTH-1:0] arid_pre;
    logic [AFU_AXI_MAX_ID_WIDTH-1:0] awid_pre;
    logic arvalid_pre;
    logic awvalid_pre;

    logic [19:0] filter_code;
    logic [19:0] filter_mask;

    logic code_rvalue_pre;
    logic code_wvalue_pre;
    logic code_rvalue_buf;
    logic code_wvalue_buf;
    logic code_rvalue;
    logic code_wvalue;

    enum int unsigned { IDLE = 0, WRITE = 1, WRITE_CD = 2, READ = 3, READ_CD = 4, RESET = 5, ALL_RD = 6, ALL_WR = 7, ALL = 8, READ_CD_NC = 9} state, next_state;

    assign combined_rd_a = is_present_rd_a[0] && is_present_rd_a[1];
    assign combined_rd_b = is_present_rd_b[0] && is_present_rd_b[1];
    assign combined_wr_a = is_present_wr_a[0] && is_present_wr_a[1];
    assign combined_wr_b = is_present_wr_b[0] && is_present_wr_b[1];

    assign is_present_rd_a[0] = (arvalid_bf==1'b1) ? qa_common[0] : 1'b0;
    assign is_present_rd_a[1] = (arvalid_bf==1'b1) ? qa_common[1] : 1'b0;
    assign is_present_rd_b[0] = (arvalid_bf==1'b1) ? qb_common[0] : 1'b0;
    assign is_present_rd_b[1] = (arvalid_bf==1'b1) ? qb_common[1] : 1'b0;

    assign is_present_wr_a[0] = (awvalid_bf==1'b1) ? qa_common[0] : 1'b0;
    assign is_present_wr_a[1] = (awvalid_bf==1'b1) ? qa_common[1] : 1'b0;
    assign is_present_wr_b[0] = (awvalid_bf==1'b1) ? qb_common[0] : 1'b0;
    assign is_present_wr_b[1] = (awvalid_bf==1'b1) ? qb_common[1] : 1'b0;


    generate
        for (genvar i = 0; i < NUM_HASH_STACK; i++) begin : gen_bf_row
        sram bf_read(
            .clock(clk),
            .wren_a(wren_a),
            .wren_b(wren_b),
            .address_a(hash_addr_a[i]),
            .address_b(hash_addr_b[i]), 
            .data_a(data_rd_a[i]),
            .data_b(data_rd_b[i]),  
            .q_a(qa_common[i]),
            .q_b(qb_common[i])
        );
        // sram_row bf_write(
        //     .clock(clk),
        //     .wren_a(wren_a),
        //     .wren_b(wren_b),
        //     .address_a(hash_wr_a[i]),
        //     .address_b(hash_wr_b[i]), 
        //     .data_a(data_wr_a[i]),
        //     .data_b(data_wr_b[i]),  
        //     .q_a(is_present_wr_a[i]),
        //     .q_b(is_present_wr_b[i])
        // );
        end
    endgenerate

    always_ff @(posedge clk) begin
            if (!rst_n) begin
                afu_data <= '0;
                arid_bf <= '0;
                awid_bf <= '0;
                arvalid_bf <= 1'b0;
                awvalid_bf <= 1'b0;
                arid_pre <= '0;
                awid_pre <= '0;
                arvalid_pre <= 1'b0;
                awvalid_pre <= 1'b0;
                code_rvalue_pre <= 1'b0;
                code_wvalue_pre <= 1'b0;
                code_rvalue_buf <= 1'b0;
                code_wvalue_buf <= 1'b0;
            end else begin
                afu_data <= csr_data;

                arid_pre <= arid;
                awid_pre <= awid;
                arvalid_pre <= arvalid;
                awvalid_pre <= awvalid;

                arid_bf <= arid_pre;
                awid_bf <= awid_pre;
                arvalid_bf <= arvalid_pre;
                awvalid_bf <= awvalid_pre;

                code_rvalue_pre <= code_rvalue;
                code_wvalue_pre <= code_wvalue;
                code_rvalue_buf <= code_rvalue_pre;
                code_wvalue_buf <= code_wvalue_pre;
            end
    end

    always_ff @(posedge clk) begin
            if (!rst_n) begin
                filter_mask <= '0;
                filter_code <= '0;
            end else begin
                if ((state==WRITE_CD) && (afu_data[63:52]==12'hECA) && (afu_data[11:0]==12'hCAE)) begin
                    filter_mask <= afu_data[51:32];
                    filter_code <= afu_data[31:12];
                end else begin
                    filter_mask <= filter_mask;
                    filter_code <= filter_code;
                end
            end
    end

    always_comb begin
        if (state!=READ_CD) begin
            code_rvalue = 0;
            code_wvalue = 0;
            
        end else begin
            if (ch_rd==channel) begin
                code_rvalue = ((addr_ar_row & filter_mask) == (filter_code & filter_mask) )? 1'b1 : 1'b0 ;
                code_wvalue = ((addr_aw_row & filter_mask) == (filter_code & filter_mask) )? 1'b1 : 1'b0 ;
            end else begin
                code_rvalue = 1'b0;
                code_wvalue = 1'b0;
            end

        end
    end

    // Hash function 1
    always_comb begin
        if (afu_data[6]!=channel) begin
             for (int i = 0; i < NUM_HASH_STACK; i++) begin
                hash_a_value[i] = '0;
            end
        end else begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                automatic int key = {afu_data[33:16], afu_data[8:7]};
                key = key ^ (key >> (10 - i));
                key = key ^ (key >> (4 - i));
                hash_a_value[i] = key[FILTER_LENGTH-1:0];
            end
        end
    end
    
    always_comb begin
        if (ch_rd!=channel) begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                hash_a_rvalue[i] = '1;
            end
        end else begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                automatic int key = addr_ar_row;
                key = key ^ (key >> (10 - i));
                key = key ^ (key >> (4 - i));
                hash_a_rvalue[i] = key[FILTER_LENGTH-1:0];
            end
        end

    end

    always_comb begin
        if (ch_wr!=channel) begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                hash_a_wvalue[i] = '1;
            end
        end else begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                automatic int key = addr_aw_row;
                key = key ^ (key >> (10 - i));
                key = key ^ (key >> (4 - i));
                hash_a_wvalue[i] = key[FILTER_LENGTH-1:0];;
            end
        end
    end    

    // Hash function 2
    always_comb begin
        if (afu_data[6]!=channel) begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                hash_b_value[i] = '1;
            end
        end else begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                automatic int key = {afu_data[33:16], afu_data[8:7]};
                key = (key ^ 32'h9dc5811c) ^ (key >> (5-i));
                key = key ^ (key >> (2 - i));
                hash_b_value[i] = key[FILTER_LENGTH-1:0];
            end
        end
    end

    always_comb begin
        if (ch_rd!=channel) begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                hash_b_rvalue[i] = '0;
            end
        end else begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                automatic int key = addr_ar_row;
                key = (key ^ 32'h9dc5811c) ^ (key >> (5-i));
                key = key ^ (key >> (2 - i));
                hash_b_rvalue[i] = key[FILTER_LENGTH-1:0];
            end
        end

    end

    always_comb begin
        if (ch_wr!=channel) begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                hash_b_wvalue[i] = '0;
            end
        end else begin
            for (int i = 0; i < NUM_HASH_STACK; i++) begin
                automatic int key = addr_aw_row;
                key = (key ^ 32'h9dc5811c) ^ (key >> (5-i));
                key = key ^ (key >> (2 - i));
                hash_b_wvalue[i] = key[FILTER_LENGTH-1:0];
            end
        end

    end     
    

//Control Logic


//Update Bloom Filter Register
generate
    for (genvar i = 0; i < NUM_HASH_STACK; i++) begin : addr_assign
        assign  hash_addr_a[i] = ((state==WRITE)||(state==RESET)) ? hash_a_value[i] : ((arvalid==1'b1) ? hash_a_rvalue[i] : hash_a_wvalue[i]);
        assign  hash_addr_b[i] = ((state==WRITE)||(state==RESET)) ? hash_b_value[i] : ((awvalid==1'b1) ? hash_b_wvalue[i] : hash_b_rvalue[i]);
        assign  data_rd_a[i] = (state==WRITE) ? 1'b1 : 1'b0;
        assign  data_rd_b[i] = (state==WRITE) ? 1'b1 : 1'b0;
    end
endgenerate

        assign wren_a = ((state==WRITE)||(state==RESET)) ? 1'b1 : 1'b0;
        assign wren_b = ((state==WRITE)||(state==RESET)) ? 1'b1 : 1'b0;

always_comb begin : next_state_logic
   next_state = IDLE;
      case(state)
      IDLE    : begin 
                   //if( afu_data == 64'hACE0DEADBEEFACE0 ) begin
                   if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   //else if (afu_data == 64'hBEEFDEADDEADBEEF) begin
                   else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                       next_state = ALL;
                   end
                   else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                   end
                   else begin
                       next_state = IDLE;
                   end

                end
      WRITE     : begin
                   if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                   end
                   else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   //else if (afu_data == 64'hBEEFDEADDEADBEEF) begin
                    else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                       next_state = ALL;
                   end
                   else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                   end
                   else begin
                       next_state = WRITE;
                   end
                end
      READ     : begin
                   if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                   end
                   //else if( afu_data == 64'hACE0DEADBEEFACE0 ) begin
                   else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                       next_state = WRITE;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   //else if (afu_data == 64'hBEEFDEADDEADBEEF) begin
                    else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                       next_state = ALL;
                   end
                   else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                   end
                   else begin
                       next_state = READ;
                   end
                end  
        WRITE_CD    : begin 
                    if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                    end
                    else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                        next_state = WRITE;
                    end
                    else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                        next_state = READ;
                    end                   
                    else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                        next_state = READ_CD;
                    end
                    else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                        next_state = RESET;
                    end
                    else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                        next_state = ALL_RD;
                    end
                    else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                        next_state = ALL_WR;
                    end
                    else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                        next_state = ALL;
                    end
                    else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                    end
                    else begin
                        next_state = WRITE_CD;
                    end
                end
        READ_CD    : begin 
                    if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                    end
                    else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                        next_state = WRITE;
                    end
                    else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                        next_state = READ;
                    end                   
                    else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                    end
                    else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                        next_state = RESET;
                    end
                    else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                        next_state = ALL_RD;
                    end
                    else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                        next_state = ALL_WR;
                    end
                    else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                        next_state = ALL;
                    end
                    else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                    end
                    else begin
                        next_state = READ_CD;
                    end
                end


      RESET     : begin
                   if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                       next_state = ALL;
                   end
                   else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                    end
                   else begin
                       next_state = RESET;
                   end
                end

      ALL_RD     : begin
                   if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                       next_state = ALL;
                   end   
                   else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                    end                
                   else begin
                       next_state = ALL_RD;
                   end
                end  

      ALL_WR     : begin
                   if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                       next_state = ALL;
                   end     
                   else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                    end             
                   else begin
                       next_state = ALL_WR;
                   end
                end  
      ALL     : begin
                   if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h0000AC0EBEEFA0CE) begin
                       next_state = READ_CD_NC;
                    end                
                   else begin
                       next_state = ALL;
                   end
                end  
      READ_CD_NC     : begin
                   if( afu_data == 64'hDEADBEEFDEADBEEF ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hACE0DEADACE0BEEF ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hDEADACE0BEEF0ECA) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'h0000DEADACE0BEEF ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'h0000ACE0BEEFACE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hBEEFDEAD0ACEBEEF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEEFBEEFBEEFACE0) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'hACE0BEEFBEEFBEEF) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'hBEEF00000ACEBEEF) begin
                       next_state = ALL;
                   end              
                   else begin
                       next_state = READ_CD_NC;
                   end
                end  
      default : next_state = IDLE;
   endcase
end


always_comb begin
    if(!rst_n) begin 
        ar_is_rfaulty = 1'b0;
        aw_is_rfaulty = 1'b0;
        ra_cache = 1'b1;
    end else begin  
        case(state)
        IDLE    : begin
                    ar_is_rfaulty = 1'b0;
                    aw_is_rfaulty = 1'b0;
                    ra_cache = 1'b1;
                    end
        WRITE     : begin 
                    ar_is_rfaulty = 1'b0;
                    aw_is_rfaulty = 1'b0;
                    ra_cache = 1'b1;
                    end
        READ     : begin 
                    ar_is_rfaulty = combined_rd_a & combined_rd_b;
                    aw_is_rfaulty = combined_wr_a & combined_wr_b;
                    ra_cache = 1'b1;
                    // ar_is_rfaulty = 1'b0;
                    // aw_is_rfaulty = 1'b0;
                    end
        RESET     : begin 
                    ar_is_rfaulty = 1'b0;
                    aw_is_rfaulty = 1'b0;
                    ra_cache = 1'b1;
                    end
        WRITE_CD     : begin 
                    ar_is_rfaulty = 1'b0;
                    aw_is_rfaulty = 1'b0;
                    ra_cache = 1'b1;
                    end                    
        READ_CD     : begin 
                    ar_is_rfaulty = code_rvalue_buf & arvalid_bf;
                    aw_is_rfaulty = combined_wr_a & combined_wr_b;
                    ra_cache = 1'b1;
                    end  
        ALL_RD     : begin 
                    ar_is_rfaulty = arvalid_bf;
                    aw_is_rfaulty = 1'b0;
                    ra_cache = 1'b1;
                    end
        ALL_WR     : begin 
                    ar_is_rfaulty = 1'b0;
                    aw_is_rfaulty = awvalid_bf;
                    ra_cache = 1'b1;
                    end
        ALL     : begin 
                    ar_is_rfaulty = arvalid_bf;
                    aw_is_rfaulty = awvalid_bf;
                    ra_cache = 1'b1;
                    end  
        READ_CD_NC     : begin 
                    ar_is_rfaulty = code_rvalue_buf & arvalid_bf;
                    aw_is_rfaulty = combined_wr_a & combined_wr_b;
                    ra_cache = 1'b0;
                    end                     

        default : begin 
                    ar_is_rfaulty = 1'b0;
                    aw_is_rfaulty = 1'b0;
                    ra_cache = 1'b1;
                    end
        endcase
    end
end

always_ff@(posedge clk) begin
   if(~rst_n)
      state <= IDLE;
   else
      state <= next_state;
end
endmodule