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

`ifndef CCV_AFU_PKG_VH
`define CCV_AFU_PKG_VH

package ccv_afu_pkg;

//-------------------------
//------ Parameters
//-------------------------
localparam CCV_AFU_DATA_WIDTH   =   512;
localparam CCV_AFU_ADDR_WIDTH   =   52;


typedef struct packed {
  logic illegal_base_address;
  logic illegal_protocol_value;
  logic illegal_write_semantics_value;
  logic illegal_read_semantics_execute_value;
  logic illegal_read_semantics_verify_value;
  logic illegal_pattern_size_value;
} config_check_t;





endpackage: ccv_afu_pkg

`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "S1GUrC2jziQGFCq1WnKTTiX0tux9Ts3LvxtGsW/r0MLQDnFaRrf1Q/z0i6gRM8P1TzNxXCrYkS/oRstnfDdOmiR1jaiEm/CT8OJ+6H5yOCLeA8PwMTSyCePCkUYRFnpclgwBDcHx9Ai+/b/8DDkmsQGlSvaa6lRdhfgq1tufZL1dyzU9cd9kmTu45U8pRDhZbpZT2HQCOPX+oDwpOWMbVBXay6Y5GENn7g1OwAUXrLgv7JAyT85zvhrDa1UHC0nBQkB9fDNa8lcH6kPqy19wMYTLbCI0WwuikaUpWBrVpnzoSmUVoy0FtGSWPmBAxNBW3sjORBn3weV5Mfm5qw68mz0B/6NKHBcA+7aZzxY/RIzgEYBoBnKAPkOAKCzScW+ypWRCCwTa2XPkeikrItodD4r4WKtgVcgbHdT9YNycaRhVB5WfltOLtlzjBqflLPezWDLWIC/q+8TtpQb3HX3zKq8V/zayo7JJzafQom5ZNfj0Pr/FPnvhseD+RpOhrMeY4Gcjkuc3KNoEy8resvBffC7XFXmibwSuBWVzLraIgkzwiRuXh3XgDQSZscX2FUxGuOPyf1Z57qdcFSVCzzoW6SeAIZIwyerSo5vakG1tyO/uai0hfqXliC7qb02HyHKGwOVZhQnnfJDFPxptUdmTQNuIxa9vaEvbansqNxrJHc8+Yh0QFFwKZyYQPv3TwvxIPSAsNPO2nn6xYR3xmUOOojiM2O9GcOMk8BMJX5S79kDRZCpLuSrxtMLgOIwbFj7ZYfrwR1nKzRABc8GrNDMmoBk2Vx0Ej6KhYm+jnaAFlK7w7w+BnApnVfOBd+3262nP556AvaST/F0U/fEHbnSLLnZOLm8UorNQXM/HPRpjDcCjGCr18+lhJM0vmHuF7xUtaTobU+VELfN+0lvCyuuLrCGJBjkHlMVrPmD4Dx0STnY8R70vGhSb8zvW3X85PZiEyhz/A0CPc2euftch18sPXm5PstdSFgks04uRIwURt8OLOfuSRHaRmzt35vYEW/ig"
`endif