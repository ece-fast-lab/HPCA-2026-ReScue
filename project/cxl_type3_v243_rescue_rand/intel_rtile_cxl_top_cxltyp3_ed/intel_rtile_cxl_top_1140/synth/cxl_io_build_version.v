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

module cxl_io_build_version (data_out);
    output [31:0] data_out;
    assign data_out[31] = 1'h1; //1 - debug, 0 - release
    assign data_out[30:0] = 30'h00000000;
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "LB+1sn9ZUTBK/dvUmwnD1oOuDluOstQGN3HibfTGfS77krtqjUQjqFHXieudrwuc18TZH4xhODjC+IdbVmDlcPlVcgpbiNAV1qYGyRVzhoH9cL5QqJIOfo+eFERXOSjBM6D8LUudtuUHtDH0GQJzDU+gRdGXQ4pI/L4IyO/Nq1e2ssyrdq5c+drSRYO37QotDwJ7KaoQQJjX2vAuMzjI9I3S9mipum0AbNCgcS3fhK0MRY0cS8Q/nkORVSYxD3o7Qu9l/FM7YhVg1aDcbL6Z8n9eSZjMheym0PxxNZcPf6zGnp504j9/HfvjYN10/y0TAbeQ1zDmS94AZmF6urAEo0YMCHSJfPBjK3ngcWvEhwz3NRElqCDjVvSOi+jvf2S9eZRVri7ZKSNaDZs6QzvMWrwngbgRfNkfWhOp5DyqZKRrX5CrOj+gwGmYUXQnq/86mqd2zjJSlLC0OWSeskzdbw09VpRbu2b+zkKXNwcVprYZBQVXlJVFa2JE0CB/mWnHSZlDfhp15D8xCx7854+MMN97e41NzjT+Ay8EfE/x+L5Y2HnJ/8o1n3MWa68Zfn0i6GlhSWEAlytw02Cft3HvOl59IK45lvt2rG2qTHe0517qucU3w+H4XyryuQAKmqITmuaEJzxhd//vrrpUv7xJk5tWEqkTy+onI0Wbsac2MLmh2H0NEVEnYAMyrzCr8ZPFq+/ZiWNanGQjx4TY0NHRS+0P96dzBFbCmp73Mc+wbxQuo6ZUOiWYO+dYnYh9HmyTm2yaD6VKnbZcpnhi8GBZaVGIhwNwlqHOBf05o57cLuWdgGX6HuACgBy8gLzpuZOBqT1xNvERfa9j7khu+xvRixaYXTetkgw7lcbP+L6LM5MGYFHki6xafVx3MFuWy4E8jaPiucE7TnkGWYdFyTf4aUzL6FVi1qkaxpFG7bipC/7ElQbMhxvlbn5vUBTxwYtwP5ktdTbHcaQy488vUhs/OaOT2DEfBHTaqC4cD03Q1HMCqJSCAW2Vr1tIGT9rT4RI"
`endif