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
///////////////////////////////////////////////////////////////////////
// Description: Generic RAM with one read port and one write port
//

module cafu_ram_1r1w (clk,     // input   clock
                      we,      // input   write enable
                      waddr,   // input   write address with configurable width
                      din,     // input   write data with configurable width
                      raddr,   // input   read address with configurable width
                      dout     // output  write data with configurable width
                     );      

parameter BUS_SIZE_ADDR = 4;                  // number of bits of address bus
parameter BUS_SIZE_DATA = 32;                 // number of bits of data bus
parameter GRAM_STYLE    = "no_rw_check";


input                           clk;
input                           we;
input   [BUS_SIZE_ADDR-1:0]     waddr;
input   [BUS_SIZE_DATA-1:0]     din;
input   [BUS_SIZE_ADDR-1:0]     raddr;
output  [BUS_SIZE_DATA-1:0]     dout;

//Add directive to don't care the behavior of read/write same address
(*ramstyle= GRAM_STYLE*) reg [BUS_SIZE_DATA-1:0] ram [(2**BUS_SIZE_ADDR)-1:0];

reg [BUS_SIZE_DATA-1:0] dout;
reg [BUS_SIZE_DATA-1:0] ram_dout;
/*synthesis translate_off */
reg                     driveX;         // simultaneous access detected. Drive X on output
/*synthesis translate_on */


always @(posedge clk)
     begin
           if (we)
             ram[waddr]<=din;  // synchronous RAM write

            ram_dout<= ram[raddr];
            dout    <= ram_dout;
                                            /*synthesis translate_off */
            if(driveX)
                 dout    <= 'hx;
            if(raddr==waddr && we)
                    driveX <= 1;
            else    driveX <= 0;            /*synthesis translate_on */
     end


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "S1GUrC2jziQGFCq1WnKTTiX0tux9Ts3LvxtGsW/r0MLQDnFaRrf1Q/z0i6gRM8P1TzNxXCrYkS/oRstnfDdOmiR1jaiEm/CT8OJ+6H5yOCLeA8PwMTSyCePCkUYRFnpclgwBDcHx9Ai+/b/8DDkmsQGlSvaa6lRdhfgq1tufZL1dyzU9cd9kmTu45U8pRDhZbpZT2HQCOPX+oDwpOWMbVBXay6Y5GENn7g1OwAUXrLgT5REzyvS20wo1V8g7sfx0GoRxRwlP8AGuPTS29VeTxCHr1e0uEKiQm8LbB5ReAnyf29cDTA1pTvyvqqS5DoCCucQgCngkEA3Epes7N83+bzqF3UYnJ02BnLrFBQEMzy/d+4byHc1i2s6Ck/4t3Ugvp6RVoXCKwbzdxbkfYUS6jWtX+dwf/EbcDm1JyCzdguCXfKssH71MDegIedOoneK5SQ1p3Gy7xLaurJHGyAKlleRN4aLKs2WpUqJ0HlvjzRcJp+MUi4SfmDAj2IwAoiTSQVsihSby2uB6FcJfwpRYIw1bHLPQ/sEghDXnerBhRcDeO+XZ8th8GMGPj3L0ARgaWIqTADcKd22lRdMwEsSvqCTo1IlvY+cv7vwWs3T1VanSDB0Z7NSrZevxmhRQnV2ARNqW9IvGBOB5XG1/oMbU5bvKSEksvvJ4loElvyWM7eTqalaSrB2ppOnXWhRmykuyKIjAsGA0GgAtwhzInKv3AJPIU61DLLv/4KLw6lwSU8HydTruShPz4qQqXHf040w3vkQtoqBNbGv2gLzlVIsuC8AWJe+dzvD6AAPESrBcdoxy235Vpn96EUYwLDi+vw3HXiEx7wFCg+xkh1xYbUcPn155cfnlZA0FKAy0WTO7Ul6xcJlGeyPlfZACMxkVBVFt1knoOzCqaD367HBPPa/10nucWnR+hKPX2qna0eBQVWxAkitTqUo9PvauNli2rYm59TZjfqhnao47hsmtpwIUURhVAe9afVcI9t1NkiGN6a6FYX9BG+6w34oCu+c7eKPl"
`endif