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
// Module Name:         gram_sdp_be.v
// ***************************************************************************
// gram_sdp_be.v: Generic simple dual port RAM with one write port and one read port
//
// Generic dual port RAM. This module helps to keep your HDL code architecture
// independent. 
//
// This module makes use of synthesis tool's automatic RAM recognition feature.
// It can infer distributed as well as block RAM. The type of inferred RAM
// depends on GRAM_STYLE and mode. 
// GRAM_AUTO : Let the tool to decide 
// GRAM_BLCK : Use block RAM
// GRAM_DIST : Use distributed RAM
// 
// Diagram of GRAM:
//
//           +---+      +------------+     +------+
//   raddr --|1/3|______|            |     | 2/3  |
//           |>  |      |            |-----|      |-- dout
//           +---+      |            |     |>     |
//        din __________|   RAM      |     +------+
//      waddr __________|            |
//        we  __________|            |
//        be  __________|            |
//        clk __________|\           |
//                      |/           |
//                      +------------+
//
// You can override parameters to customize RAM.
//

import gbl_pkg::*;

  module gram_sdp_be (clk,    // input   clock
                      we,     // input   write enable
                      be,     // input   write ByteEnables
                      waddr,  // input   write address with configurable width
                      din,    // input   write data with configurable width
                      raddr,  // input   read address with configurable width
                      dout    // output  write data with configurable width
                     );

  parameter BUS_SIZE_ADDR = 4;                  // number of bits of address bus
  parameter BUS_SIZE_DATA = 32;                 // number of bits of data bus
  parameter BUS_SIZE_BE =   BUS_SIZE_DATA/8;
  parameter GRAM_STYLE =    gbl_pkg::GRAM_AUTO; // GRAM_AUTO, GRAM_BLCK, GRAM_DIST
  //localparam RAM_BLOCK_TYPE = GRAM_STYLE==gbl_pkg::GRAM_BLCK
  //                          ? "M20K"
  //                          :GRAM_STYLE==gbl_pkg::GRAM_DIST
  //                           ? "MLAB"
  //                           : "AUTO";


input                           clk;
input                           we;
input   [BUS_SIZE_BE-1:0]       be;
input   [BUS_SIZE_ADDR-1:0]     waddr;
input   [BUS_SIZE_DATA-1:0]     din;
input   [BUS_SIZE_ADDR-1:0]     raddr;
output  [BUS_SIZE_DATA-1:0]     dout;

//Add directive to don't care the behavior of read/write same address
(*ramstyle=GRAM_STYLE*) reg [BUS_SIZE_BE-1:0][7:0] ram [(2**BUS_SIZE_ADDR)-1:0];  //ram divided into bytes.

reg [BUS_SIZE_ADDR-1:0] raddr_q;
reg [BUS_SIZE_DATA-1:0] dout;
reg [BUS_SIZE_DATA-1:0] ram_dout;
/*synthesis translate_off */
reg                     driveX;         // simultaneous access detected. Drive X on output
/*synthesis translate_on */

// mw: Start timescale test
/*synthesis translate_off */
initial
begin
  $display("mw: printing the timescale upon entry into gram_sdp.");
  $printtimescale(); // mw: added to observe timescale upon entry into gram_sdp
  $display("mw: printing the array parameters for RAM detection in gram_sdp_be.");
  $display("mw: from gram_sdp_be, inside hierarchy %m with array params: %4d x %4d",BUS_SIZE_ADDR,BUS_SIZE_DATA);
end
/*synthesis translate_on */
// mw: End timescale test


