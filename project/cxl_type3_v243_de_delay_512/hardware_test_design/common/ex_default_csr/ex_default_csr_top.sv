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

module ex_default_csr_top (
    input  logic        csr_avmm_clk,
    input  logic        csr_avmm_rstn,  
    output logic        csr_avmm_waitrequest,  
    output logic [63:0] csr_avmm_readdata,
    output logic        csr_avmm_readdatavalid,
    input  logic [63:0] csr_avmm_writedata,
    input  logic [21:0] csr_avmm_address,
    input  logic        csr_avmm_poison,
    input  logic        csr_avmm_write,
    input  logic        csr_avmm_read, 
    input  logic [7:0]  csr_avmm_byteenable,
    output logic [63:0] afu_data
);


//CSR block


  

   custom_csr_top custom_csr_top_inst(
       .clk          (csr_avmm_clk),
       .reset_n      (csr_avmm_rstn),
       .writedata    (csr_avmm_writedata),
       .read         (csr_avmm_read),
       .write        (csr_avmm_write),
       .byteenable   (csr_avmm_byteenable),
       .readdata     (csr_avmm_readdata),
       .readdatavalid(csr_avmm_readdatavalid),
       .address      ({10'h0,csr_avmm_address}),
       .poison       (csr_avmm_poison),
       .waitrequest  (csr_avmm_waitrequest),
       .afu_data     (afu_data)
   );

//USER LOGIC Implementation 
//
//


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiLKq57WTWHkGyz+IiA5NU7mLhZNm6D/fdlcivzKCrV1hZfDXzAjylyfXXTGl1v8KZFSoQsWNU7VfsVeuroWxLASEpsZ0Tjimvkozp+WSyPrI7hFQwHUawIMbOpgk8PQuVh6t703xvg2GIK+5MLAsCp7mSiCU/L6Q9KRIHtKYKqRRNw25JFlEfm6Qi2GxcmIUZFJnHSG+W5fB4FvLZPlzxTVDKFCq6wv43fZ71Pev6JsPIE0AB+APBVcVaifLqlXO5jjgwS5jnYBWMnhopAxaGoIVienQa/bEtu9zkWT0gq7L6xHTlE6/vkXQreucYdXYZRCQsqm7oHx2qbJ20O+fGi6uVVzfVicbTt+iNMWx0ap1652Cl7vTc002WrUtFyqBe+TipU+cRr8wHIoTtXDDROtzjSCwhRdJmxfN9HSNFELo/p1BSqnuAuivLqXLCuWJNQteYfo+gzSTYcrLq5pBTOrk1am6hni7qH/4addB3gjBxZq45XLcQSwPjX44xpHQ34hntdW1rB29eCoR8JJzhuXi6Ndr/rVSnZik+rwXCCKCiSQ4nZqmap5Yo55JcdLOqmFB5ikUqpRlBwwUrw0kSGI3NeZ/6CJsKCiV9XrTKt637aR1VhEeMwU8KoRSBgZM1VEhHX05RnjBXsEJ9fmdv8c5YAgUtjyTz0YQMsmry+IUhhG3XGyui/Fk3wh6DswJwG+Af3kVgRl9iqLEoqs4E9Pi2gteQEaB/oXZO8R5eB9btBBJtxb/95ioKBjaFM3QKMoF9kFBOyTYTjcN2qVJ5rO"
`endif