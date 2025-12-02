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
///////////////////////////////////////////////////////////////////////

/*  Page 603 of CXL 2.0 Spec

PatternSize: Defines what size (in bytes) of P or B to use starting from 
least significant byte. As an example, if this is programmed to 3b011, 
only the lower 3 bytes of P or B registers will be used as a pattern. 
This will be programmed consistently with the ByteMask field and the base
address.
*/

module pattern_reduce_by_pattern_size
(
   input [2:0]           pattern_size_reg_in,
   input [31:0]          pattern_in,

   output logic [31:0]   pattern_out
);


always_comb
begin
  case( pattern_size_reg_in )
    // 3'b100 : pattern_out = pattern_in;
    3'b011  : pattern_out = {8'd0, pattern_in[23:0]};
    3'b010  : pattern_out = {16'd0, pattern_in[15:0]};
    3'b001  : pattern_out = {24'd0, pattern_in[7:0]};
    3'b000  : pattern_out = 32'd0;
    default : pattern_out = pattern_in;
  endcase
end



endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "toBy3eJcLoSPS5XA1REjlBIBfxW/zCO99PlPlkF25O2Q6SyFrPkf/K7O7Q5GGQxBkYEd7jRqTx3KwhSdOj0WeB6/jVImkxYV0nci4EFJEHmbz/rzkI6MnVFvMwIqa3e3m8X2Ksz9+zFu6tYhDo4SH1G9K9DW8BTXx8DTa49+oqFRXnuAzLPngudt1WnGJOGL7z81zZ/8PFqsyMuwEPQ+TP08ciL6yzp0s+46BkzVKs4cNhvsN+cXxO5YleV9KYlluGoNb9zbF+vzjpMWjYrw585BTU3pT1qZE7HVsdMZYaELTQJDmEn1vRQyBf35nNtuT/X2U8QGYl3u5nNjBHVZ+wi90PFg5slNhY/qwy8nX2OVH7FhnNRTXaSgm5uMxuzTpbFsvC4ztqEIQ2CObJiqH+n6I5k4cunfFveJzMy2yJQiB8W4DW8MDSkts19PHX1CuoMp5QD+wCwQ45j+qG8OcV+R4gd1wOUcWFtJahSQQ2OGQTP4UKmdmas7Gw+lRbaa5jfCXMFbhAMoeA0+XLw5LE1qu1ujSCsN6Y5XoZxHUQQ7qo/O86G0STYuY2Dv5gxOJo2P9AXkSbiIMqgUcZb0kyFm+agRrZ1izbfgRDKENFyp03isvUzr64hlUSpJeF8Y466lZ7mqqriODEyCqo26puo7xQVl90S0TABJO4Qv92vEqgYt3pH80xVyzPeStxOoYUIzQ0pFbPpnz+PmR1a6u0FsKOwJ4mcptYZVi/KYKsjXw/LKpAQE2pJdw17HY8oJfd+847b6nPh0XEcfZ4u0juVVXY1T1RkcS8k2EspBTtbWndzdE2owNYwjVfTbg0y3TluI538hYNXmbjjrOqJ66F7LksAgE1zWmm/CNLXccajtwUkOupMPsG+BGVIqsOhUUnnMJpXeM6BdjKtmuszsqJ0ZVW9yG+C7h2dzC9xNObljDhRnX+t+gWbuJ4pXt+LXxVwNSpMCevolsGCWryc1ETehHATf3SBpmIQmx/8BrtZKroaMlPSl4E1PirT0ExGe"
`endif