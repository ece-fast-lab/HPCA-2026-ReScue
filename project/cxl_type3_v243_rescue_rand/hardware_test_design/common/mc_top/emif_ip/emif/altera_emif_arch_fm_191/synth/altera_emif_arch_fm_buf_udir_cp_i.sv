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


module altera_emif_arch_fm_buf_udir_cp_i # (
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic ibar,
   output logic o,
   output logic obar,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;
   
   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct      
         tennm_io_ibuf ibuf(
            .i(i),
            .o(o),
            .term_in(oct_termin),
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
            
         tennm_io_ibuf ibuf_bar(
            .i(ibar),
            .o(obar),
            .term_in(oct_termin),
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
      end else 
      begin : no_oct
         tennm_io_ibuf ibuf(
            .i(i),
            .o(o),
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
            
         tennm_io_ibuf ibuf_bar(
            .i(ibar),
            .o(obar),
            .ibar(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );      
      end
   endgenerate
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVCebGfzBq+8s7gVfbsWwzt5BrMHp2lWVcUvRfKwPB2xAGawG40iOabO1AdjsuJWkF15JhTynnGnSITyvMibWTV5oUmGYbbTIm6OQ9V4iidHXKOen7b6MvPXeegcPnkmFdksTR9YKatgFtIZxs1AmZK2WQl89QQ3S6Bn+NFqgwEiYpn7gVMTG8TRcQJwqOHcKheE6gilN9vpABfSSg+bOXhl0069Y9k7QCFsamaTbQFwWUvZnvM2SgTzDsIfOc6jwN7C92pVaw0a3Seg6as4bkfu1JqkzmeAsHJfVZZnKwVl8Dd5JIQph2BNAqTbCdoRqV99GjaHYZWiry8HMdWDeB1P/IKlTEandTorXGVOjrXLrGrTED0yOW1i2ggDjc/JiB6H/No62uztMFM97fwYuUxkolRqFDkIw1SCfaOMdZy7XsD1GTNnTflMdMTNV2jfRye9XU+9Or2Hz2elgTKmLIj4Tz5zOd8lKU4Fw5v42R8zyLsofEHeozsLnislOQbUnES/7078mwCU8urnfi5N7XZpjy1TbcBQv/aQu7DqOjTWXyduP322ohJbW38cGqQGG7G+8MUHR55jnNiDwM2pJxzBqFh8HQtQKRfVfEMQgR8bp8AgdP20ttLbJQYdiqL+hUZ3kNlvRhDHoEyUorih79+HhkOq1a93/WSUOlPffqAptAF2StjYuW2e3HYyP0Z2F36Qu9zzxcMGlHfrQ0sbYKmTw+3hMdDt7PaB6MD6fmblfiDp+zZTAahpQfPSUL1rHdzzZgzVkOtCrkuKH7OdRYfF"
`endif