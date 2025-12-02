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



module altera_emif_arch_fm_oct #(
   parameter PHY_CALIBRATED_OCT = 0
) (
   input  logic oct_rzqin, 
   output logic oct_termin 
);
   localparam OCT_USER_OCT = "A_OCT_USER_OCT_OFF";

   generate if (PHY_CALIBRATED_OCT == 1) begin
     tennm_termination term_inst (
       .req_recal (1'b0),
       .ack_recal (/*open*/),
       .rzqin     (oct_rzqin),
       .serdataout(oct_termin)
     );
   end
   endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVArjbp4VJ1l4L/XEKMblP2yZ6Et+wOrWqhTA2K8G/+Fa0gW6hGSYHRORp0NpJ5zSs+/3xWwBOe7KBIENpPGy4fhPqKDPYBXlbXuVOfxWWevDnRNhCTBJBzyC2gOk68Fq9Fy0riwt0zucnxEgN6hoE2J4l5k4ARonM6N3mQ6W6mEf0B2X6GGiIjvWUH4ZArVIzUkHturp4WkqttahupbqgEDSYSWlhK0hQJ85j7J0+ajk/LXTWd5LdkZ/Kdgsb2w6EAGR6bjBB95PUxoeUATdzxj3GzQvjG1GlqxdqdDLrH+msOyY/3GMpn7p/BlFY0RoJ8ADHL1MWrr0qqOnJIJT8BtTOLvo1SfK+Y60PNX5pCw0KtvY/3jjz37EXR1DAAeUARIHCXZ2AFUnA5UurmF5UeI/7o5lmf0HxUdIWP+Vru+rwI+fN68cmeWMbXbNYLe0GzQtSsdqU+PJo39UvM9DrFssEzYF75A+hdsviodKsF4opqphCssf1aH7s26J3OGtF7no7EzX2afyh1AO4AapTH637HeCXQvrwv9KXrvjgluu9allMROvC00shTbSiRNNiJaLEPKre5lqP/ob1jgfw8JdCkfHwam+Xm30jdcfFbFFN7kwC1Hxwz3bW9hsVaoACpnn1BuBSen+6gbdYTI8yl5pA3h1SrtT7GroGLa3IkpvJWfvqKmZFeK3rhy3UebIjBKqcv/EN1qByakA0rPRA96rMRtvIi0SyFYhhJvph0drm6MhYor8TrAPIcyxVc7Q1BDjiKJ1PwQ/rPTJYLEg11Q"
`endif