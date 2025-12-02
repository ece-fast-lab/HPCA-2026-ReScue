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


// $Id: //acds/rel/24.3/ip/iconnect/merlin/altera_reset_controller/altera_reset_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2024/08/01 $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // 
    // We omit the "preserve" attribute on the final
    // output register, so that the synthesis tool can
    // duplicate it where needed.
    // -----------------------------------------------
    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "oaB9haQCDayXzRDcszs1tg6iwG+cJCBi7rQB+aTnAh4Db/Vo9Cs9Rf7uF3dqR57pQkCkzE0zN8L/18bpoWn88Cn5xaq3Yy/2rsUQC5nBtd3sGgFmx7fyUgiDl9fpWF062uwHTTFZcSP56Se83A5XfQ4P7Tm/Iby8QCF9pHU4fFq3ex4N0azmCjq6RXN+15KjF5kys/brfzQ7+NWli91jPoUlxeVajEAQFIJIECjQ+tYfrOuy2CdiMP3yeWm0Kb9T8JCP8J+/ZEpWGVWtK6m//xQIn4pXxdCau0Ay8mlii/7yTxK8cUKF9+tZGuQ+O95hqXbz0FpxcBS6YXE0AfNRgxKE8rW4C55Kpm+p+pZ0LijMV5F9JmkhX67eOhHN67Jk6ErHHLt4M/+mh9reqmnlqnlhK7RxFzbTIY2KZrxKyriORRLt7dXqYgUl1vcsGIFOAUz5ci21J2IsGNK9OMplQAv2RE7IDLbPjRdBdKbPSqdOoIHiB9yEyfSvBLfA9BNTmnf8y2xNaN6lwrznwA7FmSu4clr/oJFzQr3k0p9GNmePkUSf04OOl1LTCLmynU1p2UVn5XTT9ZHtV16/t01JcxlBKgpHmbOIZ9tO6ML36USeyJBV3B2pmnXCUVi3jnF88hUY7U+sElkhBIw9RtI8QOw1E3tZ0XMeVZc7jllu2uQqsioX2vXFhdjpPGnO7kAWVkrDQM1iBpkH8nOu3ZDwosPksfomSsmh5kUwwV/J5xFOky7KB+zmZpXIXeUWoixqN3bN9Vj6BHZdpQm6bYfxxSEZkrEQODWrR41pXqSqAxG9ZZqWqxmc0kA2jSD+yVZDD+fPPc9fmjA3//VbuotJMhID6Ygyk4/Wdu/nC3M/djMOdL3jXBGH+YPFhyliad/GwzR8oXY+Pk4ow2W/9DCLxn8/3Y8PcFH6+VWgWIdYb80YSBsqPsMd/SF/xOUaXunLnLnbig+44Ot7g750CdsbRzsImNTBMqG7yPdRPjnPct4Kg8Qd96nCpvqFJMggxQdH"
`endif