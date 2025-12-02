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



module altera_emif_arch_fm_cal_counter # (
   parameter IS_HPS = 0
) (
   input logic pll_ref_clk_int,
   input logic local_reset_req_int,
   input logic afi_cal_in_progress
);
   timeunit 1ps;
   timeprecision 1ps;

   typedef enum {
      INIT,
      IDLE,
      COUNT_CAL,
      STOP
   } counter_state_t;

   logic                         done;
   logic [31:0]                  clk_counter;

   generate
      if (IS_HPS == 0) begin : non_hps
         logic                         cal_done;
         logic                         reset_req_sync;
         logic                         cal_in_progress_sync;

         altera_std_synchronizer_nocut
         inst_sync_reset_n (
            .clk     (pll_ref_clk_int),
            .reset_n (1'b1),
            .din     (local_reset_req_int),
            .dout    (reset_req_sync)
         );

         altera_std_synchronizer_nocut
         inst_sync_cal_in_progress (
            .clk     (pll_ref_clk_int),
            .reset_n (1'b1),
            .din     (afi_cal_in_progress),
            .dout    (cal_in_progress_sync)
         );

         counter_state_t counter_state /* synthesis ignore_power_up */;

         assign done = ((counter_state == STOP) ? 1'b1 : 1'b0);

         always_ff @(posedge pll_ref_clk_int) begin
            if(reset_req_sync == 1'b1) begin
               counter_state <= INIT;
            end
            else begin
               case(counter_state)
                  INIT:
                  begin
                     clk_counter <= 32'h0;
                     counter_state <= IDLE;
                  end

                  IDLE:
                  begin
                     if (cal_in_progress_sync == 1'b1)
                     begin
                        counter_state <= COUNT_CAL;
                     end
                  end

                  COUNT_CAL:
                  begin
                     clk_counter[31:0] <= clk_counter[31:0] + 32'h0000_0001;

                     if (cal_in_progress_sync == 1'b0)
                     begin
                        counter_state <= STOP;
                     end
                  end

                  STOP:
                  begin
                     counter_state <= STOP;
                  end

                  default:
                  begin
                     counter_state <= INIT;
                  end
               endcase
            end
         end
      end else begin : hps
         assign done = 1'b1;
         assign clk_counter = '0;
      end
   endgenerate

`ifdef ALTERA_EMIF_ENABLE_ISSP
   altsource_probe #(         
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("CALC"),
      .probe_width             (33),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
      ) cal_counter_issp (
      .probe  ({done, clk_counter[31:0]})
   );
`endif

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "AkDMPQOIIBdUXJUhCY52t3tbYDqXLRT52E5ixmZO0uPIiLYJYXmvta4pFJ02IBPPGIT2TNlVDsKSvVYXIouIW3+7aiOKefqrRsAdehbNE32jACVZGhhWbzy3szTqf0uEFX9R013QJTOv5J6g1voik7ro4grooLGTSGkMVb4gcDO55U1rrsm6St9TUaqtK0kUq5O3EnV7TSjC5mQCTLijd71E/Cuksp1vhZhmO5ulHVAvZ9jAmlZK0eCRWC8Z7YvdiOHBCHaad3/sG3FKJDTkUcNF2S9kMVoWatSSdEFVZZ/tSQxEw3HeiZ6LshTc2Iyo4UVJVL+ueZRscGlcnlmvu++5qed36NEp8ewIHTZPu4xn9aByVydMLzpQ2+2xs1L2nc41VSW9p8lDmZHPRAUMGl6TpxHRJLgNZ1rVYXPtAORZA6dKCsEtqiqbJ7C7u/a8LiapHGIeMnc4r4Z18NwwwgW3sGDbFfGEud0/LW11pTC6W8qrvGIemoblQRWmXllB6goayNcdG5kQQZfDk8KkxtrXzKzaIuiR3yzsV2mcfVdrgtJRzIXaGSgVb5bEBd5QibKMW6RM9KFnLmIqAsS5e5FKGY5TG2tz6cVUIqMNEQ3K4MIJ8mmnkNAC8YBi/dYHQB6GZ+Y2iQQHtJwerE2exxazbmcX2aV4i3RXhFUT8YaCSP8+TNEp8NNtZf4tYeYOrXnyLRyCg6CC8c3i9eM8P5c2uLJ7ZBENVn+4TnQSMnNZZNwgdXN1kim634dEsXD2a0rH2yBKHjjzXnHnSXdUxiMAoio1xR2IkbYnK/dW+r61Ra+d4Eg4tDhXkJ3kPjVpR7bgtY2WlxYwZQXnOVKBKbf6jByq+M361weSl2n67iPI1VPFRak2JUgXZLzXwhqVFgpLR742aIQOFdg/aeqOMmo+wQeJovk+fxsDRY7Tys01++AJ79WDGdSpHXzRQWkl99KI6eI/5XSK8qp/TeJ9750ClRKZqmY5Gsa5ol4yHXsIm8/cB31ffq4Q2OPKuuWJ"
`endif