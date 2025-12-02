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


module altera_emif_arch_fm_buf_udir_se_o #(
   parameter OCT_CONTROL_WIDTH = 1,
   parameter CALIBRATED_OCT = 1
) (
   input  logic i,
   output logic o,
   input  logic oe,
   input  logic oct_termin
);
   timeunit 1ns;
   timeprecision 1ps;

   generate
      if (CALIBRATED_OCT) 
      begin : cal_oct
         tennm_io_obuf obuf (
            .i(i),
            .o(o),
            .term_in(oct_termin),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .oe(oe),
            .dynamicterminationcontrol(),
            .devoe()
            );    
      end else 
      begin : no_oct
         tennm_io_obuf obuf (
            .i(i),
            .o(o),
            .seriesterminationcontrol(),
            .parallelterminationcontrol(),
            .obar(),
            .oe(oe),
            .dynamicterminationcontrol(),
            .devoe()
            );    
      end
   endgenerate
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVB3fiTe7tNmJq/XPU0nVYx+RFaOpqQn0nQfdiDSXxXJFmVZmrc21iIpeAZSm+fkQNc6ku8iZ8o+w8nyLBsrvEiY+VCLpEAICrZOYUK1VzD4cZbpD4/wd8ULJ8yuKd6GT32upv3en5qygjjT6KwGb46S31YweQLHeChwnMhqSQb7ru3/gL1e7qVAUlGkAv+fXqZkMleqZcCaPQPWRJ+IUgkzeQ7/jf+kuXPcJ459wDHR/rY5pR5URO2uOPQXU4wYqEEjMhTn9oHvu0NChcmdojBRwAf1mATB2s3utZ4TA+q2Kr0EHjjE/NXW4QTe4GDUa2Ez54NkIn8wdhC5btVvKP0bS9xFkTt1+Ppj92owM4ZPdv8Hp7leBW0gGSDz4wsya62DHkI+b80wH5yqG3zURw0C/gqmNxEx3vDZlPZ6vmtjKO0Jg6abwrGYgD4PL5X5GiwilA5D9OoYvRvs4Qe3K6nQknm24geBle8RgwUZNz6t6PJrYrmzX31gtWy4RCRjCHdV19q0KOzxpfrw1nLHgNVVvLFtXHNfq1aVqCeMl72jHC8og1iypEsQQD2Fwf21KlNT7E+BB7C2Uv/HbO4incL3RwGoG+OzF0MkTB6MqHfzDDTGqyEFww0FnEengrZlq2OP9V4hQkwkA+6VJs32muQa8eHkD+ZLINLpd7U5fywvDt3TT1Bt7dNyanzxmfsgbvov8JYBVtEhbPM1jY66Um8EIZ/+yYKMhe7cROS+VBVIf11Eyfbk8OvMPsHGwaL8UlIBmNykbFI/1c9RaXDPt7OC"
`endif