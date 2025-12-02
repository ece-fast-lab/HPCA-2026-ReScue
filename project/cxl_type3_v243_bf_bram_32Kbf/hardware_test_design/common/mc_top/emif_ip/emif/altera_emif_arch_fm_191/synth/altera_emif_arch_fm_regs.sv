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



///////////////////////////////////////////////////////////////////////////////
// This module handles the creation of a conditional register stage.
// This module may be used to implement a synchronizer (with properly selected
// REGISTER value)
///////////////////////////////////////////////////////////////////////////////

// The following ensures that the register stage isn't synthesized into
// RAM-based shift-regs (especially if customer logic implements another follow-on
// pipeline stage). RAM-based shift-regs can degrade timing for C2P/P2C transfers.
(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)

 module altera_emif_arch_fm_regs #(
   parameter REGISTER       = 0,
   parameter WIDTH          = 0
) (
   input  logic              clk,
   input  logic              reset_n,
   input  logic [WIDTH-1:0]  data_in,
   output logic [WIDTH-1:0]  data_out
) /* synthesis dont_merge */;
   timeunit 1ns;
   timeprecision 1ps;

   generate
      genvar stage;

      if (REGISTER == 0) begin : no_reg
         assign data_out = data_in;
      end else begin : regs
         logic [WIDTH-1:0] sr_out [(REGISTER > 0 ? REGISTER-1 : 0):0];

         assign data_out = sr_out[REGISTER-1];

         for (stage = 0; stage < REGISTER; stage = stage + 1)
         begin : stage_gen
            always_ff @(posedge clk or negedge reset_n) begin
               if (~reset_n) begin
                  sr_out[stage] <= '0;
               end else begin
                  sr_out[stage] <= (stage == 0) ? data_in : sr_out[stage-1];
               end
            end
         end
      end
   endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVDYJE9PBQGTFyQvjw/B6FgbI2vbQagt5mipqgsyUvHcSyPyHTJJS3vNnHG7cw4p/kR6PcseUf0u4bHelmnDf4B1u6k68ZfZz3LReblV0lugHtzVR1G/O3yb9IClTBXksSGly8WhyYsA8ilM10x55dzeqnLEu6E/fWN0/FGDHBsaNjsQG7YCeglk0TjXvSY05dKfsTZXSegeFgyOd3g4rYVT8Y5aQ1WGrGKQhZTezJK+xzGIYl0vtzOtJe9f1bWDKKPoSQ5Lu+jYsJwdDWPi5UlCqesO6gRxMmBMRxE57oExxlbaRCyJCN6IXtRVt8CKINfsyNZ4tcjQNKlUiVbb1RADrY+S+p7y08EJG/oav9F7u9R+Dd/6uL16v3nJ+R6Qe/44LmmeolEGud+G/oWghrDj0ftgTP4k/75RgKmSWOlON4OtqVqkepLpHuhFTwhqGnfSrySjQtgA3G3LhTNWe6dLJAwC2f+QmBIPQDX4tKHnGfZxya3v3dmPhpWQ04++sOK7T1EnbRdMWKFxqlUHR64a7GgR0y0yxCLvQNJim+3RNiKl0c6FXHHmbdH+uPKwvshStuANxWWhnjApRmoKhNgVmf1Q2C1NGsR7OsaWGAnycYJ62Qo4o4Eza1UbTPYPBt3F9MgcztuA022rIPjrc43cVojr9iQ66LPFuCXmWyqi3nvxvMXTaFn/ZAc9FZSz+05sKcmrzi559xoz3uKJ22PbPAHX76lFbNrCLscrrV2nN+XOLqDQ+itiUjNR1MR3je0wVu0R88QCcm3Wr0mHWVuI"
`endif