`ifndef CXLDCOH_RAM
  // If it's not the case that this is being run with Leucadia (LCD) RAM replacements 
  // then use the TBF generate statement, previously in place, as-is, with GRAM_MODE cases 0,1,2,3
  generate
  always_ff @(posedge clk)
    begin
      if (we)
        for (int i=0; i<BUS_SIZE_DATA/8; i++) 
        begin
          // ram[waddr][BUS_SIZE_DATA-1:0]<=din[BUS_SIZE_DATA-1:0]; // synchronous write the RAM
          if (be[i])                
            ram[waddr][i]  <= din[7+(8*i)-:8]; 
        end
      ram_dout<= ram[raddr];
      dout    <= ram_dout;
      /*synthesis translate_off */
      if(driveX)
        dout    <= 'hx;
      if(raddr==waddr && we)
        driveX <= 1;
      else
        driveX <= 0;            
      /*synthesis translate_on */
    end
  endgenerate
`else 
  // ------------------------------------------------------------------------------------------------------------------------
  // We are defined as Leucadia (LCD), so we want to replace the RAM call that was previously made for TBF with a Leucadia
  // replacement RAM that was created using memlister (for TSMC N5 arrays) by Vijay Gullapalli for our use in the BBS in
  // the Leucadia ASIC.
  // ------------------------------------------------------------------------------------------------------------------------

  generate 

  logic [127:0] RSCOUT                ;
  logic         RSCIN       = 1'b0    ;
  logic         RSCEN       = 1'b0    ;
  logic         RSCRST      = 1'b0    ;
  logic         RSCLK       = 1'b0    ;
  logic         FISO        = 1'b0    ;
  logic [2:0]   WA          = 3'b100  ; // mw: Value of 3'b100 provided by Vijay in vcs.ucli file from Outlook email sent 6/8/20
  logic [2:0]   WPULSE      = 3'b000  ;
  logic [1:0]   RA          = 2'b00   ;
  logic [3:0]   RM          = 4'b0100 ; // mw: Value of 4'b0100 provided by Vijay in vcs.ucli file from Outlook email sent 6/8/20


  // ------------------------------------------------------------------------------------------------------------------------
  // Generate the RAM code based on the dimensions of the array.
  // These RAMS are only used once.  They are self-contained to handle the depth and width of the data in a  
  //  single instance.  
  // ------------------------------------------------------------------------------------------------------------------------

  if (BUS_SIZE_ADDR == 9  & BUS_SIZE_DATA == 16 )
    begin: bbs_512x16_be

      logic   [BUS_SIZE_DATA-1:0]     bitWrEn;
 
      always_comb
        begin
          for (int i=0; i<BUS_SIZE_DATA/8; i++)
          begin
          //bitWrEn[7+(8*i):(8*i)] = {8{be[i]}};  // mw: Error-[IRIPS] Illegal range in part select. Unknown range in part select.bbs_512x16_be.bitWrEn[(7 + (8 * i)):(8 * i)]
            bitWrEn[7+(8*i)-:8] = {8{be[i]}};
          end
        end

      saculs0g4u2p512x16m4b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_9x16_d1w1
        (
          // Outputs
          .RSCOUT   (RSCOUT[0]  ),
          .QB       (ram_dout   ),
          // Inputs
          .ADRA     (waddr      ),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we         ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr      ),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );
    end // bbs_512x16_be

  // ------------------------------------------------------------------------------------------------------------------------
  // Width-Coupling (only) RAMs 
  // ------------------------------------------------------------------------------------------------------------------------

  // ------------------------------------------------------------------------------------------------------------------------
  // bbs_512x512
  //  NOTE: Width is split between two RAMs
  // ------------------------------------------------------------------------------------------------------------------------

  if (BUS_SIZE_ADDR == 9  & BUS_SIZE_DATA == 512)
    begin: bbs_512x512_be

       logic   [BUS_SIZE_DATA-1:0]     bitWrEn;
 
      always_comb
        begin
          for (int i=0; i<BUS_SIZE_DATA/8; i++)
          begin
            bitWrEn[7+(8*i)-:8] = {8{be[i]}};
          end
        end

      sacrls0g4u2p512x256m2b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_9x512_d1w2_1
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[1]  ),
          .QB         (ram_dout[BUS_SIZE_DATA-1:BUS_SIZE_DATA/2]),
          // Inputs
          .ADRA       (waddr      ),
          .DA         (din[BUS_SIZE_DATA-1:BUS_SIZE_DATA/2]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA-1:BUS_SIZE_DATA/2]),
          .WEA        (we         ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr      ),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p512x256m2b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_9x512_d1w2_0
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[0]  ),
          .QB         (ram_dout[BUS_SIZE_DATA/2-1:0]),
          // Inputs
          .ADRA       (waddr      ),
          .DA         (din[BUS_SIZE_DATA/2-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/2-1:0]),
          .WEA        (we         ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr      ),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );
    end // bbs_512x512_be



  // ------------------------------------------------------------------------------------------------------------------------
  // Depth-Coupling (only) RAMs 
  // ------------------------------------------------------------------------------------------------------------------------

  // ------------------------------------------------------------------------------------------------------------------------
  // bbs_2048x16
  //  NOTE: Depth is split between two 1024x16 RAMs
  // ------------------------------------------------------------------------------------------------------------------------

  if (BUS_SIZE_ADDR == 11 & BUS_SIZE_DATA == 16 )
    begin: bbs_2048x16_be

      logic                     we_1;         // write enable for BBS_1r1w1c_2048x16_1
      logic                     we_0;         // write enable for BBS_1r1w1c_2048x16_0

      logic [BUS_SIZE_DATA-1:0] ram_dout_1;   // ram_dout for BBS_1r1w1c_2048x16_1
      logic [BUS_SIZE_DATA-1:0] ram_dout_0;   // ram_dout for BBS_1r1w1c_2048x16_0

      assign  we_1 =  we &  waddr[BUS_SIZE_ADDR-1];
      assign  we_0 =  we & ~waddr[BUS_SIZE_ADDR-1];

      logic   [BUS_SIZE_DATA-1:0]     bitWrEn;
 
      always_comb
        begin
          for (int i=0; i<BUS_SIZE_DATA/8; i++)
          begin
            bitWrEn[7+(8*i)-:8] = {8{be[i]}};
          end
        end

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_11x16_d2w1_1
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[1]  ),
          .QB       (ram_dout_1 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-2:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_1       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_11x16_d2w1_0
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[0]  ),
          .QB       (ram_dout_0 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-2:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_0       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      assign ram_dout = raddr[BUS_SIZE_ADDR-1] ?  ram_dout_1 : ram_dout_0;

    end // bbs_2048x16_be

  // ------------------------------------------------------------------------------------------------------------------------
  // bbs_32768x16 (32k x 16)
  //  NOTE: Depth is split between 32 1024x16 RAMs
  // ------------------------------------------------------------------------------------------------------------------------

  if (BUS_SIZE_ADDR == 15 & BUS_SIZE_DATA == 16 )
    begin: bbs_32kx16_be

      logic                     we_31;        // write enable for DC_1r1w1c_BE_15x16_d32w1_31
      logic                     we_30;        // write enable for DC_1r1w1c_BE_15x16_d32w1_30
      logic                     we_29;        // write enable for DC_1r1w1c_BE_15x16_d32w1_29
      logic                     we_28;        // write enable for DC_1r1w1c_BE_15x16_d32w1_28
      logic                     we_27;        // write enable for DC_1r1w1c_BE_15x16_d32w1_27
      logic                     we_26;        // write enable for DC_1r1w1c_BE_15x16_d32w1_26
      logic                     we_25;        // write enable for DC_1r1w1c_BE_15x16_d32w1_25
      logic                     we_24;        // write enable for DC_1r1w1c_BE_15x16_d32w1_24
      logic                     we_23;        // write enable for DC_1r1w1c_BE_15x16_d32w1_23
      logic                     we_22;        // write enable for DC_1r1w1c_BE_15x16_d32w1_22
      logic                     we_21;        // write enable for DC_1r1w1c_BE_15x16_d32w1_21
      logic                     we_20;        // write enable for DC_1r1w1c_BE_15x16_d32w1_20
      logic                     we_19;        // write enable for DC_1r1w1c_BE_15x16_d32w1_19
      logic                     we_18;        // write enable for DC_1r1w1c_BE_15x16_d32w1_18
      logic                     we_17;        // write enable for DC_1r1w1c_BE_15x16_d32w1_17
      logic                     we_16;        // write enable for DC_1r1w1c_BE_15x16_d32w1_16
      logic                     we_15;        // write enable for DC_1r1w1c_BE_15x16_d32w1_15
      logic                     we_14;        // write enable for DC_1r1w1c_BE_15x16_d32w1_14
      logic                     we_13;        // write enable for DC_1r1w1c_BE_15x16_d32w1_13
      logic                     we_12;        // write enable for DC_1r1w1c_BE_15x16_d32w1_12
      logic                     we_11;        // write enable for DC_1r1w1c_BE_15x16_d32w1_11
      logic                     we_10;        // write enable for DC_1r1w1c_BE_15x16_d32w1_10
      logic                     we_9;         // write enable for DC_1r1w1c_BE_15x16_d32w1_9
      logic                     we_8;         // write enable for DC_1r1w1c_BE_15x16_d32w1_8
      logic                     we_7;         // write enable for DC_1r1w1c_BE_15x16_d32w1_7
      logic                     we_6;         // write enable for DC_1r1w1c_BE_15x16_d32w1_6
      logic                     we_5;         // write enable for DC_1r1w1c_BE_15x16_d32w1_5
      logic                     we_4;         // write enable for DC_1r1w1c_BE_15x16_d32w1_4
      logic                     we_3;         // write enable for DC_1r1w1c_BE_15x16_d32w1_3
      logic                     we_2;         // write enable for DC_1r1w1c_BE_15x16_d32w1_2
      logic                     we_1;         // write enable for DC_1r1w1c_BE_15x16_d32w1_1
      logic                     we_0;         // write enable for DC_1r1w1c_BE_15x16_d32w1_0

      logic [BUS_SIZE_DATA-1:0] ram_dout_31;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_31
      logic [BUS_SIZE_DATA-1:0] ram_dout_30;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_30
      logic [BUS_SIZE_DATA-1:0] ram_dout_29;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_29
      logic [BUS_SIZE_DATA-1:0] ram_dout_28;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_28
      logic [BUS_SIZE_DATA-1:0] ram_dout_27;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_27
      logic [BUS_SIZE_DATA-1:0] ram_dout_26;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_26
      logic [BUS_SIZE_DATA-1:0] ram_dout_25;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_25
      logic [BUS_SIZE_DATA-1:0] ram_dout_24;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_24
      logic [BUS_SIZE_DATA-1:0] ram_dout_23;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_23
      logic [BUS_SIZE_DATA-1:0] ram_dout_22;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_22
      logic [BUS_SIZE_DATA-1:0] ram_dout_21;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_21
      logic [BUS_SIZE_DATA-1:0] ram_dout_20;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_20
      logic [BUS_SIZE_DATA-1:0] ram_dout_19;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_19
      logic [BUS_SIZE_DATA-1:0] ram_dout_18;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_18
      logic [BUS_SIZE_DATA-1:0] ram_dout_17;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_17
      logic [BUS_SIZE_DATA-1:0] ram_dout_16;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_16
      logic [BUS_SIZE_DATA-1:0] ram_dout_15;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_15
      logic [BUS_SIZE_DATA-1:0] ram_dout_14;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_14
      logic [BUS_SIZE_DATA-1:0] ram_dout_13;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_13
      logic [BUS_SIZE_DATA-1:0] ram_dout_12;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_12
      logic [BUS_SIZE_DATA-1:0] ram_dout_11;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_11
      logic [BUS_SIZE_DATA-1:0] ram_dout_10;  // ram_dout for DC_1r1w1c_BE_15x16_d32w1_10
      logic [BUS_SIZE_DATA-1:0] ram_dout_9;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_9
      logic [BUS_SIZE_DATA-1:0] ram_dout_8;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_8
      logic [BUS_SIZE_DATA-1:0] ram_dout_7;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_7
      logic [BUS_SIZE_DATA-1:0] ram_dout_6;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_6
      logic [BUS_SIZE_DATA-1:0] ram_dout_5;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_5
      logic [BUS_SIZE_DATA-1:0] ram_dout_4;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_4
      logic [BUS_SIZE_DATA-1:0] ram_dout_3;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_3
      logic [BUS_SIZE_DATA-1:0] ram_dout_2;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_2
      logic [BUS_SIZE_DATA-1:0] ram_dout_1;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_1
      logic [BUS_SIZE_DATA-1:0] ram_dout_0;   // ram_dout for DC_1r1w1c_BE_15x16_d32w1_0

      assign  we_31 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd31;
      assign  we_30 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd30;
      assign  we_29 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd29;
      assign  we_28 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd28;
      assign  we_27 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd27;
      assign  we_26 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd26;
      assign  we_25 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd25;
      assign  we_24 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd24;
      assign  we_23 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd23;
      assign  we_22 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd22;
      assign  we_21 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd21;
      assign  we_20 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd20;
      assign  we_19 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd19;
      assign  we_18 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd18;
      assign  we_17 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd17;
      assign  we_16 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd16;
      assign  we_15 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd15;
      assign  we_14 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd14;
      assign  we_13 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd13;
      assign  we_12 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd12;
      assign  we_11 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd11;
      assign  we_10 = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd10;
      assign  we_9  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd9 ;
      assign  we_8  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd8 ;
      assign  we_7  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd7 ;
      assign  we_6  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd6 ;
      assign  we_5  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd5 ;
      assign  we_4  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd4 ;
      assign  we_3  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd3 ;
      assign  we_2  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd2 ;
      assign  we_1  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd1 ;
      assign  we_0  = we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd0 ;

      logic   [BUS_SIZE_DATA-1:0]     bitWrEn;
 
      always_comb
        begin
          for (int i=0; i<BUS_SIZE_DATA/8; i++)
          begin
            bitWrEn[7+(8*i)-:8] = {8{be[i]}};
          end
        end

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_31
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[31] ),
          .QB       (ram_dout_31),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_31      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_30
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[30] ),
          .QB       (ram_dout_30),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_30      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_29
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[29] ),
          .QB       (ram_dout_29),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_29      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_28
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[28] ),
          .QB       (ram_dout_28),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_28      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_27
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[27] ),
          .QB       (ram_dout_27),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_27      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_26
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[26] ),
          .QB       (ram_dout_26),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_26      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_25
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[25] ),
          .QB       (ram_dout_25),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_25      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_24
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[24] ),
          .QB       (ram_dout_24),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_24      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_23
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[23] ),
          .QB       (ram_dout_23),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_23      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_22
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[22] ),
          .QB       (ram_dout_22),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_22      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_21
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[21] ),
          .QB       (ram_dout_21),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_21      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_20
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[20] ),
          .QB       (ram_dout_20),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_20      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_19
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[19] ),
          .QB       (ram_dout_19),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_19      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_18
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[18] ),
          .QB       (ram_dout_18),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_18      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_17
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[17] ),
          .QB       (ram_dout_17),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_17      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_16
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[16] ),
          .QB       (ram_dout_16),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_16      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_15
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[15] ),
          .QB       (ram_dout_15),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_15      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_14
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[14] ),
          .QB       (ram_dout_14),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_14      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_13
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[13] ),
          .QB       (ram_dout_13),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_13      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_12
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[12] ),
          .QB       (ram_dout_12),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_12      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_11
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[11] ),
          .QB       (ram_dout_11),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_11      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_10
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[10] ),
          .QB       (ram_dout_10),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_10      ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_9
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[9]  ),
          .QB       (ram_dout_9 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_9       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_8
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[8]  ),
          .QB       (ram_dout_8 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_8       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_7
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[7]  ),
          .QB       (ram_dout_7 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_7       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_6
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[6]  ),
          .QB       (ram_dout_6 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_6       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_5
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[5]  ),
          .QB       (ram_dout_5 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_5       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_4
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[4]  ),
          .QB       (ram_dout_4 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_4       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_3
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[3]  ),
          .QB       (ram_dout_3 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_3       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_2
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[2]  ),
          .QB       (ram_dout_2 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_2       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_1
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[1]  ),
          .QB       (ram_dout_1 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_1       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );

      sasuls0g4u2p1024x16m16b1w1c1p0d0l1rm4rw11e10zh0h0ms0mg0
        DC_1r1w1c_BE_15x16_d32w1_0
        ( 
          // Outputs
          .RSCOUT   (RSCOUT[0]  ),
          .QB       (ram_dout_0 ),
          // Inputs
          .ADRA     (waddr[BUS_SIZE_ADDR-6:0]),
          .DA       (din        ),
          .WEMA     (bitWrEn    ),
          .WEA      (we_0       ),
          .MEA      ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .CLK      (clk        ),
          .RME      ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RM       (RM         ),
          .TEST_RNM ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .LS       ('0         ),
          .BC0      ('0         ),
          .BC1      ('0         ),
          .BC2      ('0         ),
          .ADRB     (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB      ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .RSCIN    (RSCIN      ),
          .RSCEN    (RSCEN      ),
          .RSCRST   (RSCRST     ),
          .RSCLK    (RSCLK      ),
          .FISO     (FISO       ),
          .WA       (WA[2:0]    ),
          .WPULSE   (WPULSE[2:0]),
          .RA       (RA[1:0]    ),
          .TEST1    ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLK).
          .TESTRWM  ('0         )
        );


      always @*
      begin
        case (raddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5])
          'd31: ram_dout = ram_dout_31;
          'd30: ram_dout = ram_dout_30;
          'd29: ram_dout = ram_dout_29;
          'd28: ram_dout = ram_dout_28;
          'd27: ram_dout = ram_dout_27;
          'd26: ram_dout = ram_dout_26;
          'd25: ram_dout = ram_dout_25;
          'd24: ram_dout = ram_dout_24;
          'd23: ram_dout = ram_dout_23;
          'd22: ram_dout = ram_dout_22;
          'd21: ram_dout = ram_dout_21;
          'd20: ram_dout = ram_dout_20;
          'd19: ram_dout = ram_dout_19;
          'd18: ram_dout = ram_dout_18;
          'd17: ram_dout = ram_dout_17;
          'd16: ram_dout = ram_dout_16;
          'd15: ram_dout = ram_dout_15;
          'd14: ram_dout = ram_dout_14;
          'd13: ram_dout = ram_dout_13;
          'd12: ram_dout = ram_dout_12;
          'd11: ram_dout = ram_dout_11;
          'd10: ram_dout = ram_dout_10;
          'd9 : ram_dout = ram_dout_9 ;
          'd8 : ram_dout = ram_dout_8 ;
          'd7 : ram_dout = ram_dout_7 ;
          'd6 : ram_dout = ram_dout_6 ;
          'd5 : ram_dout = ram_dout_5 ;
          'd4 : ram_dout = ram_dout_4 ;
          'd3 : ram_dout = ram_dout_3 ;
          'd2 : ram_dout = ram_dout_2 ;
          'd1 : ram_dout = ram_dout_1 ;
          'd0 : ram_dout = ram_dout_0 ;
        endcase
      end  

    end // bbs_32kx16_be

  // ------------------------------------------------------------------------------------------------------------------------
  // Depth and Width-Coupling RAMs 
  // ------------------------------------------------------------------------------------------------------------------------

  // ------------------------------------------------------------------------------------------------------------------------
  // bbs_2048x512
  //  NOTE: Full width is created using four 1024x128 ({_7, _6, _5, _4} and {_3,_2,_1,_0}) to create two 1024x512 segments
  //  NOTE: Full Depth is created by stacking {_7, _6, _5, _4} onto {_3,_2,_1,_0} to create 2048x512
  // ------------------------------------------------------------------------------------------------------------------------

  if (BUS_SIZE_ADDR == 11 & BUS_SIZE_DATA == 512)
    begin: bbs_2048x512_be

      logic                     we_1;         // write enable for DC_1r1w2c_BE_11x512_d2w4_{7,6,5,4}
      logic                     we_0;         // write enable for DC_1r1w2c_BE_11x512_d2w4_{3,2,1,0}

      logic [BUS_SIZE_DATA-1:0] ram_dout_1;   // ram_dout for DC_1r1w2c_BE_11x512_d2w4_{7,6,5,4}
      logic [BUS_SIZE_DATA-1:0] ram_dout_0;   // ram_dout for DC_1r1w2c_BE_11x512_d2w4_{3,2,1,0}

      assign  we_1 =  we &  waddr[BUS_SIZE_ADDR-1];
      assign  we_0 =  we & ~waddr[BUS_SIZE_ADDR-1];

      logic   [BUS_SIZE_DATA-1:0]     bitWrEn;
 
      always_comb
        begin
          for (int i=0; i<BUS_SIZE_DATA/8; i++)
          begin
            bitWrEn[7+(8*i)-:8] = {8{be[i]}};
          end
        end

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_7
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[7]  ),
          .QB         (ram_dout_1[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_6
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[6]  ),
          .QB         (ram_dout_1[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_5
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[5]  ),
          .QB         (ram_dout_1[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_4
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[4]  ),
          .QB         (ram_dout_1[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_3
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[3]  ),
          .QB         (ram_dout_0[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_2
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[2]  ),
          .QB         (ram_dout_0[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_1
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[1]  ),
          .QB         (ram_dout_0[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_11x512_d2w4_0
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[0]  ),
          .QB         (ram_dout_0[BUS_SIZE_DATA/4-1:0]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-2:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-2:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      assign ram_dout = raddr[BUS_SIZE_ADDR-1] ?  ram_dout_1 : ram_dout_0;

    end // bbs_2048x512_be

  // ------------------------------------------------------------------------------------------------------------------------
  // bbs_32kx512
  //  NOTE: Full width is created using four 1024x128 ({_31,_30,_29,_28} ... {_3,_2,_1,_0}) to create 1024 x 512
  //  NOTE: Full Depth is created by stacking duos {{_31,_30,_29,_28} on ... on {_3,_2,_1,_0}} to create 32k x 512
  // ------------------------------------------------------------------------------------------------------------------------

  if (BUS_SIZE_ADDR == 15 & BUS_SIZE_DATA == 512)
    begin: bbs_32kx512_be

      logic                     we_31;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{127,126,125,124}
      logic                     we_30;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{123,122,121,120}
      logic                     we_29;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{119,118,117,116}
      logic                     we_28;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{115,114,113,112}
      logic                     we_27;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{111,110,109,108}
      logic                     we_26;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{107,106,105,104}
      logic                     we_25;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{103,102,101,100}
      logic                     we_24;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{99,98,97,96}
      logic                     we_23;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{95,94,93,92}
      logic                     we_22;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{91,90,89,88}
      logic                     we_21;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{87,86,85,84}
      logic                     we_20;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{83,82,81,80}
      logic                     we_19;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{79,78,77,76}
      logic                     we_18;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{75,74,73,72}
      logic                     we_17;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{71,70,69,68}
      logic                     we_16;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{67,66,65,64}
      logic                     we_15;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{63,62,61,60}
      logic                     we_14;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{59,58,57,56}
      logic                     we_13;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{55,54,53,52}
      logic                     we_12;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{51,50,49,48}
      logic                     we_11;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{47,46,45,44}
      logic                     we_10;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{43,42,41,40}
      logic                     we_9 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{39,38,37,36}
      logic                     we_8 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{35,34,33,32}
      logic                     we_7 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{31,30,29,28}
      logic                     we_6 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{27,26,25,24}
      logic                     we_5 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{23,22,21,20}
      logic                     we_4 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{19,18,17,16}
      logic                     we_3 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{15,14,13,12}
      logic                     we_2 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{11,10,9,8}
      logic                     we_1 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{7,6,5,4}
      logic                     we_0 ;        // write enable for DC_1r1w2c_BE_15x512_d32w4_{3,2,1,0}


      logic [BUS_SIZE_DATA-1:0] ram_dout_31;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{127,126,125,124}
      logic [BUS_SIZE_DATA-1:0] ram_dout_30;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{123,122,121,120}
      logic [BUS_SIZE_DATA-1:0] ram_dout_29;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{119,118,117,116}
      logic [BUS_SIZE_DATA-1:0] ram_dout_28;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{115,114,113,112}
      logic [BUS_SIZE_DATA-1:0] ram_dout_27;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{111,110,109,108}
      logic [BUS_SIZE_DATA-1:0] ram_dout_26;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{107,106,105,104}
      logic [BUS_SIZE_DATA-1:0] ram_dout_25;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{103,102,101,100}
      logic [BUS_SIZE_DATA-1:0] ram_dout_24;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{99,98,97,96}
      logic [BUS_SIZE_DATA-1:0] ram_dout_23;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{95,94,93,92}
      logic [BUS_SIZE_DATA-1:0] ram_dout_22;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{91,90,89,88}
      logic [BUS_SIZE_DATA-1:0] ram_dout_21;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{87,86,85,84}
      logic [BUS_SIZE_DATA-1:0] ram_dout_20;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{83,82,81,80}
      logic [BUS_SIZE_DATA-1:0] ram_dout_19;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{79,78,77,76}
      logic [BUS_SIZE_DATA-1:0] ram_dout_18;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{75,74,73,72}
      logic [BUS_SIZE_DATA-1:0] ram_dout_17;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{71,70,69,68}
      logic [BUS_SIZE_DATA-1:0] ram_dout_16;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{67,66,65,64}
      logic [BUS_SIZE_DATA-1:0] ram_dout_15;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{63,62,61,60}
      logic [BUS_SIZE_DATA-1:0] ram_dout_14;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{59,58,57,56}
      logic [BUS_SIZE_DATA-1:0] ram_dout_13;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{55,54,53,52}
      logic [BUS_SIZE_DATA-1:0] ram_dout_12;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{51,50,49,48}
      logic [BUS_SIZE_DATA-1:0] ram_dout_11;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{47,46,45,44}
      logic [BUS_SIZE_DATA-1:0] ram_dout_10;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{43,42,41,40}
      logic [BUS_SIZE_DATA-1:0] ram_dout_9 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{39,38,37,36}
      logic [BUS_SIZE_DATA-1:0] ram_dout_8 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{35,34,33,32}
      logic [BUS_SIZE_DATA-1:0] ram_dout_7 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{31,30,29,28}
      logic [BUS_SIZE_DATA-1:0] ram_dout_6 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{27,26,25,24}
      logic [BUS_SIZE_DATA-1:0] ram_dout_5 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{23,22,21,20}
      logic [BUS_SIZE_DATA-1:0] ram_dout_4 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{19,18,17,16}
      logic [BUS_SIZE_DATA-1:0] ram_dout_3 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{15,14,13,12}
      logic [BUS_SIZE_DATA-1:0] ram_dout_2 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{11,10,9,8}
      logic [BUS_SIZE_DATA-1:0] ram_dout_1 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{7,6,5,4}
      logic [BUS_SIZE_DATA-1:0] ram_dout_0 ;  // ram_dout for DC_1r1w2c_BE_15x512_d32w4_{3,2,1,0}

      assign  we_31 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd31;
      assign  we_30 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd30;
      assign  we_29 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd29;
      assign  we_28 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd28;
      assign  we_27 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd27;
      assign  we_26 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd26;
      assign  we_25 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd25;
      assign  we_24 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd24;
      assign  we_23 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd23;
      assign  we_22 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd22;
      assign  we_21 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd21;
      assign  we_20 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd20;
      assign  we_19 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd19;
      assign  we_18 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd18;
      assign  we_17 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd17;
      assign  we_16 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd16;
      assign  we_15 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd15;
      assign  we_14 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd14;
      assign  we_13 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd13;
      assign  we_12 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd12;
      assign  we_11 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd11;
      assign  we_10 =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd10;
      assign  we_9  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd9 ;
      assign  we_8  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd8 ;
      assign  we_7  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd7 ;
      assign  we_6  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd6 ;
      assign  we_5  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd5 ;
      assign  we_4  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd4 ;
      assign  we_3  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd3 ;
      assign  we_2  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd2 ;
      assign  we_1  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd1 ;
      assign  we_0  =  we & waddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5] == 5'd0 ;

      logic   [BUS_SIZE_DATA-1:0]     bitWrEn;
 
      always_comb
        begin
          for (int i=0; i<BUS_SIZE_DATA/8; i++)
          begin
            bitWrEn[7+(8*i)-:8] = {8{be[i]}};
          end
        end

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_127
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[127]  ),
          .QB         (ram_dout_31[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_31      ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_126
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[126]  ),
          .QB         (ram_dout_31[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_31      ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_125
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[125]  ),
          .QB         (ram_dout_31[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_31      ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_124
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[124]  ),
          .QB         (ram_dout_31[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_31      ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_123
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[123]  ),
          .QB         (ram_dout_30[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_30       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_122
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[122]  ),
          .QB         (ram_dout_30[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_30       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_121
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[121]  ),
          .QB         (ram_dout_30[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_30       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_120
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[120]  ),
          .QB         (ram_dout_30[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_30       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_119
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[119]  ),
          .QB         (ram_dout_29[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_29       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_118
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[118]  ),
          .QB         (ram_dout_29[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_29       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_117
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[117]  ),
          .QB         (ram_dout_29[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_29       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_116
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[116]  ),
          .QB         (ram_dout_29[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_29       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_115
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[115]  ),
          .QB         (ram_dout_28[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_28       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_114
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[114]  ),
          .QB         (ram_dout_28[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_28       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_113
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[113]  ),
          .QB         (ram_dout_28[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_28       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_112
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[112]  ),
          .QB         (ram_dout_28[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_28       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_111
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[111]  ),
          .QB         (ram_dout_27[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_27       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_110
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[110]  ),
          .QB         (ram_dout_27[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_27       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_109
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[109]  ),
          .QB         (ram_dout_27[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_27       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_108
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[108]  ),
          .QB         (ram_dout_27[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_27       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_107
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[107]  ),
          .QB         (ram_dout_26[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_26       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_106
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[106]  ),
          .QB         (ram_dout_26[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_26       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_105
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[105]  ),
          .QB         (ram_dout_26[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_26       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_104
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[104]  ),
          .QB         (ram_dout_26[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_26       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_103
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[103]  ),
          .QB         (ram_dout_25[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_25       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_102
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[102]  ),
          .QB         (ram_dout_25[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_25       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_101
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[101]  ),
          .QB         (ram_dout_25[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_25       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_100
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[100]  ),
          .QB         (ram_dout_25[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_25       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_99
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[99]  ),
          .QB         (ram_dout_24[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_24       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_98
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[98]  ),
          .QB         (ram_dout_24[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_24       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_97
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[97]  ),
          .QB         (ram_dout_24[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_24       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_96
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[96]  ),
          .QB         (ram_dout_24[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_24       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_95
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[95]  ),
          .QB         (ram_dout_23[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_23       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_94
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[94]  ),
          .QB         (ram_dout_23[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_23       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_93
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[93]  ),
          .QB         (ram_dout_23[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_23       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_92
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[92]  ),
          .QB         (ram_dout_23[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_23       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_91
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[91]  ),
          .QB         (ram_dout_22[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_22       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_90
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[90]  ),
          .QB         (ram_dout_22[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_22       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_89
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[89]  ),
          .QB         (ram_dout_22[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_22       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_88
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[88]  ),
          .QB         (ram_dout_22[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_22       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_87
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[87]  ),
          .QB         (ram_dout_21[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_21       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_86
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[86]  ),
          .QB         (ram_dout_21[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_21       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_85
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[85]  ),
          .QB         (ram_dout_21[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_21       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_84
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[84]  ),
          .QB         (ram_dout_21[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_21       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_83
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[83]  ),
          .QB         (ram_dout_20[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_20       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_82
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[82]  ),
          .QB         (ram_dout_20[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_20       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_81
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[81]  ),
          .QB         (ram_dout_20[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_20       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_80
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[80]  ),
          .QB         (ram_dout_20[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_20       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_79
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[79]  ),
          .QB         (ram_dout_19[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_19       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_78
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[78]  ),
          .QB         (ram_dout_19[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_19       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_77
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[77]  ),
          .QB         (ram_dout_19[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_19       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_76
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[76]  ),
          .QB         (ram_dout_19[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_19       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_75
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[75]  ),
          .QB         (ram_dout_18[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_18       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_74
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[74]  ),
          .QB         (ram_dout_18[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_18       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_73
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[73]  ),
          .QB         (ram_dout_18[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_18       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_72
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[72]  ),
          .QB         (ram_dout_18[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_18       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_71
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[71]  ),
          .QB         (ram_dout_17[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_17       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_70
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[70]  ),
          .QB         (ram_dout_17[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_17       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_69
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[69]  ),
          .QB         (ram_dout_17[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_17       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_68
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[68]  ),
          .QB         (ram_dout_17[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_17       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_67
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[67]  ),
          .QB         (ram_dout_16[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_16       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_66
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[66]  ),
          .QB         (ram_dout_16[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_16       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_65
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[65]  ),
          .QB         (ram_dout_16[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_16       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_64
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[64]  ),
          .QB         (ram_dout_16[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_16       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_63
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[63]  ),
          .QB         (ram_dout_15[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_15       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_62
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[62]  ),
          .QB         (ram_dout_15[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_15       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_61
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[61]  ),
          .QB         (ram_dout_15[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_15       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_60
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[60]  ),
          .QB         (ram_dout_15[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_15       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_59
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[59]  ),
          .QB         (ram_dout_14[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_14       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_58
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[58]  ),
          .QB         (ram_dout_14[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_14       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_57
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[57]  ),
          .QB         (ram_dout_14[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_14       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_56
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[56]  ),
          .QB         (ram_dout_14[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_14       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_55
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[55]  ),
          .QB         (ram_dout_13[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_13       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_54
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[54]  ),
          .QB         (ram_dout_13[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_13       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_53
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[53]  ),
          .QB         (ram_dout_13[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_13       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_52
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[52]  ),
          .QB         (ram_dout_13[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_13       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_51
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[51]  ),
          .QB         (ram_dout_12[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_12       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_50
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[50]  ),
          .QB         (ram_dout_12[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_12       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_49
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[49]  ),
          .QB         (ram_dout_12[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_12       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_48
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[48]  ),
          .QB         (ram_dout_12[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_12       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_47
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[47]  ),
          .QB         (ram_dout_11[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_11       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_46
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[46]  ),
          .QB         (ram_dout_11[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_11       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_45
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[45]  ),
          .QB         (ram_dout_11[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_11       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_44
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[44]  ),
          .QB         (ram_dout_11[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_11       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_43
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[43]  ),
          .QB         (ram_dout_10[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_10       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_42
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[42]  ),
          .QB         (ram_dout_10[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_10       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_41
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[41]  ),
          .QB         (ram_dout_10[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_10       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_40
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[40]  ),
          .QB         (ram_dout_10[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_10       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_39
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[39]  ),
          .QB         (ram_dout_9[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_9       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_38
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[38]  ),
          .QB         (ram_dout_9[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_9       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_37
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[37]  ),
          .QB         (ram_dout_9[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_9       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_36
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[36]  ),
          .QB         (ram_dout_9[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_9       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_35
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[35]  ),
          .QB         (ram_dout_8[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_8       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_34
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[34]  ),
          .QB         (ram_dout_8[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_8       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_33
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[33]  ),
          .QB         (ram_dout_8[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_8       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_32
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[32]  ),
          .QB         (ram_dout_8[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_8       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_31
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[31]  ),
          .QB         (ram_dout_7[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_7       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_30
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[30]  ),
          .QB         (ram_dout_7[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_7       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_29
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[29]  ),
          .QB         (ram_dout_7[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_7       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_28
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[28]  ),
          .QB         (ram_dout_7[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_7       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_27
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[27]  ),
          .QB         (ram_dout_6[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_6       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_26
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[26]  ),
          .QB         (ram_dout_6[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_6       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_25
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[25]  ),
          .QB         (ram_dout_6[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_6       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_24
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[24]  ),
          .QB         (ram_dout_6[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_6       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_23
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[23]  ),
          .QB         (ram_dout_5[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_5       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_22
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[22]  ),
          .QB         (ram_dout_5[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_5       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_21
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[21]  ),
          .QB         (ram_dout_5[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_5       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_20
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[20]  ),
          .QB         (ram_dout_5[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_5       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_19
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[19]  ),
          .QB         (ram_dout_4[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_4       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_18
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[18]  ),
          .QB         (ram_dout_4[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_4       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_17
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[17]  ),
          .QB         (ram_dout_4[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_4       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_16
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[16]  ),
          .QB         (ram_dout_4[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_4       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_15
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[15]  ),
          .QB         (ram_dout_3[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_3       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_14
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[14]  ),
          .QB         (ram_dout_3[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_3       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_13
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[13]  ),
          .QB         (ram_dout_3[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_3       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_12
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[12]  ),
          .QB         (ram_dout_3[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_3       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_11
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[11]  ),
          .QB         (ram_dout_2[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_2       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_10
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[10]  ),
          .QB         (ram_dout_2[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_2       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_9
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[9]  ),
          .QB         (ram_dout_2[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_2       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_8
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[8]  ),
          .QB         (ram_dout_2[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_2       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_7
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[7]  ),
          .QB         (ram_dout_1[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_6
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[6]  ),
          .QB         (ram_dout_1[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_5
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[5]  ),
          .QB         (ram_dout_1[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_4
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[4]  ),
          .QB         (ram_dout_1[BUS_SIZE_DATA/4-1:0]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_1       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_3
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[3]  ),
          .QB         (ram_dout_0[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[4*BUS_SIZE_DATA/4-1:3*BUS_SIZE_DATA/4]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_2
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[2]  ),
          .QB         (ram_dout_0[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          // Inputs   
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[3*BUS_SIZE_DATA/4-1:2*BUS_SIZE_DATA/4]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_1
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[1]  ),
          .QB         (ram_dout_0[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEMA       (bitWrEn[2*BUS_SIZE_DATA/4-1:BUS_SIZE_DATA/4]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );

      sacrls0g4u2p1024x128m4b4w1c1p0d0l1rm4rw11zh0h0ms0mg0
        DC_1r1w2c_BE_15x512_d32w4_0
        ( 
          // Outputs
          .RSCOUT     (RSCOUT[0]  ),
          .QB         (ram_dout_0[BUS_SIZE_DATA/4-1:0]),
          // Inputs
          .ADRA       (waddr[BUS_SIZE_ADDR-6:0]),
          .DA         (din[BUS_SIZE_DATA/4-1:0]),
          .WEMA       (bitWrEn[BUS_SIZE_DATA/4-1:0]),
          .WEA        (we_0       ),
          .MEA        ('1         ),  // Memory Enable input (wr). When the Memory Enable input is Logic High, the memory is enabled and write operations can be performed using ADRA and WEA.
          .RSCIN      (RSCIN      ),
          .RSCEN      (RSCEN      ),
          .RSCRST     (RSCRST     ),
          .RSCLK      (RSCLK      ),
          .FISO       (FISO       ),
          .CLKA       (clk        ),
          .TEST1A     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKA).
          .TEST_RNMA  ('0         ),  // When this pin is high, memory will go in idle state and bit-lines are pre-charged high. ATPG mode should be turned off in this mode.
          .RMEA       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMA        ('0         ),
          .RA         (RA[1:0]    ),
          .WA         (WA[2:0]    ),
          .WPULSE     (WPULSE[2:0]),
          .LS         ('0         ),
          .ADRB       (raddr[BUS_SIZE_ADDR-6:0]),
          .MEB        ('1         ),  // Memory Enable input (rd). When the Memory Enable input is Logic High, the memory is enabled and read operations can be performed using ADRB.
          .CLKB       (clk        ),
          .TEST1B     ('0         ),  // When TEST1=1, the memory self time circuitry is bypassed, and the memory timing is controlled by the external clock signal (CLKB).
          .RMEB       ('0         ),  // Read-Write Margin Enable Input. This input selects between the default Read-Write margin setting (RME=0), and the external pin Read-Write margin setting (RME=1).
          .RMB        ('0         )
        );


      always @*
      begin
        case (raddr[BUS_SIZE_ADDR-1:BUS_SIZE_ADDR-5])
          'd31: ram_dout = ram_dout_31;
          'd30: ram_dout = ram_dout_30;
          'd29: ram_dout = ram_dout_29;
          'd28: ram_dout = ram_dout_28;
          'd27: ram_dout = ram_dout_27;
          'd26: ram_dout = ram_dout_26;
          'd25: ram_dout = ram_dout_25;
          'd24: ram_dout = ram_dout_24;
          'd23: ram_dout = ram_dout_23;
          'd22: ram_dout = ram_dout_22;
          'd21: ram_dout = ram_dout_21;
          'd20: ram_dout = ram_dout_20;
          'd19: ram_dout = ram_dout_19;
          'd18: ram_dout = ram_dout_18;
          'd17: ram_dout = ram_dout_17;
          'd16: ram_dout = ram_dout_16;
          'd15: ram_dout = ram_dout_15;
          'd14: ram_dout = ram_dout_14;
          'd13: ram_dout = ram_dout_13;
          'd12: ram_dout = ram_dout_12;
          'd11: ram_dout = ram_dout_11;
          'd10: ram_dout = ram_dout_10;
          'd9 : ram_dout = ram_dout_9 ;
          'd8 : ram_dout = ram_dout_8 ;
          'd7 : ram_dout = ram_dout_7 ;
          'd6 : ram_dout = ram_dout_6 ;
          'd5 : ram_dout = ram_dout_5 ;
          'd4 : ram_dout = ram_dout_4 ;
          'd3 : ram_dout = ram_dout_3 ;
          'd2 : ram_dout = ram_dout_2 ;
          'd1 : ram_dout = ram_dout_1 ;
          'd0 : ram_dout = ram_dout_0 ;
        endcase
      end
      
    end // bbs_32kx512_be


  // ------------------------------------------------------------------------------------------------------------------------
  // Next we generate the common code to handle the GRAM_MODE being either: 
  //  type 1 (dout fed directly from the ram_dout (QB) output, or 
  //  type 3 (dout fed from a cycle-delayed buffer stage of ram_dout (QB) output
  // All of the above instance generations use this same logic.
  // ------------------------------------------------------------------------------------------------------------------------

      // Single Instance RAMs
  if (  (BUS_SIZE_ADDR == 9  & BUS_SIZE_DATA == 16  )
      // Width-Coupling (only) RAMs
      | (BUS_SIZE_ADDR == 9  & BUS_SIZE_DATA == 512 )
      // Depth-Coupling (only) RAMs
      | (BUS_SIZE_ADDR == 11 & BUS_SIZE_DATA == 16  )
      | (BUS_SIZE_ADDR == 15 & BUS_SIZE_DATA == 16  )
      // Depth-Coupling and Width-Coupling RAMs
      | (BUS_SIZE_ADDR == 11 & BUS_SIZE_DATA == 512 ) 
      | (BUS_SIZE_ADDR == 15 & BUS_SIZE_DATA == 512 )
     )
    begin: common_ram_code
      always @(posedge clk)
      begin
        dout <= ram_dout; // Create an additional stage of flop
        /*synthesis translate_off */
        if(driveX)
          dout <=   'hx;
        if(raddr==waddr && we)
          driveX <= 1;
        else
          driveX <= 0;            
        /*synthesis translate_on */
      end
    end // common_ram_code

  // ------------------------------------------------------------------------------------------------------------------------
  // Else if the Leucadia instances are not detected, then generate the old tbf RAM logic as a fallback
  // ------------------------------------------------------------------------------------------------------------------------
  else 
    begin: tbf_ram
      always_ff @(posedge clk)
      begin
        if (we)
          for (int i=0; i<BUS_SIZE_DATA/8; i++) 
          begin
            // ram[waddr][BUS_SIZE_DATA-1:0]<=din[BUS_SIZE_DATA-1:0]; // synchronous write the RAM
            if (be[i])
              ram[waddr][i]  <= din[7+(8*i)-:8];
          end
        ram_dout<= ram[raddr];
        dout    <= ram_dout;
        /*synthesis translate_off */
        if(driveX)
            dout    <= 'hx;
        if(raddr==waddr && we)
            driveX <= 1;
        else
            driveX <= 0;            
        /*synthesis translate_on */
      end
    end // tbf_ram
 endgenerate
`endif

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "HctnGl1QgJ/HrZ7MMmd72NbAcF/u+kXDuPpMPqJXsAp/MA+zAhJgRWEND0PDbuawYVxrsZmjSMCRHx90KPdgdv0fqrf0cXOTVsiQ7DIzyBvdPSGO5S6adPXyRN7COgS975AeAYFWvBgSUbB5qQtgqu1VILF85Sgd1iObKFiPApDxsNlRAP2mdOxzOXwbWNqTIwMXfWEThHIHnaPVFR00nF5nlJVE9ssIv3e5JYv//X1eagV1yCrSSpd/3o0WzUs+MRxHLxqjv9cICLvdMDhoCPrrU+ZhU5zeCDAN1Vp894++vofSr80DqUmITNyYMyrFeVDjvahvZuEetP39DuvdJRChUkJJDxlaANvQOiTMGEBJuOwqOe5LqNFJix4j8Lv5XK5k7I2QVx2AHmG6toqW6nhVV4fwrJipuEyr2y/U9aZ3Yr2/LRgRpjFHGpvD2dIH5eH1O+VLrTU/y16CcPgmh0DSmoSgFPhtEREI4nurYse6eY/N2TEX4LQWB0m0ilKfCIML23Kgj1h+Q5XowCtk+oLm6z2VVr4Qq8zpwk9AT/uD6tWrQIL5Vgs4AZv781KVBM/Hz8o9sbaTK9Ay/ik8N47AN6/KWmKDGrV+cPUGN/kQjWBNst8ZJXdDiLWx5SN4TThaW+3axE/BFvoXofZGMbor1Blm8DeRldk2uhvmHBMVcTZG5h0n9WfFt53/i/FjJb9qcB4gvtdnrGqe4RiiO7RdWRFgLeR3IeuYx3idT82zRu3vNPy1Uot5xB9I22X3PB7YJ4fjcywYe4u6Dn5oOax/HDrHBayp31l5EUxIBEtkLpa9y6rbMJiDrkPdw+1n4mwfI8wOyywweUenCh52nMbIstYMKREb1k38PZG6xjT4UELwUezwluYsRnjqfQu9/Dp36eYUcw8+dH8jNcaScAe6/HbXojWEivpr49BnuKo7CRFaqs0+1O3+LFjggeaLm+MDA3l6Q5AdECo1yTS677d12QWa8Qe786G+FUIndkJzQ1TKnDBiZ6fKgq59+Law"
`endif