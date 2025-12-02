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


///////////////////////////////////////////////////////////////////////////////
//  Reset request sequencing state machine.
//
///////////////////////////////////////////////////////////////////////////////
module altera_emif_arch_fm_local_reset # (
   parameter PHY_CONFIG_ENUM    = "",
   parameter IS_HPS             = 0
) (
   input  logic   afi_clk,
   input  logic   afi_reset_n,
   input  logic   emif_usr_clk,
   input  logic   emif_usr_reset_n,

   input  logic   local_reset_req_int,
   output logic   core2seq_reset_req,

   output logic   local_reset_done,
   input  logic   seq2core_reset_done
);
   timeunit 1ns;
   timeprecision 1ps;

   typedef enum {
      WAIT_RESET_DONE,
      WAIT_USER_RESET_REQ_1ST_DEASSERT,
      WAIT_USER_RESET_REQ_ASSERT,
      WAIT_USER_RESET_REQ_2ND_DEASSERT,
      ASSERT_CORE2SEQ_RESET_REQ
   } state_t;

   generate
      if (IS_HPS) begin: hps
         assign core2seq_reset_req = 1'b0;
         assign local_reset_done   = 1'b0;
      end else begin : non_hps
         logic clk;
         logic reset_n;

         if (PHY_CONFIG_ENUM == "CONFIG_PHY_AND_HARD_CTRL") begin : hmc
            assign clk = emif_usr_clk;
            assign reset_n = emif_usr_reset_n;
         end else begin : non_hmc
            assign clk = afi_clk;
            assign reset_n = afi_reset_n;
         end

         ////////////////////////////////////////////////////////////////////
         // State machine
         ////////////////////////////////////////////////////////////////////
         state_t state                 /* synthesis ignore_power_up */;
         logic   core2seq_reset_req_r  /* synthesis ignore_power_up dont_merge syn_noprune syn_preserve = 1 */;
         logic   local_reset_done_r    /* synthesis ignore_power_up dont_merge syn_noprune syn_preserve = 1 */;

         always_ff @(posedge clk, negedge reset_n)
         begin
            if (!reset_n) begin
               state                <= WAIT_RESET_DONE;
               core2seq_reset_req_r <= 1'b0;
               local_reset_done_r   <= 1'b0;
            end else begin
               case (state)
                  WAIT_RESET_DONE:
                  begin
                     // Wait until sequencer signals it's ready to accept a reset request.
                     if (seq2core_reset_done) begin
                        if (local_reset_req_int == 1'b1) begin
                           state                <= WAIT_USER_RESET_REQ_1ST_DEASSERT;
                           core2seq_reset_req_r <= 1'b0;
                           local_reset_done_r   <= 1'b1;
                        end else begin
                           state                <= WAIT_USER_RESET_REQ_ASSERT;
                           core2seq_reset_req_r <= 1'b0;
                           local_reset_done_r   <= 1'b1;
                        end
                     end
                     else
                     begin
                        state                <= WAIT_RESET_DONE;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b0;
                     end
                  end

                  WAIT_USER_RESET_REQ_1ST_DEASSERT:
                  begin
                     if (~local_reset_req_int) begin
                        state                <= WAIT_USER_RESET_REQ_ASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end else begin
                        state                <= WAIT_USER_RESET_REQ_1ST_DEASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end
                  end

                  WAIT_USER_RESET_REQ_ASSERT:
                  begin
                     if (local_reset_req_int) begin
                        state                <= WAIT_USER_RESET_REQ_2ND_DEASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end else begin
                        state                <= WAIT_USER_RESET_REQ_ASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end

                  end

                  WAIT_USER_RESET_REQ_2ND_DEASSERT:
                  begin
                     if (~local_reset_req_int) begin
                        state                <= ASSERT_CORE2SEQ_RESET_REQ;
                        core2seq_reset_req_r <= 1'b1;
                        local_reset_done_r   <= 1'b0;
                     end else begin
                        state                <= WAIT_USER_RESET_REQ_2ND_DEASSERT;
                        core2seq_reset_req_r <= 1'b0;
                        local_reset_done_r   <= 1'b1;
                     end
                  end

                  ASSERT_CORE2SEQ_RESET_REQ:
                  begin
                     state                   <= ASSERT_CORE2SEQ_RESET_REQ;
                     core2seq_reset_req_r    <= 1'b1;
                     local_reset_done_r      <= 1'b0;
                  end
                  default:
                  begin
                     state                   <= WAIT_RESET_DONE;
                     core2seq_reset_req_r    <= 1'b0;
                     local_reset_done_r      <= 1'b0;
                  end
               endcase
            end
         end

         ////////////////////////////////////////////////////////////////////
         // Output generation
         ////////////////////////////////////////////////////////////////////
         assign core2seq_reset_req = core2seq_reset_req_r;

         // Instead of passing seq2core_reset_done directly to user, we have the ability
         // to acknowledge the reset request earlier, as soon as a local_reset_req pulse
         // is detected.
         assign local_reset_done = local_reset_done_r;
      end
   endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVCG40VtM62ldBb2Y9dC+5GBjlFnhyXCZlFBajnmFtTmClIAJig+S+E09mWgeKIYBBs9JYb7hiHVho6djuDyc1hQkH7DGd5l4DeJOpjlIpwOVrCAijnCmrYe3vcCCPfOgPMGy6NkJjMpXmm1wyMYoPp8OyYCVoXhak9ruLXx9RrqxTUeQM8JZmUY+TznJQN81fibJ4bI/xjofURoMo4iDojdyQGevg7/EWETNeei/VN0QqoG5la8/MrUSvUiSkJ4HTbSkHAHxu6aLBGifHfS84JKYSZUP3XAe7lIWF0sxL9J4DkOFJns8g+dThWJu07ADnv8Wh4+qb97XLJSRg1tOaRSTQsVYzOId1KPTfrzMGpmfMqfO3KdJUFhyD/ifJjrXKC/sb1HRwo4rzQK+VTHnjomyv/aqD734IuO/c8tHOa8KjrquseylkDa8AvxTEtgK1JJLEC90rxB7Nm+1Br+m88uWjwbKtf9gC6YnAIvEXBeENdVHHkVcfZNBG4mLf9G8pPlvAUrax56t0NM7ib0DhaMRo2g/AuO3tUaHItjfE0DhgkVKydXWqR+IezhIIKPdt1LT5Hktr6AemqE0tCyWq1+eL+MJI1+WhKRZKUvjvIs1CbqFyiBUEaLZ+hbcPdnX8BS5mYvCTqfKJHfXfvHgyOanY6QJguSghJcawujssGWfCxgScXOH/msd835SuZ1ELVRgeJJAm+AKt5gzW3DmotPXrVYSJKbvUPuGYuQD8VZjT0amC1Lj3seKWDakjWdLtYTRJGBPjeWc7Tip+pudRxb"
`endif