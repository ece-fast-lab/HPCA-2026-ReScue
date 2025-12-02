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
// Description: Generic RAM with one read port and one write port.
//              Write port includes byte enables.
//

module cafu_ram_1r1w_be (clk,    // input   clock
                         we,     // input   write enable
                         be,     // input   write ByteEnables
                         waddr,  // input   write address with configurable width
                         din,    // input   write data with configurable width
                         raddr,  // input   read address with configurable width
                         dout    // output  write data with configurable width
                        );

parameter BUS_SIZE_ADDR = 4;                  // number of bits of address bus
parameter BUS_SIZE_DATA = 32;                 // number of bits of data bus
parameter BUS_SIZE_BE   = BUS_SIZE_DATA/8;
parameter GRAM_STYLE    = "no_rw_check, M20K";


input                           clk;
input                           we;
input   [BUS_SIZE_BE-1:0]       be;
input   [BUS_SIZE_ADDR-1:0]     waddr;
input   [BUS_SIZE_DATA-1:0]     din;
input   [BUS_SIZE_ADDR-1:0]     raddr;
output  [BUS_SIZE_DATA-1:0]     dout;

//Add directive to don't care the behavior of read/write same address
(*ramstyle=GRAM_STYLE*) reg [BUS_SIZE_BE-1:0][7:0] ram [(2**BUS_SIZE_ADDR)-1:0];  //ram divided into bytes.

reg [BUS_SIZE_ADDR-1:0] raddr_q;
reg [BUS_SIZE_DATA-1:0] dout;
reg [BUS_SIZE_DATA-1:0] ram_dout;
/*synthesis translate_off */
reg                     driveX;         // simultaneous access detected. Drive X on output
/*synthesis translate_on */


always_ff @(posedge clk)
  begin
    if (we)
      for (int i=0; i<BUS_SIZE_DATA/8; i++) 
      begin
        if (be[i])                
          ram[waddr][i]  <= din[7+(8*i)-:8];  // synchronous RAM write with byte enables
      end
    ram_dout<= ram[raddr];
    dout    <= ram_dout;
    /*synthesis translate_off */
    if(driveX)
      dout    <= 'hx;
    if(raddr==waddr && we)
      driveX <= 1;
    else
      driveX <= 0;            
    /*synthesis translate_on */
  end


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "S1GUrC2jziQGFCq1WnKTTiX0tux9Ts3LvxtGsW/r0MLQDnFaRrf1Q/z0i6gRM8P1TzNxXCrYkS/oRstnfDdOmiR1jaiEm/CT8OJ+6H5yOCLeA8PwMTSyCePCkUYRFnpclgwBDcHx9Ai+/b/8DDkmsQGlSvaa6lRdhfgq1tufZL1dyzU9cd9kmTu45U8pRDhZbpZT2HQCOPX+oDwpOWMbVBXay6Y5GENn7g1OwAUXrLgys1GXKmw9gjDyyDqFwzN77IyP7RpRca6GzjdlwOjRi8x6SSJ98oO5ELunmu29KVHFovskf8ywA5Jir+H4EFQ9iUBQ8dMPZhRTYO8KjFcOqXWdWepR9M+ww2CvmxYqZeiC3g7C08do4a4ZI5vmk9zYtbfe7aSSjp+TBvh7OcgXvx8DCUHzD143xLOV5Cqa65gbvzLtawcRknBV206ctrjns5/kmEVhZyFdLZ4fa2gzcWaqKx6xaJsjworks2/HtRrJVI5OAFP88PKrrmdghfXx8Dn6uPXTYqYrw9UJKX7DBz1HPLkemyDgqd7Rv/s5VQ1MqEg7d2PGd7sMWK3ad2zdHxOUgSTn5xOf45IYnCsoYLDh5YmXGMnLwXsUOl8ygDjt89F/YJftsqm1UPuUAoSMXsmOZLkOvvwKPQt96Foo1TWVRc2XLuqAMExF38TQdhYhNSNaBy5oBJimRpB8Ji4VdOAsqhn4hz6XHAr80X36Wbv+ElBLThh6TGfon4n92BhkiO7/eTx9l5v600b6mvYNQG1/V7+0s2OO7/6oZlfDSuqkcZzJujKwzVtVDbyXLTC/H6cP0jH53pftsdTnThbTOUrd4n/AdPM7PZ/+PTfRHwtQ5rtZezQBN0LdBdYXByW2b2gGOzw8gDohxG+vtelTlwviNvBsmF2je5or1YxOCaSarafJr4p9jefdx/UMuHcUC3WSjLZsief/CdsuBTdL3ZGoZzVYf1NLbTBBL9LVp+oVDJJPAhXRegqSaQYymZ77hxKCk7/JKGhDu1BmbVek"
`endif