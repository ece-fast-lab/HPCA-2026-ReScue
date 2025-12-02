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




module altera_emif_arch_fm_hmc_mmr_if #(

   parameter PORT_CTRL_MMR_SLAVE_ADDRESS_WIDTH             = 1,
   parameter PORT_CTRL_MMR_SLAVE_RDATA_WIDTH               = 1,
   parameter PORT_CTRL_MMR_SLAVE_WDATA_WIDTH               = 1,
   parameter PORT_CTRL_MMR_SLAVE_BCOUNT_WIDTH              = 1
) (
   input  logic [33:0]                                        ctl2core_mmr_0,
   output logic [50:0]                                        core2ctl_mmr_0,
   input  logic [33:0]                                        ctl2core_mmr_1,
   output logic [50:0]                                        core2ctl_mmr_1,

   input  logic                                               emif_usr_clk,
   
   output logic                                               mmr_slave_waitrequest_0,
   input  logic                                               mmr_slave_read_0,
   input  logic                                               mmr_slave_write_0,
   input  logic [PORT_CTRL_MMR_SLAVE_ADDRESS_WIDTH-1:0]       mmr_slave_address_0,
   output logic [PORT_CTRL_MMR_SLAVE_RDATA_WIDTH-1:0]         mmr_slave_readdata_0,
   input  logic [PORT_CTRL_MMR_SLAVE_WDATA_WIDTH-1:0]         mmr_slave_writedata_0,
   input  logic [PORT_CTRL_MMR_SLAVE_BCOUNT_WIDTH-1:0]        mmr_slave_burstcount_0,
   input  logic                                               mmr_slave_beginbursttransfer_0,
   output logic                                               mmr_slave_readdatavalid_0,
   
   output logic                                               mmr_slave_waitrequest_1,
   input  logic                                               mmr_slave_read_1,
   input  logic                                               mmr_slave_write_1,
   input  logic [PORT_CTRL_MMR_SLAVE_ADDRESS_WIDTH-1:0]       mmr_slave_address_1,
   output logic [PORT_CTRL_MMR_SLAVE_RDATA_WIDTH-1:0]         mmr_slave_readdata_1,
   input  logic [PORT_CTRL_MMR_SLAVE_WDATA_WIDTH-1:0]         mmr_slave_writedata_1,
   input  logic [PORT_CTRL_MMR_SLAVE_BCOUNT_WIDTH-1:0]        mmr_slave_burstcount_1,
   input  logic                                               mmr_slave_beginbursttransfer_1,
   output logic                                               mmr_slave_readdatavalid_1   
);
   timeunit 1ns;
   timeprecision 1ps;
   
   assign core2ctl_mmr_1[13:10]      = 'b0;
   assign core2ctl_mmr_0[13:10]      = 'b0;

   always_ff @(posedge emif_usr_clk) begin
      core2ctl_mmr_0[9:0]        <= mmr_slave_address_0;
      core2ctl_mmr_0[45:14]      <= mmr_slave_writedata_0;
      core2ctl_mmr_0[46]         <= mmr_slave_write_0;
      core2ctl_mmr_0[47]         <= mmr_slave_read_0;
      core2ctl_mmr_0[49:48]      <= mmr_slave_burstcount_0;
      core2ctl_mmr_0[50]         <= mmr_slave_beginbursttransfer_0;
      
      mmr_slave_readdata_0       <= ctl2core_mmr_0[31:0];
      mmr_slave_readdatavalid_0  <= ctl2core_mmr_0[32];
      mmr_slave_waitrequest_0    <= ctl2core_mmr_0[33];

      core2ctl_mmr_1[9:0]        <= mmr_slave_address_1;
      core2ctl_mmr_1[45:14]      <= mmr_slave_writedata_1;
      core2ctl_mmr_1[46]         <= mmr_slave_write_1;
      core2ctl_mmr_1[47]         <= mmr_slave_read_1;
      core2ctl_mmr_1[49:48]      <= mmr_slave_burstcount_1;
      core2ctl_mmr_1[50]         <= mmr_slave_beginbursttransfer_1;
      
      mmr_slave_readdata_1       <= ctl2core_mmr_1[31:0];
      mmr_slave_readdatavalid_1  <= ctl2core_mmr_1[32];
      mmr_slave_waitrequest_1    <= ctl2core_mmr_1[33];
   end
   
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVB8OB4dSJT0Ot/xiLkOSvazytnXnzaOIfiDDOstMYej3aPgdyW6yEHA1vTxJFsjoh7pv3Zxxzo+C4JOi8cb6SkdfM6uIrIIa3t5RjiwzsohFgg5fCzM/MPZPcKJxqL9l3YMzwKD5mBWRTQQDS2J8XL+Ev14YDj4V96QXFxl0koxeQfh7mUYNIkjK/gjqmR4DTU2rCwGrtIl2GLJPOE5Nbd4uKRGgbwusIyTVc3bEIKw+0/IwZ/YlRrhHrHHQcc4qU3NwCJA2sl5Y7tV82TWQkeueFZWePG52HBLesXiROjHHgNckx5eo/Z2eGb3wUjS3FyteHXhvqNArLTMU3zgI1eQ3GH8GrD8JfPOISwNaIfyAAOxD8gjVaeiIjwREb3hTT7YN4mfHJNYKPQI5WkksceZL5R/oo0yZXt4JLGtsim2Q5s6d8Ew4Fq0HfDcmwanp0N8AzfuR9HVwGF0jpfKJQ2nx6jCmv9WfgURjcRp7Rpux5exProc678XRH7mvA5G+DaDj+87ul2n4Uwi7amc/0dlKzAMhFCQEX+buFyQofa4MURRPvPMwyav2AlH0r4dZWt2lOiYuyDQ29WXigZFvAWnUuR+wu2CYGn8R03DcikNiczqh5trR15sTO51pAulKKpFFK7AkuYoREg7gH2L/flwbu7vA2LV+wdxIKnuhb5M/Rkm7GzUWpWc+QIrix+uOxfTIjEA5vTviq6gQXITnhAbf2X6oSjkvagx4yH+777L9DSDpQdrwf3x0wXQaX5Wg8sW1qmitALVJAZ2wS4q7jw2"
`endif