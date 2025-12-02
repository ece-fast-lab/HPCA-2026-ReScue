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


module altera_emif_arch_fm_buf_udir_df_o #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic ibar,
   output logic o,
   output logic obar,
   input  logic oein,
   input  logic oeinb,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;

   localparam DCCEN = "true";

   logic pdiff_out_o;
   logic pdiff_out_obar;

   logic pdiff_out_oe;
   logic pdiff_out_oebar;

   tennm_pseudo_diff_out # (
      .feedthrough("true")
   ) pdiff_out (
      .i(i),
      .ibar(ibar),
      .o(pdiff_out_o),
      .obar(pdiff_out_obar),
      .oein(oein),
      .oebin(oeinb),
      .oeout(pdiff_out_oe),
      .oebout(pdiff_out_oebar),
      .dtcin(),
      .dtcbarin(),
      .dtc(),
      .dtcbar()
   );

   generate
      if (CALIBRATED_OCT)
      begin : cal_oct
         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf (
            .i(pdiff_out_o),
            .o(o),
            .oe(pdiff_out_oe),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf_bar (
            .i(pdiff_out_obar),
            .o(obar),
            .oe(pdiff_out_oebar),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );
      end else
      begin : no_oct
         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf (
            .i(pdiff_out_o),
            .o(o),
            .oe(pdiff_out_oe),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf_bar (
            .i(pdiff_out_obar),
            .o(obar),
            .oe(pdiff_out_oebar),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol(),
            .obar(),
            .devoe()
         );
      end
   endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVCbp/70tG3hsbtXnVG3VixCbj95X6xZNK2LronqM3h8K6Az3kncSrrTS6wodnAjiz0YrVILdvomK5s6vPC6tRNSSugOJxXVIq2SsUXJcev5NtXnMnGIbG34p2UcnNkqVrWlnxkHMLrFNkxI48fmnjrcsiTjln2wxY9rFTdHG0auEcbSS0AUMXRVRWQ0q6SEKoIaSJVjxgHvRrruNuIuTlRS6x18bqA+xFXfl9I/l+L/vFFGbF7gLj/05g4w5Jisq7C8STbpUIV+vbUi+bKEbBM810AZwC9W/ZP0ox2kLPSakl7Y9e9hT3IM5HKC7WwHI15pyJZcwlmZPEG3sgRuB9vxbj2jZ5dN53HP5UXO6Q2inis99PNX2uBdqWiCILnyWwWRCaTJo02khbg/RXDe22kXTkVtSWB656h0eBfDb9nKpWi3xZojZB4RRfJjJwK/weP7n/RmMWZ8wUZkVGN9L7XA9kIdI7mSMpfGfG3jYWZ6GRjLtYScwzK+RW5ZZJfw1MQjMn7fCSoSYZMD1skqlS1UPXtFQLZfzg0EKivsp+OfJIcgQf5SWIFhhQ9FS0xWeFnUqHqPsNKKJE1rviwp4dg5jPH8bb4ESCkSyfHZS/aBstxTbf3F2OFIGwa5uwB4je7j0CGbGhg6Fa0bOdweNsA1lA/eggsudZ+aq1E3GJR3YvvaI9K4gMV6l1j6u7ndB7Xj9BAWI0zkdOkP7qqFQjw/p4yTyiGuuvosmrv55OozqBjSMzkAhMjA8Z1Ne5WH3CVs6tMiW4wFdj1ZQ9Ta2R32"
`endif