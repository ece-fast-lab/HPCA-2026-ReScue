module intel_rtile_cxl_top_cxltyp3_ed (
		input  wire         refclk4,                           //             refclk.clk
		input  wire         refclk0,                           //            refclk0.clk
		input  wire         refclk1,                           //            refclk1.clk
		input  wire         resetn,                            //             resetn.reset_n
		input  wire         nInit_done,                        //         ninit_done.ninit_done
		output wire         sip_warm_rstn_o,                   //      sip_warm_rstn.reset_n
		output wire         cxl_warm_rst_n,                    //          warm_rstn.reset_n
		output wire         cxl_cold_rst_n,                    //          cold_rstn.reset_n
		output wire         pll_lock_o,                        //                pll.pll_lock_o
		input  wire [1:0]   u2ip_0_qos_devload,                //        qos_devload.u2ip_0_qos_devload
		input  wire [1:0]   u2ip_1_qos_devload,                //                   .u2ip_1_qos_devload
		input  wire [15:0]  cxl_rx_n,                          //                cxl.rx_n
		input  wire [15:0]  cxl_rx_p,                          //                   .rx_p
		output wire [15:0]  cxl_tx_n,                          //                   .tx_n
		output wire [15:0]  cxl_tx_p,                          //                   .tx_p
		input  wire [63:0]  mc2ip_memsize,                     //            memsize.mem_size
		output wire         ip2hdm_clk,                        //         ip2hdm_clk.clk
		output wire         ip2hdm_reset_n,                    //     ip2hdm_reset_n.reset
		input  wire [4:0]   mc2ip_0_sr_status,                 //            mc2ip_0.sr_status
		input  wire [4:0]   mc2ip_1_sr_status,                 //            mc2ip_1.sr_status
		output wire         ip2cafu_avmm_clk,                  //           cafu_csr.clk
		output wire         ip2cafu_avmm_rstn,                 //                   .rstn
		input  wire         cafu2ip_avmm_waitrequest,          //                   .waitrequest
		input  wire [63:0]  cafu2ip_avmm_readdata,             //                   .readdata
		input  wire         cafu2ip_avmm_readdatavalid,        //                   .readdatavalid
		output wire         ip2cafu_avmm_burstcount,           //                   .burstcount
		output wire [63:0]  ip2cafu_avmm_writedata,            //                   .writedata
		output wire         ip2csr_avmm_poison,                //                   .poison
		output wire [21:0]  ip2cafu_avmm_address,              //                   .address
		output wire         ip2cafu_avmm_write,                //                   .write
		output wire         ip2cafu_avmm_read,                 //                   .read
		output wire [7:0]   ip2cafu_avmm_byteenable,           //                   .byteenable
		output wire [31:0]  ccv_afu_conf_base_addr_high,       //            ccv_afu.base_addr_high
		output wire         ccv_afu_conf_base_addr_high_valid, //                   .base_addr_high_valid
		output wire [27:0]  ccv_afu_conf_base_addr_low,        //                   .base_addr_low
		output wire         ccv_afu_conf_base_addr_low_valid,  //                   .base_addr_low_valid
		output wire         ip2csr_avmm_clk,                   //             ip2csr.clock
		output wire         ip2csr_avmm_rstn,                  //                   .reset_n
		input  wire         csr2ip_avmm_waitrequest,           //                   .waitrequest
		input  wire [63:0]  csr2ip_avmm_readdata,              //                   .readdata
		input  wire         csr2ip_avmm_readdatavalid,         //                   .readdatavalid
		output wire [63:0]  ip2csr_avmm_writedata,             //                   .writedata
		output wire         ip2cafu_avmm_poison,               //                   .poison
		output wire [21:0]  ip2csr_avmm_address,               //                   .address
		output wire         ip2csr_avmm_write,                 //                   .write
		output wire         ip2csr_avmm_read,                  //                   .read
		output wire [7:0]   ip2csr_avmm_byteenable,            //                   .byteenable
		output wire         ip2uio_tx_ready,                   //         usr_tx_st0.ready
		input  wire         uio2ip_tx_st0_dvalid,              //                   .dvalid
		input  wire         uio2ip_tx_st0_sop,                 //                   .sop
		input  wire         uio2ip_tx_st0_eop,                 //                   .eop
		input  wire [255:0] uio2ip_tx_st0_data,                //                   .data
		input  wire [7:0]   uio2ip_tx_st0_data_parity,         //                   .data_parity
		input  wire [127:0] uio2ip_tx_st0_hdr,                 //                   .hdr
		input  wire [3:0]   uio2ip_tx_st0_hdr_parity,          //                   .hdr_parity
		input  wire         uio2ip_tx_st0_hvalid,              //                   .hvalid
		input  wire [31:0]  uio2ip_tx_st0_prefix,              //                   .prefix
		input  wire [0:0]   uio2ip_tx_st0_prefix_parity,       //                   .prefix_parity
		input  wire         uio2ip_tx_st0_pvalid,              //                   .pvalid
		input  wire [2:0]   uio2ip_tx_st0_empty,               //                   .empty
		input  wire         uio2ip_tx_st0_misc_parity,         //                   .misc_parity
		input  wire         uio2ip_tx_st1_dvalid,              //         usr_tx_st1.dvalid
		input  wire         uio2ip_tx_st1_sop,                 //                   .sop
		input  wire         uio2ip_tx_st1_eop,                 //                   .eop
		input  wire [255:0] uio2ip_tx_st1_data,                //                   .data
		input  wire [7:0]   uio2ip_tx_st1_data_parity,         //                   .data_parity
		input  wire [127:0] uio2ip_tx_st1_hdr,                 //                   .hdr
		input  wire [3:0]   uio2ip_tx_st1_hdr_parity,          //                   .hdr_parity
		input  wire         uio2ip_tx_st1_hvalid,              //                   .hvalid
		input  wire [31:0]  uio2ip_tx_st1_prefix,              //                   .prefix
		input  wire [0:0]   uio2ip_tx_st1_prefix_parity,       //                   .prefix_parity
		input  wire         uio2ip_tx_st1_pvalid,              //                   .pvalid
		input  wire [2:0]   uio2ip_tx_st1_empty,               //                   .empty
		input  wire         uio2ip_tx_st1_misc_parity,         //                   .misc_parity
		input  wire         uio2ip_tx_st2_dvalid,              //         usr_tx_st2.dvalid
		input  wire         uio2ip_tx_st2_sop,                 //                   .sop
		input  wire         uio2ip_tx_st2_eop,                 //                   .eop
		input  wire [255:0] uio2ip_tx_st2_data,                //                   .data
		input  wire [7:0]   uio2ip_tx_st2_data_parity,         //                   .data_parity
		input  wire [127:0] uio2ip_tx_st2_hdr,                 //                   .hdr
		input  wire [3:0]   uio2ip_tx_st2_hdr_parity,          //                   .hdr_parity
		input  wire         uio2ip_tx_st2_hvalid,              //                   .hvalid
		input  wire [31:0]  uio2ip_tx_st2_prefix,              //                   .prefix
		input  wire [0:0]   uio2ip_tx_st2_prefix_parity,       //                   .prefix_parity
		input  wire         uio2ip_tx_st2_pvalid,              //                   .pvalid
		input  wire [2:0]   uio2ip_tx_st2_empty,               //                   .empty
		input  wire         uio2ip_tx_st2_misc_parity,         //                   .misc_parity
		input  wire         uio2ip_tx_st3_dvalid,              //         usr_tx_st3.dvalid
		input  wire         uio2ip_tx_st3_sop,                 //                   .sop
		input  wire         uio2ip_tx_st3_eop,                 //                   .eop
		input  wire [255:0] uio2ip_tx_st3_data,                //                   .data
		input  wire [7:0]   uio2ip_tx_st3_data_parity,         //                   .data_parity
		input  wire [127:0] uio2ip_tx_st3_hdr,                 //                   .hdr
		input  wire [3:0]   uio2ip_tx_st3_hdr_parity,          //                   .hdr_parity
		input  wire         uio2ip_tx_st3_hvalid,              //                   .hvalid
		input  wire [31:0]  uio2ip_tx_st3_prefix,              //                   .prefix
		input  wire [0:0]   uio2ip_tx_st3_prefix_parity,       //                   .prefix_parity
		input  wire         uio2ip_tx_st3_pvalid,              //                   .pvalid
		input  wire [2:0]   uio2ip_tx_st3_empty,               //                   .empty
		input  wire         uio2ip_tx_st3_misc_parity,         //                   .misc_parity
		output wire [2:0]   ip2uio_tx_st_Hcrdt_update,         //          usr_tx_st.Hcrdt_update
		output wire [5:0]   ip2uio_tx_st_Hcrdt_update_cnt,     //                   .Hcrdt_update_cnt
		output wire [2:0]   ip2uio_tx_st_Hcrdt_init,           //                   .Hcrdt_init
		input  wire [2:0]   uio2ip_tx_st_Hcrdt_init_ack,       //                   .Hcrdt_init_ack
		output wire [2:0]   ip2uio_tx_st_Dcrdt_update,         //                   .Dcrdt_update
		output wire [11:0]  ip2uio_tx_st_Dcrdt_update_cnt,     //                   .Dcrdt_update_cnt
		output wire [2:0]   ip2uio_tx_st_Dcrdt_init,           //                   .Dcrdt_init
		input  wire [2:0]   uio2ip_tx_st_Dcrdt_init_ack,       //                   .Dcrdt_init_ack
		output wire         ip2uio_rx_st0_dvalid,              //        usr_rx_st_0.dvalid
		output wire         ip2uio_rx_st0_sop,                 //                   .sop
		output wire         ip2uio_rx_st0_eop,                 //                   .eop
		output wire         ip2uio_rx_st0_passthrough,         //                   .passthrough
		output wire [255:0] ip2uio_rx_st0_data,                //                   .data
		output wire [7:0]   ip2uio_rx_st0_data_parity,         //                   .data_parity
		output wire [127:0] ip2uio_rx_st0_hdr,                 //                   .hdr
		output wire [3:0]   ip2uio_rx_st0_hdr_parity,          //                   .hdr_parity
		output wire         ip2uio_rx_st0_hvalid,              //                   .hvalid
		output wire [31:0]  ip2uio_rx_st0_prefix,              //                   .prefix
		output wire [0:0]   ip2uio_rx_st0_prefix_parity,       //                   .prefix_parity
		output wire         ip2uio_rx_st0_pvalid,              //                   .pvalid
		output wire [2:0]   ip2uio_rx_st0_bar,                 //                   .bar
		output wire [2:0]   ip2uio_rx_st0_pfnum,               //                   .pfnum
		output wire         ip2uio_rx_st0_misc_parity,         //                   .misc_parity
		output wire [2:0]   ip2uio_rx_st0_empty,               //                   .empty
		output wire         ip2uio_rx_st1_dvalid,              //        usr_rx_st_1.dvalid
		output wire         ip2uio_rx_st1_sop,                 //                   .sop
		output wire         ip2uio_rx_st1_eop,                 //                   .eop
		output wire         ip2uio_rx_st1_passthrough,         //                   .passthrough
		output wire [255:0] ip2uio_rx_st1_data,                //                   .data
		output wire [7:0]   ip2uio_rx_st1_data_parity,         //                   .data_parity
		output wire [127:0] ip2uio_rx_st1_hdr,                 //                   .hdr
		output wire [3:0]   ip2uio_rx_st1_hdr_parity,          //                   .hdr_parity
		output wire         ip2uio_rx_st1_hvalid,              //                   .hvalid
		output wire [31:0]  ip2uio_rx_st1_prefix,              //                   .prefix
		output wire [0:0]   ip2uio_rx_st1_prefix_parity,       //                   .prefix_parity
		output wire         ip2uio_rx_st1_pvalid,              //                   .pvalid
		output wire [2:0]   ip2uio_rx_st1_bar,                 //                   .bar
		output wire [2:0]   ip2uio_rx_st1_pfnum,               //                   .pfnum
		output wire         ip2uio_rx_st1_misc_parity,         //                   .misc_parity
		output wire [2:0]   ip2uio_rx_st1_empty,               //                   .empty
		output wire         ip2uio_rx_st2_dvalid,              //        usr_rx_st_2.dvalid
		output wire         ip2uio_rx_st2_sop,                 //                   .sop
		output wire         ip2uio_rx_st2_eop,                 //                   .eop
		output wire         ip2uio_rx_st2_passthrough,         //                   .passthrough
		output wire [255:0] ip2uio_rx_st2_data,                //                   .data
		output wire [7:0]   ip2uio_rx_st2_data_parity,         //                   .data_parity
		output wire [127:0] ip2uio_rx_st2_hdr,                 //                   .hdr
		output wire [3:0]   ip2uio_rx_st2_hdr_parity,          //                   .hdr_parity
		output wire         ip2uio_rx_st2_hvalid,              //                   .hvalid
		output wire [31:0]  ip2uio_rx_st2_prefix,              //                   .prefix
		output wire [0:0]   ip2uio_rx_st2_prefix_parity,       //                   .prefix_parity
		output wire         ip2uio_rx_st2_pvalid,              //                   .pvalid
		output wire [2:0]   ip2uio_rx_st2_bar,                 //                   .bar
		output wire [2:0]   ip2uio_rx_st2_pfnum,               //                   .pfnum
		output wire         ip2uio_rx_st2_misc_parity,         //                   .misc_parity
		output wire [2:0]   ip2uio_rx_st2_empty,               //                   .empty
		output wire         ip2uio_rx_st3_dvalid,              //        usr_rx_st_3.dvalid
		output wire         ip2uio_rx_st3_sop,                 //                   .sop
		output wire         ip2uio_rx_st3_eop,                 //                   .eop
		output wire         ip2uio_rx_st3_passthrough,         //                   .passthrough
		output wire [255:0] ip2uio_rx_st3_data,                //                   .data
		output wire [7:0]   ip2uio_rx_st3_data_parity,         //                   .data_parity
		output wire [127:0] ip2uio_rx_st3_hdr,                 //                   .hdr
		output wire [3:0]   ip2uio_rx_st3_hdr_parity,          //                   .hdr_parity
		output wire         ip2uio_rx_st3_hvalid,              //                   .hvalid
		output wire [31:0]  ip2uio_rx_st3_prefix,              //                   .prefix
		output wire [0:0]   ip2uio_rx_st3_prefix_parity,       //                   .prefix_parity
		output wire         ip2uio_rx_st3_pvalid,              //                   .pvalid
		output wire [2:0]   ip2uio_rx_st3_bar,                 //                   .bar
		output wire [2:0]   ip2uio_rx_st3_pfnum,               //                   .pfnum
		output wire         ip2uio_rx_st3_misc_parity,         //                   .misc_parity
		output wire [2:0]   ip2uio_rx_st3_empty,               //                   .empty
		input  wire [2:0]   uio2ip_rx_st_Hcrdt_update,         //          usr_rx_st.Hcrdt_update
		input  wire [5:0]   uio2ip_rx_st_Hcrdt_update_cnt,     //                   .Hcrdt_update_cnt
		input  wire [2:0]   uio2ip_rx_st_Hcrdt_init,           //                   .Hcrdt_init
		output wire [2:0]   ip2uio_rx_st_Hcrdt_init_ack,       //                   .Hcrdt_init_ack
		input  wire [2:0]   uio2ip_rx_st_Dcrdt_update,         //                   .Dcrdt_update
		input  wire [11:0]  uio2ip_rx_st_Dcrdt_update_cnt,     //                   .Dcrdt_update_cnt
		input  wire [2:0]   uio2ip_rx_st_Dcrdt_init,           //                   .Dcrdt_init
		output wire [2:0]   ip2uio_rx_st_Dcrdt_init_ack,       //                   .Dcrdt_init_ack
		output wire [7:0]   ip2uio_bus_number,                 //                uio.usr_bus_number
		output wire [4:0]   ip2uio_device_number,              //                   .usr_device_number
		output wire [2:0]   pf0_max_payload_size,              //           ext_comp.pfo_mpss
		output wire [2:0]   pf0_max_read_request_size,         //                   .pf0_mrrs
		output wire         pf0_bus_master_en,                 //                   .pfo_bus_master_en
		output wire         pf0_memory_access_en,              //                   .pfo_mem_access_en
		output wire [2:0]   pf1_max_payload_size,              //                   .pf1_mpss
		output wire [2:0]   pf1_max_read_request_size,         //                   .pf1_mrrs
		output wire         pf1_bus_master_en,                 //                   .pf1_bus_master_en
		output wire         pf1_memory_access_en,              //                   .pf1_mem_access_en
		output wire         pf0_msix_enable,                   // pf0_msix_interface.msix_enable
		output wire         pf0_msix_fn_mask,                  //                   .msix_fn_mask
		output wire         pf1_msix_enable,                   // pf1_msix_interface.msix_enable
		output wire         pf1_msix_fn_mask,                  //                   .msix_fn_mask
		input  wire [63:0]  dev_serial_num,                    //                   .dev_serial_num
		input  wire         dev_serial_num_valid,              //                   .dev_serial_num_valid
		input  wire [95:0]  cafu2ip_csr0_cfg_if,               //      cafu_csr0_cfg.cafu2ip_cfg_if
		output wire [6:0]   ip2cafu_csr0_cfg_if,               //                   .ip2cafu_cfg_if
		output wire         ip2cafu_quiesce_req,               //            quiesce.quiesce_req
		input  wire         cafu2ip_quiesce_ack,               //                   .quiesce_ack
		input  wire         usr2ip_cxlreset_initiate,          //      cxl_reset_inf.cxlreset_initiate
		output wire         ip2usr_cxlreset_req,               //                   .cxlreset_req
		input  wire         usr2ip_cxlreset_ack,               //                   .cxlreset_ack
		output wire         ip2usr_cxlreset_error,             //                   .cxlreset_error
		output wire         ip2usr_cxlreset_complete,          //                   .cxlreset_complete
		input  wire         usr2ip_app_err_valid,              //        usr_err_inf.err_valid
		input  wire [31:0]  usr2ip_app_err_hdr,                //                   .err_hdr
		input  wire [13:0]  usr2ip_app_err_info,               //                   .err_info
		input  wire [2:0]   usr2ip_app_err_func_num,           //                   .err_fn_num
		output wire         ip2usr_app_err_ready,              //                   .err_rdy
		output wire         ip2usr_aermsg_correctable_valid,   //                   .aermsg_correctable_valid
		output wire         ip2usr_aermsg_uncorrectable_valid, //                   .aermsg_uncorrectable_valid
		output wire         ip2usr_aermsg_res,                 //                   .aermsg_res
		output wire         ip2usr_aermsg_bts,                 //                   .aermsg_bts
		output wire         ip2usr_aermsg_bds,                 //                   .aermsg_bds
		output wire         ip2usr_aermsg_rrs,                 //                   .aermsg_rrs
		output wire         ip2usr_aermsg_rtts,                //                   .aermsg_rtts
		output wire         ip2usr_aermsg_anes,                //                   .aermsg_anes
		output wire         ip2usr_aermsg_cies,                //                   .aermsg_cies
		output wire         ip2usr_aermsg_hlos,                //                   .aermsg_hlos
		output wire [1:0]   ip2usr_aermsg_fmt,                 //                   .aermsg_fmt
		output wire [4:0]   ip2usr_aermsg_type,                //                   .aermsg_type
		output wire [2:0]   ip2usr_aermsg_tc,                  //                   .aermsg_tc
		output wire         ip2usr_aermsg_ido,                 //                   .aermsg_ido
		output wire         ip2usr_aermsg_th,                  //                   .aermsg_th
		output wire         ip2usr_aermsg_td,                  //                   .aermsg_td
		output wire         ip2usr_aermsg_ep,                  //                   .aermsg_ep
		output wire         ip2usr_aermsg_ro,                  //                   .aermsg_ro
		output wire         ip2usr_aermsg_ns,                  //                   .aermsg_ns
		output wire [1:0]   ip2usr_aermsg_at,                  //                   .aermsg_at
		output wire [9:0]   ip2usr_aermsg_length,              //                   .aermsg_length
		output wire [95:0]  ip2usr_aermsg_header,              //                   .aermsg_header
		output wire         ip2usr_aermsg_und,                 //                   .aermsg_und
		output wire         ip2usr_aermsg_anf,                 //                   .aermsg_anf
		output wire         ip2usr_aermsg_dlpes,               //                   .aermsg_dlpes
		output wire         ip2usr_aermsg_sdes,                //                   .aermsg_sdes
		output wire [4:0]   ip2usr_aermsg_fep,                 //                   .aermsg_fep
		output wire         ip2usr_aermsg_pts,                 //                   .aermsg_pts
		output wire         ip2usr_aermsg_fcpes,               //                   .aermsg_fcpes
		output wire         ip2usr_aermsg_cts,                 //                   .aermsg_cts
		output wire         ip2usr_aermsg_cas,                 //                   .aermsg_cas
		output wire         ip2usr_aermsg_ucs,                 //                   .aermsg_ucs
		output wire         ip2usr_aermsg_ros,                 //                   .aermsg_ros
		output wire         ip2usr_aermsg_mts,                 //                   .aermsg_mts
		output wire         ip2usr_aermsg_uies,                //                   .aermsg_uies
		output wire         ip2usr_aermsg_mbts,                //                   .aermsg_mbts
		output wire         ip2usr_aermsg_aebs,                //                   .aermsg_aebs
		output wire         ip2usr_aermsg_tpbes,               //                   .aermsg_tpbes
		output wire         ip2usr_aermsg_ees,                 //                   .aermsg_ees
		output wire         ip2usr_aermsg_ures,                //                   .aermsg_ures
		output wire         ip2usr_aermsg_avs,                 //                   .aermsg_avs
		output wire         ip2usr_serr_out,                   //                   .serr_out
		output wire         ip2usr_debug_waitrequest,          //                   .dbg_waitreq
		output wire [31:0]  ip2usr_debug_readdata,             //                   .dbg_rddata
		output wire         ip2usr_debug_readdatavalid,        //                   .dbg_drvalid
		input  wire [31:0]  usr2ip_debug_writedata,            //                   .dbg_wrad
		input  wire [31:0]  usr2ip_debug_address,              //                   .dbg_add
		input  wire         usr2ip_debug_write,                //                   .dbg_wrt
		input  wire         usr2ip_debug_read,                 //                   .dbg_read
		input  wire [3:0]   usr2ip_debug_byteenable,           //                   .dbg_byten
		output wire         ip2hdm_aximm0_awvalid,             //      ip2hdm_aximm0.awvalid
		output wire [11:0]  ip2hdm_aximm0_awid,                //                   .awid
		output wire [51:0]  ip2hdm_aximm0_awaddr,              //                   .awaddr
		output wire [9:0]   ip2hdm_aximm0_awlen,               //                   .awlen
		output wire [3:0]   ip2hdm_aximm0_awregion,            //                   .awregion
		output wire         ip2hdm_aximm0_awuser,              //                   .awuser
		output wire [2:0]   ip2hdm_aximm0_awsize,              //                   .awsize
		output wire [1:0]   ip2hdm_aximm0_awburst,             //                   .awburst
		output wire [2:0]   ip2hdm_aximm0_awprot,              //                   .awport
		output wire [3:0]   ip2hdm_aximm0_awqos,               //                   .awqos
		output wire [3:0]   ip2hdm_aximm0_awcache,             //                   .awcache
		output wire [1:0]   ip2hdm_aximm0_awlock,              //                   .awlock
		input  wire         hdm2ip_aximm0_awready,             //                   .awready
		output wire         ip2hdm_aximm0_wvalid,              //                   .wvalid
		output wire [511:0] ip2hdm_aximm0_wdata,               //                   .wdata
		output wire [63:0]  ip2hdm_aximm0_wstrb,               //                   .wstrb
		output wire         ip2hdm_aximm0_wlast,               //                   .wlast
		output wire         ip2hdm_aximm0_wuser,               //                   .wuser
		input  wire         hdm2ip_aximm0_wready,              //                   .wready
		input  wire         hdm2ip_aximm0_bvalid,              //                   .bvlaid
		input  wire [11:0]  hdm2ip_aximm0_bid,                 //                   .bid
		input  wire         hdm2ip_aximm0_buser,               //                   .buser
		input  wire [1:0]   hdm2ip_aximm0_bresp,               //                   .brsp
		output wire         ip2hdm_aximm0_bready,              //                   .bready
		output wire         ip2hdm_aximm0_arvalid,             //                   .arvalid
		output wire [11:0]  ip2hdm_aximm0_arid,                //                   .arid
		output wire [51:0]  ip2hdm_aximm0_araddr,              //                   .araddr
		output wire [9:0]   ip2hdm_aximm0_arlen,               //                   .arlen
		output wire [3:0]   ip2hdm_aximm0_arregion,            //                   .arregion
		output wire         ip2hdm_aximm0_aruser,              //                   .aruser
		output wire [2:0]   ip2hdm_aximm0_arsize,              //                   .arsize
		output wire [1:0]   ip2hdm_aximm0_arburst,             //                   .arburst
		output wire [2:0]   ip2hdm_aximm0_arprot,              //                   .arport
		output wire [3:0]   ip2hdm_aximm0_arqos,               //                   .arqos
		output wire [3:0]   ip2hdm_aximm0_arcache,             //                   .arcache
		output wire [1:0]   ip2hdm_aximm0_arlock,              //                   .arlock
		input  wire         hdm2ip_aximm0_arready,             //                   .arready
		input  wire         hdm2ip_aximm0_rvalid,              //                   .rvalid
		input  wire         hdm2ip_aximm0_rlast,               //                   .rlast
		input  wire [11:0]  hdm2ip_aximm0_rid,                 //                   .rid
		input  wire [511:0] hdm2ip_aximm0_rdata,               //                   .rdata
		input  wire         hdm2ip_aximm0_ruser,               //                   .ruser
		input  wire [1:0]   hdm2ip_aximm0_rresp,               //                   .rresp
		output wire         ip2hdm_aximm0_rready,              //                   .rready
		output wire         ip2hdm_aximm1_awvalid,             //      ip2hdm_aximm1.awvalid
		output wire [11:0]  ip2hdm_aximm1_awid,                //                   .awid
		output wire [51:0]  ip2hdm_aximm1_awaddr,              //                   .awaddr
		output wire [9:0]   ip2hdm_aximm1_awlen,               //                   .awlen
		output wire [3:0]   ip2hdm_aximm1_awregion,            //                   .awregion
		output wire         ip2hdm_aximm1_awuser,              //                   .awuser
		output wire [2:0]   ip2hdm_aximm1_awsize,              //                   .awsize
		output wire [1:0]   ip2hdm_aximm1_awburst,             //                   .awburst
		output wire [2:0]   ip2hdm_aximm1_awprot,              //                   .awport
		output wire [3:0]   ip2hdm_aximm1_awqos,               //                   .awqos
		output wire [3:0]   ip2hdm_aximm1_awcache,             //                   .awcache
		output wire [1:0]   ip2hdm_aximm1_awlock,              //                   .awlock
		input  wire         hdm2ip_aximm1_awready,             //                   .awready
		output wire         ip2hdm_aximm1_wvalid,              //                   .wvalid
		output wire [511:0] ip2hdm_aximm1_wdata,               //                   .wdata
		output wire [63:0]  ip2hdm_aximm1_wstrb,               //                   .wstrb
		output wire         ip2hdm_aximm1_wlast,               //                   .wlast
		output wire         ip2hdm_aximm1_wuser,               //                   .wuser
		input  wire         hdm2ip_aximm1_wready,              //                   .wready
		input  wire         hdm2ip_aximm1_bvalid,              //                   .bvlaid
		input  wire [11:0]  hdm2ip_aximm1_bid,                 //                   .bid
		input  wire         hdm2ip_aximm1_buser,               //                   .buser
		input  wire [1:0]   hdm2ip_aximm1_bresp,               //                   .brsp
		output wire         ip2hdm_aximm1_bready,              //                   .bready
		output wire         ip2hdm_aximm1_arvalid,             //                   .arvalid
		output wire [11:0]  ip2hdm_aximm1_arid,                //                   .arid
		output wire [51:0]  ip2hdm_aximm1_araddr,              //                   .araddr
		output wire [9:0]   ip2hdm_aximm1_arlen,               //                   .arlen
		output wire [3:0]   ip2hdm_aximm1_arregion,            //                   .arregion
		output wire         ip2hdm_aximm1_aruser,              //                   .aruser
		output wire [2:0]   ip2hdm_aximm1_arsize,              //                   .arsize
		output wire [1:0]   ip2hdm_aximm1_arburst,             //                   .arburst
		output wire [2:0]   ip2hdm_aximm1_arprot,              //                   .arport
		output wire [3:0]   ip2hdm_aximm1_arqos,               //                   .arqos
		output wire [3:0]   ip2hdm_aximm1_arcache,             //                   .arcache
		output wire [1:0]   ip2hdm_aximm1_arlock,              //                   .arlock
		input  wire         hdm2ip_aximm1_arready,             //                   .arready
		input  wire         hdm2ip_aximm1_rvalid,              //                   .rvalid
		input  wire         hdm2ip_aximm1_rlast,               //                   .rlast
		input  wire [11:0]  hdm2ip_aximm1_rid,                 //                   .rid
		input  wire [511:0] hdm2ip_aximm1_rdata,               //                   .rdata
		input  wire         hdm2ip_aximm1_ruser,               //                   .ruser
		input  wire [1:0]   hdm2ip_aximm1_rresp,               //                   .rresp
		output wire         ip2hdm_aximm1_rready               //                   .rready
	);
endmodule

