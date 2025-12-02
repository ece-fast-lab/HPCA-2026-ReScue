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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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


// $Id: //acds/main/ip/merlin/altera_merlin_burst_adapter/altera_merlin_burst_adapter.sv#68 $
// $Revision: #68 $
// $Date: 2014/01/23 $

`timescale 1 ns / 1 ns

// -------------------------------------------------------
// Adapter for uncompressed transactions only. This adapter will
// typically be used to adapt burst length for non-bursting 
// wide to narrow Avalon links.
// -------------------------------------------------------
module altera_merlin_burst_adapter_uncompressed_only
#(
    parameter 
    PKT_BYTE_CNT_H  = 5,
    PKT_BYTE_CNT_L  = 0,
    PKT_BYTEEN_H    = 83,
    PKT_BYTEEN_L    = 80,
    ST_DATA_W       = 84,
    ST_CHANNEL_W    = 8
)
(
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                           sink0_valid,
    input  [ST_DATA_W-1 : 0]        sink0_data,
    input  [ST_CHANNEL_W-1 : 0]     sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg                      source0_valid,
    output reg [ST_DATA_W-1    : 0] source0_data,
    output reg [ST_CHANNEL_W-1 : 0] source0_channel,
    output reg                      source0_startofpacket,
    output reg                      source0_endofpacket,
    input                           source0_ready
);
    localparam
        PKT_BYTE_CNT_W = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
        NUM_SYMBOLS    = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;

    wire [PKT_BYTE_CNT_W - 1 : 0] num_symbols_sig = NUM_SYMBOLS[PKT_BYTE_CNT_W - 1 : 0];

    always_comb begin : source0_data_assignments
        source0_valid         = sink0_valid;
        source0_channel       = sink0_channel;
        source0_startofpacket = sink0_startofpacket;
        source0_endofpacket   = sink0_endofpacket;

        source0_data          = sink0_data;
        source0_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L] = num_symbols_sig;

        sink0_ready = source0_ready;
    end

endmodule



`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "oaB9haQCDayXzRDcszs1tg6iwG+cJCBi7rQB+aTnAh4Db/Vo9Cs9Rf7uF3dqR57pQkCkzE0zN8L/18bpoWn88Cn5xaq3Yy/2rsUQC5nBtd3sGgFmx7fyUgiDl9fpWF062uwHTTFZcSP56Se83A5XfQ4P7Tm/Iby8QCF9pHU4fFq3ex4N0azmCjq6RXN+15KjF5kys/brfzQ7+NWli91jPoUlxeVajEAQFIJIECjQ+tZa+HCRG1gQNG7PDCibYr0thqaJjvyS2kx3a3HZJ1kTeIZsqvw8SQj6rWzCXrENWGaumg6FNhPTRhnGcIt8lnySUClrHhGX+FkhD+gJ97vn54xCI4Nrm1LcmDj63APcLrdwj7SF9CleQRby3yzL18kR9vMjbS+2LUYWLEKsXaYk7NSje7f6moZjbX+OcM1fUR4Jsm++fLQbOpunaC8zSM5gkcBH9ZE4u52tfe5e0RcqLq1hWohsqse2ajXQZmzLZ1D9HgzG6KDubpL3l3CTLNoJneBfWQl0uCfGYHeu1QqBrX+/N9dJ5BK5c6EncVIilrOP7CnNUJUWc515Hrv3tk1f+mKQDfTwkzFGPKQU+2LJUctClX3mkipXQ+H6RElNrhIJ8Fxy3x3oWkHdLBs9NzO4Lfz0kDLvBnGeuoHfM0jUe8KGuGx5GwIrragfGqoojeadLg1E+wYYIYS8HwJ4l6m9Mwg+mvQU9C8gbjisiWySivGEVmEz54ssN74IduyX7LGNIF6zBXfNPLgjDquPX/m7D6/3Zq49ZqjUWlWR0K3G0OEnGlZEneZKmTpwv6MiZg/FGAmSRjwv0IKs2DZcfqJJpYzdBR7Atjl3Qjjt/sa074N8bkJAI9UP8CLHGIDNi6RBe3+yJtmDmrW9sy2JWLxUj7dhgD5GiulF9ho1uYikLZT53iVrCVAx1N0fe0nyt/8W2OPUjllDzUxwMoY+u1e8RtAZcaKQcb5itK4H7/AmnK+kS0u4lg6zZeGeGjHvh16rcfkEmqHkKId6N0xs34Xx"
`endif