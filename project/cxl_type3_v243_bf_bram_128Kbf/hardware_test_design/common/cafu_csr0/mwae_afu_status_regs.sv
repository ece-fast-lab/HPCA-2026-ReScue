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
`include "ccv_afu_globals.vh.iv"

module mwae_afu_status_regs
//   import ccv_afu_cfg_pkg::*;
   import tmp_cafu_csr0_cfg_pkg::*;
   import ccv_afu_pkg::*;
(
  input clk,
  input reset_n,                //  active low
  input i_mwea_top_level_fsm_busy,
  input i_alg_1a_execute_busy,
  input i_alg_1a_verify_sc_busy,
  input i_alg_1a_verify_nsc_busy,
  input i_alg_1b_execute_busy,
  input i_alg_1b_verify_sc_busy,
  input i_alg_1b_verify_nsc_busy,
  input i_alg_2_execute_busy,

  input [7:0]  i_current_loop_number,
  input [3:0]  i_current_set_number,
  input [31:0] i_current_base_pattern,
  input [51:0] i_current_base_address,

  output tmp_cafu_csr0_cfg_pkg::tmp_new_DEVICE_AFU_STATUS1_t device_afu_status_1_reg,
  output tmp_cafu_csr0_cfg_pkg::tmp_new_DEVICE_AFU_STATUS2_t device_afu_status_2_reg
);


always_ff @( posedge clk )
begin
  if( reset_n == 1'b0 ) 
  begin
       device_afu_status_1_reg.afu_busy               <= 1'b0;
       device_afu_status_1_reg.alg_execute_busy       <= 1'b0;
       device_afu_status_1_reg.alg_verify_nsc_busy    <= 1'b0;
       device_afu_status_1_reg.alg_verify_sc_busy     <= 1'b0;
       device_afu_status_1_reg.loop_number            <= 'd0;
       device_afu_status_1_reg.set_number             <= 'd0;
       device_afu_status_1_reg.current_base_pattern   <= 'd0;
  end
  else begin
       device_afu_status_1_reg.afu_busy               <= i_mwea_top_level_fsm_busy;
       device_afu_status_1_reg.alg_execute_busy       <= i_alg_1a_execute_busy;
       device_afu_status_1_reg.alg_verify_nsc_busy    <= i_alg_1a_verify_nsc_busy;
       device_afu_status_1_reg.alg_verify_sc_busy     <= i_alg_1a_verify_sc_busy;
       device_afu_status_1_reg.loop_number            <= i_current_loop_number;
       device_afu_status_1_reg.set_number             <= i_current_set_number;
       device_afu_status_1_reg.current_base_pattern   <= i_current_base_pattern;
  end
end

always_ff @( posedge clk )
begin
  if( reset_n == 1'b0 )  device_afu_status_2_reg.current_base_address <= 'd0;
  else                   device_afu_status_2_reg.current_base_address <= i_current_base_address;
end


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "S1GUrC2jziQGFCq1WnKTTiX0tux9Ts3LvxtGsW/r0MLQDnFaRrf1Q/z0i6gRM8P1TzNxXCrYkS/oRstnfDdOmiR1jaiEm/CT8OJ+6H5yOCLeA8PwMTSyCePCkUYRFnpclgwBDcHx9Ai+/b/8DDkmsQGlSvaa6lRdhfgq1tufZL1dyzU9cd9kmTu45U8pRDhZbpZT2HQCOPX+oDwpOWMbVBXay6Y5GENn7g1OwAUXrLgvMV+GBrDBqtOpeCugqOJCfRN88FCsx/ixuONmrlszo1ztbHtU1esFSh13Qdf1eUp7WzsneCmTR42qbJW736EbElbvIdh5J2TfTq0mNasA6hceXHEnN5gXO5RncpxkjrXDwApbBY87pu8223BqRE67yz2g5nynsKMdaTig2pwnrXIChK/IN+lM20l7H4YaXHCNSO93Zb3OFQpHB7CgijfwLaQ76SE+vTvyGJg39mNUHMy+jB/mKwhaQpB0Blwh5oWl5Jw1JmnyOA++eWl9zDgSBSs+BGQXJ9mAzXNka/amtsKVo1U8Xc+A+HoZX1C/tWO+iJkwSeSlMXenEZRkZXB0PVHgP/+ONHrOCFwYMSIZYx00yupuS+CblBJq7dofgOMNZIiJ54Kkr4pwGU3g9hElE6yzAFsdPhysmOnN9AcG+CWvrxjPzjx089Qy4LYmsNoC0AYHnvThcp2H/BGQECbh2w/JkbB7MKxywOHPK+/flSV/Vt3k1sloZLlfeO+J/o4X63Bc/lUC2OXMGzZCwBxzBNLunVD7kB/QzPE7qmHPcCbkLv/0GxjJ1AG12pD2Qe9zKbOrh2c00SkJ5jqqbo6USApThktcZGn8nuyW3kVXbC7rvMRV5GMrr5Ex+xrZnjX0Pf0BrLXHNK2enfRzR6/PGTjESg3sObpN/4JvXXxS5uYdP6SzUw1uyU/hkoJ0zbCRNovCuCfLCMB6/Kn5t1XCLlgMEtCKAKBFcqYANqD+rjhpOaFg2CPeWM0k+tHPc/RStDW6AZn8bU89KBKTf+78"
`endif