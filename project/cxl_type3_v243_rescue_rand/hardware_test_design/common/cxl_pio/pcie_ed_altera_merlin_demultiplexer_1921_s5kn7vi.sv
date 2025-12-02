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


// -------------------------------------
// Merlin Demultiplexer
//
// Asserts valid on the appropriate output
// given a one-hot channel signal.
// -------------------------------------

`timescale 1 ns / 1 ns

// ------------------------------------------
// Generation parameters:
//   output_name:         pcie_ed_altera_merlin_demultiplexer_1921_s5kn7vi
//   ST_DATA_W:           1267
//   ST_CHANNEL_W:        1
//   NUM_OUTPUTS:         1
//   VALID_WIDTH:         1
// ------------------------------------------

//------------------------------------------
// Message Supression Used
// QIS Warnings
// 15610 - Warning: Design contains x input pin(s) that do not drive logic
//------------------------------------------

// altera message_off 16753
module pcie_ed_altera_merlin_demultiplexer_1921_s5kn7vi
(
    // -------------------
    // Sink
    // -------------------
    input  [1-1      : 0]   sink_valid,
    input  [1267-1    : 0]   sink_data, // ST_DATA_W=1267
    input  [1-1 : 0]   sink_channel, // ST_CHANNEL_W=1
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    // -------------------
    // Sources 
    // -------------------
    output reg                      src0_valid,
    output reg [1267-1    : 0] src0_data, // ST_DATA_W=1267
    output reg [1-1 : 0] src0_channel, // ST_CHANNEL_W=1
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,


    // -------------------
    // Clock & Reset
    // -------------------
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) // setting message suppression on clk
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) // setting message suppression on reset
    input reset

);

    localparam NUM_OUTPUTS = 1;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    // -------------------
    // Demux
    // -------------------
    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid;

    end

    // -------------------
    // Backpressure
    // -------------------
    assign ready_vector[0] = src0_ready;

    assign sink_ready = |(sink_channel & ready_vector);

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiKXnqNYiSZ510qbcE9jNMwg6VKEPVeDRpPwzM9ZTcch38TGyrVMS5rxa9K6PQ1oKwAtYznVipvSm34g+erWcuSOEo+6Fsg0rCI023BjgKKgMq1raRZlfdkTWLZjpzkaQPxiK75njQ5mO4rPskGRbNYyRlVHtk7K7mBIOABPx5TYQAt42ZE59OXiviwcKpYkASrpYK6IeEE4adKj/LPByllEGyb/d46HuxsVa9n7lqNUaKafsHoHbudcXp7T6YwbzUkpfg3gR9IOnPHurQAT3S02PHYLJkTX6KJHdK3oSDlUp6R4L0t1Kvpuz32sY6WG0XHkJC01gymPrnXeOrsoaD0gfLz/QmW7Sk8ekMTg3zaZNv0/wkNIxMUMJnOlN9+0Bg5Ng0aUZgLQ1668qS351K5CIRrRwL9RARDzQcgFRKZDv9nbpokNJUJVWKKqYbOAAjSE5Stk0pCPePylA5XGyOUQgUGRWE6WyXAEBQfda9yl5P0RSCxW/UBvR18stynHjfmRDz2TRzZdCNM62tf21tK31PJJrZP6lhIW8mhTNv0QiDN+FgipIO1vsr/nHXB/bzyODdnYozk4CJ27Vb4hWADdOaYtDtLhyx/UqPZSiamXAcMf0ZpaMo5vJac2K7wAMeF/C638KM9o8vnKt3klRVxz+BjULUjXy44rPkia3fbmowrH5gxAcCSsKV5JL3mFPX1LqKVUIog43Czz2+NvJWBshCd4k6ARt4kAEfb+OFlrzI0yJk3WjuMmBja/gJU+TQlaXZZizhwcF8wO3s1Agfe2"
`endif