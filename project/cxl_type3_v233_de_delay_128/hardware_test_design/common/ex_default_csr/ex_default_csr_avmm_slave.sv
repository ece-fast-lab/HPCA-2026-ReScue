// (C) 2001-2023 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// Copyright 2023 Intel Corporation.
//
// THIS SOFTWARE MAY CONTAIN PREPRODUCTION CODE AND IS PROVIDED BY THE
// COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

module custom_csr_top#(
    parameter REGFILE_SIZE = 64,
    parameter UPDATE_SIZE =8
)(

// AVMM Slave Interface
   input               clk,
   input               reset_n,
   input  logic [63:0] writedata,
   input  logic        read,
   input  logic        write,
   input  logic [7:0]  byteenable,
   output logic [63:0] readdata,
   output logic        readdatavalid,
   input  logic [21:0] address,
   input  logic        poison,
   output logic        waitrequest,

   //input  logic        afu_clk,
   output logic [63:0] afu_data
   //input  logic [7:0]  afu_addr

   //modified for bloom filter
   //input  logic        afu_clk,
   //output logic [63:0] repair_address,
   //output logic        repair_valid

);

 // modified for bloom filter
 logic [63:0] data [REGFILE_SIZE];    // CSR regfile
 //logic [31:0] csr_test_reg;
 logic [63:0] mask ;
 logic [19:0] address_shift3;
 logic config_access; 
 logic [7:0]  afu_addr;
 

 assign mask[7:0]   = byteenable[0]? 8'hFF:8'h0; 
 assign mask[15:8]  = byteenable[1]? 8'hFF:8'h0; 
 assign mask[23:16] = byteenable[2]? 8'hFF:8'h0; 
 assign mask[31:24] = byteenable[3]? 8'hFF:8'h0; 
 assign mask[39:32] = byteenable[4]? 8'hFF:8'h0; 
 assign mask[47:40] = byteenable[5]? 8'hFF:8'h0; 
 assign mask[55:48] = byteenable[6]? 8'hFF:8'h0; 
 assign mask[63:56] = byteenable[7]? 8'hFF:8'h0; 
 assign config_access = address[21];
 assign address_shift3 = address[21:3];  

//Terminating extented capability header
 localparam EX_CAP_HEADER  = 32'h00000000;


//Write logic
/* bit 21 = 0: memory space; bit 21 = 1: config space */
always @(posedge clk) begin
    if (!reset_n) begin
        for (int i = 0; i < REGFILE_SIZE; i++) begin
            if (write && address_shift3 == i) begin
                data[i] <= '0;
            end
        end
    end
    else begin
        for (int i = 0; i < REGFILE_SIZE; i++) begin 
            if(write && address_shift3 == i) begin
                data[i] <= writedata & mask; 
            end    
        end
    end       
end 

always @(posedge clk) begin
    if (!reset_n) begin
                afu_data <= '0;
                afu_addr <= '0;
    end
    else begin
                afu_data <= data[afu_addr];
                afu_addr <= afu_addr + 1; 
    end    
end       


//Read logic
always @(posedge clk) begin
    if (!reset_n) begin
        readdata  <= 64'h0;
    end
    else begin
        if(read && (address[20:0] == 21'h00E00) && config_access) begin //In ED PF1 capability chain with HEADER E00 terminate here with data zero 
           readdata <= {EX_CAP_HEADER} & mask;
        end
        else if (read && (address_shift3 < REGFILE_SIZE)) begin
            readdata <= data[address_shift3] & mask;
        end
        else begin
           readdata  <= 64'h0;
        end        
    end    
end 


//Control Logic
enum int unsigned { IDLE = 0,WRITE = 2, READ = 4 } state, next_state;

always_comb begin : next_state_logic
   next_state = IDLE;
      case(state)
      IDLE    : begin 
                   if( write ) begin
                       next_state = WRITE;
                   end
                   else begin
                     if (read) begin  
                       next_state = READ;
                     end
                     else begin
                       next_state = IDLE;
                     end
                   end 
                end
      WRITE     : begin
                   next_state = IDLE;
                end
      READ      : begin
                   next_state = IDLE;
                end
      default : next_state = IDLE;
   endcase
end


always_comb begin
   case(state)
   IDLE    : begin
               waitrequest  = 1'b1;
               readdatavalid= 1'b0;
             end
   WRITE     : begin 
               waitrequest  = 1'b0;
               readdatavalid= 1'b0;
             end
   READ     : begin 
               waitrequest  = 1'b0;
               readdatavalid= 1'b1;
             end
   default : begin 
               waitrequest  = 1'b1;
               readdatavalid= 1'b0;
             end
   endcase
end

always_ff@(posedge clk) begin
   if(~reset_n)
      state <= IDLE;
   else
      state <= next_state;
end

endmodule