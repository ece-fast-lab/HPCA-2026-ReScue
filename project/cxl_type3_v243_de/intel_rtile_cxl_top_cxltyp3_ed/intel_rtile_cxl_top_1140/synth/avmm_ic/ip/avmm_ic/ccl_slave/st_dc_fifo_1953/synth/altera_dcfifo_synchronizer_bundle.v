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


// $File: //acds/rel/24.3/ip/iconnect/avalon_st/altera_avalon_dc_fifo/altera_dcfifo_synchronizer_bundle.v $
// $Revision: #1 $
// $Date: 2024/08/01 $
// $Author: psgswbuild $
//-------------------------------------------------------------------------------

`timescale 1 ns / 1 ns
module altera_dcfifo_synchronizer_bundle(
                                     clk,
                                     reset_n,
                                     din,
                                     dout
                                     );
   parameter WIDTH = 1;
   parameter DEPTH = 3;   
   parameter retiming_reg_en = 0;

   input clk;
   input reset_n;
   input [WIDTH-1:0] din;
   output [WIDTH-1:0] dout;
   
   genvar i;
   
   generate
      for (i=0; i<WIDTH; i=i+1)
        begin : sync
           altera_std_synchronizer_nocut #(.depth(DEPTH), .retiming_reg_en(retiming_reg_en))
                                   u (
                                      .clk(clk), 
                                      .reset_n(reset_n), 
                                      .din(din[i]), 
                                      .dout(dout[i])
                                      );
        end
   endgenerate
   
endmodule 

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "VudRjuN0tk1dliq/IZQS+q6A3SwrLYgqCGAOiZv6F7upYp/VWDT/TGkE2+r3VsSMpoY/9177GbiXiuHLiFHjByPXYvWCf2+RVLxekQxp9S/K2P8ezIyFtWg0BRLwe9ztN5krrnwZdjpoQ0u8sXAqllkXKlv7b8JRiMxdE4uGu+2hX7MvV2mRvO7errmCrVl0uXMUjAnriNrHGqd9XmJgpXHjMHklF2UpcodnVU9qRuKD+FM4UluD0Dm0UCvIwmRNwZRRn1z/Z373LcySFzURNm0+1Q+mPLmkivtOVngBTQwJD3tmFHmHf1vEd5jRZStsfDBbMYcH6jPvDIC2rzExDtheW+ngFyDSks5gDFWFdDdek0q4F775a+FPc8IgAepWI56+pbssXbBsbZsAG3hJu1UkelLDFZrzW57ppBJMSXriHrxBm869owrasH43Di7FPtDxuPiI/bBBoZgv42tYdiMYI7IsCw5KLcHpOyiUip23HIhgs9W5BEVoAsfSVWb6WP7RUKTogJBWHptZcsHpGns2HkCZZUfP0nfXrJtFlqaTe6eOlcYchcLWrre3ZyQThCt69oi7ADMRTnyqaQLlMeFBK25lHEqciFs8WDgc+CJ78ztv83QkinwD5LWBNzTqxdpw9cywfzd0in85PLALmzkvPqb7qE/axrlQh3vk2c3KAF8zJhdB6pv6KsPBe0tnAggyDoh018lN03iNmDJhNs59x/zt7mLT60IQ+f7fS6NHeuVDaXQ/OGY00H3EgPVRlpMPn6FLYvmEO4XeJwpYvwOdKSeMKkVw1/73Ru1YdXx89kFmtlMqn/Gfu0bfUe8ke4lLRdquPn5B61PWGODW2qH1W0QI0WIDbPqXd7JTV3wBQ+FmVRZXcyfaqaV45pqSMo6iGyGlCAY2ebcLd19lYINHaY41TfMKs0LPTXLJh4p2gHdOWgW7GgFPcPkqT7na4Wq75XMX4umuyzNZ0HIOkHVYMxHFTRybAc3cf+QgerFuswMhBT2RlrYedTd7GoqH"
`endif