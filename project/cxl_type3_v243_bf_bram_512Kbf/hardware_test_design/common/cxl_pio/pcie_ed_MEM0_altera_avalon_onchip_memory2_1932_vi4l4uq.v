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


//Legal Notice: (C)2023 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 13469 16735 16788 

module pcie_ed_MEM0_altera_avalon_onchip_memory2_1932_vi4l4uq (
                                                                // inputs:
                                                                 address,
                                                                 byteenable,
                                                                 chipselect,
                                                                 clk,
                                                                 clken,
                                                                 freeze,
                                                                 reset,
                                                                 reset_req,
                                                                 write,
                                                                 writedata,

                                                                // outputs:
                                                                 readdata
                                                              )
;

//  parameter INIT_FILE = "pcie_ed_MEM0_MEM0.hex";


  output  [1023: 0] readdata;
  input   [  7: 0] address;
  input   [127: 0] byteenable;
  input            chipselect;
  input            clk;
  input            clken;
  input            freeze;
  input            reset;
  input            reset_req;
  input            write;
  input   [1023: 0] writedata;


wire             clocken0;
wire             freeze_dummy_signal;
reg     [1023: 0] readdata;
wire    [1023: 0] readdata_ram;
wire             reset_dummy_signal;
wire             wren;
  assign reset_dummy_signal = reset;
  assign freeze_dummy_signal = freeze;
  always @(posedge clk)
    begin
      if (clken)
          readdata <= readdata_ram;
    end


  assign wren = chipselect & write;
  assign clocken0 = clken & ~reset_req;
  altsyncram the_altsyncram
    (
      .address_a (address),
      .byteena_a (byteenable),
      .clock0 (clk),
      .clocken0 (clocken0),
      .data_a (writedata),
      .q_a (readdata_ram),
      .wren_a (wren)
    );

  defparam the_altsyncram.byte_size = 8,
//           the_altsyncram.init_file = INIT_FILE,
           the_altsyncram.lpm_type = "altsyncram",
           the_altsyncram.maximum_depth = 256,
           the_altsyncram.numwords_a = 256,
           the_altsyncram.operation_mode = "SINGLE_PORT",
           the_altsyncram.outdata_reg_a = "UNREGISTERED",
           the_altsyncram.ram_block_type = "AUTO",
           the_altsyncram.read_during_write_mode_mixed_ports = "DONT_CARE",
           the_altsyncram.read_during_write_mode_port_a = "DONT_CARE",
           the_altsyncram.width_a = 1024,
           the_altsyncram.width_byteena_a = 128,
           the_altsyncram.widthad_a = 8;

  //s1, which is an e_avalon_slave
  //s2, which is an e_avalon_slave

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiLWeM7iwnYIyWCYiaJUJvVtFSseqdcJhAvfQagXPDvJJGhtGnto1etfv4nAu2R2lFMMjIJZGZggjtYBBFA48QGD62hEKXsWcIDKgvMyeDgmz4kTqXAHQUlVql4+aGLs0jVIqJcdumGu/mcK3dJxUf0mTHSnGSFOUDcragX3OdXvuSIGHxVXRD+pELE1cdbUhICMbGm83rs+/Ohy9Vq/jn7uOVjNoTE7o/fV2RlGhN+fmPO3j6sHXEWiZWBMWmZSjIqqnBHgpzyjjAde8jg19ANyR0RsU6ALwf0alPJIs3gIl51gQ52F/mn1xl1ScAiQ5bH/5+RBw6HWHhwENsBF7pPxd/jGmvRAnl+FuiOuYoESxpDtbzo3ha50ACVtJgH1/w+WgjbzgSdlUKnBpDNgKezXYLS6HyRl0X2qRVwyGDm1XyDwyqMPgrM8s1l+rYb//SllZlfsEaRMGl1n/5UJdg0CrdiVkluJzUtTFN/eRwu8gZefMUwCmEMFXcqtOosDZiiZMipplFxkdpmN4yXLP0/5fQ8GE4jXdhk+8Lh5zAmOwUoOzbhyNnJUcJ3DwSacPEUeymc4nkU/fS2xYa6EhECJS/R8rUHtywNPmT6FmmkGqkQgo+Tkc0VDEE6j2NDipvWHrEY638K1TDWyhJAwwqIT2Wk9VM3DuB5GKn79nD1ide31kgHEahM0FrYM/njoyWpQ8ubdz8Zv/7OKQ64WPAxJ+vmhqNcuNWq+JjJBpXV+PwEFOu+xRw0b/mTPBbnrEbIW8E0c7W5kOkFdlr9liN0h"
`endif