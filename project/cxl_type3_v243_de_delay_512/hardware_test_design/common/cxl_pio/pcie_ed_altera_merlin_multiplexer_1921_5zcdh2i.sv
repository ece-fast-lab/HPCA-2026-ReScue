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
//   output_name:         pcie_ed_altera_merlin_multiplexer_1921_5zcdh2i
//   NUM_INPUTS:          1
//   ARBITRATION_SHARES:  1
//   ARBITRATION_SCHEME   "no-arb"
//   PIPELINE_ARB:        0
//   PKT_TRANS_LOCK:      1220 (arbitration locking enabled)
//   ST_DATA_W:           1267
//   ST_CHANNEL_W:        1
// ------------------------------------------

module pcie_ed_altera_merlin_multiplexer_1921_5zcdh2i
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
    localparam PIPELINE_ARB     = 0;
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
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiIbSVLgKc52ROWWGlpEgV5fbVM1jHxxUHWuvW288prvj8RxeMbywKRPU3cEM8+RFSu17ANiqbw+1luTBqK0NJz/vk47uh9zfq5yScHw0cJPK3dDGnmC8gNM2gGIsFXT0AV4Am1et79bZon8booiXd9sjd4wQCn2OglJQpFt1lEfVuAQnh1bPlcYjaBPiKsd1PwAe/uGIxph8yULfCQIqcpz+Q2sOZ+3D4cJ3NYY/CeEFe1uE+8K4GL1mXtXEAoyDz/+MvykXCj156urJTsYKK3qBPE+JuFuxJsFV4EZ6fNGe5DjV/gZjhj7YLjQ69TDjijwowii/PovEbVDIzV+91LytYoKhb8OVpX6QvRVFqtaxAjqaMq1v/7z1h1x0BV3gfu6U8eY04q+aOyRhVadodvIjnOnYwlGJKEvitWMhf9u9/fuuLREfl5zq9wWhJaDjNevndLRrNqRw9Zdr+uRVH+9+T1M4wlJ+Qi92ewuUhkwR6OeRiyo1Uox+vOUZlm/OXkxfIBD+5iLl4xunqxtnY+QkURyZiFpG3T9Bcd9oZ1Q+jl5l0TeG8oUfh3Wai/NFoacEYM1x02VhXqIQ+GGX5Imbw7Zb/TpJspPxvPbVMJp7p9dqtSokUnWqqFcxuAqwnt+cCG44FcQt2Pp5ReMbLbeShC2igo5TQ8Bf4Pjs9RPWsG+keaIP8spiv9kk/MAABT0u2el3sh9+gZipDA8Z5s/S79mHmjOlnUT65w8n+t0c4fdmzKC7f6PX0N22Q8kbRvRANYM5NHIS+cTyl26IjvR"
`endif