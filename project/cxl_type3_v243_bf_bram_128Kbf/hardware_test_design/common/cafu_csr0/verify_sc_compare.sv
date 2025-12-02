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


// Copyright 2023 Intel Corporation.
//
// THIS SOFTWARE MAY CONTAIN PREPRODUCTION CODE AND IS PROVIDED BY THE
// COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
///////////////////////////////////////////////////////////////////////

/*  Page 602 of CXL 2.0 Spec
*/

module verify_sc_compare
(
    input [511:0]   received_in,
    input [511:0]   expected_in,
    input [63:0]    byte_mask_reg_in,
    
    output logic [63:0]  compare_out
);
   
logic [511:0]  compare_z;


generate
genvar i;
    for( i = 0; i<512; i=i+1 )
    begin : gen_compare_z
        assign compare_z[i] = ( received_in[i] ^ expected_in[i] );
    end
endgenerate

generate
genvar j;
    /*
     *  do an binary OR of each byte to see if it has a mismatch but then
     *  AND that result with the byte mask index of that byte to see if 
     *  it is a byte that is enabled
     */
    for( j=0; j<512; j=j+8 )
    begin : gen_compare_out
       assign compare_out[j/8] = |compare_z[(j+7):j] & byte_mask_reg_in[j/8];
    end
endgenerate
    

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "toBy3eJcLoSPS5XA1REjlBIBfxW/zCO99PlPlkF25O2Q6SyFrPkf/K7O7Q5GGQxBkYEd7jRqTx3KwhSdOj0WeB6/jVImkxYV0nci4EFJEHmbz/rzkI6MnVFvMwIqa3e3m8X2Ksz9+zFu6tYhDo4SH1G9K9DW8BTXx8DTa49+oqFRXnuAzLPngudt1WnGJOGL7z81zZ/8PFqsyMuwEPQ+TP08ciL6yzp0s+46BkzVKs5rjqJDyXiimwmJbg8gMrySo+51ZE2ci3dfNdy5RH5ae6gdT7Y18bZ8CybRm1Ic4h5TCtPLeXPW6xo2hxcqRDtkjyJYnIHHe8A+7G/F1mkGy9PRqK6o/6QhUsc/JzbalUzp2VOr8yySlrihdXA5XFzQwPyIIyJi/CT1QBsjfD3ccNWnRw2yPLHT7eP11vOj498Rv84+DLtdIHnL/BH7zIKf4s0l5tNLNNpq6Mla4lRdnaHG0JymAab12V7Hlyka4NuSdY6utczohXPBBsh41GqUcfhAofiohJnSBR+ArfFEY/tLMqY2V+byd1Vjk3eK30Nr/3qxzvtt12w9ikFMNCHDTHlHeW0nlPSsKTP1B33qsZQfna6SXNcpFb10DIRLE9oynpR/FH8+Uak1BX02ZUBFMjO/GMyPobV444VsoxK2Q5cZ2WOz/pO2bPHF2u8fcujohVbxILadbBrpNIy+uBS/OPRs56fuPhw/89ycKO5YCGz6wpyn5BHjGrQulfxwONGBzpgs4XAX80EdRlGjv08UA0OzcS1rkTFFShXWW/snscwGr9U9yEoF+GQ1aK5SlNYxGB/dPMMYzf87gRznScmTwItGOaev7U387q2/Fn2T983loX4+zaNDQJrDnMAlJRnHJmbLWQ5wKLqCkZ+oN/uMUz4zLEd1v7SNVYlqUwRReIVRHZnJl1FhhlkvuoNaUx2HeBTv9goZFa3stw0SX3HXqZ6fQ68z0JZqhLTHfgJOFuo1P6MqCxnv2zHuFsxXc57yTSr+XHy2zSPDBMsndEs/"
`endif