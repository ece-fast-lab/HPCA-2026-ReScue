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
// This module implements the gearbox logic to compress the number of wire
// connections to the IOSSM debug port.
//
///////////////////////////////////////////////////////////////////////////////

module altera_emif_f2c_gearbox #(
   // Port widths for core debug access
   parameter PORT_CAL_DEBUG_ADDRESS_WIDTH              = 1,
   parameter PORT_CAL_DEBUG_BYTEEN_WIDTH               = 1,
   parameter PORT_CAL_DEBUG_RDATA_WIDTH                = 1,
   parameter PORT_CAL_DEBUG_WDATA_WIDTH                = 1
) (
   input  logic                                       clk,
   input  logic                                       reset_n,

   input  logic [PORT_CAL_DEBUG_ADDRESS_WIDTH-1:0]    cal_debug_addr,
   input  logic [PORT_CAL_DEBUG_BYTEEN_WIDTH-1:0]     cal_debug_byteenable,
   input  logic                                       cal_debug_read,
   input  logic                                       cal_debug_write,
   input  logic [PORT_CAL_DEBUG_WDATA_WIDTH-1:0]      cal_debug_write_data,

   output logic [PORT_CAL_DEBUG_RDATA_WIDTH-1:0]      cal_debug_read_data,
   output logic                                       cal_debug_read_data_valid,
   output logic                                       cal_debug_waitrequest,

   input logic  [7:0]                                 soft_nios_read_data,
   input logic                                        soft_nios_rdata_valid_n,
   input logic                                        soft_nios_waitrequest_n,

   output logic                                       soft_nios_read,
   output logic                                       soft_nios_write,
   output logic                                       soft_nios_byteenable,
   output logic [7:0]                                 soft_nios_write_data,
   output logic [6:0]                                 soft_nios_address
);
   timeunit 1ps;
   timeprecision 1ps;

   typedef enum logic [2:0] {
      F2C_IDLE = 3'b000,
      F2C_WAIT = 3'b001,
      F2C_CMD  = 3'b010,
      F2C_RDATA= 3'b100
   } f2c_state_t;

   localparam F2C_RDATA_SHIFT_CNT = PORT_CAL_DEBUG_RDATA_WIDTH / 8;
   localparam F2C_CMD_SHIFT_CNT   = PORT_CAL_DEBUG_BYTEEN_WIDTH;

   logic                                              f2c_cmd_valid;
   logic                                              f2c_cmd_rnw;
   logic [PORT_CAL_DEBUG_ADDRESS_WIDTH-1:0]           f2c_cmd_addr;
   logic [PORT_CAL_DEBUG_BYTEEN_WIDTH-1:0]            f2c_byteenable;
   logic [PORT_CAL_DEBUG_WDATA_WIDTH-1:0]             f2c_write_data;
   logic [PORT_CAL_DEBUG_RDATA_WIDTH-1:0]             f2c_read_data;

   logic [3:0]                                        f2c_cmd_shift;
   logic [3:0]                                        f2c_data_shift;

   logic                                              f2c_cmd_done;
   logic                                              f2c_rdata_done;
   logic                                              f2c_cmd_carry_out;
   logic                                              f2c_data_carry_out;

   f2c_state_t                                        f2c_state /* synthesis ignore_power_up */;

   always_ff @(posedge clk, negedge reset_n) begin
      if (!reset_n)
         f2c_state <= F2C_IDLE;
      else begin
         case (f2c_state)
            F2C_IDLE:
               if (cal_debug_read | cal_debug_write)
                  f2c_state <= F2C_WAIT;
            F2C_WAIT:
               if (~soft_nios_waitrequest_n)
                  f2c_state <= F2C_CMD;
            F2C_CMD:
               if (f2c_cmd_done)
                  f2c_state <= f2c_cmd_rnw ? F2C_RDATA : F2C_IDLE;
            F2C_RDATA:
               if (f2c_rdata_done)
                  f2c_state <= F2C_IDLE;
            default:
               f2c_state <= F2C_IDLE;
         endcase
      end
   end

   always_ff @(posedge clk, negedge reset_n) begin
      if (!reset_n) begin
         f2c_cmd_rnw     <= 1'b0;
         f2c_cmd_addr    <=  'b0;
         f2c_byteenable  <=  'b0;
         f2c_write_data  <=  'b0;
         f2c_cmd_shift   <=  'b0;
         f2c_data_shift  <=  'b0;
      end else if (f2c_state == F2C_IDLE) begin
         f2c_cmd_rnw     <=   cal_debug_read;
         f2c_cmd_addr    <=   cal_debug_addr;
         f2c_byteenable  <=   cal_debug_byteenable;
         f2c_write_data  <=   cal_debug_write_data;
         f2c_cmd_shift   <=  'b0;
         f2c_data_shift  <=  'b0;
      end else if (f2c_state == F2C_CMD) begin
         {f2c_cmd_carry_out, f2c_cmd_shift} <=  f2c_cmd_shift + 1;
         f2c_cmd_addr    <=  {7'b0,f2c_cmd_addr   [PORT_CAL_DEBUG_ADDRESS_WIDTH - 1 : 7]};
         f2c_byteenable  <=  {1'b0,f2c_byteenable [PORT_CAL_DEBUG_BYTEEN_WIDTH  - 1 : 1]};
         f2c_write_data  <=  {8'b0,f2c_write_data [PORT_CAL_DEBUG_WDATA_WIDTH   - 1 : 8]};
      end else if (f2c_state == F2C_RDATA && ~soft_nios_rdata_valid_n) begin
         {f2c_data_carry_out, f2c_data_shift} <=  f2c_data_shift + 1;
         f2c_read_data   <=  {soft_nios_read_data, f2c_read_data[PORT_CAL_DEBUG_RDATA_WIDTH - 1 : 8]};
      end
   end

   always_ff @(posedge clk, negedge reset_n) begin
      if (!reset_n)
         cal_debug_read_data_valid <= 1'b0;
      else
         cal_debug_read_data_valid <= f2c_rdata_done;
   end

   assign f2c_cmd_valid            = f2c_state == F2C_CMD;
   assign f2c_cmd_done             = f2c_cmd_shift  == (F2C_CMD_SHIFT_CNT   - 1);
   assign f2c_rdata_done           = f2c_data_shift == (F2C_RDATA_SHIFT_CNT - 1);

   assign soft_nios_read           = f2c_cmd_valid  &  f2c_cmd_rnw;
   assign soft_nios_write          = f2c_cmd_valid  & ~f2c_cmd_rnw;
   assign soft_nios_byteenable     = f2c_byteenable [0];
   assign soft_nios_write_data     = f2c_write_data [7:0];
   assign soft_nios_address        = f2c_cmd_addr   [6:0];

   assign cal_debug_waitrequest    = f2c_state != F2C_IDLE;
   assign cal_debug_read_data      = f2c_read_data;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4V/MWEYpCfQX0eb7tguubHFMH9Tigh75ZlYgRv/o3J/jI4HGhXSh8uGfjCk/IDuGMiILY6NkUzaBT+tXSE0TyB2idx4Hpxke202OcWJ6uAWLfNANXoD2Kib1zuWIrxSoO1MdOsBOnafqVVTiwn28xWg3OMWltW0qzujZBIdSWiJ3ChiCeOqkKlbsH+RwYb+sAp3SDamHgtDjrQwrjmTMiX0+Lr3Yij2yjqP+aVdrbrOUn8btVzkUB1Vg2WpiJ7YjfUKEZKBQ6afK2EeGDYGeNX4/A8bfEiygivEjho0SDjm7QrolIEho4g9rhaARlFec1/KIdS/MOcKDqVxn+ne0rtVOgHaDidc5AQIdhL5/breQsTFLetUmAhkQQlEDuY5j+TH8JYgRpL53ULR6UudeODJyngw6VoEzsuwWGRrzbJJ3qWbSSQqFist5oTeYrn197JQgHU5NbiJrEMUa6G8GVtj9c4K77gT4TQ8fhJnmpDya4LWdSB9u5Gy1QHcTzCNRcGtTln30wcQEF/ImFjwJx3oc3KRQZM5X81RINBPD8fQpAA1MLfzqj1zEKudb4UiAwsn77QiUN5y/WEBdgUdSmfKjtY6S5hwu0Brma+8v9s/48hS007Z7IkqMFwtQXobg/twHCEz7+1bty+8CVANJKtJj3IRvjT3QKcZH7dghyV3VoibtAAmrteS3+IgSxXDfkn0CXWKkyJmroLpIszB9WD22lcXHGSX6G0NoImSZhif+b3c2mlBWffPTSDTNYCfqKDptd1tZWSSq+MJ21ZQ4pK3KC3b3JgJYnLLmXRUOS9P5/Pt7H4JfkdIBnFbS6m6FgQcNHUIVspQvxnxKmrZbrSNug5JJFcpS3t/zJOH/wPbslzvWtdRbvgcsiksUowKZVcWi5H/SBpiTGE7KjXto/PBWuWO1pbWFVz5KQwn6qUyEL7tSJFsotEHiSI+f83WV1SqxIinLBpLRqhGp6YOOmiEvpJ6tO+9mATJ72/l/H5sxvArjqQnmkxrLrJFtdK0h"
`endif