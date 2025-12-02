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



////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Expose extra core clocks from IOPLL
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
module altera_emif_arch_fm_pll_extra_clks #(
   parameter PLL_NUM_OF_EXTRA_CLKS = 0,
   parameter DIAG_SIM_REGTEST_MODE = 0
) (
   input  logic                                               pll_locked,            
   input  logic [8:0]                                         pll_c_counters,        
   output logic                                               pll_extra_clk_0,       
   output logic                                               pll_extra_clk_1,
   output logic                                               pll_extra_clk_2,
   output logic                                               pll_extra_clk_3,
   output logic                                               pll_extra_clk_diag_ok
);
   timeunit 1ns;
   timeprecision 1ps;
   
   logic [3:0] pll_extra_clks;
   
   // Extra core clocks to user logic.
   // These clocks are unrelated to EMIF core clock domains. The feature is intended as a
   // way to reuse EMIF PLL to generate core clocks for designs in which physical PLLs are scarce.
   assign pll_extra_clks   = pll_c_counters[8:5];
   assign pll_extra_clk_0  = pll_extra_clks[0];
   assign pll_extra_clk_1  = pll_extra_clks[1];
   assign pll_extra_clk_2  = pll_extra_clks[2];
   assign pll_extra_clk_3  = pll_extra_clks[3];
   
   // In internal test mode, generate additional counters clocked by the extra clocks
   generate
      genvar i;
      
      if (DIAG_SIM_REGTEST_MODE && PLL_NUM_OF_EXTRA_CLKS > 0) begin: test_mode
         logic [PLL_NUM_OF_EXTRA_CLKS-1:0] pll_extra_clk_diag_done;
      
         for (i = 0; i < PLL_NUM_OF_EXTRA_CLKS; ++i)
         begin : extra_clk
            logic [9:0] counter;

            always_ff @(posedge pll_extra_clks[i] or negedge pll_locked) begin
               if (~pll_locked) begin	
                  counter <= '0;
                  pll_extra_clk_diag_done[i] <= 1'b0;
               end else begin
                  if (~counter[9]) begin
                     counter <= counter + 1'b1;
                  end
                  pll_extra_clk_diag_done[i] <= counter[9];
               end
            end         
         end
         
         assign pll_extra_clk_diag_ok = &pll_extra_clk_diag_done;
         
      end else begin : normal_mode
         assign pll_extra_clk_diag_ok = 1'b1;
      end
   endgenerate
   
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVDvR9eACeE+QMA2/jZek/TG6g9uOk/o2DOidh1AQI0aox//DuvnmAzMU5e51c0UzaZXRlxj7wg/78kam0sHrKl5jVghhh+yNeA6K3bMaiO9T16Y9RnzUplohtht1w88T6abFkeSiNRBLLG2EO4yCG9Gl3A/noNLC0+UX2utNtUW8VTkHiOvA3DR3Jz0zHuw0TF5j6wjgDit2uQYEnzJq6PiZfdBffI+V+lawEBt4drakIMG3lyG2vfHK9VDU33jDthgfRKSnq0ZLq793tsqrf9+IOtom/lsaeXyRIcZ+KiDDFrp+51sRvkQb8iKqg/VLeCyewZ4Xaw2F5JeHZuR2luEIGZiTdzPBAPKJhUQDdbBxYshB03UEejm8oq+9TqNSMD2cAgg4oSnJcrTb47EaU+YK070EBSh5ulrsbvqOXfwJdIN8jwneN2kahewx7mEnd8IBp6WZT2aXcUoxvIi2Xit22zjjOZ5SLMmjKpEIIGeV1sj2NSur/uoD7iEOhj6q0nPCRbbt9odkrH3VOmjCcXTzExiqIZBgmUHxalbsZHcgXOJXsI5afl8dTTgUitETbDQwYjpF0Va3Yc5wKn+gM3B2rQaApeE8skUfgXUrWMKbGjw6S04dgPN3DBpucIjYEIIsI7NVHL3dd64fK63p9ENhESVWcj7hqlQUEO77oxpnfIYBoV/y0mXumnJO3of2TwJGlkJEGPj8f8M2fzNnsrZgSwfKKaTwOB7GCVoSnGdY4nzRbYIcl4WrsC7zTWWbh+EdNj1OxzpUZ69S0GniLQF"
`endif