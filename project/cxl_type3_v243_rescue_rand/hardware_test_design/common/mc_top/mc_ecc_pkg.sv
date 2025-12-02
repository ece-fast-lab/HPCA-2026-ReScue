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
//
///////////////////////////////////////////////////////////////////////
// Creation Date : Feb, 2023
// Description   : SBCNT/DBCNT 

package mc_ecc_pkg;

 
//-------------------------
//------ Dev Mem Interfaces
//-------------------------
typedef struct packed {
    logic [7:0]                      SBE;
    logic [7:0]                      DBE;
    logic                            Valid;
} mc_rddata_ecc_t;

localparam  CL_ADDR_MSB = 51;
localparam  CL_ADDR_LSB = 6;
typedef logic [CL_ADDR_MSB:CL_ADDR_LSB]        Cl_Addr_t;

typedef struct packed {
    logic [255:0]   Data1;
    logic [255:0]   Data0;
} DataCL_t;

typedef struct packed {
    mc_rddata_ecc_t                  RdDataECC;
    logic                            RdDataValid;
} mc_devmem_if_t;

typedef struct packed {
    Cl_Addr_t                        DevAddr;
    logic [32:0]                     SBECnt;
    logic [32:0]                     DBECnt;
    logic [32:0]                     PoisonRtnCnt;
    logic                            NewSBE;
    logic                            NewDBE;
    logic                            NewPoisonRtn;
    logic                            NewPartialWr;
} mc_err_cnt_t;

localparam MC_ERR_CNT_WIDTH = $bits(mc_err_cnt_t); //149;
  

endpackage : mc_ecc_pkg
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiL/85rDKvWnn9XolBvQLmV7o4vyZABFUdzSzR9AgS12WDzVMZDJMaVyYjwgpr078ZcNYgfZyl5OLqKH5xm6CVsqR5jP17hQ9kvvPJfB1cNrYc2FlnAejaczlW8C8/skYaFRH+Qs5psRmMXfeSeiwPUfE2scDdFvgOB1nT6z3zgTBA9TOBhog/ss3zz04iSpQDfGfHcqNnQvXhADIry4IZshAnyhIheZmtKkC1DcjxSpC6RssA4na1d3afZ5NND/LTHQ7GdVQyECsRSfAfN3jcnveIao86nVth0eQ8dZCD+hFdW0Dy11A+v9+YME7hx+ANm/cRKbfM+VuYf0pwCzZGO/80+V0l16mZOWRbikzdGXA3y6JhT/HqGBz0difYFGbmjb6zabCwxQaet1hwl1S0PUoTF+1Xl3GIerjynYN9afvvwufPRCYca10JbyogrVw4z1HMMlNrKBJbyPWZnES7mcwVnFrVLACJGwzSvefG2C2tuXH8U4ESxAUYcTRjgacPltS5u4Tr4phmbp1qnU0VKQJ7vvAJyRoF87iAnSlCxcMjqQuCEJ0S0u+jjQ+ZpMw8ij2tHs4JWwBi/Yg4ZRykA/yrLv9S/U97dRMPbyn6qvVDjojugfZNf65iLTgB5IftcPdzfV+sb+ieS7RFwCq4kgZK1k6HJHclJJaET+qXRJC5biHdBnbAFVQiECzYuwBmZ/39nvgRbBpbj7eNo4l90/KS6ZM62Zu7YJQlIi0e/VQVtutg3X4BpK+bCGHcx7K3qV+hgvrzUuowNEPQX4g96q"
`endif