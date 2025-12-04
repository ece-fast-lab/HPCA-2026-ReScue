import cxlip_top_pkg::*;
import afu_axi_if_pkg::*;

module bloom_filter #(
    parameter FILTER_SIZE=32768, //2^15=32768, 2^16=65536, 2^17=131072
    parameter NUM_HASH_STACK=2, //2^15=32768, 2^16=65536, 2^17=131072
    parameter AFU_AXI_MAX_ID_W = 8
    )(
    input logic clk,
    input logic rst_n,

    input logic [63:0] csr_data,  
    input logic [26:0] addr_ar,
    input logic [26:0] addr_aw,  
    input logic channel,
    input logic ch_rd,
    input logic ch_wr,

    output logic ar_is_faulty,
    output logic aw_is_faulty,

    input logic [AFU_AXI_MAX_ID_W-1:0] arid,
    input logic [AFU_AXI_MAX_ID_W-1:0] awid,
    input logic arvalid,
    input logic awvalid,

    output logic [AFU_AXI_MAX_ID_W-1:0] arid_bf,
    output logic [AFU_AXI_MAX_ID_W-1:0] awid_bf,
    output logic arvalid_bf,
    output logic awvalid_bf
    );

    localparam FILTER_LENGTH = $clog2(FILTER_SIZE);

    logic [FILTER_LENGTH-1:0] hash_addr_a [NUM_HASH_STACK-1:0], hash_addr_b [NUM_HASH_STACK-1:0]; //wire?
    // logic [FILTER_LENGTH-1:0] hash_wr_a [NUM_HASH_STACK-1:0], hash_wr_b [NUM_HASH_STACK-1:0]; //wire?
    logic [FILTER_LENGTH-1:0] hash_a_value [NUM_HASH_STACK-1:0], hash_b_value [NUM_HASH_STACK-1:0]; //wire?
    logic [FILTER_LENGTH-1:0] hash_a_rvalue [NUM_HASH_STACK-1:0], hash_b_rvalue [NUM_HASH_STACK-1:0]; //wire?
    logic [FILTER_LENGTH-1:0] hash_a_wvalue [NUM_HASH_STACK-1:0], hash_b_wvalue [NUM_HASH_STACK-1:0]; //wire?

    logic data_rd_a [NUM_HASH_STACK-1:0], data_rd_b [NUM_HASH_STACK-1:0]; //wire?
    // logic data_wr_a [NUM_HASH_STACK-1:0], data_wr_b [NUM_HASH_STACK-1:0]; //wire?

    logic is_present_rd_a [NUM_HASH_STACK-1:0], is_present_rd_b [NUM_HASH_STACK-1:0]; //wire?
    logic is_present_wr_a [NUM_HASH_STACK-1:0], is_present_wr_b [NUM_HASH_STACK-1:0]; //wire?

    logic [63:0] afu_data;
    logic [FILTER_LENGTH-1:0] cnt_reset;
    logic wren_a, wren_b;

    logic combined_rd_a, combined_rd_b, combined_wr_a, combined_wr_b;

    logic qa_common[NUM_HASH_STACK-1:0], qb_common[NUM_HASH_STACK-1:0];

    logic [AFU_AXI_MAX_ID_W-1:0] arid_pre;
    logic [AFU_AXI_MAX_ID_W-1:0] awid_pre;
    logic arvalid_pre;
    logic awvalid_pre;

    logic [26:0] filter_code;
    logic [26:0] filter_mask;

    logic code_rvalue_pre;
    logic code_wvalue_pre;
    logic code_rvalue_buf;
    logic code_wvalue_buf;
    logic code_rvalue;
    logic code_wvalue;

    //Control Logic
    enum int unsigned { IDLE = 0, WRITE = 1, WRITE_CD = 2, READ = 3, READ_CD = 4, RESET = 5, ALL_RD = 6, ALL_WR = 7, ALL = 8} state, next_state;


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
        // sram bf_write(
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
                if ((state==WRITE_CD) && (afu_data[63:59]==5'b01010) && (afu_data[4:0]==5'b10101)) begin
                    filter_mask <= afu_data[58:32];
                    filter_code <= afu_data[31:5];
                end else begin
                    filter_mask <= filter_mask;
                    filter_code <= filter_code;
                end

            end
    end

    always_comb begin
        if ((state!=READ_CD)&&(state!=ALL_RD)) begin
            code_rvalue = 0;
            code_wvalue = 0;
            
        end else begin
            if (ch_rd==channel) begin
                code_rvalue = ((addr_ar & filter_mask) == (filter_code & filter_mask) )? 1'b1 : 1'b0 ;
                code_wvalue = ((addr_aw & filter_mask) == (filter_code & filter_mask) )? 1'b1 : 1'b0 ;
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
                automatic int key = afu_data[33:7];
                key = key ^ (key >> (13 - i));
                key = key ^ (key >> (7 - i));
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
                automatic int key = addr_ar;
                key = key ^ (key >> (13 - i));
                key = key ^ (key >> (7 - i));
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
                automatic int key = addr_aw;
                key = key ^ (key >> (13 - i));
                key = key ^ (key >> (7 - i));
                hash_a_wvalue[i] = key[FILTER_LENGTH-1:0];
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
                automatic int key = afu_data[33:7];
                key = (key ^ 32'h811c9dc5) ^ (key >> (11-i));
                key = key ^ (key >> (3 - i));
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
                automatic int key = addr_ar;
                key = (key ^ 32'h811c9dc5) ^ (key >> (11-i));
                key = key ^ (key >> (3 - i));
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
                automatic int key = addr_aw;
                key = (key ^ 32'h811c9dc5) ^ (key >> (11-i));
                key = key ^ (key >> (3 - i));
                hash_b_wvalue[i] = key[FILTER_LENGTH-1:0];
            end
        end
        
    end     



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
                   if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = IDLE;
                   end

                end
      WRITE     : begin
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = WRITE;
                   end
                end
      READ     : begin
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = READ;
                   end
                end
        WRITE_CD    : begin 
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = WRITE_CD;
                   end

                end
        READ_CD    : begin 
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = READ_CD;
                   end

                end

      RESET     : begin
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = RESET;
                   end
                end  
      ALL_RD     : begin
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = ALL_RD;
                   end
                end 
      ALL_WR     : begin
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h3EA7BEA60EAFAEA8) begin
                       next_state = ALL;
                   end
                   else begin
                       next_state = ALL_WR;
                   end
                end 
      ALL     : begin
                   if( afu_data == 64'h7EA7BA0F2EA9BA08 ) begin
                       next_state = IDLE;
                   end
                   else if( afu_data == 64'hAFE0D0FDBF0FAFC0 ) begin
                       next_state = WRITE;
                   end
                   else if (afu_data == 64'hFEA0AFE0B0FFA0EF) begin
                       next_state = READ;
                   end
                   else if( afu_data == 64'hF0E0FEA0BACFEFAC ) begin
                       next_state = WRITE_CD;
                   end
                   else if (afu_data == 64'hCEAFE0AC0FEF0AE0) begin
                       next_state = READ_CD;
                   end
                   else if (afu_data == 64'hAECF0EAFBEABBCBF) begin
                       next_state = RESET;
                   end
                   else if (afu_data == 64'hBEAC0EADFEABABE3) begin
                       next_state = ALL_RD;
                   end
                   else if (afu_data == 64'h7CE09EA93EA31EA1) begin
                       next_state = ALL_WR;
                   end
                   else begin
                       next_state = ALL;
                   end
                end                                                                       
      default : next_state = IDLE;
   endcase
end


always_comb begin
    if(!rst_n) begin 
        ar_is_faulty = 1'b0;
        aw_is_faulty = 1'b0;
    end else begin  
        case(state)
        IDLE    : begin
                    ar_is_faulty = 1'b0;
                    aw_is_faulty = 1'b0;
                    end
        WRITE     : begin 
                    ar_is_faulty = 1'b0;
                    aw_is_faulty = 1'b0;
                    end
        READ     : begin 
                    ar_is_faulty = combined_rd_a & combined_rd_b;
                    aw_is_faulty = combined_wr_a & combined_wr_b;
                    // ar_is_faulty = 1'b0;
                    // aw_is_faulty = 1'b0;
                    end
        RESET     : begin 
                    ar_is_faulty = 1'b0;
                    aw_is_faulty = 1'b0;
                    end
        WRITE_CD     : begin 
                    ar_is_faulty = 1'b0;
                    aw_is_faulty = 1'b0;
                    end                    
        READ_CD     : begin 
                    ar_is_faulty = (code_rvalue_buf & arvalid_bf);
                    aw_is_faulty = combined_wr_a & combined_wr_b;
                    end                                     
        ALL_RD     : begin 
                    ar_is_faulty = (code_rvalue_buf & arvalid_bf);
                    aw_is_faulty = awvalid_bf;
                    end
        ALL_WR     : begin 
                    ar_is_faulty = 1'b0;
                    aw_is_faulty = awvalid_bf;
                    end
        ALL     : begin 
                    ar_is_faulty = arvalid_bf;
                    aw_is_faulty = awvalid_bf;
                    end                     
        default : begin 
                    ar_is_faulty = 1'b0;
                    aw_is_faulty = 1'b0;
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
