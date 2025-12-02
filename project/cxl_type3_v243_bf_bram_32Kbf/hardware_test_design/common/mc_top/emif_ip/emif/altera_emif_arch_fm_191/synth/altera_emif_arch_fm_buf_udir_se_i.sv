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


module altera_emif_arch_fm_buf_udir_se_i #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   input  logic oct_termin,
   output logic o
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
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .ibar(),
            .dynamicterminationcontrol()
            );    
      end else 
      begin : no_oct
         tennm_io_ibuf ibuf(
            .i(i),
            .o(o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .ibar(),
            .dynamicterminationcontrol()
            );
      end
   endgenerate
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVDGbvYHYD8r1w9wJIremjBK45snN8lAOmU8LOSGa3LXcjyaI7hiN95aT5MFr0XJ0Q0Dy6nSsaefjX+jB5fdxevKJvdcdzY++1ZazpsUQJBkyj33OR2NxBj8xQnBFd6SoyXuxtTVJSr9n3wqkceFvjO2ioEojFN5kedOosZC/SVGX+miTlNJETgoNRLnh419KePbx6cX+Dn7N7NxbViqwnWJK1gvwJC2b4yLQkajKU7V2iyrU8lDW+RvQfx7M93T2WyxyZ/YrbnDKrh1K8aOrBMgXBXlrUUMc6s+I/U8bUmw/rOObs4d5Jq+uOYbEQ+KDRREs7ie9MmzA6oy7v+uExmng7hjwV/HJQBJfWCnSgRiZuqPMuiyhFb4ubhJ77/l2f4SR1hFgoml8QlX8D6kPOsw2azZu6Ar45p1Lzf0xjiYfnn2hSFFoS/ITWLYoVCkV4WoEjNofTr0g5V+81g25eyUT4K1WiJWJs3AZ48C0nARNOjyoRvgz+jOQ5hJzNqPhmFUGOXcaV5iY5L1SdMKDEVs6HJv9NEtnrIGQwaX6Ng8+DSNVYsmBBuyxhZRyONmj0ng6wKlKhF4rGvvXwgT500aZPgGeBTLYRl6za+chY8KV13yT1fNeW5rsqdxQybAtzQcdJ5Q876GSpu+dktV53uM6HrvDBVit+QM066smmnCq1YS4YXL0as/B5yEl48BZAio9buipzl8oHst8DdW7klT2JzYrysZAOsmk0UsA9x+A+sfeS+DkeAw0mfimTq2EllhT85/hkktVNJ89xzhEFFL"
`endif