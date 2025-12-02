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


module altera_emif_arch_fm_buf_bdir_df #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter HPRX_CTLE_EN = "off",
   parameter HPRX_OFFSET_CAL = "false",
   parameter CALIBRATED_OCT = 1
) (
   inout  tri   io,
   inout  tri   iobar,
   output logic ibuf_o,
   input  logic obuf_i,
   input  logic obuf_ibar,
   input  logic obuf_oe,
   input  logic obuf_oebar,
   input  logic obuf_dtc,
   input  logic obuf_dtcbar,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;

   localparam DCCEN = "true";

   logic pdiff_out_o;
   logic pdiff_out_obar;
   logic pdiff_out_oe;
   logic pdiff_out_oebar;

   generate
      if (CALIBRATED_OCT)
      begin : cal_oct
         logic pdiff_out_dtc;
         logic pdiff_out_dtcbar;

         tennm_io_ibuf # (
            .hprx_ctle_en (HPRX_CTLE_EN),
            .hprx_offset_cal (HPRX_OFFSET_CAL),
            .differential_mode ("true")
         ) ibuf (
            .i(io),
            .ibar(iobar),
            .o(ibuf_o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
         );

         tennm_pseudo_diff_out # (
            .feedthrough ("true")
         ) pdiff_out (
            .i(obuf_i),
            .ibar(obuf_ibar),
            .oein(obuf_oe),
            .oebin(obuf_oebar),
            .dtcin(obuf_dtc),
            .dtcbarin(obuf_dtcbar),
            .o(pdiff_out_o),
            .obar(pdiff_out_obar),
            .oeout(pdiff_out_oe),
            .oebout(pdiff_out_oebar),
            .dtc(pdiff_out_dtc),
            .dtcbar(pdiff_out_dtcbar)
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf (
            .i(pdiff_out_o),
            .o(io),
            .oe(pdiff_out_oe),
            .term_in(oct_termin),
            .dynamicterminationcontrol(pdiff_out_dtc),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .devoe()
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf_bar (
            .i(pdiff_out_obar),
            .o(iobar),
            .oe(pdiff_out_oebar),
            .term_in(oct_termin),
            .dynamicterminationcontrol(pdiff_out_dtcbar),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .devoe()
         );
      end else
      begin : no_oct
         tennm_io_ibuf  # (
            .hprx_ctle_en (HPRX_CTLE_EN),
            .hprx_offset_cal (HPRX_OFFSET_CAL),
            .differential_mode ("true")
         ) ibuf (
            .i(io),
            .ibar(iobar),
            .o(ibuf_o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .dynamicterminationcontrol()
         );

         tennm_pseudo_diff_out # (
            .feedthrough ("true")
         ) pdiff_out (
            .i(obuf_i),
            .ibar(obuf_ibar),
            .oein(obuf_oe),
            .oebin(obuf_oebar),
            .dtcin(),
            .dtcbarin(),
            .o(pdiff_out_o),
            .obar(pdiff_out_obar),
            .oeout(pdiff_out_oe),
            .oebout(pdiff_out_oebar),
            .dtc(),
            .dtcbar()
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf (
            .i(pdiff_out_o),
            .o(io),
            .oe(pdiff_out_oe),
            .dynamicterminationcontrol(),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .devoe()
         );

         tennm_io_obuf # (
            .dccen(DCCEN)
         ) obuf_bar (
            .i(pdiff_out_obar),
            .o(iobar),
            .oe(pdiff_out_oebar),
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
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVAUqwGenl0c2Y1OLNQMuq8Np2jt9HYRwK1SOoBgWeOrOe7O88vdku6oUCzNBXT+K9M2kMA8S+dxr9JbKJ0vB2Y7QngAk0aQyusXG+1weHYCG4HhNpLJJveG4n+OlqWkhS1YFU1r9rmJ4MYbGumFrQTWNDm+yOAcG51yfVjl2myBz2We1U7xWr4F/8aF6nek4YRvQDm/H+385VDTVB/3zxjw8vS+4eQUr61+ZekJeXZmt+rOSrufLEoNNmQDMZ/SicjYSPkt9fG3V6NRAltfOxsR68hAxBMRHTuUFOJ8j8iN2uXQVDk95UNubLH15DpyBWvvV9ofLspPvCEHVmiZimpfE08oUMnpNi6PsFIuwrS7Yp4hAGbnroFQFnpxY8BXFjZPiVpBvnBCGIjiueGAoJqijczF0xzxxCKKsRbeNMZbvnMKUKmxzRgSp19iloC2qH6aClUKtZTrCVhk2xfYBLAoVQzp8tMQgqHoU4u3jh6mKMoyr5EhiVzsASKajEuGlg4FrkTD+KuuIbKkNpCC89E/7IuBZGOmVzCuOgUZlnavSxXDjrNDAlShX9x31dSuQyQemGUMeY974bms3vuN90G+GNA258odrk1I9vsZhIZZONc7yJeD8cxhAt7CzvcuKHJ/H9Tipptil1ZujW0vbdeBR7KJ6Cei9p+p571bu7JUULjgnRWd7bAPE1NmKpxtCpYSh4IJdANGbnWyWbaIZjHqseF9o1bTJxdbUbTrEcRq6K0xeLRaDc4W8m1Zqa7x9FpCGtpJll5MuRuuQmpG0bny"
`endif