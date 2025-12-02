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



////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  EMIF IOPLL instantiation for 20nm families
//
//  The following table describes the usage of IOPLL by EMIF. 
//
//  PLL Counter    Fanouts                          Usage
//  =====================================================================================
//  VCO Outputs    vcoph[7:0] -> phy_clk_phs[7:0]   FR clocks, 8 phases (45-deg apart)
//                 vcoph[0] -> DLL                  FR clock to DLL
//  C-counter 0    lvds_clk[0] -> phy_clk[1]        Secondary PHY clock tree (C2P/P2C rate)
//  C-counter 1    loaden[0] -> phy_clk[0]          Primary PHY clock tree (PHY/HMC rate)
//  C-counter 2    phy_clk[2]                       Feedback PHY clock tree (slowest phy clock in system)
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
module altera_emif_arch_fm_pll_fast_sim #(
   parameter PLL_SIM_VCO_FREQ_PS                     = 0,
   parameter PLL_SIM_PHYCLK_0_FREQ_PS                = 0,
   parameter PLL_SIM_PHYCLK_1_FREQ_PS                = 0,
   parameter PLL_SIM_PHYCLK_FB_FREQ_PS               = 0,
   parameter PLL_SIM_PHY_CLK_VCO_PHASE_PS            = 0,
   parameter PORT_DFT_ND_PLL_CNTSEL_WIDTH            = 1,
   parameter PORT_DFT_ND_PLL_NUM_SHIFT_WIDTH         = 1,
   parameter PORT_DFT_ND_PLL_CORE_REFCLK_WIDTH       = 1
   
) (
   input  logic                                               pll_ref_clk_int,       
   output logic                                               pll_locked,            
   output logic                                               pll_dll_clk,           
   output logic [7:0]                                         phy_clk_phs,           
   output logic [1:0]                                         phy_clk,               
   output logic                                               phy_fb_clk_to_tile,    
   input  logic                                               phy_fb_clk_to_pll,     
   output logic [8:0]                                         pll_c_counters,        
   input  logic                                               pll_phase_en,          
   input  logic                                               pll_up_dn,             
   input  logic [PORT_DFT_ND_PLL_CNTSEL_WIDTH-1:0]            pll_cnt_sel,           
   input  logic [PORT_DFT_ND_PLL_NUM_SHIFT_WIDTH-1:0]         pll_num_phase_shifts,  
   output logic                                               pll_phase_done,        
   input  logic [PORT_DFT_ND_PLL_CORE_REFCLK_WIDTH-1:0]       pll_core_refclk        
);
   timeunit 1ps;
   timeprecision 1ps;

   localparam VCO_PHASES = 8;

   reg vco_out, phyclk0_out, phyclk1_out, fbclk_out;
   reg [4:0] pll_lock_count;
   // synthesis translate_off
   initial begin
      vco_out <= 1'b1;
      forever #(PLL_SIM_VCO_FREQ_PS/2) vco_out <= ~vco_out;
   end
   initial begin
      phyclk0_out <= 1'b1;
      #(PLL_SIM_VCO_FREQ_PS*PLL_SIM_PHY_CLK_VCO_PHASE_PS/VCO_PHASES);
      forever #(PLL_SIM_PHYCLK_0_FREQ_PS/2) phyclk0_out <= ~phyclk0_out;
   end
   initial begin
      phyclk1_out <= 1'b1;
      #(PLL_SIM_VCO_FREQ_PS*PLL_SIM_PHY_CLK_VCO_PHASE_PS/VCO_PHASES);
      forever #(PLL_SIM_PHYCLK_1_FREQ_PS/2) phyclk1_out <= ~phyclk1_out;
   end
   initial begin
      fbclk_out <= 1'b1;
      #(PLL_SIM_VCO_FREQ_PS*PLL_SIM_PHY_CLK_VCO_PHASE_PS/VCO_PHASES);
      forever #(PLL_SIM_PHYCLK_FB_FREQ_PS/2) fbclk_out <= ~fbclk_out;
   end

   initial begin
      pll_lock_count <= 5'b0;
   end
   // synthesis translate_on
   
   always @ (posedge vco_out) begin
      if (pll_lock_count != 5'b11111) begin
         pll_lock_count <= pll_lock_count + 1;
      end
   end

   assign pll_locked = (pll_lock_count == 5'b11111);
   assign pll_dll_clk = pll_locked & vco_out;
   assign phy_clk_phs[0] = pll_locked & vco_out;
   always @ (*) begin
      phy_clk_phs[1] <= #(PLL_SIM_VCO_FREQ_PS/VCO_PHASES) phy_clk_phs[0];
      phy_clk_phs[2] <= #(PLL_SIM_VCO_FREQ_PS/VCO_PHASES) phy_clk_phs[1];
      phy_clk_phs[3] <= #(PLL_SIM_VCO_FREQ_PS/VCO_PHASES) phy_clk_phs[2];
      phy_clk_phs[4] <= #(PLL_SIM_VCO_FREQ_PS/VCO_PHASES) phy_clk_phs[3];
      phy_clk_phs[5] <= #(PLL_SIM_VCO_FREQ_PS/VCO_PHASES) phy_clk_phs[4];
      phy_clk_phs[6] <= #(PLL_SIM_VCO_FREQ_PS/VCO_PHASES) phy_clk_phs[5];
      phy_clk_phs[7] <= #(PLL_SIM_VCO_FREQ_PS/VCO_PHASES) phy_clk_phs[6];
   end
   assign phy_clk = {pll_locked & phyclk1_out, pll_locked & phyclk0_out};
   assign phy_fb_clk_to_tile = pll_locked & fbclk_out;
   assign pll_c_counters[0] =  pll_locked & phyclk1_out; 
   assign pll_c_counters[1] =  pll_locked & phyclk0_out;
   assign pll_c_counters[2] =  pll_locked & fbclk_out;
   assign pll_c_counters[8:3] = 6'd0;
   assign pll_phase_done = 1'b1;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVBoUFzrqhBcGPzlncOwxSwbvY7JkCxYYCwnRwRywaf7SYmWNdOxo+fzyuYxkqtZfJ4gf+uFo/vRThuuMhsvYPO8aIsXlcNmCyQyvlDuDOqhzP/c6aobdzNSJnMeZ3mUFWcS5DJf84eQxyxRovaoWsfEBnPXi1x7vXZBPgvGlUMlifdFf7a+ouglYL7PW82Tgt9CqSnMp9LUhwVjvyvl4+JKPh6+C7M+MuWmqVZsu+DhEqOc2aSVBWtXdoYnhiIsmMznFQMcGRoXNwtgEGWCBp4qC+KI9Lh2Ep0GLTAN81QDcr1bPg9yE9pSmoELcBHeYOuzh6rcmlllyJ4vRCz/Wc3r9pJz+pJ16HWucChm2ZY515pWP+t5rK4XBTH/Fc5d6hUutTT/m+PdDwtTvruvnBaq4jlDMQcZ4jhum/vBPI0wbmhejb7ZIcyqIcTWeyyFUNthRqUQeaHHhjScxNtop5FJxm2VUG3V827pZgwGNKqXTatPHuk+bs3Q94zyB6EzzMbzLPOVCOYsmNEJ+qBs+LQxGi0HYOrgrH/cSeD4IqMI1QzLbEN1jvTvO3flnRA0L3mjLDH/9bUtOJzVAdOV4b3Lt99GHbYKaQ54Dejcy0TkOaM/WYvdsYyY4WcxRBLxwYJ2p7L3VNxOIDJWtSdAk4OHvB+XN8ri6eGrxO3SJ1lxxgBvMEknmDdPsERwmqysU0LyEpMERwKoq9PHYq3js5Q1C65C2bYBdMM8E3FbvYbaW5g7PRp51nO4AdszKrezhI+0zhcg235HEWDnipRkbVn9"
`endif