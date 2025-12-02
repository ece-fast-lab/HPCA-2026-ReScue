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

module mwae_error_injection_regs
    import ccv_afu_pkg::*;
//   import ccv_afu_cfg_pkg::*;
   import tmp_cafu_csr0_cfg_pkg::*;
(
  input clk,
  input reset_n,

  `ifdef INCLUDE_POISON_INJECTION
         input [2:0] algorithm_reg,
         input       force_disable_afu,
         input       i_cache_poison_inject_busy,
  `endif

  output tmp_cafu_csr0_cfg_pkg::tmp_new_DEVICE_ERROR_INJECTION_t   new_device_error_injection_reg
);

logic cache_poison_busy;

`ifdef INCLUDE_POISON_INJECTION
  always_ff @( posedge clk )
  begin
         if( reset_n == 1'b0 )           cache_poison_busy <= 1'b0;
//    else if( algorithm_reg == 'd0 )      cache_poison_busy <= 1'b0;
    else if( force_disable_afu == 1'b1 ) cache_poison_busy <= 1'b0;
    else                                 cache_poison_busy <= i_cache_poison_inject_busy;
  end
`else
      assign cache_poison_busy = 1'b0;
`endif

assign new_device_error_injection_reg.CachePoisonInjectionBusy = cache_poison_busy;
//assign new_device_error_injection_reg.MemPoisonInjectionBusy   = 1'b0;
//assign new_device_error_injection_reg.IOPoisonInjectionBusy    = 1'b0;
//assign new_device_error_injection_reg.CacheMemCRCInjectionBusy = 1'b0;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "S1GUrC2jziQGFCq1WnKTTiX0tux9Ts3LvxtGsW/r0MLQDnFaRrf1Q/z0i6gRM8P1TzNxXCrYkS/oRstnfDdOmiR1jaiEm/CT8OJ+6H5yOCLeA8PwMTSyCePCkUYRFnpclgwBDcHx9Ai+/b/8DDkmsQGlSvaa6lRdhfgq1tufZL1dyzU9cd9kmTu45U8pRDhZbpZT2HQCOPX+oDwpOWMbVBXay6Y5GENn7g1OwAUXrLi4pTzOqL4+QhymtAAcyzWgJigYj2p5XhiAG7cvF1LGKhNWQ4WddFkIrqW12iS1xIx46hJnZJsGy6AM7OyYtKYBPgoaNuJPRj0cO6qATcv8iNGhWhQQQckev443Ykgsmov1Z2TFb2Sde15ykPsGImgNlP5joCWCsIkAo+U3BCB42n8cGM/LtyyHiNkqQs0CS3Ct/zcnUmIAnImiwHg+1Nc+JO6Gx/BlrV1KdMN82KrSbm2vcDrf2+vvJBhzT10T6JuPLT5K8963H3WdZW7Emcj3TzNaoQkXgP1EFvQgnZ/Z7wnXOp5l7cgyDgiPvQyrYLxtSrjUf9Ka7ha2gqlyuW+qrytUEmbViQzrp/ahg7+NMLSrsm2Vh89rmIXc5WZ0ESqmHlcq9koPg+cZDKcCuo2yXnAg8tHTSIiwHeXFgZWxfzQUDPbCsEt9CzGkhPFwhwJmPkyb5DhtPNGVqyPisTC4gSHNQYBSeXIxinG81n+RuN7SeY+lekZ11XycdW4JvIIduOjs6CF7h6zQb9cmR58/fR89pwOBaQtBNOL2HucrgBj5k3WkymSuAsNrrb75VATI43SqLmBtcJ7msigGasbXA9pRyBlSz/jv7JgQMZpFGm2dMBpCrLlGGiMPydvQ4z2kIeUchlipPsx1qmY+4GB+Z+PUQpGv9c8j6wEruH6F7FoiZVsXp28FOFVA3SkPm63RyY1l2GfsZfMmIexbJmvGzIF/30X7Co7123WZnn2Th2iyMVKyCQXDKZfOAauqV8mNyrg9vWguZquuOf41dApE"
`endif