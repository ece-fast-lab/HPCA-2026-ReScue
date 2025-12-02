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

module cxl_compliance_csr_top (
    input               Uclk,
    input               Ureset_n,    
    input  logic        csr_avmm_clk,
    input  logic        csr_avmm_rstn,  
    output logic        csr_avmm_waitrequest,  
    output logic [63:0] csr_avmm_readdata,
    output logic        csr_avmm_readdatavalid,
    input  logic [63:0] csr_avmm_writedata,
    input  logic [21:0] csr_avmm_address,
    input  logic        csr_avmm_write,
    input  logic        csr_avmm_read, 
    input  logic [7:0]  csr_avmm_byteenable,
    input  logic [31:0] cxl_compliance_conf_base_addr_high ,
    input  logic        cxl_compliance_conf_base_addr_high_valid,
    input  logic [31:0] cxl_compliance_conf_base_addr_low ,
    input  logic        cxl_compliance_conf_base_addr_low_valid
);


//CSR block

   cxl_compliance_csr_avmm_slave cxl_compliance_csr_avmm_slave_inst(
       .clk          (csr_avmm_clk),
       .reset_n      (csr_avmm_rstn),
       .writedata    (csr_avmm_writedata),
       .read         (csr_avmm_read),
       .write        (csr_avmm_write),
       .byteenable   (csr_avmm_byteenable),
       .readdata     (csr_avmm_readdata),
       .readdatavalid(csr_avmm_readdatavalid),
       .address      (csr_avmm_address),
       .waitrequest  (csr_avmm_waitrequest)
   );

//USER LOGIC Implementation 
//
//


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "H5Me4muwCdD0wBXpIwtSHqPANYFBkFppw7IUkQY+I8Y1cqEvwrQMxWqFMKwLm7G0oFI/8qM3gg9Ahkl/UuJRsLliGlwrzfpbgyM86R6Oz+qDL3K9O8Cc5Du/d7O8jr9kfynJFusl+KRffoROdl/hjYcFVztTZhZpmGHP5EapDR6DhG5+wyFFiSW/nl+Sd3PVKcYLM0BKR+BADBGrQc8x46ziuT5BxFLwpeqcvs+Mz8EwtnvcRqOFCY0o9e9MmyUpy9JuU1yfDE8AiSNY+FwDQcmfXwvQdna/TJUj/+uNlAtzf2yReTXfryzlp+0ypo4DR/hee3V+dFj50mJK4JilLxcjIVc/ZfrmyzI1hFmvsfCcKGb0rTfMrqnrB3xxgtjVuuSmrvkoEVk7DoMukLAFe3nrN7IBbxPKC+uLNZGhq/itWVlwlJ/MI9e89n85dnXEry0imcOY1+XkuLDdo3aTIGhwydh2J1AdkmRAcSZCopx5xNvRY2Cp2SAr8koRIPLNtDjoyjppxGQ0GL7KN2yy9yESv8syTtI+klmYBCgQRU2mbpMn8K9e6sHYZ+rd9uvvBKSGdfxKIeo8fcvfHHjhc+iwt8Y0ogIoSklhjFWau8Xa/b07oOMMbIZpZC2FI0pIqIFKwio/nZiUlu2+KM5z2owXboiBoGdSQQG35ZF3DR15TzLiYU4QWZ45O71zPmmZhTopneS9P9DyXa3W5pOnyjqyveqO3+wm7/IXG8EZSZHdLWK9vDy6KHmfLkwp/Hp7QmS1c0N5Ty4G4bz1pf9DBYzNMfKosWJqeOjKu6Q+q7b4l5UTQwCvNZEn+LRoDqgWkzKUJ7NtX+fwut1FVQsWtNZZxDLodRkXcSYRfieBXa1wXXhjO3B8AO2rUP486PedsQehn+cEL3+HDdjhgeZ+8N2AYn0i0K4qMUxdMfvrkxKf3QaplLneEX/fYVjsyNOqc40CmyngaEEzbY3zt4KXyudK6aqmoLc01arv71iQeHmMbvw8kjsd3mcVF/DqDn6Q"
`endif