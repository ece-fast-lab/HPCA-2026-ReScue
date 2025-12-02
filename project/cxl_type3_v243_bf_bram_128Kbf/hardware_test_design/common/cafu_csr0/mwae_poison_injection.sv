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
`include "ccv_afu_globals.vh.iv"

module mwae_poison_injection
(
  input clk,
  input reset_n,
  input wvalid,    // from the axi write data channel
  input poison_injection_start,
  input force_disable_afu,

  output logic poison_injection_busy,
  output logic set_wuser_poison
);

/* =======================================================================================
*/
typedef enum logic [1:0] {
  IDLE                   = 2'd0,
  CHECK_FOR_WVALID       = 2'd1,
  CLEAR_BUSY             = 2'd2,
  WAIT_START_LOW         = 2'd3
} fsm_enum;

fsm_enum    state;
fsm_enum    next_state;

/* =======================================================================================
*/
always_ff @( posedge clk )
begin
       if( reset_n == 1'b0 )           state <= IDLE;
  else if( force_disable_afu == 1'b1 ) state <= IDLE; 
  else                                 state <= next_state;
end

/* =======================================================================================
*/
logic set_busy_high;
logic set_busy_low;

always_comb
begin
  set_busy_high    = 1'b0;
  set_busy_low     = 1'b0;
  set_wuser_poison = 1'b0;

  case( state )
    IDLE :
    begin
      if( poison_injection_start == 1'b0 )    next_state = IDLE;
      else begin
	                                   set_busy_high = 1'b1;
                                              next_state = CHECK_FOR_WVALID;
      end
    end

    CHECK_FOR_WVALID :
    begin
      if( wvalid == 1'b0 )                    next_state = CHECK_FOR_WVALID;
      else begin
	                                set_wuser_poison = 1'b1;
                                              next_state = CLEAR_BUSY;
      end
    end

    CLEAR_BUSY :
    begin
	                                    set_busy_low = 1'b1;
                                              next_state = WAIT_START_LOW;
    end

    WAIT_START_LOW :   // require clear of start to do another poison injection
    begin
      if( poison_injection_start == 1'b0 )    next_state = IDLE;
      else                                    next_state = WAIT_START_LOW;
    end

    default :                                 next_state = IDLE;
  endcase
end

/* =======================================================================================
*/
always_ff @( posedge clk )
begin
       if( reset_n == 1'b0 )       poison_injection_busy <= 1'b0;
  else if( set_busy_high == 1'b1 ) poison_injection_busy <= 1'b1;
  else if( set_busy_low  == 1'b1 ) poison_injection_busy <= 1'b0;
  else                             poison_injection_busy <= poison_injection_busy;
end

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "S1GUrC2jziQGFCq1WnKTTiX0tux9Ts3LvxtGsW/r0MLQDnFaRrf1Q/z0i6gRM8P1TzNxXCrYkS/oRstnfDdOmiR1jaiEm/CT8OJ+6H5yOCLeA8PwMTSyCePCkUYRFnpclgwBDcHx9Ai+/b/8DDkmsQGlSvaa6lRdhfgq1tufZL1dyzU9cd9kmTu45U8pRDhZbpZT2HQCOPX+oDwpOWMbVBXay6Y5GENn7g1OwAUXrLg819/lXOzvvpnY4B0RK1Hoe7Qj2/9dgFhqiTPZ3UCS5L+5P+deAPg6z+qSTfALzMpdEilDJkzd4oB+4nPGBx2NUj2eLH6x+zYhEHvmRBUY6MgtQdc0Yt82sD4B52gzTNhfVGGb0oNj7B12epbD/tJIGn5/qw4OWYcGr8r3Mq8MUkZ7sVxUUYcIGQacebUC6P8fmCJ+knp3zEsf9wBpMi/fJ8dWaciCvrYU3JfTTfzdeyZcE81VcusFqJEPvZW16tdsPP8D32ecfjK27KdlzuvhoVw/IxZ7TZiWyTVykvHgV67Rxo1LnpWoAtFJFZAba5GDnzxQ3CJzyTAWa8F0VDApsb88SoxXyTzYWBaINwj1JT3C6T+aQa/h6uFU+02XEBi8+DtwA6LNDQq3l+4dIK0CDSi+1Hiep6kftNWJBn+toTwYL+jRLYLjMEi9iB2slNOnuvpKoUXnF5y1bibRcCg4XvKDOZ+xXa6yJB2dWuRfYi2bFmLCQvFGdS0LgXAr+feGZntppYXp10v5hk18AFW2slweBwwRLeA2MwI+1Yr530x9d+DaFISjJ2AKzSq9EBBNQnznpbyePf7+foswzsWeupBZ/XfbLv4JkP49Ma3G22muBn/b9wiSxtj9e8NMnP9JXdyqRUd6ZGZWeL3BSkHClCIPwqdb/csQi3x3GVXvWkWkcutc1wA06nYGE6Y2Lh0JCvOQrj4xxSVbtDZPENxBksAwhAfjB3CWeDH2YKsOX2X6ckciNt9cG46pJnu11i/PyvvZEx3pIEZz1SbLyTMZ"
`endif