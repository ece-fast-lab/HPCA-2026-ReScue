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


// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporat's design                tools, logic functions and other
// software and tools, and its AMPP partner logic functions, and any output
// files any of the foregoing (including device programming or simulation
// files), and any associated documentation or information are expressly subject
// to the terms and conditions of the Altera Program License Subscription
// Agreement, Altera MegaCore Function License Agreement, or other applicable
// license agreement, including, without limitation, that your use is for the
// sole purpose of programming logic devices manufactured by Altera and sold by
// Altera or its authorized distributors.  Please refer to the applicable
// agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

//`default_nettype none

module intel_pcie_reset_sync #(
  parameter                  WIDTH_RST              = 1
) (
  input                      clk,
  input                      rst_n,
  output [WIDTH_RST-1:0]     srst_n
);

  wire                       sync_rst_n;

  reg   [WIDTH_RST-1:0]      sync_rst_n_r /* synthesis dont_merge */;
  reg   [WIDTH_RST-1:0]      sync_rst_n_rr /* synthesis dont_merge */;

  assign srst_n              = sync_rst_n_rr;

  intel_std_synchronizer_nocut sync (.clk (clk), .reset_n (rst_n), .din (1'b1), .dout (sync_rst_n) );

  always @(posedge clk) begin
    sync_rst_n_r             <= {(WIDTH_RST){sync_rst_n}};
    sync_rst_n_rr            <= {(WIDTH_RST){sync_rst_n_r}};
  end 


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiLVp3fp/9sAJd0EsoL1rnHI2Qu06BLleTid43MOpOzktOrxui5/EpJs3bp64lSTuTjr9d3k+DbQgBtBHZ9HXA2Mwj5loaMw3TdCQH3II0mje+xxjRILp8hMMjbDqBWHkUTEzdWQSMUwkrVaePwE60zJIVXZhLDmPbNTtIYnbgprUiDnl+VfzPXaGpfXNMVKImQkUWJ/GTUSwEgqxQIyWFiZJuIqTjSeMsGPVmPvbPNNkzjCQK1FcN2j31v3I3QxZk7hOULt56SAXAAHLKIml5GqsOxAzkwmAJ8FfAord9Kpib5z8snX60T/pIMJAqo2bo88JyeAKlwIWGQlBRZDBe40GHP4H19ysLB3kt84qEYuJq2CHEYxWlm4ZoC0sAkSZFyO4wtuy94KloY+azScCDMOrQXH2wducdkxGMi+tS5iwepMgZD2v2zC7dWe/ow4CQ0WTwvJx3l4+XPrij0uoFgGZsVNZnIzaDTQCSqk1w0qzVpQkIM6SDTMnXvRETMSKUpwmq1KT8UvXHcpWLWDiRWYaq+f+UlzkkwktVI2ODyJWzfrp7wEU3gh1GmYonasntJzoVtNhP1enhV88pqF3TC9A6JlFK0kgry+Se7lTyKlAZs9gw0YVjneNxgSpjig04D5qTwsCiAe6jOhTb6b5SKyvBN+K0/fbPXBzaN6L9Y9boi4bDDGvDJ0xMBndPjkeRChhNgTI0VTR35UX+vXy1KymzVn5Z6lDr9XarwR4Z2kcBNRCtIeoDcFfUqyCNH5mD0YFnnHRNXE+6vdRJ8yv951"
`endif