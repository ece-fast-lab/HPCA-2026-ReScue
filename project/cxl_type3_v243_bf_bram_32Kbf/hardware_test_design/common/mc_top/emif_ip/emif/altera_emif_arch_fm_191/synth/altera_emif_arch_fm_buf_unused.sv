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


module altera_emif_arch_fm_buf_unused (
   output logic o
);
   timeunit 1ns;
   timeprecision 1ps;

   assign o = 1'b0;
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVByh60+8TGXWFmz3L7usEOBDHuBU7zNrN2nj0R8Qrjn5rk/MQ/zNJdTl8790N645dV0jDJr+ewHQNG12FZUqk9jLpSHdNWSIMff+/w6VpusgDZ4dAcYkrAxj7xZ9Raf0qZSsFXRjQL72Csc51GcIOyTI+8XTrUTbgsXm6K9cYWygeQy9HxuO3BSSO7PSIKGu+RRbgrSSUkFYyI0BPvlCPMAl2xRoZUtWXWI9ycMdob/KNujtscpq/lDoWOuspkfDXof7sO5hvcHWnPgW88ertmor9A7X7cMxS5HRMB59rQsgU/QSlTxd8YH1TtbrSUe+W/ZBt28cGVjAShwbOehXFePWMWWPaS+NOVR4mMmHktOt0z1VAtUUorFoczdUL9e2v1hXshSSan9lDdtPmsJgfNiXnbrVbmeAAxzZ3EtCo3ejUOtZfqk7bRxbjjt3oSuea087W4c38JuVcgL3MupZX2JFPWMjVb03EGdxYkTUs5Ylc1gpxYniHhTY135TjCf/s9P7VTxqpxFH+StLEKxV2kVa0IKrJvyii9lYxztadb5ImNgssno8UhnRLjjcegrwQtmd/9gQHiN1nXDUzn0iIQrcFfR96esFSQRzEfL353HvFpq6TCCWAvSHX/phDcOCbdsHnWkiG5sHKhwmCEyJLxYdSlTY0UOc8qnTshnL7tP/GP0gDmMy/Ed7nhimum7D70ikFCyhSfZ7q3gQGJCpZInB/9BL2pkYMOPtdVet8cp5be/1A+QXY1rpl2bgCgJQNEyowu1x+jNbkHjOo0F9ia8"
`endif