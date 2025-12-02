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


// (C) 2001-2023 Intel Corporation. All rights reserved.
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


// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.




// ------------------------------------------
// Merlin Multiplexer
// ------------------------------------------

// altera message_off 13448

`timescale 1 ns / 1 ns


// ------------------------------------------
// Generation parameters:
//   output_name:         pcie_ed_altera_merlin_multiplexer_1921_zxmqgaq
//   NUM_INPUTS:          1
//   ARBITRATION_SHARES:  1
//   ARBITRATION_SCHEME   "round-robin"
//   PIPELINE_ARB:        1
//   PKT_TRANS_LOCK:      1220 (arbitration locking enabled)
//   ST_DATA_W:           1267
//   ST_CHANNEL_W:        1
// ------------------------------------------

module pcie_ed_altera_merlin_multiplexer_1921_zxmqgaq
(
    // ----------------------
    // Sinks
    // ----------------------
    input                       sink0_valid,
    input [1267-1   : 0]  sink0_data,
    input [1-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    // ----------------------
    // Source
    // ----------------------
    output reg                  src_valid,
    output [1267-1    : 0] src_data,
    output [1-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    // ----------------------
    // Clock & Reset
    // ----------------------
    input clk,
    input reset
);
    localparam PAYLOAD_W        = 1267 + 1 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 1;
    localparam ST_DATA_W        = 1267;
    localparam ST_CHANNEL_W     = 1;
    localparam PKT_TRANS_LOCK   = 1220;
    localparam SYNC_RESET       = 1;

    assign	src_valid			=  sink0_valid;
    assign	src_data			=  sink0_data;
    assign	src_channel			=  sink0_channel;
    assign	src_startofpacket  	        =  sink0_startofpacket;
    assign	src_endofpacket		        =  sink0_endofpacket;
    assign	sink0_ready			=  src_ready;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiL/fpkRCoTXom4fJJ9DtM+AjX1WkHRPA2abIadVBeksmGafYCM8RAgAZsEAV513iZRoQAL6V+KjfXbB57vv0o9+kdVmHiXLGvQK5OX0TvUHimCY9M3mfK/Algr+ALn9AVmz6uoKYg+VHUTFTJtypXsL0OeumuA5+Y/q2+uRXLZ/BjbzE26ur5KFGmp6d6EbfA/6lajivMsAqUkUXMXmNewt81B+P1bzg8CJl0dVSFQFxPw3lEUAigCNXCp4M4d/wZ8iZHVf654LIweo+B0FVtrfLpu+WK8hagZy/i7ICAkrF80oMGzSGnToHuzZZ0dzw+dnkCHoRNcW41vg/lQpps89LIF8LQTMlHhED8I1gGqai4B1NCFqBRoD407q/n1NiN7SyWpxXeaRizuWxhY1JfOZpAN/OOdkwl/TNbZjlFGa5e66xGjfqb2kedDhU3HJNYiH/VVVUq/jwR3VAv8gjJ/A0ITkEELaJIlncyfhxNIipCFBobTvMUuLHf+mOn10dZ+GgXtMq0pxawceLD9fP+AzJnHzB0qkirIafD0KqA+EN/5ZYdzWMIIQaus+1AobvV9087ZIr/WDSFqDyXFR19fzIX86dNdrVg/wbmLAsuz7RKHalAnVrweZnsj9hi6xOR3+9MeGDPxuUoP6w04iDlb7rE5aEoxX/37OyiepaznrUrI8apYdRDf5OBPulLmuSVRLDcNFWJJKGMogrJg6BkQ6Tqh3492LXMIcvyBsrBqiDs/XdZotzISJUUos/xVlL7SPQy+sWclM3XJwx/yGJKYW"
`endif