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

package ext_csr_if_pkg;

import tmp_cafu_csr0_cfg_pkg::*;

typedef struct packed {
    tmp_cafu_csr0_cfg_pkg::tmp_DVSEC_FBCAP_HDR2_t       dvsec_fbcap_hdr2;       // 32 bits wide
    tmp_cafu_csr0_cfg_pkg::tmp_DVSEC_FBCTRL2_STATUS2_t  dvsec_fbctrl2_status2;  // 32 bits wide
    tmp_cafu_csr0_cfg_pkg::tmp_DVSEC_FBCTRL_STATUS_t    dvsec_fbctrl_status;    // 32 bits wide
} cafu2ip_csr0_cfg_if_t;

typedef struct packed {
    logic   rsvd ;   // 1 bit
    tmp_cafu_csr0_cfg_pkg::tmp_new_DVSEC_FBCTRL2_STATUS2_t       new_dvsec_fbctrl2_status2;       // 6 bits wide
} ip2cafu_csr0_cfg_if_t;

// Module connect script has issue with "= $bits(cafu2ip_csr0_cfg_if_t)"
localparam CAFU2IP_CSR0_CFG_IF_WIDTH = 96;
localparam IP2CAFU_CSR0_CFG_IF_WIDTH = 7;
localparam TMP_NEW_DVSEC_FBCTRL2_STATUS2_T_BW = $bits( tmp_cafu_csr0_cfg_pkg::tmp_new_DVSEC_FBCTRL2_STATUS2_t );

typedef struct packed {
   logic [51:6]    DevAddr;
   logic [32:0]    SBECnt;
   logic [32:0]    DBECnt;
   logic [32:0]    PoisonRtnCnt;
   logic           NewSBE;
   logic           NewDBE;
   logic           NewPoisonRtn;
   logic           NewPartialWr;
} mc_err_cnt_t;


//-------------------------
//----- CXL Device Type
//      Used by DOE CDAT FSM
typedef enum logic [1:0] {
    INV_TYPE_DEV        = 2'b00,        // (mem_capable, cache_capable)
    TYPE_1_DEV          = 2'b01,
    TYPE_3_DEV          = 2'b10,
    TYPE_2_DEV          = 2'b11
} CxlDeviceType_e;

//-------------------------
//----- DOE CDAT POR values.
//      Type 1 POR Values
//      Included structures DSMAS, DSLBIS and DSIS
localparam  TYPE1_CDAT_0 = 32'h00000030;        // CDAT Length
localparam  TYPE1_CDAT_1 = 32'h0000AA01;        // CDAT Checksum and Rev.

//      Type 3 POR Values
//      Included structures DSMAS, DSLBIS and DSEMTS
localparam  TYPE3_CDAT_0 = 32'h00000058;        // CDAT Length
localparam  TYPE3_CDAT_1 = 32'h00005501;        // CDAT Checksum and Rev.


endpackage: ext_csr_if_pkg
