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


module altera_emif_arch_fm_buf_udir_df_i # (
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic ibar,
   output logic o,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;
   
   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct   
         tennm_io_ibuf  # (
            .differential_mode ("true")
         ) ibuf (
            .i(i),
            .ibar(ibar),
            .o(o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );
      end else 
      begin : no_oct
         tennm_io_ibuf  # (
            .differential_mode ("true")
         ) ibuf (
            .i(i),
            .ibar(ibar),
            .o(o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
            );      
      end
   endgenerate      
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVDUyW6C41jDqqn+5nyx8CMSwh+1vgEGIZA+Tl7OZmOKvB5+971DqffZDhXatesmYBjYcACPhcp+c9gbt+++JEOXP9FtxwscZORSSWjpAhGI922S3jEJWomCZH/3fgdj+7NgZbyMPsiF8Ejv5yhmZIXvai5PcInvP8Zmem5+erHpKbA/6zGF7CiPK0R8WxPi8uJtydlfN/U3mn90nz/9ldT/adsZby272Uoh90DM7UxvVW95caYEz01ulRkagezlZpXDG9dbEVJkg/ltQ5sswTcNsDGiT0i2qTJLIA5T9XuuPVTI1F0yrtbSblg+qRv7EClyRLhlLpP9YAWMW4uKMA7vcoGhb0lBh5KPKX4sT89Px5+VKWo4H1UN7Kmgd/G/84jPCWeixGUDbXCwmIpEl+MkvU/+SH/x1Fgp4jG4/jhO32ltWs1sKwJDGO1UCzPMpMF8zFiajG0CPH2gLXQ4RiRl7r1AIo1PxJqJNiPtrv2iqyr2mD5OJYHvN0dnCpqAm0Ee818bW21w/zLeaCvr/oyPrw2umiGg/xadKw8rNNRKOpB+7q+p4Tlrcf16ktGpyFkPhD9fguA7j/pTrDopJX0kmZfl2cA9t+XBKGsVR/rX0VvZ3BNojR+Kllp3J6ve4Cuaye+ghZ7fWcArs0Rtd2DlaW186DmyhrtyBQj7k1bTqSz+N2ArJnWDFFLbdTIc57oYItjxJ5H8wcXbcpr5zq3a1L7i/sDk3vTQvaSAI55ZjHNkb8DNdHC13R6dWGJsMron8qeyY5MvCe8cYawoQUBt"
`endif