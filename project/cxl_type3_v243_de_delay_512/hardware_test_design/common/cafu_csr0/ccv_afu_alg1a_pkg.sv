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
/*
  Description   : FPGA CXL Compliance Engine Initiator AFU
                  Speaks to the AXI-to-CCIP+ translator.
                  This afu is the initiatior
                  The axi-to-ccip+ is the responder
*/

`ifndef CCV_AFU_ALG1A_PKG_VH
`define CCV_AFU_ALG1A_PKG_VH

package ccv_afu_alg1a_pkg;

//-------------------------
//------ Parameters
//-------------------------

typedef enum logic [1:0] {
  MODE_IDLE        = 2'd0,
  MODE_EXECUTE     = 2'd1,
  MODE_VERIFY_SC   = 2'd2,
  MODE_VERIFY_NSC  = 2'd3
} alg1a_mode_enum;

typedef enum logic [3:0] {
  AXI_WR_IDLE            = 4'd0,
//  AXI_WR_WAIT_TIL_4      = 4'd1,
  AXI_WR_WAIT_TIL_NOT_EMPTY = 4'd1,
  AXI_WR_FIRST_POP       = 4'd2,
  AXI_WR_FIRST_AWVALID   = 4'd3,
  AXI_WR_FIRST_AWREADY   = 4'd4,
  AXI_WR_NEXT_AWREADY    = 4'd5,
  AXI_WR_NEXT_AWVALID    = 4'd6,
  AXI_WR_LAST_AWREADY    = 4'd7,
  AXI_WR_LAST_AWVALID    = 4'd8,
  AXI_WR_LAST_WREADY     = 4'd9,
  AXI_WR_LAST_WVALID     = 4'd10,

  AXI_WR_FIRST_WAIT              = 4'd11,
  AXI_WR_FIRST_AWREADY_PLUS_POP2 = 4'd12



} alg1a_exe_axi_write_fsm_enum;







endpackage: ccv_afu_alg1a_pkg

`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "S1GUrC2jziQGFCq1WnKTTiX0tux9Ts3LvxtGsW/r0MLQDnFaRrf1Q/z0i6gRM8P1TzNxXCrYkS/oRstnfDdOmiR1jaiEm/CT8OJ+6H5yOCLeA8PwMTSyCePCkUYRFnpclgwBDcHx9Ai+/b/8DDkmsQGlSvaa6lRdhfgq1tufZL1dyzU9cd9kmTu45U8pRDhZbpZT2HQCOPX+oDwpOWMbVBXay6Y5GENn7g1OwAUXrLhYVzMUtN6kxlq5O9o/LpDrdjey1dQXuKx9y02JoejTzuSBMUw/0NkOKEJE7dk7Fsv5mwiAuNfHeMTeXfe3OlD6sazBWAuZfihyeIYoWYRiN+rQE3/snoMjktk/0OZiDX9bWJf93PHc1H36X7VjN+/P0qfrQ9NbMKISevGe3DSYypgXIgfcAta0M3DQ/whZMZQLYDaVlCihIj+V4PzAqsYdHFwghxAAWbK35L2QSLlrBC3G2FAQARPs5NOGjFNNlvARUEwRpulBkGuHCnp7HL988wk8VtT9WTMTmqWIUnMSZJP1JcGMWDHKrc3RPrSvkB8r2iWdLFd5HWqMPtA9reb1FXOPNyN5vDRQ0zJRSYXCU5LY4KQjaw+ybQsOjWGZGT/1s33Xr9CqSrLGPcgiTXYNaWPzqQLwX6WT1nrCBsESxAUjECcJgYH9mPSeqt/ZlyCMeuC+hOyqTt4xP6+1Rvc55p9pu7GIN1NNGRk9iHog/NyC1Fu1WqGNdehGVl4pWEWdJEWe/9E5W2VYI2+bQN5QGXl/vYdmHJsxYDBmaZTsOKBYo7vBn49zId3X3txJAuQosQbdacy4FLd/yqoe0or6ceHl2Ydj/l7bD+rir91RrNDogZmpaxA1JAVEyUqkTNsGXnGtHhToMR//LALU0YdXVa3h4Kk6rGpy3j11ZSkueexxB9VSkhS6mIk1gXPzcEokn3cfQD2fwClFZdm425IVNDS1TIP2HR8cCEVI+bX6sF4oPabSSmbXVPoeHraO+7Y2djsPJZ72D8Led6BIL6q+"
`endif