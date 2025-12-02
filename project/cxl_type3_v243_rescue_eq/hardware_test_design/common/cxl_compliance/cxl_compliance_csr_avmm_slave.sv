// (C) 2001-2024 Intel Corporation. All rights reserved.
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


// Copyright 2022 Intel Corporation.
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

module cxl_compliance_csr_avmm_slave(
 
// AVMM Slave Interface
   input               clk,
   input               reset_n,
   input  logic [63:0] writedata,
   input  logic        read,
   input  logic        write,
   input  logic [7:0]  byteenable,
   output logic [63:0] readdata,
   output logic        readdatavalid,
   input  logic [31:0] address,
   output logic        waitrequest
);


 logic [63:0] csr_test_f000_reg;
 logic [31:0] csr_test_fffc_reg;
 logic [31:0] csr_test_f00_reg;
 logic [31:0] csr_test_ffc_reg;
 logic [63:0] mask ;
 logic config_access; 

 assign mask[7:0]   = byteenable[0]? 8'hFF:8'h0; 
 assign mask[15:8]  = byteenable[1]? 8'hFF:8'h0; 
 assign mask[23:16] = byteenable[2]? 8'hFF:8'h0; 
 assign mask[31:24] = byteenable[3]? 8'hFF:8'h0; 
 assign mask[39:32] = byteenable[3]? 8'hFF:8'h0; 
 assign mask[47:40] = byteenable[3]? 8'hFF:8'h0; 
 assign mask[55:48] = byteenable[3]? 8'hFF:8'h0; 
 assign mask[63:56] = byteenable[3]? 8'hFF:8'h0; 
 assign config_access = address[21];  

 
//Write logic
always @(posedge clk) begin
    if (!reset_n) begin
        csr_test_f000_reg <= 64'h0;
        csr_test_fffc_reg <= 32'h0;
        csr_test_f00_reg  <= 32'h0;
        csr_test_ffc_reg  <= 32'h0;
    end
    else begin
        if (write && (address[20:0] == 21'hF000)) begin 
           csr_test_f000_reg <= writedata & mask;
        end
        else if (write && (address[20:0] == 21'hFFFC)) begin 
          csr_test_fffc_reg <= writedata & mask;
        end
        else if (write && (address[20:0] == 21'h000F00) && config_access) begin
          csr_test_f00_reg <= writedata & mask;
        end  
        else if (write && (address[20:0] == 21'h000FFC) && config_access) begin
          csr_test_ffc_reg <= writedata & mask;
        end  
        else begin
           csr_test_f000_reg <= csr_test_f000_reg;
           csr_test_fffc_reg <= csr_test_fffc_reg;
           csr_test_f00_reg <= csr_test_f00_reg;
           csr_test_ffc_reg <= csr_test_ffc_reg;
        end        
    end    
end 

//Read logic
always @(posedge clk) begin
    if (!reset_n) begin
        readdata  <= 64'h0;
    end
    else begin
        if (read && (address[20:0] == 21'hF000)) begin 
           readdata <= csr_test_f000_reg & mask;
        end
        else if(read && (address[20:0] == 21'hFFFC)) begin
           readdata <= {32'h0,csr_test_fffc_reg} & mask;
        end
        else if(read && (address[20:0] == 21'h00F00) && config_access) begin
           readdata <= {32'h0,csr_test_f00_reg} & mask;
        end
        else if(read && (address[20:0] == 21'h00FFC) && config_access) begin
           readdata <= {32'h0,csr_test_ffc_reg} & mask;
        end
        else begin
           readdata  <= 32'h0;
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
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "H5Me4muwCdD0wBXpIwtSHqPANYFBkFppw7IUkQY+I8Y1cqEvwrQMxWqFMKwLm7G0oFI/8qM3gg9Ahkl/UuJRsLliGlwrzfpbgyM86R6Oz+qDL3K9O8Cc5Du/d7O8jr9kfynJFusl+KRffoROdl/hjYcFVztTZhZpmGHP5EapDR6DhG5+wyFFiSW/nl+Sd3PVKcYLM0BKR+BADBGrQc8x46ziuT5BxFLwpeqcvs+Mz8FQvW67qryOfd1jVEW7muwCubRJnA9xNpiNtVQ3+2wAmYqJkzWzjdR8lqp08yNN9kJvFk//f8dFwSXlA4twoCbde1KhMXCLtHuIj70em588RCSIt4N08TfcDqfaL0TNaoLqFpxtpUGxYjp2pgp98ON4rHBVmtWUdqNoxWpwLJxDDDZnl9AifQYTR42VwrMEoHkjkleJWn+J2n8Jz+iy76urMzF1L1+fBWQ5nc55/lr+ZyLcWufm3H500+egppE9B4EM2sbvA2jOk3HwCKTn1jGhowbTFcL9Zb+GmebLkqr5ou76WAXN5n09SelU1ZaJBW1pJtFgiju0d8cYgbnhIfrXNebi03B0Loh0TSSB0WHA6COHEAi29IAewlFdqrgofgql7lE8dpjBLWfodP5z877gkKbgT2AuurAivyIRF5kKD6Dfc2bXCq+WT3OHXauPzko6UV9/jVVRWz9AHMCx0JA9Eebx7nOOgleccgl28eGHVjS1wBBAKakHUo+QmfVOxTW1PWZrZ+mDoOfKYBEYh5iKuQhpSCep+QocfarJV+Nz6lTlVax7EN+KWv1wnj6yivniQOHv0pg5I3mYjPZy0MVyRt4asqcU+fyeWgU2jqiXYT3EwmWfpGJpvoKVCLbY8/IwDKhapMx3NN/2H2nhGVKTv9L0nYDTMsFMqclHhunwcZ/OV/YEAnzknFxVvqrqTFhASxN+lBho/oBfVzpoef2LWJqkEvVlAdRk6MqObcfXn0lCqpEW4R/N6bR++M7NPtmZ/d1dxUc3OeHEA4QQEvje"
`endif