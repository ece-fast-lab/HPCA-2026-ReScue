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


// Copyright 2022 Intel Corporation.
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

module cxl_io_image_version (data_out);
    output [31:0] data_out;
    assign data_out[15:0] = 16'h4202; //CXL IO version
    assign data_out[31:16] = 16'h5491;
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "H5Me4muwCdD0wBXpIwtSHqPANYFBkFppw7IUkQY+I8Y1cqEvwrQMxWqFMKwLm7G0oFI/8qM3gg9Ahkl/UuJRsLliGlwrzfpbgyM86R6Oz+qDL3K9O8Cc5Du/d7O8jr9kfynJFusl+KRffoROdl/hjYcFVztTZhZpmGHP5EapDR6DhG5+wyFFiSW/nl+Sd3PVKcYLM0BKR+BADBGrQc8x46ziuT5BxFLwpeqcvs+Mz8EU+JQLGovseqKCRmckiX/STlJfLejncLzMuTM5Q5M02Reso/OhplbxSs8PHTCQD1flO2Zl2bl3aaI7Fhwc2ALiI/4uFwmzo8Ufk4bEY7/aR9Eug+HR6LCmuwZwrxmfPabVxkDyf1vLIkoaDzJk2/4QD2Gbc0w2LpZ8a32uD+YnV+rUQ4QcxR98GjjOp520olwkY5eTPQWRO5USPMDB3ebOtRCBTx8dO31MtCXoh2DhUfXc9YfcskLi71UchvFT5eFiJyBMn6hZxvrdPAlUqY8a5nZjsXOxJkkDOmvKdXXjmbH4B3qEWpiNrqCPVhSCXVPFZolma4aPMNWEh1lz/T7X9Ub06cL7OAUYUFFCjdKQd3WWBUKFFKX7iRz7TCAmnGUsMC7qrNF3YlJQm5bGFGiW01mP2z3UJXKfB2gCxzN8d1OPQlHkIOZ3bWBcKv3ftAwQMjSaDMrkBkj6/CkL2h9jwpXVFyfTZoJB0flfJgVHJ2m7WIHPI1u6y9VDXxvqIG4YjvLCO8ZPMf45jkazPbVYYp0imP3XQHaFsrz/fKd0cdC7vhfhEjAyNZdNr134pceS9kn7icQRNLPn8QvUGAlACIyuAPxSjgZPY96fpbAFOz7ul9hcqMI5HeidxkWQFZst+PbxqDPurKLhwzjKeK4KQqNWGqksGVNYy5yLP4QACxLZe826JbkH8kpbBx83rijyefrtWKaWRCUF5+pEVylUsp0HutOV1sXTzTtAdQOo7BmMtMnz6v2qUTVCv/SVZv1vC2d/1okO+BCbzbaLd2ZJ"
`endif
