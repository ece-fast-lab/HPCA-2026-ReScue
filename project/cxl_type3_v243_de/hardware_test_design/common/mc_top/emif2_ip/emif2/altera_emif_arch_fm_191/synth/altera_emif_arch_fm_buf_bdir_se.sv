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


module altera_emif_arch_fm_buf_bdir_se #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter HPRX_CTLE_EN = "off",
   parameter HPRX_OFFSET_CAL = "false",
   parameter CALIBRATED_OCT = 1
) (
   inout  tri   io,
   output logic ibuf_o,
   input  logic obuf_i,
   input  logic obuf_oe,
   input  logic obuf_dtc,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;
   
   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct
         tennm_io_ibuf # (
            .hprx_ctle_en (HPRX_CTLE_EN),
            .hprx_offset_cal (HPRX_OFFSET_CAL)
         ) ibuf (
            .i(io),
            .o(ibuf_o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .ibar()
            );
            
         tennm_io_obuf obuf (
            .i(obuf_i),
            .o(io),
            .oe(obuf_oe),
            .term_in(oct_termin),
            .dynamicterminationcontrol(obuf_dtc),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .devoe()
            );
      end else 
      begin : no_oct
         tennm_io_ibuf # (
            .hprx_ctle_en (HPRX_CTLE_EN),
            .hprx_offset_cal (HPRX_OFFSET_CAL)
         ) ibuf (
            .i(io),
            .o(ibuf_o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .ibar()
         );
            
         tennm_io_obuf obuf (
            .i(obuf_i),
            .o(io),
            .oe(obuf_oe),
            .dynamicterminationcontrol(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .devoe()
            );      
      end
   endgenerate            
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVB0Bibmwz1LK2c1PcLPwCqGUjDvjXVSX7P/YXnsmzTZcP5VlYxFmasAjDaqlHwu27jeX0FhMJdW3ZVIJh7awMx83UAfnwgSMSaIRrlTR/PZ6T+UTV/sEHGpbYT7DAMyD6jxATCEGebLA/kfchOPnG7g/PRSzsL9fHOddrGdpPdw52xtDsy70P9slzauWLMCQtgsHj4juJY3/j0bP08wNp0V4uzN+FQjX2Mz/ZoNBM4dKIgQuKgK+6Uzccv2vIyIHfkkL3QGt1hwgXauAjROlzA9bkXlHHyGB5wjmWYpPdc01vu7PCaEuQyUtQFlVPzkMcEzwbu375Di/0NQ6vi+CFkdPMxyBP/3I+m2cgGUWgVlAYUoA1nx8NUO9XMXrUursYcBIhtdUFGj+w7Yjb2SyLl2hUSHwXts36gMt1XqPg+AuDM/67tUHmpX8OX3pWf4wZNk8h5oAnK+BJzFKb991x1IJK1XaXbPbEj3cUFg5V+Q6bv5CQkSwQMLzG6kDQ4F8u7W4XVCHc98yPS5RMH636iP4M9nvO8vkq0rnFA8RhfyHfxVfqPfgK++3XRpQME6mFGGShe0bxbsZ047/1Ioo7B3zpZOBR6L/sDsmZyOEGj09M6xhg12J9IlrdlN8w8qn/r6Z2YIPoj61CvDteD2saMRBcMTC3KeAa4SDg4iqTBIneh3CnA/z5CQ6fHgvrAQrhJHxIHMCgJsffOsNFGX1NzwvvJjczrv4dijMB8q6CyIiZFOsZ77pidcxXrcAXfCERZsGVS7k0CBBW3MbgVx9/RS"
`endif