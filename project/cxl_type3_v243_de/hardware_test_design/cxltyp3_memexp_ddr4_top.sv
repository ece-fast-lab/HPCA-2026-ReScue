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

`include "cxl_type3ddr_define.svh.iv"
import cxlip_top_pkg::*;
import intel_cxl_pio_parameters :: *;

//`ifdef QUARTUS_FPGA_SYNTH
`include "rnr_cxl_soft_ip_intf.svh.iv"
`include "rnr_ial_sip_intf.svh.iv"
//`endif


//module cxl_memexp_top (
module cxltyp3_memexp_ddr4_top (
  input                    refclk0,     // to RTile
  input                    refclk1,     // to RTile
  input                    refclk4,     // to Fabric PLL
  input                    resetn,

  //---------------------------
  // CXL-IP SPI interface
//  input                    spi_MISO,
//  output                   spi_MOSI,
//  output                   spi_SCLK,
//  output                   spi_SS_n,

  input             [15:0] cxl_rx_n,
  input             [15:0] cxl_rx_p,
  output            [15:0] cxl_tx_n,
  output            [15:0] cxl_tx_p,

`ifdef RTILE_PIPE_MODE
// CXL_SIM reduction Pipe Mode 
  output wire         phy_sys_ial_0__pipe_Reset_l,             //          phy_sys_ial_.0__pipe_Reset_l,       
  output wire         phy_sys_ial_1__pipe_Reset_l,             //                      .1__pipe_Reset_l,       
  output wire         phy_sys_ial_2__pipe_Reset_l,             //                      .2__pipe_Reset_l,       
  output wire         phy_sys_ial_3__pipe_Reset_l,             //                      .3__pipe_Reset_l,       
  output wire         phy_sys_ial_4__pipe_Reset_l,             //                      .4__pipe_Reset_l,       
  output wire         phy_sys_ial_5__pipe_Reset_l,             //                      .5__pipe_Reset_l,       
  output wire         phy_sys_ial_6__pipe_Reset_l,             //                      .6__pipe_Reset_l,       
  output wire         phy_sys_ial_7__pipe_Reset_l,             //                      .7__pipe_Reset_l,       
  output wire         phy_sys_ial_8__pipe_Reset_l,             //                      .8__pipe_Reset_l,       
  output wire         phy_sys_ial_9__pipe_Reset_l,             //                      .9__pipe_Reset_l,       
  output wire         phy_sys_ial_10__pipe_Reset_l,            //                      .10__pipe_Reset_l,      
  output wire         phy_sys_ial_11__pipe_Reset_l,            //                      .11__pipe_Reset_l,      
  output wire         phy_sys_ial_12__pipe_Reset_l,            //                      .12__pipe_Reset_l,      
  output wire         phy_sys_ial_13__pipe_Reset_l,            //                      .13__pipe_Reset_l,      
  output wire         phy_sys_ial_14__pipe_Reset_l,            //                      .14__pipe_Reset_l,      
  output wire         phy_sys_ial_15__pipe_Reset_l,            //                      .15__pipe_Reset_l,      
  output wire         o_phy_0_pipe_TxDataValid,                //         o_phy_0_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_0_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_0_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_0_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_0_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_0_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_0_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_0_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_0_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_0_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_0_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_0_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_0_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_0_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_0_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_0_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_0_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_0_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_0_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_0_pipe_RxClk,                      //         i_phy_0_pipe_.RxClk,                 
  input  wire         i_phy_0_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_0_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_0_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_0_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_0_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_0_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_0_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_0_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_0_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_1_pipe_TxDataValid,                //         o_phy_1_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_1_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_1_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_1_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_1_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_1_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_1_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_1_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_1_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_1_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_1_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_1_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_1_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_1_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_1_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_1_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_1_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_1_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_1_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_1_pipe_RxClk,                      //         i_phy_1_pipe_.RxClk,                 
  input  wire         i_phy_1_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_1_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_1_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_1_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_1_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_1_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_1_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_1_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_1_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_2_pipe_TxDataValid,                //         o_phy_2_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_2_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_2_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_2_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_2_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_2_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_2_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_2_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_2_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_2_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_2_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_2_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_2_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_2_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_2_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_2_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_2_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_2_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_2_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_2_pipe_RxClk,                      //         i_phy_2_pipe_.RxClk,                 
  input  wire         i_phy_2_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_2_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_2_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_2_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_2_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_2_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_2_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_2_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_2_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_3_pipe_TxDataValid,                //         o_phy_3_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_3_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_3_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_3_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_3_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_3_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_3_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_3_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_3_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_3_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_3_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_3_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_3_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_3_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_3_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_3_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_3_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_3_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_3_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_3_pipe_RxClk,                      //         i_phy_3_pipe_.RxClk,                 
  input  wire         i_phy_3_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_3_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_3_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_3_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_3_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_3_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_3_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_3_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_3_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_4_pipe_TxDataValid,                //         o_phy_4_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_4_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_4_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_4_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_4_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_4_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_4_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_4_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_4_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_4_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_4_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_4_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_4_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_4_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_4_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_4_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_4_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_4_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_4_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_4_pipe_RxClk,                      //         i_phy_4_pipe_.RxClk,                 
  input  wire         i_phy_4_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_4_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_4_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_4_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_4_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_4_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_4_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_4_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_4_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_5_pipe_TxDataValid,                //         o_phy_5_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_5_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_5_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_5_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_5_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_5_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_5_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_5_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_5_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_5_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_5_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_5_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_5_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_5_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_5_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_5_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_5_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_5_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_5_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_5_pipe_RxClk,                      //         i_phy_5_pipe_.RxClk,                 
  input  wire         i_phy_5_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_5_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_5_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_5_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_5_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_5_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_5_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_5_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_5_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_6_pipe_TxDataValid,                //         o_phy_6_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_6_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_6_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_6_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_6_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_6_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_6_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_6_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_6_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_6_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_6_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_6_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_6_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_6_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_6_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_6_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_6_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_6_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_6_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_6_pipe_RxClk,                      //         i_phy_6_pipe_.RxClk,                 
  input  wire         i_phy_6_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_6_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_6_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_6_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_6_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_6_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_6_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_6_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_6_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_7_pipe_TxDataValid,                //         o_phy_7_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_7_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_7_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_7_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_7_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_7_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_7_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_7_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_7_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_7_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_7_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_7_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_7_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_7_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_7_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_7_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_7_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_7_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_7_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_7_pipe_RxClk,                      //         i_phy_7_pipe_.RxClk,                 
  input  wire         i_phy_7_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_7_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_7_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_7_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_7_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_7_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_7_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_7_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_7_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_8_pipe_TxDataValid,                //         o_phy_8_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_8_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_8_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_8_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_8_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_8_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_8_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_8_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_8_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_8_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_8_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_8_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_8_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_8_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_8_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_8_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_8_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_8_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_8_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_8_pipe_RxClk,                      //         i_phy_8_pipe_.RxClk,                 
  input  wire         i_phy_8_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_8_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_8_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_8_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_8_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_8_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_8_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_8_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_8_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_9_pipe_TxDataValid,                //         o_phy_9_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_9_pipe_TxData,                     //                      .TxData,                
  output wire         o_phy_9_pipe_TxDetRxLpbk,                //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_9_pipe_TxElecIdle,                 //                      .TxElecIdle,            
  output wire [3:0]   o_phy_9_pipe_PowerDown,                  //                      .PowerDown,             
  output wire [2:0]   o_phy_9_pipe_Rate,                       //                      .Rate,                  
  output wire         o_phy_9_pipe_PclkChangeAck,              //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_9_pipe_PCLKRate,                   //                      .PCLKRate,              
  output wire [1:0]   o_phy_9_pipe_Width,                      //                      .Width,                 
  output wire         o_phy_9_pipe_PCLK,                       //                      .PCLK,                  
  output wire         o_phy_9_pipe_rxelecidle_disable,         //                      .rxelecidle_disable,    
  output wire         o_phy_9_pipe_txcmnmode_disable,          //                      .txcmnmode_disable,     
  output wire         o_phy_9_pipe_srisenable,                 //                      .srisenable,            
  output wire         o_phy_9_pipe_RxStandby,                  //                      .RxStandby,             
  output wire         o_phy_9_pipe_RxTermination,              //                      .RxTermination,         
  output wire [1:0]   o_phy_9_pipe_RxWidth,                    //                      .RxWidth,               
  output wire [7:0]   o_phy_9_pipe_M2P_MessageBus,             //                      .M2P_MessageBus,        
  output wire         o_phy_9_pipe_rxbitslip_req,              //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_9_pipe_rxbitslip_va,               //                      .rxbitslip_va,          
  input  wire         i_phy_9_pipe_RxClk,                      //         i_phy_9_pipe_.RxClk,                 
  input  wire         i_phy_9_pipe_RxValid,                    //                      .RxValid,               
  input  wire [39:0]  i_phy_9_pipe_RxData,                     //                      .RxData,                
  input  wire         i_phy_9_pipe_RxElecIdle,                 //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_9_pipe_RxStatus,                   //                      .RxStatus,              
  input  wire         i_phy_9_pipe_RxStandbyStatus,            //                      .RxStandbyStatus,       
  input  wire         i_phy_9_pipe_PhyStatus,                  //                      .PhyStatus,             
  input  wire         i_phy_9_pipe_PclkChangeOk,               //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_9_pipe_P2M_MessageBus,             //                      .P2M_MessageBus,        
  input  wire         i_phy_9_pipe_RxBitSlip_Ack,              //                      .RxBitSlip_Ack,         
  output wire         o_phy_10_pipe_TxDataValid,               //        o_phy_10_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_10_pipe_TxData,                    //                      .TxData,                
  output wire         o_phy_10_pipe_TxDetRxLpbk,               //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_10_pipe_TxElecIdle,                //                      .TxElecIdle,            
  output wire [3:0]   o_phy_10_pipe_PowerDown,                 //                      .PowerDown,             
  output wire [2:0]   o_phy_10_pipe_Rate,                      //                      .Rate,                  
  output wire         o_phy_10_pipe_PclkChangeAck,             //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_10_pipe_PCLKRate,                  //                      .PCLKRate,              
  output wire [1:0]   o_phy_10_pipe_Width,                     //                      .Width,                 
  output wire         o_phy_10_pipe_PCLK,                      //                      .PCLK,                  
  output wire         o_phy_10_pipe_rxelecidle_disable,        //                      .rxelecidle_disable,    
  output wire         o_phy_10_pipe_txcmnmode_disable,         //                      .txcmnmode_disable,     
  output wire         o_phy_10_pipe_srisenable,                //                      .srisenable,            
  output wire         o_phy_10_pipe_RxStandby,                 //                      .RxStandby,             
  output wire         o_phy_10_pipe_RxTermination,             //                      .RxTermination,         
  output wire [1:0]   o_phy_10_pipe_RxWidth,                   //                      .RxWidth,               
  output wire [7:0]   o_phy_10_pipe_M2P_MessageBus,            //                      .M2P_MessageBus,        
  output wire         o_phy_10_pipe_rxbitslip_req,             //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_10_pipe_rxbitslip_va,              //                      .rxbitslip_va,          
  input  wire         i_phy_10_pipe_RxClk,                     //        i_phy_10_pipe_.RxClk,                 
  input  wire         i_phy_10_pipe_RxValid,                   //                      .RxValid,               
  input  wire [39:0]  i_phy_10_pipe_RxData,                    //                      .RxData,                
  input  wire         i_phy_10_pipe_RxElecIdle,                //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_10_pipe_RxStatus,                  //                      .RxStatus,              
  input  wire         i_phy_10_pipe_RxStandbyStatus,           //                      .RxStandbyStatus,       
  input  wire         i_phy_10_pipe_PhyStatus,                 //                      .PhyStatus,             
  input  wire         i_phy_10_pipe_PclkChangeOk,              //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_10_pipe_P2M_MessageBus,            //                      .P2M_MessageBus,        
  input  wire         i_phy_10_pipe_RxBitSlip_Ack,             //                      .RxBitSlip_Ack,         
  output wire         o_phy_11_pipe_TxDataValid,               //        o_phy_11_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_11_pipe_TxData,                    //                      .TxData,                
  output wire         o_phy_11_pipe_TxDetRxLpbk,               //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_11_pipe_TxElecIdle,                //                      .TxElecIdle,            
  output wire [3:0]   o_phy_11_pipe_PowerDown,                 //                      .PowerDown,             
  output wire [2:0]   o_phy_11_pipe_Rate,                      //                      .Rate,                  
  output wire         o_phy_11_pipe_PclkChangeAck,             //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_11_pipe_PCLKRate,                  //                      .PCLKRate,              
  output wire [1:0]   o_phy_11_pipe_Width,                     //                      .Width,                 
  output wire         o_phy_11_pipe_PCLK,                      //                      .PCLK,                  
  output wire         o_phy_11_pipe_rxelecidle_disable,        //                      .rxelecidle_disable,    
  output wire         o_phy_11_pipe_txcmnmode_disable,         //                      .txcmnmode_disable,     
  output wire         o_phy_11_pipe_srisenable,                //                      .srisenable,            
  output wire         o_phy_11_pipe_RxStandby,                 //                      .RxStandby,             
  output wire         o_phy_11_pipe_RxTermination,             //                      .RxTermination,         
  output wire [1:0]   o_phy_11_pipe_RxWidth,                   //                      .RxWidth,               
  output wire [7:0]   o_phy_11_pipe_M2P_MessageBus,            //                      .M2P_MessageBus,        
  output wire         o_phy_11_pipe_rxbitslip_req,             //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_11_pipe_rxbitslip_va,              //                      .rxbitslip_va,          
  input  wire         i_phy_11_pipe_RxClk,                     //        i_phy_11_pipe_.RxClk,                 
  input  wire         i_phy_11_pipe_RxValid,                   //                      .RxValid,               
  input  wire [39:0]  i_phy_11_pipe_RxData,                    //                      .RxData,                
  input  wire         i_phy_11_pipe_RxElecIdle,                //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_11_pipe_RxStatus,                  //                      .RxStatus,              
  input  wire         i_phy_11_pipe_RxStandbyStatus,           //                      .RxStandbyStatus,       
  input  wire         i_phy_11_pipe_PhyStatus,                 //                      .PhyStatus,             
  input  wire         i_phy_11_pipe_PclkChangeOk,              //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_11_pipe_P2M_MessageBus,            //                      .P2M_MessageBus,        
  input  wire         i_phy_11_pipe_RxBitSlip_Ack,             //                      .RxBitSlip_Ack,         
  output wire         o_phy_12_pipe_TxDataValid,               //        o_phy_12_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_12_pipe_TxData,                    //                      .TxData,                
  output wire         o_phy_12_pipe_TxDetRxLpbk,               //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_12_pipe_TxElecIdle,                //                      .TxElecIdle,            
  output wire [3:0]   o_phy_12_pipe_PowerDown,                 //                      .PowerDown,             
  output wire [2:0]   o_phy_12_pipe_Rate,                      //                      .Rate,                  
  output wire         o_phy_12_pipe_PclkChangeAck,             //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_12_pipe_PCLKRate,                  //                      .PCLKRate,              
  output wire [1:0]   o_phy_12_pipe_Width,                     //                      .Width,                 
  output wire         o_phy_12_pipe_PCLK,                      //                      .PCLK,                  
  output wire         o_phy_12_pipe_rxelecidle_disable,        //                      .rxelecidle_disable,    
  output wire         o_phy_12_pipe_txcmnmode_disable,         //                      .txcmnmode_disable,     
  output wire         o_phy_12_pipe_srisenable,                //                      .srisenable,            
  output wire         o_phy_12_pipe_RxStandby,                 //                      .RxStandby,             
  output wire         o_phy_12_pipe_RxTermination,             //                      .RxTermination,         
  output wire [1:0]   o_phy_12_pipe_RxWidth,                   //                      .RxWidth,               
  output wire [7:0]   o_phy_12_pipe_M2P_MessageBus,            //                      .M2P_MessageBus,        
  output wire         o_phy_12_pipe_rxbitslip_req,             //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_12_pipe_rxbitslip_va,              //                      .rxbitslip_va,          
  input  wire         i_phy_12_pipe_RxClk,                     //        i_phy_12_pipe_.RxClk,                 
  input  wire         i_phy_12_pipe_RxValid,                   //                      .RxValid,               
  input  wire [39:0]  i_phy_12_pipe_RxData,                    //                      .RxData,                
  input  wire         i_phy_12_pipe_RxElecIdle,                //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_12_pipe_RxStatus,                  //                      .RxStatus,              
  input  wire         i_phy_12_pipe_RxStandbyStatus,           //                      .RxStandbyStatus,       
  input  wire         i_phy_12_pipe_PhyStatus,                 //                      .PhyStatus,             
  input  wire         i_phy_12_pipe_PclkChangeOk,              //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_12_pipe_P2M_MessageBus,            //                      .P2M_MessageBus,        
  input  wire         i_phy_12_pipe_RxBitSlip_Ack,             //                      .RxBitSlip_Ack,         
  output wire         o_phy_13_pipe_TxDataValid,               //        o_phy_13_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_13_pipe_TxData,                    //                      .TxData,                
  output wire         o_phy_13_pipe_TxDetRxLpbk,               //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_13_pipe_TxElecIdle,                //                      .TxElecIdle,            
  output wire [3:0]   o_phy_13_pipe_PowerDown,                 //                      .PowerDown,             
  output wire [2:0]   o_phy_13_pipe_Rate,                      //                      .Rate,                  
  output wire         o_phy_13_pipe_PclkChangeAck,             //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_13_pipe_PCLKRate,                  //                      .PCLKRate,              
  output wire [1:0]   o_phy_13_pipe_Width,                     //                      .Width,                 
  output wire         o_phy_13_pipe_PCLK,                      //                      .PCLK,                  
  output wire         o_phy_13_pipe_rxelecidle_disable,        //                      .rxelecidle_disable,    
  output wire         o_phy_13_pipe_txcmnmode_disable,         //                      .txcmnmode_disable,     
  output wire         o_phy_13_pipe_srisenable,                //                      .srisenable,            
  output wire         o_phy_13_pipe_RxStandby,                 //                      .RxStandby,             
  output wire         o_phy_13_pipe_RxTermination,             //                      .RxTermination,         
  output wire [1:0]   o_phy_13_pipe_RxWidth,                   //                      .RxWidth,               
  output wire [7:0]   o_phy_13_pipe_M2P_MessageBus,            //                      .M2P_MessageBus,        
  output wire         o_phy_13_pipe_rxbitslip_req,             //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_13_pipe_rxbitslip_va,              //                      .rxbitslip_va,          
  input  wire         i_phy_13_pipe_RxClk,                     //        i_phy_13_pipe_.RxClk,                 
  input  wire         i_phy_13_pipe_RxValid,                   //                      .RxValid,               
  input  wire [39:0]  i_phy_13_pipe_RxData,                    //                      .RxData,                
  input  wire         i_phy_13_pipe_RxElecIdle,                //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_13_pipe_RxStatus,                  //                      .RxStatus,              
  input  wire         i_phy_13_pipe_RxStandbyStatus,           //                      .RxStandbyStatus,       
  input  wire         i_phy_13_pipe_PhyStatus,                 //                      .PhyStatus,             
  input  wire         i_phy_13_pipe_PclkChangeOk,              //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_13_pipe_P2M_MessageBus,            //                      .P2M_MessageBus,        
  input  wire         i_phy_13_pipe_RxBitSlip_Ack,             //                      .RxBitSlip_Ack,         
  output wire         o_phy_14_pipe_TxDataValid,               //        o_phy_14_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_14_pipe_TxData,                    //                      .TxData,                
  output wire         o_phy_14_pipe_TxDetRxLpbk,               //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_14_pipe_TxElecIdle,                //                      .TxElecIdle,            
  output wire [3:0]   o_phy_14_pipe_PowerDown,                 //                      .PowerDown,             
  output wire [2:0]   o_phy_14_pipe_Rate,                      //                      .Rate,                  
  output wire         o_phy_14_pipe_PclkChangeAck,             //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_14_pipe_PCLKRate,                  //                      .PCLKRate,              
  output wire [1:0]   o_phy_14_pipe_Width,                     //                      .Width,                 
  output wire         o_phy_14_pipe_PCLK,                      //                      .PCLK,                  
  output wire         o_phy_14_pipe_rxelecidle_disable,        //                      .rxelecidle_disable,    
  output wire         o_phy_14_pipe_txcmnmode_disable,         //                      .txcmnmode_disable,     
  output wire         o_phy_14_pipe_srisenable,                //                      .srisenable,            
  output wire         o_phy_14_pipe_RxStandby,                 //                      .RxStandby,             
  output wire         o_phy_14_pipe_RxTermination,             //                      .RxTermination,         
  output wire [1:0]   o_phy_14_pipe_RxWidth,                   //                      .RxWidth,               
  output wire [7:0]   o_phy_14_pipe_M2P_MessageBus,            //                      .M2P_MessageBus,        
  output wire         o_phy_14_pipe_rxbitslip_req,             //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_14_pipe_rxbitslip_va,              //                      .rxbitslip_va,          
  input  wire         i_phy_14_pipe_RxClk,                     //        i_phy_14_pipe_.RxClk,                 
  input  wire         i_phy_14_pipe_RxValid,                   //                      .RxValid,               
  input  wire [39:0]  i_phy_14_pipe_RxData,                    //                      .RxData,                
  input  wire         i_phy_14_pipe_RxElecIdle,                //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_14_pipe_RxStatus,                  //                      .RxStatus,              
  input  wire         i_phy_14_pipe_RxStandbyStatus,           //                      .RxStandbyStatus,       
  input  wire         i_phy_14_pipe_PhyStatus,                 //                      .PhyStatus,             
  input  wire         i_phy_14_pipe_PclkChangeOk,              //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_14_pipe_P2M_MessageBus,            //                      .P2M_MessageBus,        
  input  wire         i_phy_14_pipe_RxBitSlip_Ack,             //                      .RxBitSlip_Ack,         
  output wire         o_phy_15_pipe_TxDataValid,               //        o_phy_15_pipe_.TxDataValid,           
  output wire [39:0]  o_phy_15_pipe_TxData,                    //                      .TxData,                
  output wire         o_phy_15_pipe_TxDetRxLpbk,               //                      .TxDetRxLpbk,           
  output wire [3:0]   o_phy_15_pipe_TxElecIdle,                //                      .TxElecIdle,            
  output wire [3:0]   o_phy_15_pipe_PowerDown,                 //                      .PowerDown,             
  output wire [2:0]   o_phy_15_pipe_Rate,                      //                      .Rate,                  
  output wire         o_phy_15_pipe_PclkChangeAck,             //                      .PclkChangeAck,         
  output wire [2:0]   o_phy_15_pipe_PCLKRate,                  //                      .PCLKRate,              
  output wire [1:0]   o_phy_15_pipe_Width,                     //                      .Width,                 
  output wire         o_phy_15_pipe_PCLK,                      //                      .PCLK,                  
  output wire         o_phy_15_pipe_rxelecidle_disable,        //                      .rxelecidle_disable,    
  output wire         o_phy_15_pipe_txcmnmode_disable,         //                      .txcmnmode_disable,     
  output wire         o_phy_15_pipe_srisenable,                //                      .srisenable,            
  output wire         o_phy_15_pipe_RxStandby,                 //                      .RxStandby,             
  output wire         o_phy_15_pipe_RxTermination,             //                      .RxTermination,         
  output wire [1:0]   o_phy_15_pipe_RxWidth,                   //                      .RxWidth,               
  output wire [7:0]   o_phy_15_pipe_M2P_MessageBus,            //                      .M2P_MessageBus,        
  output wire         o_phy_15_pipe_rxbitslip_req,             //                      .rxbitslip_req,         
  output wire [4:0]   o_phy_15_pipe_rxbitslip_va,              //                      .rxbitslip_va,          
  input  wire         i_phy_15_pipe_RxClk,                     //        i_phy_15_pipe_.RxClk,                 
  input  wire         i_phy_15_pipe_RxValid,                   //                      .RxValid,               
  input  wire [39:0]  i_phy_15_pipe_RxData,                    //                      .RxData,                
  input  wire         i_phy_15_pipe_RxElecIdle,                //                      .RxElecIdle,            
  input  wire [2:0]   i_phy_15_pipe_RxStatus,                  //                      .RxStatus,              
  input  wire         i_phy_15_pipe_RxStandbyStatus,           //                      .RxStandbyStatus,       
  input  wire         i_phy_15_pipe_PhyStatus,                 //                      .PhyStatus,             
  input  wire         i_phy_15_pipe_PclkChangeOk,              //                      .PclkChangeOk,          
  input  wire [7:0]   i_phy_15_pipe_P2M_MessageBus,            //                      .P2M_MessageBus,        
  input  wire         i_phy_15_pipe_RxBitSlip_Ack,             //                      .RxBitSlip_Ack,         
 
/* synthesis translate_on */
`endif
//-----------------------NOTE---------------------------------------
// DDR Memory Interface (2 Channel)
//------------------------------------------------------------------

  input  [1:0]        mem_refclk     ,            // EMIF PLL reference clock
  output [1:0][0:0]   mem_ck         ,  // DDR4 interface signals
  output [1:0][0:0]   mem_ck_n       ,  //
  output [1:0][16:0]  mem_a          ,  //
  output [1:0]        mem_act_n      ,             //
  output [1:0][1:0]   mem_ba         ,  //
  output [1:0][1:0]   mem_bg         ,  //
`ifdef HDM_64G
  output [1:0][1:0]   mem_cke        ,  //
  output [1:0][1:0]   mem_cs_n       ,  //
  output [1:0][1:0]   mem_odt        ,  //
`else
  output [1:0][0:0]   mem_cke        ,  //
  output [1:0][0:0]   mem_cs_n       ,  //
  output [1:0][0:0]   mem_odt        ,  //
`endif
  output [1:0]        mem_reset_n    ,           //
  output [1:0]        mem_par        ,               //
  input  [1:0]        mem_oct_rzqin  ,         //
  input  [1:0]        mem_alert_n    ,
`ifdef ENABLE_DDR_DBI_PINS              //Micron DIMM
  inout  [1:0][8:0]   mem_dqs        ,  //
  inout  [1:0][8:0]   mem_dqs_n      ,  //
  inout  [1:0][8:0]   mem_dbi_n      ,  //
`else
  inout  [1:0][17:0]  mem_dqs        ,  //
  inout  [1:0][17:0]  mem_dqs_n      ,  //
`endif  
  inout  [1:0][71:0]  mem_dq            //

);

  //-------------------------------------------------------
  // Signals & Settings                                  --
  //-------------------------------------------------------

 logic                        usr2ip_app_err_valid   ; 
 logic [31:0]                 usr2ip_app_err_hdr     ;
 logic [13:0]                 usr2ip_app_err_info    ;
 logic [2:0]                  usr2ip_app_err_func_num;
 logic                        ip2usr_app_err_ready   ;
     logic                        ip2usr_aermsg_correctable_valid ;
     logic                        ip2usr_aermsg_uncorrectable_valid;
     logic                        ip2usr_aermsg_res ;  
     logic                        ip2usr_aermsg_bts ;  
     logic                        ip2usr_aermsg_bds ;  
     logic                        ip2usr_aermsg_rrs ;  
     logic                        ip2usr_aermsg_rtts;  
     logic                        ip2usr_aermsg_anes;  
     logic                        ip2usr_aermsg_cies;  
     logic                        ip2usr_aermsg_hlos;  
     logic [1:0]                  ip2usr_aermsg_fmt ;  
     logic [4:0]                  ip2usr_aermsg_type;  
     logic [2:0]                  ip2usr_aermsg_tc  ;  
     logic                        ip2usr_aermsg_ido ;  
     logic                        ip2usr_aermsg_th  ;  
     logic                        ip2usr_aermsg_td  ;  
     logic                        ip2usr_aermsg_ep  ;  
     logic                        ip2usr_aermsg_ro  ;  
     logic                        ip2usr_aermsg_ns  ;  
     logic [1:0]                  ip2usr_aermsg_at  ;  
     logic [9:0]                  ip2usr_aermsg_length;
     logic [95:0]                 ip2usr_aermsg_header;
     logic                        ip2usr_aermsg_und;   
     logic                        ip2usr_aermsg_anf;   
     logic                        ip2usr_aermsg_dlpes; 
     logic                        ip2usr_aermsg_sdes;  
     logic [4:0]                  ip2usr_aermsg_fep;   
     logic                        ip2usr_aermsg_pts;   
     logic                        ip2usr_aermsg_fcpes; 
     logic                        ip2usr_aermsg_cts ;  
     logic                        ip2usr_aermsg_cas ;  
     logic                        ip2usr_aermsg_ucs ;  
     logic                        ip2usr_aermsg_ros ;  
     logic                        ip2usr_aermsg_mts ;  
     logic                        ip2usr_aermsg_uies;  
     logic                        ip2usr_aermsg_mbts;  
     logic                        ip2usr_aermsg_aebs;  
     logic                        ip2usr_aermsg_tpbes; 
     logic                        ip2usr_aermsg_ees;   
     logic                        ip2usr_aermsg_ures;  
     logic                        ip2usr_aermsg_avs ; 

     logic                        ip2usr_err_valid        ;
     logic [127:0]                ip2usr_err_hdr          ;
     logic [31:0]                 ip2usr_err_tlp_prefix   ;
     logic [13:0]                 ip2usr_err_info         ;


 logic                        ip2usr_serr_out        ;

 logic                              ip2usr_debug_waitrequest   ;
 logic [31:0]                       ip2usr_debug_readdata      ;
 logic                              ip2usr_debug_readdatavalid ;
 logic [31:0]                       usr2ip_debug_writedata     ;
 logic [31:0]                       usr2ip_debug_address       ;
 logic                              usr2ip_debug_write         ;
 logic                              usr2ip_debug_read          ;
 logic [3:0]                        usr2ip_debug_byteenable    ;

  logic                                             ip2hdm_reset_n;

  logic                                             pll_lock_o;

   // DDRMC <--> CXL-IP Slice
     logic [35:0]                                       hdm_size_256mb ; // Brought out to top from 22ww18a
      logic [63:0]                                      mc2ip_memsize;

//Channel-0
    
//      logic [63:0]                                      mc2ip_0_memsize;
	
      logic [cxlip_top_pkg::MC_SR_STAT_WIDTH-1:0]       mc2ip_0_sr_status                ;    
      //logic                                             mc2ip_0_rspfifo_full;
      //logic                                             mc2ip_0_rspfifo_empty;
      //logic [cxlip_top_pkg::RSPFIFO_DEPTH_WIDTH-1:0]    mc2ip_0_rspfifo_fill_level  ;
      logic                                             mc2ip_0_reqfifo_full;
  //    logic                                             mc2ip_0_reqfifo_empty;
      logic [cxlip_top_pkg::REQFIFO_DEPTH_WIDTH-1:0]    mc2ip_0_reqfifo_fill_level  ;
    
      logic                                             hdm2ip_avmm0_cxlmem_ready;	
      logic                                             hdm2ip_avmm0_ready;
      logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    hdm2ip_avmm0_readdata            ;
      logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         hdm2ip_avmm0_rsp_mdata           ;
      logic                                             hdm2ip_avmm0_read_poison;
      logic                                             hdm2ip_avmm0_readdatavalid;
 // Error Correction Code (ECC)
    // Note *ecc_err_* are valid when hdm2ip_avmm0_readdatavalid is active
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm0_ecc_err_corrected   ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm0_ecc_err_detected    ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm0_ecc_err_fatal       ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm0_ecc_err_syn_e       ;
      logic                                             hdm2ip_avmm0_ecc_err_valid;	
	
     logic                                             ip2hdm_avmm0_read;
     logic                                             ip2hdm_avmm0_write;
     logic                                             ip2hdm_avmm0_write_poison;
     logic                                             ip2hdm_avmm0_write_ras_sbe;    
     logic                                             ip2hdm_avmm0_write_ras_dbe;    
     logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    ip2hdm_avmm0_writedata           ;
     logic [cxlip_top_pkg::MC_HA_DP_BE_WIDTH-1:0]      ip2hdm_avmm0_byteenable          ;
       logic [(cxlip_top_pkg::CXLIP_FULL_ADDR_MSB):(cxlip_top_pkg::CXLIP_FULL_ADDR_LSB)]    ip2hdm_avmm0_address            ;  //added from 22ww18a
     logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         ip2hdm_avmm0_req_mdata           ;


//Channel 1
     logic [63:0]                                      mc2ip_1_memsize;
	
      logic [cxlip_top_pkg::MC_SR_STAT_WIDTH-1:0]       mc2ip_1_sr_status                ;    
      //logic                                             mc2ip_1_rspfifo_full;
      //logic                                             mc2ip_1_rspfifo_empty;
      //logic [cxlip_top_pkg::RSPFIFO_DEPTH_WIDTH-1:0]    mc2ip_1_rspfifo_fill_level  ;
      logic                                             mc2ip_1_reqfifo_full;
    //  logic                                             mc2ip_1_reqfifo_empty;
      logic [cxlip_top_pkg::REQFIFO_DEPTH_WIDTH-1:0]    mc2ip_1_reqfifo_fill_level  ;
    
      logic                                             hdm2ip_avmm1_cxlmem_ready;	
      logic                                             hdm2ip_avmm1_ready;
      logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    hdm2ip_avmm1_readdata            ;
      logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         hdm2ip_avmm1_rsp_mdata           ;
      logic                                             hdm2ip_avmm1_read_poison;
      logic                                             hdm2ip_avmm1_readdatavalid;
 // Error Correction Code (ECC)
    // Note *ecc_err_* are valid when hdm2ip_avmm1_readdatavalid is active
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm1_ecc_err_corrected   ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm1_ecc_err_detected    ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm1_ecc_err_fatal       ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm1_ecc_err_syn_e       ;
      logic                                             hdm2ip_avmm1_ecc_err_valid;	
	
     logic                                             ip2hdm_avmm1_read;
     logic                                             ip2hdm_avmm1_write;
     logic                                             ip2hdm_avmm1_write_poison;
     logic                                             ip2hdm_avmm1_write_ras_sbe;    
     logic                                             ip2hdm_avmm1_write_ras_dbe;    
     logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    ip2hdm_avmm1_writedata           ;
     logic [cxlip_top_pkg::MC_HA_DP_BE_WIDTH-1:0]      ip2hdm_avmm1_byteenable          ;
       logic [(cxlip_top_pkg::CXLIP_FULL_ADDR_MSB):(cxlip_top_pkg::CXLIP_FULL_ADDR_LSB)]    ip2hdm_avmm1_address            ;  //added from 22ww18a
     logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         ip2hdm_avmm1_req_mdata           ;
	
//Channel 2
    
      logic [63:0]                                      mc2ip_2_memsize;
	
      logic [cxlip_top_pkg::MC_SR_STAT_WIDTH-1:0]       mc2ip_2_sr_status                ;    
      //logic                                             mc2ip_2_rspfifo_full;
      //logic                                             mc2ip_2_rspfifo_empty;
      //logic [cxlip_top_pkg::RSPFIFO_DEPTH_WIDTH-1:0]    mc2ip_2_rspfifo_fill_level  ;
      logic                                             mc2ip_2_reqfifo_full;
     // logic                                             mc2ip_2_reqfifo_empty;
      logic [cxlip_top_pkg::REQFIFO_DEPTH_WIDTH-1:0]    mc2ip_2_reqfifo_fill_level  ;
    
      logic                                             hdm2ip_avmm2_cxlmem_ready;	
      logic                                             hdm2ip_avmm2_ready;
      logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    hdm2ip_avmm2_readdata            ;
      logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         hdm2ip_avmm2_rsp_mdata           ;
      logic                                             hdm2ip_avmm2_read_poison;
      logic                                             hdm2ip_avmm2_readdatavalid;
 // Error Correction Code (ECC)
    // Note *ecc_err_* are valid when hdm2ip_avmm2_readdatavalid is active
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm2_ecc_err_corrected   ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm2_ecc_err_detected    ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm2_ecc_err_fatal       ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm2_ecc_err_syn_e       ;
      logic                                             hdm2ip_avmm2_ecc_err_valid;	
	
     logic                                             ip2hdm_avmm2_read;
     logic                                             ip2hdm_avmm2_write;
     logic                                             ip2hdm_avmm2_write_poison;
     logic                                             ip2hdm_avmm2_write_ras_sbe;    
     logic                                             ip2hdm_avmm2_write_ras_dbe;    
     logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    ip2hdm_avmm2_writedata           ;
     logic [cxlip_top_pkg::MC_HA_DP_BE_WIDTH-1:0]      ip2hdm_avmm2_byteenable          ;
       logic [(cxlip_top_pkg::CXLIP_FULL_ADDR_MSB):(cxlip_top_pkg::CXLIP_FULL_ADDR_LSB)]    ip2hdm_avmm2_address            ;  //added from 22ww18a
     logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         ip2hdm_avmm2_req_mdata           ;

//Channel 3
      logic [63:0]                                      mc2ip_3_memsize;
	
      logic [cxlip_top_pkg::MC_SR_STAT_WIDTH-1:0]       mc2ip_3_sr_status                ;    
      //logic                                             mc2ip_3_rspfifo_full;
      //logic                                             mc2ip_3_rspfifo_empty;
      //logic [cxlip_top_pkg::RSPFIFO_DEPTH_WIDTH-1:0]    mc2ip_3_rspfifo_fill_level  ;
      logic                                             mc2ip_3_reqfifo_full;
   //   logic                                             mc2ip_3_reqfifo_empty;
      logic [cxlip_top_pkg::REQFIFO_DEPTH_WIDTH-1:0]    mc2ip_3_reqfifo_fill_level  ;
    
      logic                                             hdm2ip_avmm3_cxlmem_ready;	
      logic                                             hdm2ip_avmm3_ready;
      logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    hdm2ip_avmm3_readdata            ;
      logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         hdm2ip_avmm3_rsp_mdata           ;
      logic                                             hdm2ip_avmm3_read_poison;
      logic                                             hdm2ip_avmm3_readdatavalid;
 // Error Correction Code (ECC)
    // Note *ecc_err_* are valid when hdm2ip_avmm3_readdatavalid is active
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm3_ecc_err_corrected   ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm3_ecc_err_detected    ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm3_ecc_err_fatal       ;
      logic [cxlip_top_pkg::ALTECC_INST_NUMBER-1:0]     hdm2ip_avmm3_ecc_err_syn_e       ;
      logic                                             hdm2ip_avmm3_ecc_err_valid;	
	
     logic                                             ip2hdm_avmm3_read;
     logic                                             ip2hdm_avmm3_write;
     logic                                             ip2hdm_avmm3_write_poison;
     logic                                             ip2hdm_avmm3_write_ras_sbe;    
     logic                                             ip2hdm_avmm3_write_ras_dbe;    
     logic [cxlip_top_pkg::MC_HA_DP_DATA_WIDTH-1:0]    ip2hdm_avmm3_writedata           ;
     logic [cxlip_top_pkg::MC_HA_DP_BE_WIDTH-1:0]      ip2hdm_avmm3_byteenable          ;
     logic [(cxlip_top_pkg::CXLIP_FULL_ADDR_MSB):(cxlip_top_pkg::CXLIP_FULL_ADDR_LSB)]    ip2hdm_avmm3_address            ;  //added from 22ww18a
     logic [cxlip_top_pkg::MC_MDATA_WIDTH-1:0]         ip2hdm_avmm3_req_mdata           ;
     logic                                              ip2hdm_clk;

     //// ---- MC axi MM

//Channel-0
     /* write address channel
      */
   logic          ip2hdm_aximm0_awvalid    ;       
   logic  [7:0]   ip2hdm_aximm0_awid       ;       
   logic  [51:0]  ip2hdm_aximm0_awaddr     ;       
   logic  [9:0]   ip2hdm_aximm0_awlen      ;       
   logic  [3:0]   ip2hdm_aximm0_awregion   ;       
   logic          ip2hdm_aximm0_awuser     ;       
   logic  [2:0]   ip2hdm_aximm0_awsize     ;      
   logic  [1:0]   ip2hdm_aximm0_awburst    ;      
   logic  [2:0]   ip2hdm_aximm0_awprot     ;      
   logic  [3:0]   ip2hdm_aximm0_awqos      ;      
   logic  [3:0]   ip2hdm_aximm0_awcache    ;      
   logic  [1:0]   ip2hdm_aximm0_awlock     ;      
   logic          hdm2ip_aximm0_awready    ;
     /* write data channel
      */
   logic          ip2hdm_aximm0_wvalid     ;          
   logic  [511:0] ip2hdm_aximm0_wdata      ;           
   logic  [63:0]  ip2hdm_aximm0_wstrb      ;           
   logic          ip2hdm_aximm0_wlast      ;           
   logic          ip2hdm_aximm0_wuser      ;           
   logic           hdm2ip_aximm0_wready  	 ;
     /* write response channel
      */
    logic          hdm2ip_aximm0_bvalid     ;
    logic [7:0]    hdm2ip_aximm0_bid        ;
    logic          hdm2ip_aximm0_buser      ;
    logic [1:0]    hdm2ip_aximm0_bresp      ;
   logic          ip2hdm_aximm0_bready     ;               
     /* read address channel
      */
   logic          ip2hdm_aximm0_arvalid    ;         
   logic  [7:0]   ip2hdm_aximm0_arid       ;         
   logic  [51:0]  ip2hdm_aximm0_araddr     ;         
   logic  [9:0]   ip2hdm_aximm0_arlen      ;         
   logic  [3:0]   ip2hdm_aximm0_arregion   ;         
   logic          ip2hdm_aximm0_aruser     ;         
   logic  [2:0]   ip2hdm_aximm0_arsize     ;         
   logic  [1:0]   ip2hdm_aximm0_arburst    ;         
   logic  [2:0]   ip2hdm_aximm0_arprot     ;         
   logic  [3:0]   ip2hdm_aximm0_arqos      ;         
   logic  [3:0]   ip2hdm_aximm0_arcache    ;         
   logic  [1:0]   ip2hdm_aximm0_arlock     ;         
   logic          hdm2ip_aximm0_arready    ; 
     /* read response channel
      */
    logic          hdm2ip_aximm0_rvalid  ; 
    logic          hdm2ip_aximm0_rlast  ;
    logic  [7:0]   hdm2ip_aximm0_rid        ;
    logic  [511:0] hdm2ip_aximm0_rdata      ;
    logic          hdm2ip_aximm0_ruser      ;
    logic  [1:0]   hdm2ip_aximm0_rresp      ;
   logic          ip2hdm_aximm0_rready     ;   



     /* write address channel
      */
   logic          ip2hdm_aximm1_awvalid    ;       
   logic  [7:0]   ip2hdm_aximm1_awid       ;       
   logic  [51:0]  ip2hdm_aximm1_awaddr     ;       
   logic  [9:0]   ip2hdm_aximm1_awlen      ;       
   logic  [3:0]   ip2hdm_aximm1_awregion   ;       
   logic          ip2hdm_aximm1_awuser     ;       
   logic  [2:0]   ip2hdm_aximm1_awsize     ;      
   logic  [1:0]   ip2hdm_aximm1_awburst    ;      
   logic  [2:0]   ip2hdm_aximm1_awprot     ;      
   logic  [3:0]   ip2hdm_aximm1_awqos      ;      
   logic  [3:0]   ip2hdm_aximm1_awcache    ;      
   logic  [1:0]   ip2hdm_aximm1_awlock     ;      
    logic          hdm2ip_aximm1_awready    ;
     /* write data channel
      */
   logic          ip2hdm_aximm1_wvalid     ;          
   logic  [511:0] ip2hdm_aximm1_wdata      ;           
   logic  [63:0]  ip2hdm_aximm1_wstrb      ;           
   logic          ip2hdm_aximm1_wlast      ;           
   logic          ip2hdm_aximm1_wuser      ;           
   logic           hdm2ip_aximm1_wready  	 ;
     /* write response channel
      */
    logic          hdm2ip_aximm1_bvalid     ;
    logic [7:0]    hdm2ip_aximm1_bid        ;
    logic          hdm2ip_aximm1_buser      ;
    logic [1:0]    hdm2ip_aximm1_bresp      ;
   logic          ip2hdm_aximm1_bready     ;               
     /* read address channel
      */
   logic          ip2hdm_aximm1_arvalid    ;         
   logic  [7:0]   ip2hdm_aximm1_arid       ;         
   logic  [51:0]  ip2hdm_aximm1_araddr     ;         
   logic  [9:0]   ip2hdm_aximm1_arlen      ;         
   logic  [3:0]   ip2hdm_aximm1_arregion   ;         
   logic          ip2hdm_aximm1_aruser     ;         
   logic  [2:0]   ip2hdm_aximm1_arsize     ;         
   logic  [1:0]   ip2hdm_aximm1_arburst    ;         
   logic  [2:0]   ip2hdm_aximm1_arprot     ;         
   logic  [3:0]   ip2hdm_aximm1_arqos      ;         
   logic  [3:0]   ip2hdm_aximm1_arcache    ;         
   logic  [1:0]   ip2hdm_aximm1_arlock     ;         
   logic          hdm2ip_aximm1_arready    ; 
     /* read response channel
      */
    logic          hdm2ip_aximm1_rvalid ; 
    logic          hdm2ip_aximm1_rlast ;
    logic  [7:0]   hdm2ip_aximm1_rid        ;
    logic  [511:0] hdm2ip_aximm1_rdata      ;
    logic          hdm2ip_aximm1_ruser      ;
    logic  [1:0]   hdm2ip_aximm1_rresp      ;
   logic           ip2hdm_aximm1_rready     ;   
  
     /* write address channel
      */
   logic          ip2hdm_aximm2_awvalid    ;       
   logic  [7:0]   ip2hdm_aximm2_awid       ;       
   logic  [51:0]  ip2hdm_aximm2_awaddr     ;       
   logic  [9:0]   ip2hdm_aximm2_awlen      ;       
   logic  [3:0]   ip2hdm_aximm2_awregion   ;       
   logic          ip2hdm_aximm2_awuser     ;       
   logic  [2:0]   ip2hdm_aximm2_awsize     ;      
   logic  [1:0]   ip2hdm_aximm2_awburst    ;      
   logic  [2:0]   ip2hdm_aximm2_awprot     ;      
   logic  [3:0]   ip2hdm_aximm2_awqos      ;      
   logic  [3:0]   ip2hdm_aximm2_awcache    ;      
   logic  [1:0]   ip2hdm_aximm2_awlock     ;      
    logic          hdm2ip_aximm2_awready    ;
     /* write data channel
      */
   logic          ip2hdm_aximm2_wvalid     ;          
   logic  [511:0] ip2hdm_aximm2_wdata      ;           
   logic  [63:0]  ip2hdm_aximm2_wstrb      ;           
   logic          ip2hdm_aximm2_wlast      ;           
   logic          ip2hdm_aximm2_wuser      ;           
   logic           hdm2ip_aximm2_wready  	 ;
     /* write response channel
      */
    logic          hdm2ip_aximm2_bvalid     ;
    logic [7:0]    hdm2ip_aximm2_bid        ;
    logic          hdm2ip_aximm2_buser      ;
    logic [1:0]    hdm2ip_aximm2_bresp      ;
   logic          ip2hdm_aximm2_bready     ;               
     /* read address channel
      */
   logic          ip2hdm_aximm2_arvalid    ;         
   logic  [7:0]   ip2hdm_aximm2_arid       ;         
   logic  [51:0]  ip2hdm_aximm2_araddr     ;         
   logic  [9:0]   ip2hdm_aximm2_arlen      ;         
   logic  [3:0]   ip2hdm_aximm2_arregion   ;         
   logic          ip2hdm_aximm2_aruser     ;         
   logic  [2:0]   ip2hdm_aximm2_arsize     ;         
   logic  [1:0]   ip2hdm_aximm2_arburst    ;         
   logic  [2:0]   ip2hdm_aximm2_arprot     ;         
   logic  [3:0]   ip2hdm_aximm2_arqos      ;         
   logic  [3:0]   ip2hdm_aximm2_arcache    ;         
   logic  [1:0]   ip2hdm_aximm2_arlock     ;         
   logic          hdm2ip_aximm2_arready    ; 
     /* read response channel
      */
    logic          hdm2ip_aximm2_rvalid ; 
    logic          hdm2ip_aximm2_rlast ;
    logic  [7:0]   hdm2ip_aximm2_rid        ;
    logic  [511:0] hdm2ip_aximm2_rdata      ;
    logic          hdm2ip_aximm2_ruser      ;
    logic  [1:0]   hdm2ip_aximm2_rresp      ;
   logic          ip2hdm_aximm2_rready     ; 
  

     /* write address channel
      */
   logic          ip2hdm_aximm3_awvalid    ;       
   logic  [7:0]   ip2hdm_aximm3_awid       ;       
   logic  [51:0]  ip2hdm_aximm3_awaddr     ;       
   logic  [9:0]   ip2hdm_aximm3_awlen      ;       
   logic  [3:0]   ip2hdm_aximm3_awregion   ;       
   logic          ip2hdm_aximm3_awuser     ;       
   logic  [2:0]   ip2hdm_aximm3_awsize     ;      
   logic  [1:0]   ip2hdm_aximm3_awburst    ;      
   logic  [2:0]   ip2hdm_aximm3_awprot     ;      
   logic  [3:0]   ip2hdm_aximm3_awqos      ;      
   logic  [3:0]   ip2hdm_aximm3_awcache    ;      
   logic  [1:0]   ip2hdm_aximm3_awlock     ;      
    logic          hdm2ip_aximm3_awready    ;
     /* write data channel
      */
   logic          ip2hdm_aximm3_wvalid     ;          
   logic  [511:0] ip2hdm_aximm3_wdata      ;           
   logic  [63:0]  ip2hdm_aximm3_wstrb      ;           
   logic          ip2hdm_aximm3_wlast      ;           
   logic          ip2hdm_aximm3_wuser      ;           
   logic           hdm2ip_aximm3_wready  	 ;
     /* write response channel
      */
    logic          hdm2ip_aximm3_bvalid     ;
    logic [7:0]    hdm2ip_aximm3_bid        ;
    logic          hdm2ip_aximm3_buser      ;
    logic [1:0]    hdm2ip_aximm3_bresp      ;
   logic          ip2hdm_aximm3_bready     ;               
     /* read address channel
      */
   logic          ip2hdm_aximm3_arvalid    ;         
   logic  [7:0]   ip2hdm_aximm3_arid       ;         
   logic  [51:0]  ip2hdm_aximm3_araddr     ;         
   logic  [9:0]   ip2hdm_aximm3_arlen      ;         
   logic  [3:0]   ip2hdm_aximm3_arregion   ;         
   logic          ip2hdm_aximm3_aruser     ;         
   logic  [2:0]   ip2hdm_aximm3_arsize     ;         
   logic  [1:0]   ip2hdm_aximm3_arburst    ;         
   logic  [2:0]   ip2hdm_aximm3_arprot     ;         
   logic  [3:0]   ip2hdm_aximm3_arqos      ;         
   logic  [3:0]   ip2hdm_aximm3_arcache    ;         
   logic  [1:0]   ip2hdm_aximm3_arlock     ;         
   logic          hdm2ip_aximm3_arready    ; 
     /* read response channel
      */
    logic          hdm2ip_aximm3_rvalid ; 
    logic          hdm2ip_aximm3_rlast ;
    logic  [7:0]   hdm2ip_aximm3_rid        ;
    logic  [511:0] hdm2ip_aximm3_rdata      ;
    logic          hdm2ip_aximm3_ruser      ;
    logic  [1:0]   hdm2ip_aximm3_rresp      ;
   logic          ip2hdm_aximm3_rready     ;   

//--------------------------


  logic                              ip2csr_avmm_clk;
  logic                              ip2csr_avmm_rstn;  
  logic                              csr2ip_avmm_waitrequest;            
  logic [63:0]                       csr2ip_avmm_readdata;               
  logic                              csr2ip_avmm_readdatavalid;          
  logic [63:0]                       ip2csr_avmm_writedata;              
  logic                             ip2csr_avmm_poison;
  logic [21:0]                       ip2csr_avmm_address;                
  logic                              ip2csr_avmm_write;                  
  logic                              ip2csr_avmm_read;                   
  logic [7:0]                        ip2csr_avmm_byteenable;


  // IO - User AVST interface
    logic                             ip2uio_tx_ready;      //TBD
     logic                            uio2ip_tx_st0_dvalid;
     logic                            uio2ip_tx_st0_sop;
     logic                            uio2ip_tx_st0_eop;
     logic                            uio2ip_tx_st0_passthrough;
     logic [(CXL_IO_DWIDTH-1):0]      uio2ip_tx_st0_data;
     logic [((CXL_IO_DWIDTH/32)-1):0] uio2ip_tx_st0_data_parity;
     logic [127:0]                    uio2ip_tx_st0_hdr;
     logic [3:0]                      uio2ip_tx_st0_hdr_parity;
     logic                            uio2ip_tx_st0_hvalid;
     logic [(CXL_IO_PWIDTH-1):0]      uio2ip_tx_st0_prefix;
     logic [((CXL_IO_PWIDTH/32)-1):0] uio2ip_tx_st0_prefix_parity;
     logic [11:0]                     uio2ip_tx_st0_RSSAI_prefix;
     logic                            uio2ip_tx_st0_RSSAI_prefix_parity;
     logic                            uio2ip_tx_st0_pvalid;
     logic                            uio2ip_tx_st0_vfactive;
     logic [10:0]                     uio2ip_tx_st0_vfnum ;
     logic [2:0]                      uio2ip_tx_st0_pfnum;
     logic [(CXL_IO_CHWIDTH-1):0]     uio2ip_tx_st0_chnum;
     logic [2:0]                      uio2ip_tx_st0_empty;  // [log2(CXL_IO_DWIDTH/32)-1:0]
     logic                            uio2ip_tx_st0_misc_parity;

     logic                            uio2ip_tx_st1_dvalid;
     logic                            uio2ip_tx_st1_sop;
     logic                            uio2ip_tx_st1_eop;
     logic                            uio2ip_tx_st1_passthrough;
     logic [(CXL_IO_DWIDTH-1):0]      uio2ip_tx_st1_data;
     logic [((CXL_IO_DWIDTH/32)-1):0] uio2ip_tx_st1_data_parity;
     logic [127:0]                    uio2ip_tx_st1_hdr;
     logic [3:0]                      uio2ip_tx_st1_hdr_parity;
     logic                            uio2ip_tx_st1_hvalid;
     logic [(CXL_IO_PWIDTH-1):0]      uio2ip_tx_st1_prefix;
     logic [((CXL_IO_PWIDTH/32)-1):0] uio2ip_tx_st1_prefix_parity;
     logic [11:0]                     uio2ip_tx_st1_RSSAI_prefix;
     logic                            uio2ip_tx_st1_RSSAI_prefix_parity;
     logic                            uio2ip_tx_st1_pvalid;
     logic                            uio2ip_tx_st1_vfactive;
     logic [10:0]                     uio2ip_tx_st1_vfnum ;
     logic [2:0]                      uio2ip_tx_st1_pfnum;
     logic [(CXL_IO_CHWIDTH-1):0]     uio2ip_tx_st1_chnum;
     logic [2:0]                      uio2ip_tx_st1_empty; 
     logic                            uio2ip_tx_st1_misc_parity;

     logic                            uio2ip_tx_st2_dvalid;
     logic                            uio2ip_tx_st2_sop;
     logic                            uio2ip_tx_st2_eop;
     logic                            uio2ip_tx_st2_passthrough;
     logic [(CXL_IO_DWIDTH-1):0]      uio2ip_tx_st2_data;
     logic [((CXL_IO_DWIDTH/32)-1):0] uio2ip_tx_st2_data_parity;
     logic [127:0]                    uio2ip_tx_st2_hdr;
     logic [3:0]                      uio2ip_tx_st2_hdr_parity;
     logic                            uio2ip_tx_st2_hvalid;
     logic [(CXL_IO_PWIDTH-1):0]      uio2ip_tx_st2_prefix;
     logic [((CXL_IO_PWIDTH/32)-1):0] uio2ip_tx_st2_prefix_parity;
     logic [11:0]                     uio2ip_tx_st2_RSSAI_prefix;
     logic                            uio2ip_tx_st2_RSSAI_prefix_parity;
     logic                            uio2ip_tx_st2_pvalid;
     logic                            uio2ip_tx_st2_vfactive;
     logic [10:0]                     uio2ip_tx_st2_vfnum ;
     logic [2:0]                      uio2ip_tx_st2_pfnum;
     logic [(CXL_IO_CHWIDTH-1):0]     uio2ip_tx_st2_chnum;
     logic [2:0]                      uio2ip_tx_st2_empty;  
     logic                            uio2ip_tx_st2_misc_parity;

     logic                            uio2ip_tx_st3_dvalid;
     logic                            uio2ip_tx_st3_sop;
     logic                            uio2ip_tx_st3_eop;
     logic                            uio2ip_tx_st3_passthrough;
     logic [(CXL_IO_DWIDTH-1):0]      uio2ip_tx_st3_data;
     logic [((CXL_IO_DWIDTH/32)-1):0] uio2ip_tx_st3_data_parity;
     logic [127:0]                    uio2ip_tx_st3_hdr;
     logic [3:0]                      uio2ip_tx_st3_hdr_parity;
     logic                            uio2ip_tx_st3_hvalid;
     logic [(CXL_IO_PWIDTH-1):0]      uio2ip_tx_st3_prefix;
     logic [((CXL_IO_PWIDTH/32)-1):0] uio2ip_tx_st3_prefix_parity;
     logic [11:0]                     uio2ip_tx_st3_RSSAI_prefix;
     logic                            uio2ip_tx_st3_RSSAI_prefix_parity;
     logic                            uio2ip_tx_st3_pvalid;
     logic                            uio2ip_tx_st3_vfactive;
     logic [10:0]                     uio2ip_tx_st3_vfnum ;
     logic [2:0]                      uio2ip_tx_st3_pfnum;
     logic [(CXL_IO_CHWIDTH-1):0]     uio2ip_tx_st3_chnum;
     logic [2:0]                      uio2ip_tx_st3_empty;  
     logic                            uio2ip_tx_st3_misc_parity;

//TBD 
    logic [2:0]                      ip2uio_tx_st_Hcrdt_update;
    //logic [(CXL_IO_CHWIDTH-1):0]     ip2uio_tx_st_Hcrdt_ch;
    logic [5:0]                      ip2uio_tx_st_Hcrdt_update_cnt;
    logic [2:0]                      ip2uio_tx_st_Hcrdt_init;
     logic [2:0]                     uio2ip_tx_st_Hcrdt_init_ack;
    logic [2:0]                      ip2uio_tx_st_Dcrdt_update;
    //logic [(CXL_IO_CHWIDTH-1):0]     ip2uio_tx_st_Dcrdt_ch;
    logic [11:0]                     ip2uio_tx_st_Dcrdt_update_cnt;
    logic [2:0]                      ip2uio_tx_st_Dcrdt_init ;
     logic [2:0]                      uio2ip_tx_st_Dcrdt_init_ack;
  
   logic                             ip2uio_rx_st0_dvalid;
   logic                             ip2uio_rx_st0_sop;
   logic                             ip2uio_rx_st0_eop;
   logic                             ip2uio_rx_st0_passthrough;
   logic  [(CXL_IO_DWIDTH-1):0]      ip2uio_rx_st0_data;
   logic  [((CXL_IO_DWIDTH/32)-1):0] ip2uio_rx_st0_data_parity;
   logic  [127:0]                    ip2uio_rx_st0_hdr;
   logic  [3:0]                      ip2uio_rx_st0_hdr_parity;
   logic                             ip2uio_rx_st0_hvalid;
   logic  [(CXL_IO_PWIDTH-1):0]      ip2uio_rx_st0_prefix;
   logic  [((CXL_IO_PWIDTH/32)-1):0] ip2uio_rx_st0_prefix_parity;
   logic  [11:0]                     ip2uio_rx_st0_RSSAI_prefix;
   logic                             ip2uio_rx_st0_RSSAI_prefix_parity;
   logic                             ip2uio_rx_st0_pvalid;
   logic  [2:0]                      ip2uio_rx_st0_bar;
   logic                             ip2uio_rx_st0_vfactive;
   logic  [10:0]                     ip2uio_rx_st0_vfnum;
   logic  [2:0]                      ip2uio_rx_st0_pfnum;
   logic  [(CXL_IO_CHWIDTH-1):0]     ip2uio_rx_st0_chnum;
   logic                             ip2uio_rx_st0_misc_parity;
   logic  [2:0]                      ip2uio_rx_st0_empty;  

   logic                             ip2uio_rx_st1_dvalid;
   logic                             ip2uio_rx_st1_sop;
   logic                             ip2uio_rx_st1_eop;
   logic                             ip2uio_rx_st1_passthrough;
   logic  [(CXL_IO_DWIDTH-1):0]      ip2uio_rx_st1_data;
   logic  [((CXL_IO_DWIDTH/32)-1):0] ip2uio_rx_st1_data_parity;
   logic  [127:0]                    ip2uio_rx_st1_hdr;
   logic  [3:0]                      ip2uio_rx_st1_hdr_parity;
   logic                             ip2uio_rx_st1_hvalid;
   logic  [(CXL_IO_PWIDTH-1):0]      ip2uio_rx_st1_prefix;
   logic  [((CXL_IO_PWIDTH/32)-1):0] ip2uio_rx_st1_prefix_parity;
   logic  [11:0]                     ip2uio_rx_st1_RSSAI_prefix;
   logic                             ip2uio_rx_st1_RSSAI_prefix_parity;
   logic                             ip2uio_rx_st1_pvalid;
   logic  [2:0]                      ip2uio_rx_st1_bar;
   logic                             ip2uio_rx_st1_vfactive;
   logic  [10:0]                     ip2uio_rx_st1_vfnum;
   logic  [2:0]                      ip2uio_rx_st1_pfnum;
   logic  [(CXL_IO_CHWIDTH-1):0]     ip2uio_rx_st1_chnum;
   logic                             ip2uio_rx_st1_misc_parity;
   logic  [2:0]                      ip2uio_rx_st1_empty;  // [log2(CXL_IO_DWIDTH/32)-1:0]
  
   logic                             ip2uio_rx_st2_dvalid;
   logic                             ip2uio_rx_st2_sop;
   logic                             ip2uio_rx_st2_eop;
   logic                             ip2uio_rx_st2_passthrough;
   logic  [(CXL_IO_DWIDTH-1):0]      ip2uio_rx_st2_data;
   logic  [((CXL_IO_DWIDTH/32)-1):0] ip2uio_rx_st2_data_parity;
   logic  [127:0]                    ip2uio_rx_st2_hdr;
   logic  [3:0]                      ip2uio_rx_st2_hdr_parity;
   logic                             ip2uio_rx_st2_hvalid;
   logic  [(CXL_IO_PWIDTH-1):0]      ip2uio_rx_st2_prefix;
   logic  [((CXL_IO_PWIDTH/32)-1):0] ip2uio_rx_st2_prefix_parity;
   logic  [11:0]                     ip2uio_rx_st2_RSSAI_prefix;
   logic                             ip2uio_rx_st2_RSSAI_prefix_parity;
   logic                             ip2uio_rx_st2_pvalid;
   logic  [2:0]                      ip2uio_rx_st2_bar;
   logic                             ip2uio_rx_st2_vfactive;
   logic  [10:0]                     ip2uio_rx_st2_vfnum;
   logic  [2:0]                      ip2uio_rx_st2_pfnum;
   logic  [(CXL_IO_CHWIDTH-1):0]     ip2uio_rx_st2_chnum;
   logic                             ip2uio_rx_st2_misc_parity;
   logic  [2:0]                      ip2uio_rx_st2_empty;  // [log2(CXL_IO_DWIDTH/32)-1:0]

   logic                             ip2uio_rx_st3_dvalid;
   logic                             ip2uio_rx_st3_sop;
   logic                             ip2uio_rx_st3_eop;
   logic                             ip2uio_rx_st3_passthrough;
   logic  [(CXL_IO_DWIDTH-1):0]      ip2uio_rx_st3_data;
   logic  [((CXL_IO_DWIDTH/32)-1):0] ip2uio_rx_st3_data_parity;
   logic  [127:0]                    ip2uio_rx_st3_hdr;
   logic  [3:0]                      ip2uio_rx_st3_hdr_parity;
   logic                             ip2uio_rx_st3_hvalid;
   logic  [(CXL_IO_PWIDTH-1):0]      ip2uio_rx_st3_prefix;
   logic  [((CXL_IO_PWIDTH/32)-1):0] ip2uio_rx_st3_prefix_parity;
   logic  [11:0]                     ip2uio_rx_st3_RSSAI_prefix;
   logic                             ip2uio_rx_st3_RSSAI_prefix_parity;
   logic                             ip2uio_rx_st3_pvalid;
   logic  [2:0]                      ip2uio_rx_st3_bar;
   logic                             ip2uio_rx_st3_vfactive;
   logic  [10:0]                     ip2uio_rx_st3_vfnum;
   logic  [2:0]                      ip2uio_rx_st3_pfnum;
   logic  [(CXL_IO_CHWIDTH-1):0]     ip2uio_rx_st3_chnum;
   logic                             ip2uio_rx_st3_misc_parity;
   logic  [2:0]                      ip2uio_rx_st3_empty;  // [log2(CXL_IO_DWIDTH/32)-1:0]
  
    logic [2:0]                       uio2ip_rx_st_Hcrdt_update;
    //logic [(CXL_IO_CHWIDTH-1):0]      uio2ip_rx_st_Hcrdt_ch;
    logic [5:0]                       uio2ip_rx_st_Hcrdt_update_cnt;
    logic [2:0]                       uio2ip_rx_st_Hcrdt_init;
   logic [2:0]                       ip2uio_rx_st_Hcrdt_init_ack;
    logic [2:0]                       uio2ip_rx_st_Dcrdt_update;
    //logic [(CXL_IO_CHWIDTH-1):0]      uio2ip_rx_st_Dcrdt_ch;
    logic [11:0]                      uio2ip_rx_st_Dcrdt_update_cnt;
    logic [2:0]                       uio2ip_rx_st_Dcrdt_init;
   logic [2:0]                       ip2uio_rx_st_Dcrdt_init_ack;

   logic [7:0]                       ip2uio_bus_number ;                            
   logic [4:0]                       ip2uio_device_number ;

 

   logic                                sip_rstn ;

   logic                  cxl_warm_rst_n; 
   logic                  cxl_cold_rst_n;  
   logic [95:0]                        cafu2ip_csr0_cfg_if ;
   logic [6:0]                         ip2cafu_csr0_cfg_if;

   logic  [1:0]                      usr2ip_qos_devload ;

    logic                                usr2ip_cxlreset_initiate ; //input to IP from ED and this BIT is owner by software VIA DVSEC_FBCTRL2_STATUS2.initiate_cxl_reset
    logic                                ip2usr_cxlreset_req      ;  //output to ED from IP
    logic                                usr2ip_cxlreset_ack      ;  //Input to IP from ED  
    logic                                ip2usr_cxlreset_error    ;//output to ED from IP
    logic                                ip2usr_cxlreset_complete ;  //output to ED from IP  

  //-------------------------------------------------------
  // IP                                 
  //-------------------------------------------------------

  wire nInit_done;

    //MSI-X User interface 
  logic                               pf0_msix_enable  ;
  logic                               pf0_msix_fn_mask ;
  logic                               pf1_msix_enable  ;
  logic                               pf1_msix_fn_mask ;  

  logic                                 ip2cafu_quiesce_req;
  logic                                 cafu2ip_quiesce_ack;

  logic                                 usr2ip_gpf_ph2_ack ;
  logic                                 ip2usr_gpf_ph2_req ;

  logic [63:0]                        dev_serial_num        ;
  logic                               dev_serial_num_valid  ; 


  //ccv_afu internal signals 
  logic                ip2cafu_avmm_clk  ;
  logic                ip2cafu_avmm_rstn ;

logic                      cafu2ip_avmm_waitrequest  ;  
logic [63:0]               cafu2ip_avmm_readdata     ;  
logic                      cafu2ip_avmm_readdatavalid;  
logic [63:0]               ip2cafu_avmm_writedata    ;  
logic                      ip2cafu_avmm_poison;
logic [21:0]               ip2cafu_avmm_address      ;  
logic                      ip2cafu_avmm_write        ;  
logic                      ip2cafu_avmm_read         ;  
logic [7:0]                ip2cafu_avmm_byteenable   ;  

logic [31:0]               ccv_afu_conf_base_addr_high       ; 
logic                      ccv_afu_conf_base_addr_high_valid ; 
logic [27:0]               ccv_afu_conf_base_addr_low        ; 
logic                      ccv_afu_conf_base_addr_low_valid  ; 
logic [2:0]                pf0_max_payload_size;
logic [2:0]                pf0_max_read_request_size;
logic                      pf0_bus_master_en;
logic                      pf0_memory_access_en;
logic [2:0]                pf1_max_payload_size;
logic [2:0]                pf1_max_read_request_size;
logic                      pf1_bus_master_en;
logic                      pf1_memory_access_en;

logic                      ip2cafu_avmm_burstcount ;
  intel_reset_release reset_release (
    .ninit_done (nInit_done)
  );

  //-------------------------------------------------------
  // IP                                 
  //-------------------------------------------------------


//QPDS UPDATE
//  cxl_type3_top cxl_type3_top_inst ( 
intel_rtile_cxl_top_cxltyp3_ed intel_rtile_cxl_top_inst (

      .refclk0,     // to RTile
      .refclk1,     // to RTile
      .refclk4,     // to Fabric PLL
      .resetn,
      .pll_lock_o,
      .sip_warm_rstn_o( sip_rstn),
      .cxl_warm_rst_n                         (cxl_warm_rst_n) ,     // OUTPUT  
      .cxl_cold_rst_n                         (cxl_cold_rst_n) ,     // OUTPUT
      .pf0_msix_enable                     (pf0_msix_enable ),
      .pf0_msix_fn_mask                    (pf0_msix_fn_mask),
      .pf1_msix_enable                     (pf1_msix_enable ),
      .pf1_msix_fn_mask                    (pf1_msix_fn_mask),
 `ifdef RTILE_PIPE_MODE
 // CXL_SIM reduction Pipe Mode 
    .phy_sys_ial_0__pipe_Reset_l                       (phy_sys_ial_0__pipe_Reset_l),                                          //  output,    width = 1,          phy_sys_ial_.0__pipe_Reset_l
    .phy_sys_ial_1__pipe_Reset_l                       (phy_sys_ial_1__pipe_Reset_l),                                          //  output,    width = 1,                      .1__pipe_Reset_l
    .phy_sys_ial_2__pipe_Reset_l                       (phy_sys_ial_2__pipe_Reset_l),                                          //  output,    width = 1,                      .2__pipe_Reset_l
    .phy_sys_ial_3__pipe_Reset_l                       (phy_sys_ial_3__pipe_Reset_l),                                          //  output,    width = 1,                      .3__pipe_Reset_l
    .phy_sys_ial_4__pipe_Reset_l                       (phy_sys_ial_4__pipe_Reset_l),                                          //  output,    width = 1,                      .4__pipe_Reset_l
    .phy_sys_ial_5__pipe_Reset_l                       (phy_sys_ial_5__pipe_Reset_l),                                          //  output,    width = 1,                      .5__pipe_Reset_l
    .phy_sys_ial_6__pipe_Reset_l                       (phy_sys_ial_6__pipe_Reset_l),                                          //  output,    width = 1,                      .6__pipe_Reset_l
    .phy_sys_ial_7__pipe_Reset_l                       (phy_sys_ial_7__pipe_Reset_l),                                          //  output,    width = 1,                      .7__pipe_Reset_l
    .phy_sys_ial_8__pipe_Reset_l                       (phy_sys_ial_8__pipe_Reset_l),                                          //  output,    width = 1,                      .8__pipe_Reset_l
    .phy_sys_ial_9__pipe_Reset_l                       (phy_sys_ial_9__pipe_Reset_l),                                          //  output,    width = 1,                      .9__pipe_Reset_l
    .phy_sys_ial_10__pipe_Reset_l                      (phy_sys_ial_10__pipe_Reset_l),                                         //  output,    width = 1,                      .10__pipe_Reset_l
    .phy_sys_ial_11__pipe_Reset_l                      (phy_sys_ial_11__pipe_Reset_l),                                         //  output,    width = 1,                      .11__pipe_Reset_l
    .phy_sys_ial_12__pipe_Reset_l                      (phy_sys_ial_12__pipe_Reset_l),                                         //  output,    width = 1,                      .12__pipe_Reset_l
    .phy_sys_ial_13__pipe_Reset_l                      (phy_sys_ial_13__pipe_Reset_l),                                         //  output,    width = 1,                      .13__pipe_Reset_l
    .phy_sys_ial_14__pipe_Reset_l                      (phy_sys_ial_14__pipe_Reset_l),                                         //  output,    width = 1,                      .14__pipe_Reset_l
    .phy_sys_ial_15__pipe_Reset_l                      (phy_sys_ial_15__pipe_Reset_l),                                         //  output,    width = 1,                      .15__pipe_Reset_l
    .o_phy_0_pipe_TxDataValid                          (o_phy_0_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_0_pipe_.TxDataValid
    .o_phy_0_pipe_TxData                               (o_phy_0_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_0_pipe_TxDetRxLpbk                          (o_phy_0_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_0_pipe_TxElecIdle                           (o_phy_0_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_0_pipe_PowerDown                            (o_phy_0_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_0_pipe_Rate                                 (o_phy_0_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_0_pipe_PclkChangeAck                        (o_phy_0_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_0_pipe_PCLKRate                             (o_phy_0_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_0_pipe_Width                                (o_phy_0_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_0_pipe_PCLK                                 (o_phy_0_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_0_pipe_rxelecidle_disable                   (o_phy_0_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_0_pipe_txcmnmode_disable                    (o_phy_0_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_0_pipe_srisenable                           (o_phy_0_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_0_pipe_RxStandby                            (o_phy_0_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_0_pipe_RxTermination                        (o_phy_0_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_0_pipe_RxWidth                              (o_phy_0_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_0_pipe_M2P_MessageBus                       (o_phy_0_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_0_pipe_rxbitslip_req                        (o_phy_0_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_0_pipe_rxbitslip_va                         (o_phy_0_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_0_pipe_RxClk                                (i_phy_0_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_0_pipe_.RxClk
    .i_phy_0_pipe_RxValid                              (i_phy_0_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_0_pipe_RxData                               (i_phy_0_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_0_pipe_RxElecIdle                           (i_phy_0_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_0_pipe_RxStatus                             (i_phy_0_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_0_pipe_RxStandbyStatus                      (i_phy_0_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_0_pipe_PhyStatus                            (i_phy_0_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_0_pipe_PclkChangeOk                         (i_phy_0_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_0_pipe_P2M_MessageBus                       (i_phy_0_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_0_pipe_RxBitSlip_Ack                        (i_phy_0_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_1_pipe_TxDataValid                          (o_phy_1_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_1_pipe_.TxDataValid
    .o_phy_1_pipe_TxData                               (o_phy_1_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_1_pipe_TxDetRxLpbk                          (o_phy_1_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_1_pipe_TxElecIdle                           (o_phy_1_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_1_pipe_PowerDown                            (o_phy_1_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_1_pipe_Rate                                 (o_phy_1_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_1_pipe_PclkChangeAck                        (o_phy_1_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_1_pipe_PCLKRate                             (o_phy_1_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_1_pipe_Width                                (o_phy_1_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_1_pipe_PCLK                                 (o_phy_1_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_1_pipe_rxelecidle_disable                   (o_phy_1_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_1_pipe_txcmnmode_disable                    (o_phy_1_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_1_pipe_srisenable                           (o_phy_1_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_1_pipe_RxStandby                            (o_phy_1_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_1_pipe_RxTermination                        (o_phy_1_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_1_pipe_RxWidth                              (o_phy_1_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_1_pipe_M2P_MessageBus                       (o_phy_1_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_1_pipe_rxbitslip_req                        (o_phy_1_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_1_pipe_rxbitslip_va                         (o_phy_1_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_1_pipe_RxClk                                (i_phy_1_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_1_pipe_.RxClk
    .i_phy_1_pipe_RxValid                              (i_phy_1_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_1_pipe_RxData                               (i_phy_1_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_1_pipe_RxElecIdle                           (i_phy_1_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_1_pipe_RxStatus                             (i_phy_1_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_1_pipe_RxStandbyStatus                      (i_phy_1_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_1_pipe_PhyStatus                            (i_phy_1_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_1_pipe_PclkChangeOk                         (i_phy_1_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_1_pipe_P2M_MessageBus                       (i_phy_1_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_1_pipe_RxBitSlip_Ack                        (i_phy_1_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_2_pipe_TxDataValid                          (o_phy_2_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_2_pipe_.TxDataValid
    .o_phy_2_pipe_TxData                               (o_phy_2_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_2_pipe_TxDetRxLpbk                          (o_phy_2_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_2_pipe_TxElecIdle                           (o_phy_2_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_2_pipe_PowerDown                            (o_phy_2_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_2_pipe_Rate                                 (o_phy_2_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_2_pipe_PclkChangeAck                        (o_phy_2_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_2_pipe_PCLKRate                             (o_phy_2_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_2_pipe_Width                                (o_phy_2_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_2_pipe_PCLK                                 (o_phy_2_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_2_pipe_rxelecidle_disable                   (o_phy_2_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_2_pipe_txcmnmode_disable                    (o_phy_2_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_2_pipe_srisenable                           (o_phy_2_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_2_pipe_RxStandby                            (o_phy_2_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_2_pipe_RxTermination                        (o_phy_2_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_2_pipe_RxWidth                              (o_phy_2_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_2_pipe_M2P_MessageBus                       (o_phy_2_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_2_pipe_rxbitslip_req                        (o_phy_2_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_2_pipe_rxbitslip_va                         (o_phy_2_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_2_pipe_RxClk                                (i_phy_2_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_2_pipe_.RxClk
    .i_phy_2_pipe_RxValid                              (i_phy_2_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_2_pipe_RxData                               (i_phy_2_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_2_pipe_RxElecIdle                           (i_phy_2_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_2_pipe_RxStatus                             (i_phy_2_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_2_pipe_RxStandbyStatus                      (i_phy_2_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_2_pipe_PhyStatus                            (i_phy_2_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_2_pipe_PclkChangeOk                         (i_phy_2_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_2_pipe_P2M_MessageBus                       (i_phy_2_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_2_pipe_RxBitSlip_Ack                        (i_phy_2_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_3_pipe_TxDataValid                          (o_phy_3_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_3_pipe_.TxDataValid
    .o_phy_3_pipe_TxData                               (o_phy_3_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_3_pipe_TxDetRxLpbk                          (o_phy_3_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_3_pipe_TxElecIdle                           (o_phy_3_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_3_pipe_PowerDown                            (o_phy_3_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_3_pipe_Rate                                 (o_phy_3_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_3_pipe_PclkChangeAck                        (o_phy_3_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_3_pipe_PCLKRate                             (o_phy_3_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_3_pipe_Width                                (o_phy_3_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_3_pipe_PCLK                                 (o_phy_3_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_3_pipe_rxelecidle_disable                   (o_phy_3_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_3_pipe_txcmnmode_disable                    (o_phy_3_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_3_pipe_srisenable                           (o_phy_3_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_3_pipe_RxStandby                            (o_phy_3_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_3_pipe_RxTermination                        (o_phy_3_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_3_pipe_RxWidth                              (o_phy_3_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_3_pipe_M2P_MessageBus                       (o_phy_3_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_3_pipe_rxbitslip_req                        (o_phy_3_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_3_pipe_rxbitslip_va                         (o_phy_3_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_3_pipe_RxClk                                (i_phy_3_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_3_pipe_.RxClk
    .i_phy_3_pipe_RxValid                              (i_phy_3_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_3_pipe_RxData                               (i_phy_3_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_3_pipe_RxElecIdle                           (i_phy_3_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_3_pipe_RxStatus                             (i_phy_3_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_3_pipe_RxStandbyStatus                      (i_phy_3_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_3_pipe_PhyStatus                            (i_phy_3_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_3_pipe_PclkChangeOk                         (i_phy_3_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_3_pipe_P2M_MessageBus                       (i_phy_3_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_3_pipe_RxBitSlip_Ack                        (i_phy_3_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_4_pipe_TxDataValid                          (o_phy_4_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_4_pipe_.TxDataValid
    .o_phy_4_pipe_TxData                               (o_phy_4_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_4_pipe_TxDetRxLpbk                          (o_phy_4_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_4_pipe_TxElecIdle                           (o_phy_4_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_4_pipe_PowerDown                            (o_phy_4_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_4_pipe_Rate                                 (o_phy_4_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_4_pipe_PclkChangeAck                        (o_phy_4_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_4_pipe_PCLKRate                             (o_phy_4_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_4_pipe_Width                                (o_phy_4_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_4_pipe_PCLK                                 (o_phy_4_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_4_pipe_rxelecidle_disable                   (o_phy_4_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_4_pipe_txcmnmode_disable                    (o_phy_4_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_4_pipe_srisenable                           (o_phy_4_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_4_pipe_RxStandby                            (o_phy_4_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_4_pipe_RxTermination                        (o_phy_4_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_4_pipe_RxWidth                              (o_phy_4_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_4_pipe_M2P_MessageBus                       (o_phy_4_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_4_pipe_rxbitslip_req                        (o_phy_4_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_4_pipe_rxbitslip_va                         (o_phy_4_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_4_pipe_RxClk                                (i_phy_4_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_4_pipe_.RxClk
    .i_phy_4_pipe_RxValid                              (i_phy_4_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_4_pipe_RxData                               (i_phy_4_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_4_pipe_RxElecIdle                           (i_phy_4_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_4_pipe_RxStatus                             (i_phy_4_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_4_pipe_RxStandbyStatus                      (i_phy_4_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_4_pipe_PhyStatus                            (i_phy_4_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_4_pipe_PclkChangeOk                         (i_phy_4_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_4_pipe_P2M_MessageBus                       (i_phy_4_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_4_pipe_RxBitSlip_Ack                        (i_phy_4_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_5_pipe_TxDataValid                          (o_phy_5_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_5_pipe_.TxDataValid
    .o_phy_5_pipe_TxData                               (o_phy_5_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_5_pipe_TxDetRxLpbk                          (o_phy_5_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_5_pipe_TxElecIdle                           (o_phy_5_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_5_pipe_PowerDown                            (o_phy_5_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_5_pipe_Rate                                 (o_phy_5_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_5_pipe_PclkChangeAck                        (o_phy_5_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_5_pipe_PCLKRate                             (o_phy_5_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_5_pipe_Width                                (o_phy_5_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_5_pipe_PCLK                                 (o_phy_5_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_5_pipe_rxelecidle_disable                   (o_phy_5_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_5_pipe_txcmnmode_disable                    (o_phy_5_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_5_pipe_srisenable                           (o_phy_5_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_5_pipe_RxStandby                            (o_phy_5_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_5_pipe_RxTermination                        (o_phy_5_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_5_pipe_RxWidth                              (o_phy_5_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_5_pipe_M2P_MessageBus                       (o_phy_5_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_5_pipe_rxbitslip_req                        (o_phy_5_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_5_pipe_rxbitslip_va                         (o_phy_5_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_5_pipe_RxClk                                (i_phy_5_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_5_pipe_.RxClk
    .i_phy_5_pipe_RxValid                              (i_phy_5_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_5_pipe_RxData                               (i_phy_5_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_5_pipe_RxElecIdle                           (i_phy_5_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_5_pipe_RxStatus                             (i_phy_5_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_5_pipe_RxStandbyStatus                      (i_phy_5_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_5_pipe_PhyStatus                            (i_phy_5_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_5_pipe_PclkChangeOk                         (i_phy_5_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_5_pipe_P2M_MessageBus                       (i_phy_5_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_5_pipe_RxBitSlip_Ack                        (i_phy_5_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_6_pipe_TxDataValid                          (o_phy_6_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_6_pipe_.TxDataValid
    .o_phy_6_pipe_TxData                               (o_phy_6_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_6_pipe_TxDetRxLpbk                          (o_phy_6_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_6_pipe_TxElecIdle                           (o_phy_6_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_6_pipe_PowerDown                            (o_phy_6_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_6_pipe_Rate                                 (o_phy_6_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_6_pipe_PclkChangeAck                        (o_phy_6_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_6_pipe_PCLKRate                             (o_phy_6_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_6_pipe_Width                                (o_phy_6_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_6_pipe_PCLK                                 (o_phy_6_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_6_pipe_rxelecidle_disable                   (o_phy_6_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_6_pipe_txcmnmode_disable                    (o_phy_6_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_6_pipe_srisenable                           (o_phy_6_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_6_pipe_RxStandby                            (o_phy_6_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_6_pipe_RxTermination                        (o_phy_6_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_6_pipe_RxWidth                              (o_phy_6_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_6_pipe_M2P_MessageBus                       (o_phy_6_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_6_pipe_rxbitslip_req                        (o_phy_6_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_6_pipe_rxbitslip_va                         (o_phy_6_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_6_pipe_RxClk                                (i_phy_6_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_6_pipe_.RxClk
    .i_phy_6_pipe_RxValid                              (i_phy_6_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_6_pipe_RxData                               (i_phy_6_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_6_pipe_RxElecIdle                           (i_phy_6_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_6_pipe_RxStatus                             (i_phy_6_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_6_pipe_RxStandbyStatus                      (i_phy_6_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_6_pipe_PhyStatus                            (i_phy_6_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_6_pipe_PclkChangeOk                         (i_phy_6_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_6_pipe_P2M_MessageBus                       (i_phy_6_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_6_pipe_RxBitSlip_Ack                        (i_phy_6_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_7_pipe_TxDataValid                          (o_phy_7_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_7_pipe_.TxDataValid
    .o_phy_7_pipe_TxData                               (o_phy_7_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_7_pipe_TxDetRxLpbk                          (o_phy_7_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_7_pipe_TxElecIdle                           (o_phy_7_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_7_pipe_PowerDown                            (o_phy_7_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_7_pipe_Rate                                 (o_phy_7_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_7_pipe_PclkChangeAck                        (o_phy_7_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_7_pipe_PCLKRate                             (o_phy_7_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_7_pipe_Width                                (o_phy_7_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_7_pipe_PCLK                                 (o_phy_7_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_7_pipe_rxelecidle_disable                   (o_phy_7_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_7_pipe_txcmnmode_disable                    (o_phy_7_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_7_pipe_srisenable                           (o_phy_7_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_7_pipe_RxStandby                            (o_phy_7_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_7_pipe_RxTermination                        (o_phy_7_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_7_pipe_RxWidth                              (o_phy_7_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_7_pipe_M2P_MessageBus                       (o_phy_7_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_7_pipe_rxbitslip_req                        (o_phy_7_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_7_pipe_rxbitslip_va                         (o_phy_7_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_7_pipe_RxClk                                (i_phy_7_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_7_pipe_.RxClk
    .i_phy_7_pipe_RxValid                              (i_phy_7_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_7_pipe_RxData                               (i_phy_7_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_7_pipe_RxElecIdle                           (i_phy_7_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_7_pipe_RxStatus                             (i_phy_7_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_7_pipe_RxStandbyStatus                      (i_phy_7_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_7_pipe_PhyStatus                            (i_phy_7_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_7_pipe_PclkChangeOk                         (i_phy_7_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_7_pipe_P2M_MessageBus                       (i_phy_7_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_7_pipe_RxBitSlip_Ack                        (i_phy_7_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_8_pipe_TxDataValid                          (o_phy_8_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_8_pipe_.TxDataValid
    .o_phy_8_pipe_TxData                               (o_phy_8_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_8_pipe_TxDetRxLpbk                          (o_phy_8_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_8_pipe_TxElecIdle                           (o_phy_8_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_8_pipe_PowerDown                            (o_phy_8_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_8_pipe_Rate                                 (o_phy_8_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_8_pipe_PclkChangeAck                        (o_phy_8_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_8_pipe_PCLKRate                             (o_phy_8_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_8_pipe_Width                                (o_phy_8_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_8_pipe_PCLK                                 (o_phy_8_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_8_pipe_rxelecidle_disable                   (o_phy_8_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_8_pipe_txcmnmode_disable                    (o_phy_8_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_8_pipe_srisenable                           (o_phy_8_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_8_pipe_RxStandby                            (o_phy_8_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_8_pipe_RxTermination                        (o_phy_8_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_8_pipe_RxWidth                              (o_phy_8_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_8_pipe_M2P_MessageBus                       (o_phy_8_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_8_pipe_rxbitslip_req                        (o_phy_8_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_8_pipe_rxbitslip_va                         (o_phy_8_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_8_pipe_RxClk                                (i_phy_8_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_8_pipe_.RxClk
    .i_phy_8_pipe_RxValid                              (i_phy_8_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_8_pipe_RxData                               (i_phy_8_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_8_pipe_RxElecIdle                           (i_phy_8_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_8_pipe_RxStatus                             (i_phy_8_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_8_pipe_RxStandbyStatus                      (i_phy_8_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_8_pipe_PhyStatus                            (i_phy_8_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_8_pipe_PclkChangeOk                         (i_phy_8_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_8_pipe_P2M_MessageBus                       (i_phy_8_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_8_pipe_RxBitSlip_Ack                        (i_phy_8_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_9_pipe_TxDataValid                          (o_phy_9_pipe_TxDataValid),                                             //  output,    width = 1,         o_phy_9_pipe_.TxDataValid
    .o_phy_9_pipe_TxData                               (o_phy_9_pipe_TxData),                                                  //  output,   width = 40,                      .TxData
    .o_phy_9_pipe_TxDetRxLpbk                          (o_phy_9_pipe_TxDetRxLpbk),                                             //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_9_pipe_TxElecIdle                           (o_phy_9_pipe_TxElecIdle),                                              //  output,    width = 4,                      .TxElecIdle
    .o_phy_9_pipe_PowerDown                            (o_phy_9_pipe_PowerDown),                                               //  output,    width = 4,                      .PowerDown
    .o_phy_9_pipe_Rate                                 (o_phy_9_pipe_Rate),                                                    //  output,    width = 3,                      .Rate
    .o_phy_9_pipe_PclkChangeAck                        (o_phy_9_pipe_PclkChangeAck),                                           //  output,    width = 1,                      .PclkChangeAck
    .o_phy_9_pipe_PCLKRate                             (o_phy_9_pipe_PCLKRate),                                                //  output,    width = 3,                      .PCLKRate
    .o_phy_9_pipe_Width                                (o_phy_9_pipe_Width),                                                   //  output,    width = 2,                      .Width
    .o_phy_9_pipe_PCLK                                 (o_phy_9_pipe_PCLK),                                                    //  output,    width = 1,                      .PCLK
    .o_phy_9_pipe_rxelecidle_disable                   (o_phy_9_pipe_rxelecidle_disable),                                      //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_9_pipe_txcmnmode_disable                    (o_phy_9_pipe_txcmnmode_disable),                                       //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_9_pipe_srisenable                           (o_phy_9_pipe_srisenable),                                              //  output,    width = 1,                      .srisenable
    .o_phy_9_pipe_RxStandby                            (o_phy_9_pipe_RxStandby),                                               //  output,    width = 1,                      .RxStandby
    .o_phy_9_pipe_RxTermination                        (o_phy_9_pipe_RxTermination),                                           //  output,    width = 1,                      .RxTermination
    .o_phy_9_pipe_RxWidth                              (o_phy_9_pipe_RxWidth),                                                 //  output,    width = 2,                      .RxWidth
    .o_phy_9_pipe_M2P_MessageBus                       (o_phy_9_pipe_M2P_MessageBus),                                          //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_9_pipe_rxbitslip_req                        (o_phy_9_pipe_rxbitslip_req),                                           //  output,    width = 1,                      .rxbitslip_req
    .o_phy_9_pipe_rxbitslip_va                         (o_phy_9_pipe_rxbitslip_va),                                            //  output,    width = 5,                      .rxbitslip_va
    .i_phy_9_pipe_RxClk                                (i_phy_9_pipe_RxClk),                                                   //   input,    width = 1,         i_phy_9_pipe_.RxClk
    .i_phy_9_pipe_RxValid                              (i_phy_9_pipe_RxValid),                                                 //   input,    width = 1,                      .RxValid
    .i_phy_9_pipe_RxData                               (i_phy_9_pipe_RxData),                                                  //   input,   width = 40,                      .RxData
    .i_phy_9_pipe_RxElecIdle                           (i_phy_9_pipe_RxElecIdle),                                              //   input,    width = 1,                      .RxElecIdle
    .i_phy_9_pipe_RxStatus                             (i_phy_9_pipe_RxStatus),                                                //   input,    width = 3,                      .RxStatus
    .i_phy_9_pipe_RxStandbyStatus                      (i_phy_9_pipe_RxStandbyStatus),                                         //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_9_pipe_PhyStatus                            (i_phy_9_pipe_PhyStatus),                                               //   input,    width = 1,                      .PhyStatus
    .i_phy_9_pipe_PclkChangeOk                         (i_phy_9_pipe_PclkChangeOk),                                            //   input,    width = 1,                      .PclkChangeOk
    .i_phy_9_pipe_P2M_MessageBus                       (i_phy_9_pipe_P2M_MessageBus),                                          //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_9_pipe_RxBitSlip_Ack                        (i_phy_9_pipe_RxBitSlip_Ack),                                           //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_10_pipe_TxDataValid                         (o_phy_10_pipe_TxDataValid),                                            //  output,    width = 1,        o_phy_10_pipe_.TxDataValid
    .o_phy_10_pipe_TxData                              (o_phy_10_pipe_TxData),                                                 //  output,   width = 40,                      .TxData
    .o_phy_10_pipe_TxDetRxLpbk                         (o_phy_10_pipe_TxDetRxLpbk),                                            //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_10_pipe_TxElecIdle                          (o_phy_10_pipe_TxElecIdle),                                             //  output,    width = 4,                      .TxElecIdle
    .o_phy_10_pipe_PowerDown                           (o_phy_10_pipe_PowerDown),                                              //  output,    width = 4,                      .PowerDown
    .o_phy_10_pipe_Rate                                (o_phy_10_pipe_Rate),                                                   //  output,    width = 3,                      .Rate
    .o_phy_10_pipe_PclkChangeAck                       (o_phy_10_pipe_PclkChangeAck),                                          //  output,    width = 1,                      .PclkChangeAck
    .o_phy_10_pipe_PCLKRate                            (o_phy_10_pipe_PCLKRate),                                               //  output,    width = 3,                      .PCLKRate
    .o_phy_10_pipe_Width                               (o_phy_10_pipe_Width),                                                  //  output,    width = 2,                      .Width
    .o_phy_10_pipe_PCLK                                (o_phy_10_pipe_PCLK),                                                   //  output,    width = 1,                      .PCLK
    .o_phy_10_pipe_rxelecidle_disable                  (o_phy_10_pipe_rxelecidle_disable),                                     //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_10_pipe_txcmnmode_disable                   (o_phy_10_pipe_txcmnmode_disable),                                      //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_10_pipe_srisenable                          (o_phy_10_pipe_srisenable),                                             //  output,    width = 1,                      .srisenable
    .o_phy_10_pipe_RxStandby                           (o_phy_10_pipe_RxStandby),                                              //  output,    width = 1,                      .RxStandby
    .o_phy_10_pipe_RxTermination                       (o_phy_10_pipe_RxTermination),                                          //  output,    width = 1,                      .RxTermination
    .o_phy_10_pipe_RxWidth                             (o_phy_10_pipe_RxWidth),                                                //  output,    width = 2,                      .RxWidth
    .o_phy_10_pipe_M2P_MessageBus                      (o_phy_10_pipe_M2P_MessageBus),                                         //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_10_pipe_rxbitslip_req                       (o_phy_10_pipe_rxbitslip_req),                                          //  output,    width = 1,                      .rxbitslip_req
    .o_phy_10_pipe_rxbitslip_va                        (o_phy_10_pipe_rxbitslip_va),                                           //  output,    width = 5,                      .rxbitslip_va
    .i_phy_10_pipe_RxClk                               (i_phy_10_pipe_RxClk),                                                  //   input,    width = 1,        i_phy_10_pipe_.RxClk
    .i_phy_10_pipe_RxValid                             (i_phy_10_pipe_RxValid),                                                //   input,    width = 1,                      .RxValid
    .i_phy_10_pipe_RxData                              (i_phy_10_pipe_RxData),                                                 //   input,   width = 40,                      .RxData
    .i_phy_10_pipe_RxElecIdle                          (i_phy_10_pipe_RxElecIdle),                                             //   input,    width = 1,                      .RxElecIdle
    .i_phy_10_pipe_RxStatus                            (i_phy_10_pipe_RxStatus),                                               //   input,    width = 3,                      .RxStatus
    .i_phy_10_pipe_RxStandbyStatus                     (i_phy_10_pipe_RxStandbyStatus),                                        //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_10_pipe_PhyStatus                           (i_phy_10_pipe_PhyStatus),                                              //   input,    width = 1,                      .PhyStatus
    .i_phy_10_pipe_PclkChangeOk                        (i_phy_10_pipe_PclkChangeOk),                                           //   input,    width = 1,                      .PclkChangeOk
    .i_phy_10_pipe_P2M_MessageBus                      (i_phy_10_pipe_P2M_MessageBus),                                         //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_10_pipe_RxBitSlip_Ack                       (i_phy_10_pipe_RxBitSlip_Ack),                                          //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_11_pipe_TxDataValid                         (o_phy_11_pipe_TxDataValid),                                            //  output,    width = 1,        o_phy_11_pipe_.TxDataValid
    .o_phy_11_pipe_TxData                              (o_phy_11_pipe_TxData),                                                 //  output,   width = 40,                      .TxData
    .o_phy_11_pipe_TxDetRxLpbk                         (o_phy_11_pipe_TxDetRxLpbk),                                            //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_11_pipe_TxElecIdle                          (o_phy_11_pipe_TxElecIdle),                                             //  output,    width = 4,                      .TxElecIdle
    .o_phy_11_pipe_PowerDown                           (o_phy_11_pipe_PowerDown),                                              //  output,    width = 4,                      .PowerDown
    .o_phy_11_pipe_Rate                                (o_phy_11_pipe_Rate),                                                   //  output,    width = 3,                      .Rate
    .o_phy_11_pipe_PclkChangeAck                       (o_phy_11_pipe_PclkChangeAck),                                          //  output,    width = 1,                      .PclkChangeAck
    .o_phy_11_pipe_PCLKRate                            (o_phy_11_pipe_PCLKRate),                                               //  output,    width = 3,                      .PCLKRate
    .o_phy_11_pipe_Width                               (o_phy_11_pipe_Width),                                                  //  output,    width = 2,                      .Width
    .o_phy_11_pipe_PCLK                                (o_phy_11_pipe_PCLK),                                                   //  output,    width = 1,                      .PCLK
    .o_phy_11_pipe_rxelecidle_disable                  (o_phy_11_pipe_rxelecidle_disable),                                     //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_11_pipe_txcmnmode_disable                   (o_phy_11_pipe_txcmnmode_disable),                                      //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_11_pipe_srisenable                          (o_phy_11_pipe_srisenable),                                             //  output,    width = 1,                      .srisenable
    .o_phy_11_pipe_RxStandby                           (o_phy_11_pipe_RxStandby),                                              //  output,    width = 1,                      .RxStandby
    .o_phy_11_pipe_RxTermination                       (o_phy_11_pipe_RxTermination),                                          //  output,    width = 1,                      .RxTermination
    .o_phy_11_pipe_RxWidth                             (o_phy_11_pipe_RxWidth),                                                //  output,    width = 2,                      .RxWidth
    .o_phy_11_pipe_M2P_MessageBus                      (o_phy_11_pipe_M2P_MessageBus),                                         //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_11_pipe_rxbitslip_req                       (o_phy_11_pipe_rxbitslip_req),                                          //  output,    width = 1,                      .rxbitslip_req
    .o_phy_11_pipe_rxbitslip_va                        (o_phy_11_pipe_rxbitslip_va),                                           //  output,    width = 5,                      .rxbitslip_va
    .i_phy_11_pipe_RxClk                               (i_phy_11_pipe_RxClk),                                                  //   input,    width = 1,        i_phy_11_pipe_.RxClk
    .i_phy_11_pipe_RxValid                             (i_phy_11_pipe_RxValid),                                                //   input,    width = 1,                      .RxValid
    .i_phy_11_pipe_RxData                              (i_phy_11_pipe_RxData),                                                 //   input,   width = 40,                      .RxData
    .i_phy_11_pipe_RxElecIdle                          (i_phy_11_pipe_RxElecIdle),                                             //   input,    width = 1,                      .RxElecIdle
    .i_phy_11_pipe_RxStatus                            (i_phy_11_pipe_RxStatus),                                               //   input,    width = 3,                      .RxStatus
    .i_phy_11_pipe_RxStandbyStatus                     (i_phy_11_pipe_RxStandbyStatus),                                        //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_11_pipe_PhyStatus                           (i_phy_11_pipe_PhyStatus),                                              //   input,    width = 1,                      .PhyStatus
    .i_phy_11_pipe_PclkChangeOk                        (i_phy_11_pipe_PclkChangeOk),                                           //   input,    width = 1,                      .PclkChangeOk
    .i_phy_11_pipe_P2M_MessageBus                      (i_phy_11_pipe_P2M_MessageBus),                                         //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_11_pipe_RxBitSlip_Ack                       (i_phy_11_pipe_RxBitSlip_Ack),                                          //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_12_pipe_TxDataValid                         (o_phy_12_pipe_TxDataValid),                                            //  output,    width = 1,        o_phy_12_pipe_.TxDataValid
    .o_phy_12_pipe_TxData                              (o_phy_12_pipe_TxData),                                                 //  output,   width = 40,                      .TxData
    .o_phy_12_pipe_TxDetRxLpbk                         (o_phy_12_pipe_TxDetRxLpbk),                                            //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_12_pipe_TxElecIdle                          (o_phy_12_pipe_TxElecIdle),                                             //  output,    width = 4,                      .TxElecIdle
    .o_phy_12_pipe_PowerDown                           (o_phy_12_pipe_PowerDown),                                              //  output,    width = 4,                      .PowerDown
    .o_phy_12_pipe_Rate                                (o_phy_12_pipe_Rate),                                                   //  output,    width = 3,                      .Rate
    .o_phy_12_pipe_PclkChangeAck                       (o_phy_12_pipe_PclkChangeAck),                                          //  output,    width = 1,                      .PclkChangeAck
    .o_phy_12_pipe_PCLKRate                            (o_phy_12_pipe_PCLKRate),                                               //  output,    width = 3,                      .PCLKRate
    .o_phy_12_pipe_Width                               (o_phy_12_pipe_Width),                                                  //  output,    width = 2,                      .Width
    .o_phy_12_pipe_PCLK                                (o_phy_12_pipe_PCLK),                                                   //  output,    width = 1,                      .PCLK
    .o_phy_12_pipe_rxelecidle_disable                  (o_phy_12_pipe_rxelecidle_disable),                                     //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_12_pipe_txcmnmode_disable                   (o_phy_12_pipe_txcmnmode_disable),                                      //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_12_pipe_srisenable                          (o_phy_12_pipe_srisenable),                                             //  output,    width = 1,                      .srisenable
    .o_phy_12_pipe_RxStandby                           (o_phy_12_pipe_RxStandby),                                              //  output,    width = 1,                      .RxStandby
    .o_phy_12_pipe_RxTermination                       (o_phy_12_pipe_RxTermination),                                          //  output,    width = 1,                      .RxTermination
    .o_phy_12_pipe_RxWidth                             (o_phy_12_pipe_RxWidth),                                                //  output,    width = 2,                      .RxWidth
    .o_phy_12_pipe_M2P_MessageBus                      (o_phy_12_pipe_M2P_MessageBus),                                         //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_12_pipe_rxbitslip_req                       (o_phy_12_pipe_rxbitslip_req),                                          //  output,    width = 1,                      .rxbitslip_req
    .o_phy_12_pipe_rxbitslip_va                        (o_phy_12_pipe_rxbitslip_va),                                           //  output,    width = 5,                      .rxbitslip_va
    .i_phy_12_pipe_RxClk                               (i_phy_12_pipe_RxClk),                                                  //   input,    width = 1,        i_phy_12_pipe_.RxClk
    .i_phy_12_pipe_RxValid                             (i_phy_12_pipe_RxValid),                                                //   input,    width = 1,                      .RxValid
    .i_phy_12_pipe_RxData                              (i_phy_12_pipe_RxData),                                                 //   input,   width = 40,                      .RxData
    .i_phy_12_pipe_RxElecIdle                          (i_phy_12_pipe_RxElecIdle),                                             //   input,    width = 1,                      .RxElecIdle
    .i_phy_12_pipe_RxStatus                            (i_phy_12_pipe_RxStatus),                                               //   input,    width = 3,                      .RxStatus
    .i_phy_12_pipe_RxStandbyStatus                     (i_phy_12_pipe_RxStandbyStatus),                                        //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_12_pipe_PhyStatus                           (i_phy_12_pipe_PhyStatus),                                              //   input,    width = 1,                      .PhyStatus
    .i_phy_12_pipe_PclkChangeOk                        (i_phy_12_pipe_PclkChangeOk),                                           //   input,    width = 1,                      .PclkChangeOk
    .i_phy_12_pipe_P2M_MessageBus                      (i_phy_12_pipe_P2M_MessageBus),                                         //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_12_pipe_RxBitSlip_Ack                       (i_phy_12_pipe_RxBitSlip_Ack),                                          //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_13_pipe_TxDataValid                         (o_phy_13_pipe_TxDataValid),                                            //  output,    width = 1,        o_phy_13_pipe_.TxDataValid
    .o_phy_13_pipe_TxData                              (o_phy_13_pipe_TxData),                                                 //  output,   width = 40,                      .TxData
    .o_phy_13_pipe_TxDetRxLpbk                         (o_phy_13_pipe_TxDetRxLpbk),                                            //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_13_pipe_TxElecIdle                          (o_phy_13_pipe_TxElecIdle),                                             //  output,    width = 4,                      .TxElecIdle
    .o_phy_13_pipe_PowerDown                           (o_phy_13_pipe_PowerDown),                                              //  output,    width = 4,                      .PowerDown
    .o_phy_13_pipe_Rate                                (o_phy_13_pipe_Rate),                                                   //  output,    width = 3,                      .Rate
    .o_phy_13_pipe_PclkChangeAck                       (o_phy_13_pipe_PclkChangeAck),                                          //  output,    width = 1,                      .PclkChangeAck
    .o_phy_13_pipe_PCLKRate                            (o_phy_13_pipe_PCLKRate),                                               //  output,    width = 3,                      .PCLKRate
    .o_phy_13_pipe_Width                               (o_phy_13_pipe_Width),                                                  //  output,    width = 2,                      .Width
    .o_phy_13_pipe_PCLK                                (o_phy_13_pipe_PCLK),                                                   //  output,    width = 1,                      .PCLK
    .o_phy_13_pipe_rxelecidle_disable                  (o_phy_13_pipe_rxelecidle_disable),                                     //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_13_pipe_txcmnmode_disable                   (o_phy_13_pipe_txcmnmode_disable),                                      //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_13_pipe_srisenable                          (o_phy_13_pipe_srisenable),                                             //  output,    width = 1,                      .srisenable
    .o_phy_13_pipe_RxStandby                           (o_phy_13_pipe_RxStandby),                                              //  output,    width = 1,                      .RxStandby
    .o_phy_13_pipe_RxTermination                       (o_phy_13_pipe_RxTermination),                                          //  output,    width = 1,                      .RxTermination
    .o_phy_13_pipe_RxWidth                             (o_phy_13_pipe_RxWidth),                                                //  output,    width = 2,                      .RxWidth
    .o_phy_13_pipe_M2P_MessageBus                      (o_phy_13_pipe_M2P_MessageBus),                                         //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_13_pipe_rxbitslip_req                       (o_phy_13_pipe_rxbitslip_req),                                          //  output,    width = 1,                      .rxbitslip_req
    .o_phy_13_pipe_rxbitslip_va                        (o_phy_13_pipe_rxbitslip_va),                                           //  output,    width = 5,                      .rxbitslip_va
    .i_phy_13_pipe_RxClk                               (i_phy_13_pipe_RxClk),                                                  //   input,    width = 1,        i_phy_13_pipe_.RxClk
    .i_phy_13_pipe_RxValid                             (i_phy_13_pipe_RxValid),                                                //   input,    width = 1,                      .RxValid
    .i_phy_13_pipe_RxData                              (i_phy_13_pipe_RxData),                                                 //   input,   width = 40,                      .RxData
    .i_phy_13_pipe_RxElecIdle                          (i_phy_13_pipe_RxElecIdle),                                             //   input,    width = 1,                      .RxElecIdle
    .i_phy_13_pipe_RxStatus                            (i_phy_13_pipe_RxStatus),                                               //   input,    width = 3,                      .RxStatus
    .i_phy_13_pipe_RxStandbyStatus                     (i_phy_13_pipe_RxStandbyStatus),                                        //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_13_pipe_PhyStatus                           (i_phy_13_pipe_PhyStatus),                                              //   input,    width = 1,                      .PhyStatus
    .i_phy_13_pipe_PclkChangeOk                        (i_phy_13_pipe_PclkChangeOk),                                           //   input,    width = 1,                      .PclkChangeOk
    .i_phy_13_pipe_P2M_MessageBus                      (i_phy_13_pipe_P2M_MessageBus),                                         //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_13_pipe_RxBitSlip_Ack                       (i_phy_13_pipe_RxBitSlip_Ack),                                          //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_14_pipe_TxDataValid                         (o_phy_14_pipe_TxDataValid),                                            //  output,    width = 1,        o_phy_14_pipe_.TxDataValid
    .o_phy_14_pipe_TxData                              (o_phy_14_pipe_TxData),                                                 //  output,   width = 40,                      .TxData
    .o_phy_14_pipe_TxDetRxLpbk                         (o_phy_14_pipe_TxDetRxLpbk),                                            //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_14_pipe_TxElecIdle                          (o_phy_14_pipe_TxElecIdle),                                             //  output,    width = 4,                      .TxElecIdle
    .o_phy_14_pipe_PowerDown                           (o_phy_14_pipe_PowerDown),                                              //  output,    width = 4,                      .PowerDown
    .o_phy_14_pipe_Rate                                (o_phy_14_pipe_Rate),                                                   //  output,    width = 3,                      .Rate
    .o_phy_14_pipe_PclkChangeAck                       (o_phy_14_pipe_PclkChangeAck),                                          //  output,    width = 1,                      .PclkChangeAck
    .o_phy_14_pipe_PCLKRate                            (o_phy_14_pipe_PCLKRate),                                               //  output,    width = 3,                      .PCLKRate
    .o_phy_14_pipe_Width                               (o_phy_14_pipe_Width),                                                  //  output,    width = 2,                      .Width
    .o_phy_14_pipe_PCLK                                (o_phy_14_pipe_PCLK),                                                   //  output,    width = 1,                      .PCLK
    .o_phy_14_pipe_rxelecidle_disable                  (o_phy_14_pipe_rxelecidle_disable),                                     //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_14_pipe_txcmnmode_disable                   (o_phy_14_pipe_txcmnmode_disable),                                      //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_14_pipe_srisenable                          (o_phy_14_pipe_srisenable),                                             //  output,    width = 1,                      .srisenable
    .o_phy_14_pipe_RxStandby                           (o_phy_14_pipe_RxStandby),                                              //  output,    width = 1,                      .RxStandby
    .o_phy_14_pipe_RxTermination                       (o_phy_14_pipe_RxTermination),                                          //  output,    width = 1,                      .RxTermination
    .o_phy_14_pipe_RxWidth                             (o_phy_14_pipe_RxWidth),                                                //  output,    width = 2,                      .RxWidth
    .o_phy_14_pipe_M2P_MessageBus                      (o_phy_14_pipe_M2P_MessageBus),                                         //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_14_pipe_rxbitslip_req                       (o_phy_14_pipe_rxbitslip_req),                                          //  output,    width = 1,                      .rxbitslip_req
    .o_phy_14_pipe_rxbitslip_va                        (o_phy_14_pipe_rxbitslip_va),                                           //  output,    width = 5,                      .rxbitslip_va
    .i_phy_14_pipe_RxClk                               (i_phy_14_pipe_RxClk),                                                  //   input,    width = 1,        i_phy_14_pipe_.RxClk
    .i_phy_14_pipe_RxValid                             (i_phy_14_pipe_RxValid),                                                //   input,    width = 1,                      .RxValid
    .i_phy_14_pipe_RxData                              (i_phy_14_pipe_RxData),                                                 //   input,   width = 40,                      .RxData
    .i_phy_14_pipe_RxElecIdle                          (i_phy_14_pipe_RxElecIdle),                                             //   input,    width = 1,                      .RxElecIdle
    .i_phy_14_pipe_RxStatus                            (i_phy_14_pipe_RxStatus),                                               //   input,    width = 3,                      .RxStatus
    .i_phy_14_pipe_RxStandbyStatus                     (i_phy_14_pipe_RxStandbyStatus),                                        //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_14_pipe_PhyStatus                           (i_phy_14_pipe_PhyStatus),                                              //   input,    width = 1,                      .PhyStatus
    .i_phy_14_pipe_PclkChangeOk                        (i_phy_14_pipe_PclkChangeOk),                                           //   input,    width = 1,                      .PclkChangeOk
    .i_phy_14_pipe_P2M_MessageBus                      (i_phy_14_pipe_P2M_MessageBus),                                         //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_14_pipe_RxBitSlip_Ack                       (i_phy_14_pipe_RxBitSlip_Ack),                                          //   input,    width = 1,                      .RxBitSlip_Ack
    .o_phy_15_pipe_TxDataValid                         (o_phy_15_pipe_TxDataValid),                                            //  output,    width = 1,        o_phy_15_pipe_.TxDataValid
    .o_phy_15_pipe_TxData                              (o_phy_15_pipe_TxData),                                                 //  output,   width = 40,                      .TxData
    .o_phy_15_pipe_TxDetRxLpbk                         (o_phy_15_pipe_TxDetRxLpbk),                                            //  output,    width = 1,                      .TxDetRxLpbk
    .o_phy_15_pipe_TxElecIdle                          (o_phy_15_pipe_TxElecIdle),                                             //  output,    width = 4,                      .TxElecIdle
    .o_phy_15_pipe_PowerDown                           (o_phy_15_pipe_PowerDown),                                              //  output,    width = 4,                      .PowerDown
    .o_phy_15_pipe_Rate                                (o_phy_15_pipe_Rate),                                                   //  output,    width = 3,                      .Rate
    .o_phy_15_pipe_PclkChangeAck                       (o_phy_15_pipe_PclkChangeAck),                                          //  output,    width = 1,                      .PclkChangeAck
    .o_phy_15_pipe_PCLKRate                            (o_phy_15_pipe_PCLKRate),                                               //  output,    width = 3,                      .PCLKRate
    .o_phy_15_pipe_Width                               (o_phy_15_pipe_Width),                                                  //  output,    width = 2,                      .Width
    .o_phy_15_pipe_PCLK                                (o_phy_15_pipe_PCLK),                                                   //  output,    width = 1,                      .PCLK
    .o_phy_15_pipe_rxelecidle_disable                  (o_phy_15_pipe_rxelecidle_disable),                                     //  output,    width = 1,                      .rxelecidle_disable
    .o_phy_15_pipe_txcmnmode_disable                   (o_phy_15_pipe_txcmnmode_disable),                                      //  output,    width = 1,                      .txcmnmode_disable
    .o_phy_15_pipe_srisenable                          (o_phy_15_pipe_srisenable),                                             //  output,    width = 1,                      .srisenable
    .o_phy_15_pipe_RxStandby                           (o_phy_15_pipe_RxStandby),                                              //  output,    width = 1,                      .RxStandby
    .o_phy_15_pipe_RxTermination                       (o_phy_15_pipe_RxTermination),                                          //  output,    width = 1,                      .RxTermination
    .o_phy_15_pipe_RxWidth                             (o_phy_15_pipe_RxWidth),                                                //  output,    width = 2,                      .RxWidth
    .o_phy_15_pipe_M2P_MessageBus                      (o_phy_15_pipe_M2P_MessageBus),                                         //  output,    width = 8,                      .M2P_MessageBus
    .o_phy_15_pipe_rxbitslip_req                       (o_phy_15_pipe_rxbitslip_req),                                          //  output,    width = 1,                      .rxbitslip_req
    .o_phy_15_pipe_rxbitslip_va                        (o_phy_15_pipe_rxbitslip_va),                                           //  output,    width = 5,                      .rxbitslip_va
    .i_phy_15_pipe_RxClk                               (i_phy_15_pipe_RxClk),                                                  //   input,    width = 1,        i_phy_15_pipe_.RxClk
    .i_phy_15_pipe_RxValid                             (i_phy_15_pipe_RxValid),                                                //   input,    width = 1,                      .RxValid
    .i_phy_15_pipe_RxData                              (i_phy_15_pipe_RxData),                                                 //   input,   width = 40,                      .RxData
    .i_phy_15_pipe_RxElecIdle                          (i_phy_15_pipe_RxElecIdle),                                             //   input,    width = 1,                      .RxElecIdle
    .i_phy_15_pipe_RxStatus                            (i_phy_15_pipe_RxStatus),                                               //   input,    width = 3,                      .RxStatus
    .i_phy_15_pipe_RxStandbyStatus                     (i_phy_15_pipe_RxStandbyStatus),                                        //   input,    width = 1,                      .RxStandbyStatus
    .i_phy_15_pipe_PhyStatus                           (i_phy_15_pipe_PhyStatus),                                              //   input,    width = 1,                      .PhyStatus
    .i_phy_15_pipe_PclkChangeOk                        (i_phy_15_pipe_PclkChangeOk),                                           //   input,    width = 1,                      .PclkChangeOk
    .i_phy_15_pipe_P2M_MessageBus                      (i_phy_15_pipe_P2M_MessageBus),                                         //   input,    width = 8,                      .P2M_MessageBus
    .i_phy_15_pipe_RxBitSlip_Ack                       (i_phy_15_pipe_RxBitSlip_Ack),                                          //   input,    width = 1,                      .RxBitSlip_Ack
  
  /* synthesis translate_on */
`endif
      
    .usr2ip_app_err_valid   ,
    .usr2ip_app_err_hdr     ,
    .usr2ip_app_err_info    ,
    .usr2ip_app_err_func_num,
    .ip2usr_app_err_ready   ,
    .ip2usr_aermsg_correctable_valid     (ip2usr_aermsg_correctable_valid  ),
    .ip2usr_aermsg_uncorrectable_valid   (ip2usr_aermsg_uncorrectable_valid),
    .ip2usr_aermsg_res                   (ip2usr_aermsg_res                ),    
    .ip2usr_aermsg_bts                   (ip2usr_aermsg_bts                ),    
    .ip2usr_aermsg_bds                   (ip2usr_aermsg_bds                ),    
    .ip2usr_aermsg_rrs                   (ip2usr_aermsg_rrs                ),    
    .ip2usr_aermsg_rtts                  (ip2usr_aermsg_rtts               ),    
    .ip2usr_aermsg_anes                  (ip2usr_aermsg_anes               ),    
    .ip2usr_aermsg_cies                  (ip2usr_aermsg_cies               ),    
    .ip2usr_aermsg_hlos                  (ip2usr_aermsg_hlos               ),    
    .ip2usr_aermsg_fmt                   (ip2usr_aermsg_fmt                ),    
    .ip2usr_aermsg_type                  (ip2usr_aermsg_type               ),    
    .ip2usr_aermsg_tc                    (ip2usr_aermsg_tc                 ),    
    .ip2usr_aermsg_ido                   (ip2usr_aermsg_ido                ),    
    .ip2usr_aermsg_th                    (ip2usr_aermsg_th                 ),    
    .ip2usr_aermsg_td                    (ip2usr_aermsg_td                 ),    
    .ip2usr_aermsg_ep                    (ip2usr_aermsg_ep                 ),    
    .ip2usr_aermsg_ro                    (ip2usr_aermsg_ro                 ),    
    .ip2usr_aermsg_ns                    (ip2usr_aermsg_ns                 ),    
    .ip2usr_aermsg_at                    (ip2usr_aermsg_at                 ),    
    .ip2usr_aermsg_length                (ip2usr_aermsg_length             ),  
    .ip2usr_aermsg_header                (ip2usr_aermsg_header             ),  
    .ip2usr_aermsg_und                   (ip2usr_aermsg_und                ),     
    .ip2usr_aermsg_anf                   (ip2usr_aermsg_anf                ),     
    .ip2usr_aermsg_dlpes                 (ip2usr_aermsg_dlpes              ),   
    .ip2usr_aermsg_sdes                  (ip2usr_aermsg_sdes               ),    
    .ip2usr_aermsg_fep                   (ip2usr_aermsg_fep                ),     
    .ip2usr_aermsg_pts                   (ip2usr_aermsg_pts                ),     
    .ip2usr_aermsg_fcpes                 (ip2usr_aermsg_fcpes              ),   
    .ip2usr_aermsg_cts                   (ip2usr_aermsg_cts                ),    
    .ip2usr_aermsg_cas                   (ip2usr_aermsg_cas                ),    
    .ip2usr_aermsg_ucs                   (ip2usr_aermsg_ucs                ),    
    .ip2usr_aermsg_ros                   (ip2usr_aermsg_ros                ),    
    .ip2usr_aermsg_mts                   (ip2usr_aermsg_mts                ),    
    .ip2usr_aermsg_uies                  (ip2usr_aermsg_uies               ),    
    .ip2usr_aermsg_mbts                  (ip2usr_aermsg_mbts               ),    
    .ip2usr_aermsg_aebs                  (ip2usr_aermsg_aebs               ),    
    .ip2usr_aermsg_tpbes                 (ip2usr_aermsg_tpbes              ),   
    .ip2usr_aermsg_ees                   (ip2usr_aermsg_ees                ),     
    .ip2usr_aermsg_ures                  (ip2usr_aermsg_ures               ),    
    .ip2usr_aermsg_avs                   (ip2usr_aermsg_avs                ), 



    .ip2usr_serr_out        , 

    .ip2usr_debug_waitrequest   ,
    .ip2usr_debug_readdata      ,
    .ip2usr_debug_readdatavalid ,
    .usr2ip_debug_writedata     ,
    .usr2ip_debug_address       ,
    .usr2ip_debug_write         ,
    .usr2ip_debug_read          ,
    .usr2ip_debug_byteenable    ,

    .usr2ip_cxlreset_initiate           (usr2ip_cxlreset_initiate),
    .ip2usr_cxlreset_req                (ip2usr_cxlreset_req),     
    .usr2ip_cxlreset_ack                (usr2ip_cxlreset_ack),     
    .ip2usr_cxlreset_error              (ip2usr_cxlreset_error),   
    .ip2usr_cxlreset_complete           (ip2usr_cxlreset_complete),

      .dev_serial_num                      (dev_serial_num               ),
      .dev_serial_num_valid                (dev_serial_num_valid         ),
      .ip2cafu_quiesce_req                 (ip2cafu_quiesce_req),
      .cafu2ip_quiesce_ack                 (cafu2ip_quiesce_ack),
      .usr2ip_gpf_ph2_ack                   (usr2ip_gpf_ph2_ack ),                   
      .ip2usr_gpf_ph2_req                   (ip2usr_gpf_ph2_req ),
  //ccv_afu change starts here 
      .ip2cafu_avmm_clk, 
      .ip2cafu_avmm_rstn,
 
      .cafu2ip_avmm_waitrequest  ,  
      .cafu2ip_avmm_readdata     ,  
      .cafu2ip_avmm_readdatavalid,  
      .ip2cafu_avmm_writedata    ,  
      .ip2csr_avmm_poison        ,
      .ip2cafu_avmm_address      ,  
      .ip2cafu_avmm_write        ,  
      .ip2cafu_avmm_read         ,  
      .ip2cafu_avmm_byteenable   ,
      .ip2cafu_avmm_burstcount ,

      .ccv_afu_conf_base_addr_high       , 
      .ccv_afu_conf_base_addr_high_valid ,
      .ccv_afu_conf_base_addr_low        , 
      .ccv_afu_conf_base_addr_low_valid  ,
      .pf0_max_payload_size     (pf0_max_payload_size     ),
      .pf0_max_read_request_size(pf0_max_read_request_size),
      .pf0_bus_master_en        (pf0_bus_master_en        ),
      .pf0_memory_access_en     (pf0_memory_access_en     ),
      .pf1_max_payload_size     (pf1_max_payload_size     ),
      .pf1_max_read_request_size(pf1_max_read_request_size),
      .pf1_bus_master_en        (pf1_bus_master_en        ),
      .pf1_memory_access_en     (pf1_memory_access_en     ),





  //ccv_afu change ends here 
      .cxl_tx_n,
      .cxl_tx_p,
      .cxl_rx_n,
      .cxl_rx_p,
      .nInit_done,    // to RTile
      // DDRMC <--> CXL Slice
      .ip2hdm_clk                             (ip2hdm_clk    ) ,     // PLD clk 
    // External CSR <--> CXL-IP
   
      .cafu2ip_csr0_cfg_if              (cafu2ip_csr0_cfg_if  ),
      .ip2cafu_csr0_cfg_if              (ip2cafu_csr0_cfg_if  ),
    

// DDRMC <--> CXL-IP Slice
    .ip2hdm_reset_n                        (ip2hdm_reset_n ),     // pipelined Warm reset from from BBS
    //.hdm_size_256mb                        (hdm_size_256mb ),   	 
    .mc2ip_memsize                         (mc2ip_memsize  ),
  
    .usr2ip_qos_devload                     (usr2ip_qos_devload     ),

    //Channel-->0	  
    .mc2ip_0_sr_status                     (mc2ip_0_sr_status          ),
    .mc2ip_1_sr_status                     (mc2ip_1_sr_status          ),
    
 

//Channel-0
     /* write address channel
      */
   .ip2hdm_aximm0_awvalid   ( ip2hdm_aximm0_awvalid   ) ,       
   .ip2hdm_aximm0_awid      ( ip2hdm_aximm0_awid      ) ,       
   .ip2hdm_aximm0_awaddr    ( ip2hdm_aximm0_awaddr    ) ,       
   .ip2hdm_aximm0_awlen     ( ip2hdm_aximm0_awlen     ) ,       
   .ip2hdm_aximm0_awregion  ( ip2hdm_aximm0_awregion  ) ,       
   .ip2hdm_aximm0_awuser    ( ip2hdm_aximm0_awuser    ) ,       
   .ip2hdm_aximm0_awsize    ( ip2hdm_aximm0_awsize    ) ,      
   .ip2hdm_aximm0_awburst   ( ip2hdm_aximm0_awburst   ) ,      
   .ip2hdm_aximm0_awprot    ( ip2hdm_aximm0_awprot    ) ,      
   .ip2hdm_aximm0_awqos     ( ip2hdm_aximm0_awqos     ) ,      
   .ip2hdm_aximm0_awcache   ( ip2hdm_aximm0_awcache   ) ,      
   .ip2hdm_aximm0_awlock    ( ip2hdm_aximm0_awlock    ) ,      
   .hdm2ip_aximm0_awready   ( hdm2ip_aximm0_awready   ) ,
     /* write data channel
      */
   .ip2hdm_aximm0_wvalid    ( ip2hdm_aximm0_wvalid   ) ,          
   .ip2hdm_aximm0_wdata     ( ip2hdm_aximm0_wdata    ) ,           
   .ip2hdm_aximm0_wstrb     ( ip2hdm_aximm0_wstrb    ) ,           
   .ip2hdm_aximm0_wlast     ( ip2hdm_aximm0_wlast    ) ,           
   .ip2hdm_aximm0_wuser     ( ip2hdm_aximm0_wuser    ) ,           
   .hdm2ip_aximm0_wready  	( hdm2ip_aximm0_wready   ) ,
     /* write response channel
      */
   .hdm2ip_aximm0_bvalid    ( hdm2ip_aximm0_bvalid   ) ,
   .hdm2ip_aximm0_bid       ( hdm2ip_aximm0_bid      ) ,
   .hdm2ip_aximm0_buser     ( hdm2ip_aximm0_buser    ) ,
   .hdm2ip_aximm0_bresp     ( hdm2ip_aximm0_bresp    ) ,
   .ip2hdm_aximm0_bready    ( ip2hdm_aximm0_bready   ) ,               
     /* read address channel
      */
   .ip2hdm_aximm0_arvalid   ( ip2hdm_aximm0_arvalid  ) ,         
   .ip2hdm_aximm0_arid      ( ip2hdm_aximm0_arid     ) ,         
   .ip2hdm_aximm0_araddr    ( ip2hdm_aximm0_araddr   ) ,         
   .ip2hdm_aximm0_arlen     ( ip2hdm_aximm0_arlen    ) ,         
   .ip2hdm_aximm0_arregion  ( ip2hdm_aximm0_arregion ) ,         
   .ip2hdm_aximm0_aruser    ( ip2hdm_aximm0_aruser   ) ,         
   .ip2hdm_aximm0_arsize    ( ip2hdm_aximm0_arsize   ) ,         
   .ip2hdm_aximm0_arburst   ( ip2hdm_aximm0_arburst  ) ,         
   .ip2hdm_aximm0_arprot    ( ip2hdm_aximm0_arprot   ) ,         
   .ip2hdm_aximm0_arqos     ( ip2hdm_aximm0_arqos    ) ,         
   .ip2hdm_aximm0_arcache   ( ip2hdm_aximm0_arcache  ) ,         
   .ip2hdm_aximm0_arlock    ( ip2hdm_aximm0_arlock   ) ,         
   .hdm2ip_aximm0_arready   ( hdm2ip_aximm0_arready  ) , 
     /* read response channel
      */
   .hdm2ip_aximm0_rvalid    ( hdm2ip_aximm0_rvalid  )  ,
   .hdm2ip_aximm0_rlast     ( hdm2ip_aximm0_rlast  )  ,

   .hdm2ip_aximm0_rid       ( hdm2ip_aximm0_rid     )  ,
   .hdm2ip_aximm0_rdata     ( hdm2ip_aximm0_rdata   )  ,
   .hdm2ip_aximm0_ruser     ( hdm2ip_aximm0_ruser   )  ,
   .hdm2ip_aximm0_rresp     ( hdm2ip_aximm0_rresp   )  ,
   .ip2hdm_aximm0_rready    ( ip2hdm_aximm0_rready  )  ,   


//Channel-1
     /* write address channel
      */
   .ip2hdm_aximm1_awvalid   ( ip2hdm_aximm1_awvalid   ) ,       
   .ip2hdm_aximm1_awid      ( ip2hdm_aximm1_awid      ) ,       
   .ip2hdm_aximm1_awaddr    ( ip2hdm_aximm1_awaddr    ) ,       
   .ip2hdm_aximm1_awlen     ( ip2hdm_aximm1_awlen     ) ,       
   .ip2hdm_aximm1_awregion  ( ip2hdm_aximm1_awregion  ) ,       
   .ip2hdm_aximm1_awuser    ( ip2hdm_aximm1_awuser    ) ,       
   .ip2hdm_aximm1_awsize    ( ip2hdm_aximm1_awsize    ) ,      
   .ip2hdm_aximm1_awburst   ( ip2hdm_aximm1_awburst   ) ,      
   .ip2hdm_aximm1_awprot    ( ip2hdm_aximm1_awprot    ) ,      
   .ip2hdm_aximm1_awqos     ( ip2hdm_aximm1_awqos     ) ,      
   .ip2hdm_aximm1_awcache   ( ip2hdm_aximm1_awcache   ) ,      
   .ip2hdm_aximm1_awlock    ( ip2hdm_aximm1_awlock    ) ,      
   .hdm2ip_aximm1_awready   ( hdm2ip_aximm1_awready   ) ,
     /* write data channel
      */
   .ip2hdm_aximm1_wvalid    ( ip2hdm_aximm1_wvalid   ) ,          
   .ip2hdm_aximm1_wdata     ( ip2hdm_aximm1_wdata    ) ,           
   .ip2hdm_aximm1_wstrb     ( ip2hdm_aximm1_wstrb    ) ,           
   .ip2hdm_aximm1_wlast     ( ip2hdm_aximm1_wlast    ) ,           
   .ip2hdm_aximm1_wuser     ( ip2hdm_aximm1_wuser    ) ,           
   .hdm2ip_aximm1_wready  	( hdm2ip_aximm1_wready   ) ,
     /* write response channel
      */
   .hdm2ip_aximm1_bvalid    ( hdm2ip_aximm1_bvalid   ) ,
   .hdm2ip_aximm1_bid       ( hdm2ip_aximm1_bid      ) ,
   .hdm2ip_aximm1_buser     ( hdm2ip_aximm1_buser    ) ,
   .hdm2ip_aximm1_bresp     ( hdm2ip_aximm1_bresp    ) ,
   .ip2hdm_aximm1_bready    ( ip2hdm_aximm1_bready   ) ,               
     /* read address channel
      */
   .ip2hdm_aximm1_arvalid   ( ip2hdm_aximm1_arvalid  ) ,         
   .ip2hdm_aximm1_arid      ( ip2hdm_aximm1_arid     ) ,         
   .ip2hdm_aximm1_araddr    ( ip2hdm_aximm1_araddr   ) ,         
   .ip2hdm_aximm1_arlen     ( ip2hdm_aximm1_arlen    ) ,         
   .ip2hdm_aximm1_arregion  ( ip2hdm_aximm1_arregion ) ,         
   .ip2hdm_aximm1_aruser    ( ip2hdm_aximm1_aruser   ) ,         
   .ip2hdm_aximm1_arsize    ( ip2hdm_aximm1_arsize   ) ,         
   .ip2hdm_aximm1_arburst   ( ip2hdm_aximm1_arburst  ) ,         
   .ip2hdm_aximm1_arprot    ( ip2hdm_aximm1_arprot   ) ,         
   .ip2hdm_aximm1_arqos     ( ip2hdm_aximm1_arqos    ) ,         
   .ip2hdm_aximm1_arcache   ( ip2hdm_aximm1_arcache  ) ,         
   .ip2hdm_aximm1_arlock    ( ip2hdm_aximm1_arlock   ) ,         
   .hdm2ip_aximm1_arready   ( hdm2ip_aximm1_arready  ) , 
     /* read response channel
      */
   .hdm2ip_aximm1_rvalid    ( hdm2ip_aximm1_rvalid  )  ,
   .hdm2ip_aximm1_rlast     ( hdm2ip_aximm1_rlast  )  ,

   .hdm2ip_aximm1_rid       ( hdm2ip_aximm1_rid     )  ,
   .hdm2ip_aximm1_rdata     ( hdm2ip_aximm1_rdata   )  ,
   .hdm2ip_aximm1_ruser     ( hdm2ip_aximm1_ruser   )  ,
   .hdm2ip_aximm1_rresp     ( hdm2ip_aximm1_rresp   )  ,
   .ip2hdm_aximm1_rready    ( ip2hdm_aximm1_rready  )  , 
   
   


  
// AFU CSR
    .ip2csr_avmm_clk                   ,
    .ip2csr_avmm_rstn                  ,
    .csr2ip_avmm_waitrequest           ,
    .csr2ip_avmm_readdata              ,
    .csr2ip_avmm_readdatavalid         ,
    .ip2csr_avmm_writedata             ,
    .ip2cafu_avmm_poison         ,
    .ip2csr_avmm_address               ,
    .ip2csr_avmm_write                 ,
    .ip2csr_avmm_read                  ,
    .ip2csr_avmm_byteenable            ,

 
             //user interface 
    .ip2uio_tx_ready                         (ip2uio_tx_ready                          ), 
    .uio2ip_tx_st0_dvalid                    (uio2ip_tx_st0_dvalid                     ),   
    .uio2ip_tx_st0_sop                       (uio2ip_tx_st0_sop                        ),   
    .uio2ip_tx_st0_eop                       (uio2ip_tx_st0_eop                        ),   
    .uio2ip_tx_st0_data                      (uio2ip_tx_st0_data                       ),   
    .uio2ip_tx_st0_data_parity               (uio2ip_tx_st0_data_parity                ),   
    .uio2ip_tx_st0_hdr                       (uio2ip_tx_st0_hdr                        ),   
    .uio2ip_tx_st0_hdr_parity                (uio2ip_tx_st0_hdr_parity                 ),   
    .uio2ip_tx_st0_hvalid                    (uio2ip_tx_st0_hvalid                     ),   
    .uio2ip_tx_st0_prefix                    (uio2ip_tx_st0_prefix                     ),   
    .uio2ip_tx_st0_prefix_parity             (uio2ip_tx_st0_prefix_parity              ),   
    .uio2ip_tx_st0_pvalid                    (uio2ip_tx_st0_pvalid                     ),   
    .uio2ip_tx_st0_empty                     (uio2ip_tx_st0_empty                      ),   
    .uio2ip_tx_st0_misc_parity               (uio2ip_tx_st0_misc_parity                ),   
    .uio2ip_tx_st1_dvalid                    (uio2ip_tx_st1_dvalid                     ),   
    .uio2ip_tx_st1_sop                       (uio2ip_tx_st1_sop                        ),   
    .uio2ip_tx_st1_eop                       (uio2ip_tx_st1_eop                        ),   
    .uio2ip_tx_st1_data                      (uio2ip_tx_st1_data                       ),   
    .uio2ip_tx_st1_data_parity               (uio2ip_tx_st1_data_parity                ),   
    .uio2ip_tx_st1_hdr                       (uio2ip_tx_st1_hdr                        ),   
    .uio2ip_tx_st1_hdr_parity                (uio2ip_tx_st1_hdr_parity                 ),   
    .uio2ip_tx_st1_hvalid                    (uio2ip_tx_st1_hvalid                     ),   
    .uio2ip_tx_st1_prefix                    (uio2ip_tx_st1_prefix                     ),   
    .uio2ip_tx_st1_prefix_parity             (uio2ip_tx_st1_prefix_parity              ),   
    .uio2ip_tx_st1_pvalid                    (uio2ip_tx_st1_pvalid                     )  , 
    .uio2ip_tx_st1_empty                     (uio2ip_tx_st1_empty                      )  , 
    .uio2ip_tx_st1_misc_parity               (uio2ip_tx_st1_misc_parity                )  , 
    .uio2ip_tx_st2_dvalid                    (uio2ip_tx_st2_dvalid                     )  , 
    .uio2ip_tx_st2_sop                       (uio2ip_tx_st2_sop                        )  , 
    .uio2ip_tx_st2_eop                       (uio2ip_tx_st2_eop                        )  , 
    .uio2ip_tx_st2_data                      (uio2ip_tx_st2_data                       )  , 
    .uio2ip_tx_st2_data_parity               (uio2ip_tx_st2_data_parity                )  , 
    .uio2ip_tx_st2_hdr                       (uio2ip_tx_st2_hdr                        )  , 
    .uio2ip_tx_st2_hdr_parity                (uio2ip_tx_st2_hdr_parity                 )  , 
    .uio2ip_tx_st2_hvalid                    (uio2ip_tx_st2_hvalid                     )  , 
    .uio2ip_tx_st2_prefix                    (uio2ip_tx_st2_prefix                     )  , 
    .uio2ip_tx_st2_prefix_parity             (uio2ip_tx_st2_prefix_parity              )  , 
    .uio2ip_tx_st2_pvalid                    (uio2ip_tx_st2_pvalid                     )  , 
    .uio2ip_tx_st2_empty                     (uio2ip_tx_st2_empty                      )  , 
    .uio2ip_tx_st2_misc_parity               (uio2ip_tx_st2_misc_parity                )  , 
    .uio2ip_tx_st3_dvalid                    (uio2ip_tx_st3_dvalid                     )  , 
    .uio2ip_tx_st3_sop                       (uio2ip_tx_st3_sop                        )  , 
    .uio2ip_tx_st3_eop                       (uio2ip_tx_st3_eop                        )  , 
    .uio2ip_tx_st3_data                      (uio2ip_tx_st3_data                       )  , 
    .uio2ip_tx_st3_data_parity               (uio2ip_tx_st3_data_parity                )  , 
    .uio2ip_tx_st3_hdr                       (uio2ip_tx_st3_hdr                        )  , 
    .uio2ip_tx_st3_hdr_parity                (uio2ip_tx_st3_hdr_parity                 )  , 
    .uio2ip_tx_st3_hvalid                    (uio2ip_tx_st3_hvalid                     )  , 
    .uio2ip_tx_st3_prefix                    (uio2ip_tx_st3_prefix                     )  , 
    .uio2ip_tx_st3_prefix_parity             (uio2ip_tx_st3_prefix_parity              )  , 
    .uio2ip_tx_st3_pvalid                    (uio2ip_tx_st3_pvalid                     )  , 
    .uio2ip_tx_st3_empty                     (uio2ip_tx_st3_empty                      )  , 
    .uio2ip_tx_st3_misc_parity               (uio2ip_tx_st3_misc_parity                )  , 
    .ip2uio_tx_st_Hcrdt_update               (ip2uio_tx_st_Hcrdt_update                )  , 
    .ip2uio_tx_st_Hcrdt_update_cnt           (ip2uio_tx_st_Hcrdt_update_cnt            )  , 
    .ip2uio_tx_st_Hcrdt_init                 (ip2uio_tx_st_Hcrdt_init                  )  , 
    .uio2ip_tx_st_Hcrdt_init_ack             (uio2ip_tx_st_Hcrdt_init_ack              )  , 
    .ip2uio_tx_st_Dcrdt_update               (ip2uio_tx_st_Dcrdt_update                )  , 
    .ip2uio_tx_st_Dcrdt_update_cnt           (ip2uio_tx_st_Dcrdt_update_cnt            )  , 
    .ip2uio_tx_st_Dcrdt_init                 (ip2uio_tx_st_Dcrdt_init                  )  , 
    .uio2ip_tx_st_Dcrdt_init_ack             (uio2ip_tx_st_Dcrdt_init_ack              )  , 
    .ip2uio_rx_st0_dvalid                    (ip2uio_rx_st0_dvalid                     )  , 
    .ip2uio_rx_st0_sop                       (ip2uio_rx_st0_sop                        )  , 
    .ip2uio_rx_st0_eop                       (ip2uio_rx_st0_eop                        )  , 
    .ip2uio_rx_st0_passthrough               (ip2uio_rx_st0_passthrough                )  , 
    .ip2uio_rx_st0_data                      (ip2uio_rx_st0_data                       )  , 
    .ip2uio_rx_st0_data_parity               (ip2uio_rx_st0_data_parity                )  , 
    .ip2uio_rx_st0_hdr                       (ip2uio_rx_st0_hdr                        )  , 
    .ip2uio_rx_st0_hdr_parity                (ip2uio_rx_st0_hdr_parity                 )  , 
    .ip2uio_rx_st0_hvalid                    (ip2uio_rx_st0_hvalid                     )  , 
    .ip2uio_rx_st0_prefix                    (ip2uio_rx_st0_prefix                     )  , 
    .ip2uio_rx_st0_prefix_parity             (ip2uio_rx_st0_prefix_parity              )  , 
    .ip2uio_rx_st0_pvalid                    (ip2uio_rx_st0_pvalid                     ),   
    .ip2uio_rx_st0_bar                       (ip2uio_rx_st0_bar                        ),   
    .ip2uio_rx_st0_pfnum                     (ip2uio_rx_st0_pfnum                      ),   
    .ip2uio_rx_st0_misc_parity               (ip2uio_rx_st0_misc_parity                ),   
    .ip2uio_rx_st0_empty                     (ip2uio_rx_st0_empty                      ),   
    .ip2uio_rx_st1_dvalid                    (ip2uio_rx_st1_dvalid                     ),   
    .ip2uio_rx_st1_sop                       (ip2uio_rx_st1_sop                        ),   
    .ip2uio_rx_st1_eop                       (ip2uio_rx_st1_eop                        ),   
    .ip2uio_rx_st1_passthrough               (ip2uio_rx_st1_passthrough                ),   
    .ip2uio_rx_st1_data                      (ip2uio_rx_st1_data                       ),   
    .ip2uio_rx_st1_data_parity               (ip2uio_rx_st1_data_parity                ),   
    .ip2uio_rx_st1_hdr                       (ip2uio_rx_st1_hdr                        ),   
    .ip2uio_rx_st1_hdr_parity                (ip2uio_rx_st1_hdr_parity                 ),   
    .ip2uio_rx_st1_hvalid                    (ip2uio_rx_st1_hvalid                     ),   
    .ip2uio_rx_st1_prefix                    (ip2uio_rx_st1_prefix                     ),   
    .ip2uio_rx_st1_prefix_parity             (ip2uio_rx_st1_prefix_parity              ),   
    .ip2uio_rx_st1_pvalid                    (ip2uio_rx_st1_pvalid                     )  , 
    .ip2uio_rx_st1_bar                       (ip2uio_rx_st1_bar                        )  , 
    .ip2uio_rx_st1_pfnum                     (ip2uio_rx_st1_pfnum                      )  , 
    .ip2uio_rx_st1_misc_parity               (ip2uio_rx_st1_misc_parity                )  , 
    .ip2uio_rx_st1_empty                     (ip2uio_rx_st1_empty                      )  , 
    .ip2uio_rx_st2_dvalid                    (ip2uio_rx_st2_dvalid                     )  , 
    .ip2uio_rx_st2_sop                       (ip2uio_rx_st2_sop                        )  , 
    .ip2uio_rx_st2_eop                       (ip2uio_rx_st2_eop                        )  , 
    .ip2uio_rx_st2_passthrough               (ip2uio_rx_st2_passthrough                )  , 
    .ip2uio_rx_st2_data                      (ip2uio_rx_st2_data                       )  , 
    .ip2uio_rx_st2_data_parity               (ip2uio_rx_st2_data_parity                )  , 
    .ip2uio_rx_st2_hdr                       (ip2uio_rx_st2_hdr                        )  , 
    .ip2uio_rx_st2_hdr_parity                (ip2uio_rx_st2_hdr_parity                 )  , 
    .ip2uio_rx_st2_hvalid                    (ip2uio_rx_st2_hvalid                     )  , 
    .ip2uio_rx_st2_prefix                    (ip2uio_rx_st2_prefix                     )  , 
    .ip2uio_rx_st2_prefix_parity             (ip2uio_rx_st2_prefix_parity              )  , 
    .ip2uio_rx_st2_pvalid                    (ip2uio_rx_st2_pvalid                     )  , 
    .ip2uio_rx_st2_bar                       (ip2uio_rx_st2_bar                        )  , 
    .ip2uio_rx_st2_pfnum                     (ip2uio_rx_st2_pfnum                      )  , 
    .ip2uio_rx_st2_misc_parity               (ip2uio_rx_st2_misc_parity                )  , 
    .ip2uio_rx_st2_empty                     (ip2uio_rx_st2_empty                      )  , 
    .ip2uio_rx_st3_dvalid                    (ip2uio_rx_st3_dvalid                     )  , 
    .ip2uio_rx_st3_sop                       (ip2uio_rx_st3_sop                        )  , 
    .ip2uio_rx_st3_eop                       (ip2uio_rx_st3_eop                        )  , 
    .ip2uio_rx_st3_passthrough               (ip2uio_rx_st3_passthrough                )  , 
    .ip2uio_rx_st3_data                      (ip2uio_rx_st3_data                       )  , 
    .ip2uio_rx_st3_data_parity               (ip2uio_rx_st3_data_parity                )  , 
    .ip2uio_rx_st3_hdr                       (ip2uio_rx_st3_hdr                        )  , 
    .ip2uio_rx_st3_hdr_parity                (ip2uio_rx_st3_hdr_parity                 )  , 
    .ip2uio_rx_st3_hvalid                    (ip2uio_rx_st3_hvalid                     )  , 
    .ip2uio_rx_st3_prefix                    (ip2uio_rx_st3_prefix                     )  , 
    .ip2uio_rx_st3_prefix_parity             (ip2uio_rx_st3_prefix_parity              )  , 
    .ip2uio_rx_st3_pvalid                    (ip2uio_rx_st3_pvalid                     )  , 
    .ip2uio_rx_st3_bar                       (ip2uio_rx_st3_bar                        )  , 
    .ip2uio_rx_st3_pfnum                     (ip2uio_rx_st3_pfnum                      )  , 
    .ip2uio_rx_st3_misc_parity               (ip2uio_rx_st3_misc_parity                )  , 
    .ip2uio_rx_st3_empty                     (ip2uio_rx_st3_empty                      )  , 
    .uio2ip_rx_st_Hcrdt_update               (uio2ip_rx_st_Hcrdt_update                )  ,  
    .uio2ip_rx_st_Hcrdt_update_cnt           (uio2ip_rx_st_Hcrdt_update_cnt            )  ,  
    .uio2ip_rx_st_Hcrdt_init                 (uio2ip_rx_st_Hcrdt_init                  )  ,  
    .ip2uio_rx_st_Hcrdt_init_ack             (ip2uio_rx_st_Hcrdt_init_ack              )  ,  
    .uio2ip_rx_st_Dcrdt_update               (uio2ip_rx_st_Dcrdt_update                )  ,  
    .uio2ip_rx_st_Dcrdt_update_cnt           (uio2ip_rx_st_Dcrdt_update_cnt            )  ,  
    .uio2ip_rx_st_Dcrdt_init                 (uio2ip_rx_st_Dcrdt_init                  )  ,  
    .ip2uio_rx_st_Dcrdt_init_ack             (ip2uio_rx_st_Dcrdt_init_ack              )  ,  
    .ip2uio_bus_number                       (ip2uio_bus_number                        )  ,  
    .ip2uio_device_number                    (ip2uio_device_number                     )    

  );

 
  //-------------------------------------------------------
  //---------------- Example Design ------------------
  //-------------------------------------------------------

//<<<
ed_top_wrapper_typ3 ed_top_wrapper_typ3_inst
(
 // Clocks
    .ip2hdm_clk                          (ip2hdm_clk),          // SIP clk    : $PLD CLK 

 // Resets
    .ip2hdm_reset_n                      (ip2hdm_reset_n),                                        //r_tbd : which reset to connect ?

//MSI-X interface 
  .pf0_msix_enable                     (pf0_msix_enable ),
  .pf0_msix_fn_mask                    (pf0_msix_fn_mask),
  .pf1_msix_enable                     (pf1_msix_enable ),
  .pf1_msix_fn_mask                    (pf1_msix_fn_mask),
  .dev_serial_num                      (dev_serial_num),
  .dev_serial_num_valid                (dev_serial_num_valid),
  .ip2cafu_quiesce_req                 (ip2cafu_quiesce_req),
  .cafu2ip_quiesce_ack                 (cafu2ip_quiesce_ack),
  .usr2ip_gpf_ph2_ack                   (usr2ip_gpf_ph2_ack ),                   
  .ip2usr_gpf_ph2_req                   (ip2usr_gpf_ph2_req ),
  .ccv_afu_conf_base_addr_high         (ccv_afu_conf_base_addr_high),
  .ccv_afu_conf_base_addr_high_valid   (ccv_afu_conf_base_addr_high_valid),
  .ccv_afu_conf_base_addr_low          (ccv_afu_conf_base_addr_low),
  .ccv_afu_conf_base_addr_low_valid    (ccv_afu_conf_base_addr_low_valid),
  .pf0_max_payload_size     (pf0_max_payload_size     ),
  .pf0_max_read_request_size(pf0_max_read_request_size),
  .pf0_bus_master_en        (pf0_bus_master_en        ),
  .pf0_memory_access_en     (pf0_memory_access_en     ),
  .pf1_max_payload_size     (pf1_max_payload_size     ),
  .pf1_max_read_request_size(pf1_max_read_request_size),
  .pf1_bus_master_en        (pf1_bus_master_en        ),
  .pf1_memory_access_en     (pf1_memory_access_en     ),

    .usr2ip_app_err_valid   ,
    .usr2ip_app_err_hdr     ,
    .usr2ip_app_err_info    ,
    .usr2ip_app_err_func_num,
    .ip2usr_app_err_ready   ,
    .ip2usr_aermsg_correctable_valid     (ip2usr_aermsg_correctable_valid  ),
    .ip2usr_aermsg_uncorrectable_valid   (ip2usr_aermsg_uncorrectable_valid),
    .ip2usr_aermsg_res                   (ip2usr_aermsg_res                ),    
    .ip2usr_aermsg_bts                   (ip2usr_aermsg_bts                ),    
    .ip2usr_aermsg_bds                   (ip2usr_aermsg_bds                ),    
    .ip2usr_aermsg_rrs                   (ip2usr_aermsg_rrs                ),    
    .ip2usr_aermsg_rtts                  (ip2usr_aermsg_rtts               ),    
    .ip2usr_aermsg_anes                  (ip2usr_aermsg_anes               ),    
    .ip2usr_aermsg_cies                  (ip2usr_aermsg_cies               ),    
    .ip2usr_aermsg_hlos                  (ip2usr_aermsg_hlos               ),    
    .ip2usr_aermsg_fmt                   (ip2usr_aermsg_fmt                ),    
    .ip2usr_aermsg_type                  (ip2usr_aermsg_type               ),    
    .ip2usr_aermsg_tc                    (ip2usr_aermsg_tc                 ),    
    .ip2usr_aermsg_ido                   (ip2usr_aermsg_ido                ),    
    .ip2usr_aermsg_th                    (ip2usr_aermsg_th                 ),    
    .ip2usr_aermsg_td                    (ip2usr_aermsg_td                 ),    
    .ip2usr_aermsg_ep                    (ip2usr_aermsg_ep                 ),    
    .ip2usr_aermsg_ro                    (ip2usr_aermsg_ro                 ),    
    .ip2usr_aermsg_ns                    (ip2usr_aermsg_ns                 ),    
    .ip2usr_aermsg_at                    (ip2usr_aermsg_at                 ),    
    .ip2usr_aermsg_length                (ip2usr_aermsg_length             ),  
    .ip2usr_aermsg_header                (ip2usr_aermsg_header             ),  
    .ip2usr_aermsg_und                   (ip2usr_aermsg_und                ),     
    .ip2usr_aermsg_anf                   (ip2usr_aermsg_anf                ),     
    .ip2usr_aermsg_dlpes                 (ip2usr_aermsg_dlpes              ),   
    .ip2usr_aermsg_sdes                  (ip2usr_aermsg_sdes               ),    
    .ip2usr_aermsg_fep                   (ip2usr_aermsg_fep                ),     
    .ip2usr_aermsg_pts                   (ip2usr_aermsg_pts                ),     
    .ip2usr_aermsg_fcpes                 (ip2usr_aermsg_fcpes              ),   
    .ip2usr_aermsg_cts                   (ip2usr_aermsg_cts                ),    
    .ip2usr_aermsg_cas                   (ip2usr_aermsg_cas                ),    
    .ip2usr_aermsg_ucs                   (ip2usr_aermsg_ucs                ),    
    .ip2usr_aermsg_ros                   (ip2usr_aermsg_ros                ),    
    .ip2usr_aermsg_mts                   (ip2usr_aermsg_mts                ),    
    .ip2usr_aermsg_uies                  (ip2usr_aermsg_uies               ),    
    .ip2usr_aermsg_mbts                  (ip2usr_aermsg_mbts               ),    
    .ip2usr_aermsg_aebs                  (ip2usr_aermsg_aebs               ),    
    .ip2usr_aermsg_tpbes                 (ip2usr_aermsg_tpbes              ),   
    .ip2usr_aermsg_ees                   (ip2usr_aermsg_ees                ),     
    .ip2usr_aermsg_ures                  (ip2usr_aermsg_ures               ),    
    .ip2usr_aermsg_avs                   (ip2usr_aermsg_avs                ), 
     

    .ip2usr_serr_out        , 

    .ip2usr_debug_waitrequest   ,
    .ip2usr_debug_readdata      ,
    .ip2usr_debug_readdatavalid ,
    .usr2ip_debug_writedata     ,
    .usr2ip_debug_address       ,
    .usr2ip_debug_write         ,
    .usr2ip_debug_read          ,
    .usr2ip_debug_byteenable    ,

    .usr2ip_cxlreset_initiate,
    .ip2usr_cxlreset_req,     
    .usr2ip_cxlreset_ack,     
    .ip2usr_cxlreset_error,   
    .ip2usr_cxlreset_complete,

    //ccv_afu signals starts here 
    .ip2cafu_avmm_clk           , 
    .ip2cafu_avmm_rstn          ,
 
    .cafu2ip_avmm_waitrequest   ,   
    .cafu2ip_avmm_readdata      , 
    .cafu2ip_avmm_readdatavalid , 
    .ip2cafu_avmm_writedata     , 
    .ip2csr_avmm_poison        ,
    .ip2cafu_avmm_address       , 
    .ip2cafu_avmm_write         , 
    .ip2cafu_avmm_read          , 
    .ip2cafu_avmm_byteenable    , 





  //ccv_afu signals ends here 
    .ip2csr_avmm_clk                   ,
    .ip2csr_avmm_rstn                  ,
    .csr2ip_avmm_waitrequest           ,
    .csr2ip_avmm_readdata              ,
    .csr2ip_avmm_readdatavalid         ,
    .ip2csr_avmm_writedata             ,
    .ip2cafu_avmm_poison         ,
    .ip2csr_avmm_address               ,
    .ip2csr_avmm_write                 ,
    .ip2csr_avmm_read                  ,
    .ip2csr_avmm_byteenable            ,




//intel_cxl_pio_ed_top intel_cxl_pio_ed_top_inst 
    .ed_rx_st0_bar_i                  (ip2uio_rx_st0_bar                   ) ,                                 
    .ed_rx_st1_bar_i                  (ip2uio_rx_st1_bar                   ) ,                                 
    .ed_rx_st2_bar_i                  (ip2uio_rx_st2_bar                   ) ,                                 
    .ed_rx_st3_bar_i                  (ip2uio_rx_st3_bar                   ) ,                                 
    .ed_rx_st0_eop_i                  (ip2uio_rx_st0_eop                   ) ,                                 
    .ed_rx_st1_eop_i                  (ip2uio_rx_st1_eop                   ) ,                                 
    .ed_rx_st2_eop_i                  (ip2uio_rx_st2_eop                   ) ,                                 
    .ed_rx_st3_eop_i                  (ip2uio_rx_st3_eop                   ) ,                                 
    .ed_rx_st0_header_i               (ip2uio_rx_st0_hdr                   ) ,                                 
    .ed_rx_st1_header_i               (ip2uio_rx_st1_hdr                   ) ,                                 
    .ed_rx_st2_header_i               (ip2uio_rx_st2_hdr                   ) ,                                 
    .ed_rx_st3_header_i               (ip2uio_rx_st3_hdr                   ) ,                                 
    .ed_rx_st0_payload_i              (ip2uio_rx_st0_data               ) ,                                 
    .ed_rx_st1_payload_i              (ip2uio_rx_st1_data               ) ,                                 
    .ed_rx_st2_payload_i              (ip2uio_rx_st2_data               ) ,                                 
    .ed_rx_st3_payload_i              (ip2uio_rx_st3_data               ) ,                                 
    .ed_rx_st0_sop_i                  (ip2uio_rx_st0_sop                   ) ,                                 
    .ed_rx_st1_sop_i                  (ip2uio_rx_st1_sop                   ) ,                                 
    .ed_rx_st2_sop_i                  (ip2uio_rx_st2_sop                   ) ,                                 
    .ed_rx_st3_sop_i                  (ip2uio_rx_st3_sop                   ) ,                                 
    .ed_rx_st0_hvalid_i               (ip2uio_rx_st0_hvalid                ) ,                                 
    .ed_rx_st1_hvalid_i               (ip2uio_rx_st1_hvalid                ) ,                                 
    .ed_rx_st2_hvalid_i               (ip2uio_rx_st2_hvalid                ) ,                                 
    .ed_rx_st3_hvalid_i               (ip2uio_rx_st3_hvalid                ) ,                                 
    .ed_rx_st0_dvalid_i               (ip2uio_rx_st0_dvalid                ) ,                                 
    .ed_rx_st1_dvalid_i               (ip2uio_rx_st1_dvalid                ) ,                                 
    .ed_rx_st2_dvalid_i               (ip2uio_rx_st2_dvalid                ) ,                                 
    .ed_rx_st3_dvalid_i               (ip2uio_rx_st3_dvalid                ) ,                                 
    .ed_rx_st0_pvalid_i               (ip2uio_rx_st0_pvalid                ) ,                                 
    .ed_rx_st1_pvalid_i               (ip2uio_rx_st1_pvalid                ) ,                                 
    .ed_rx_st2_pvalid_i               (ip2uio_rx_st2_pvalid                ) ,                                 
    .ed_rx_st3_pvalid_i               (ip2uio_rx_st3_pvalid                ) ,                                 
    .ed_rx_st0_empty_i                (ip2uio_rx_st0_empty                 ) ,                                 
    .ed_rx_st1_empty_i                (ip2uio_rx_st1_empty                 ) ,                                 
    .ed_rx_st2_empty_i                (ip2uio_rx_st2_empty                 ) ,                                 
    .ed_rx_st3_empty_i                (ip2uio_rx_st3_empty                 ) ,                                 
    .ed_rx_st0_pfnum_i                (ip2uio_rx_st0_pfnum                 ) ,    
    .ed_rx_st1_pfnum_i                (ip2uio_rx_st1_pfnum                 ) ,                                 
    .ed_rx_st2_pfnum_i                (ip2uio_rx_st2_pfnum                 ) ,                                 
    .ed_rx_st3_pfnum_i                (ip2uio_rx_st3_pfnum                 ) ,                                 
    .ed_rx_st0_tlp_prfx_i             (ip2uio_rx_st0_prefix                ) ,                                 
    .ed_rx_st1_tlp_prfx_i             (ip2uio_rx_st1_prefix                ) ,                                 
    .ed_rx_st2_tlp_prfx_i             (ip2uio_rx_st2_prefix                ) ,                                 
    .ed_rx_st3_tlp_prfx_i             (ip2uio_rx_st3_prefix                ) ,                                 
    .ed_rx_st0_data_parity_i          (ip2uio_rx_st0_data_parity           ) ,                                 
    .ed_rx_st0_hdr_parity_i           (ip2uio_rx_st0_hdr_parity            ) ,                                   
    .ed_rx_st0_tlp_prfx_parity_i      (ip2uio_rx_st0_prefix_parity       ) ,                                   
    .ed_rx_st0_misc_parity_i          (ip2uio_rx_st0_misc_parity           ) ,                                   
    .ed_rx_st1_data_parity_i          (ip2uio_rx_st1_data_parity           ) ,                                   
    .ed_rx_st1_hdr_parity_i           (ip2uio_rx_st1_hdr_parity            ) ,                                   
    .ed_rx_st1_tlp_prfx_parity_i      (ip2uio_rx_st1_prefix_parity       ) ,                                   
    .ed_rx_st1_misc_parity_i          (ip2uio_rx_st1_misc_parity           ) ,                                   
    .ed_rx_st2_data_parity_i           (ip2uio_rx_st2_data_parity          ) ,                                
    .ed_rx_st2_hdr_parity_i            (ip2uio_rx_st2_hdr_parity           ) ,                                
    .ed_rx_st2_tlp_prfx_parity_i       (ip2uio_rx_st2_prefix_parity      ) ,                                
    .ed_rx_st2_misc_parity_i           (ip2uio_rx_st2_misc_parity          ) ,                                
    .ed_rx_st3_data_parity_i           (ip2uio_rx_st3_data_parity          ) ,                                
    .ed_rx_st3_hdr_parity_i            (ip2uio_rx_st3_hdr_parity           ) ,                                
    .ed_rx_st3_tlp_prfx_parity_i       (ip2uio_rx_st3_prefix_parity      ) ,                                
    .ed_rx_st3_misc_parity_i           (ip2uio_rx_st3_misc_parity          ) ,                                
    .ed_rx_bus_number                  (ip2uio_bus_number                   ) ,
    .ed_rx_device_number               (ip2uio_device_number                ) ,
    .ed_rx_function_number             (3'd0)                               ,
    
    .ed_rx_st_ready_o                  (usr_rx_st_ready                  ) ,                             
    .ed_clk                            (usr_clk                          ) ,                             
    .ed_rst_n                          (usr_rst_n                        ) ,                             
    .ed_tx_st0_eop_o                   (uio2ip_tx_st0_eop                  ) ,                             
    .ed_tx_st1_eop_o                   (uio2ip_tx_st1_eop                  ) ,                             
    .ed_tx_st2_eop_o                   (uio2ip_tx_st2_eop                  ) ,                             
    .ed_tx_st3_eop_o                   (uio2ip_tx_st3_eop                  ) ,                             
    .ed_tx_st0_header_o                (uio2ip_tx_st0_hdr               ) ,                             
    .ed_tx_st1_header_o                (uio2ip_tx_st1_hdr               ) ,                             
    .ed_tx_st2_header_o                (uio2ip_tx_st2_hdr               ) ,                             
    .ed_tx_st3_header_o                (uio2ip_tx_st3_hdr               ) ,                             
    .ed_tx_st0_prefix_o                (uio2ip_tx_st0_prefix               ) ,                             
    .ed_tx_st1_prefix_o                (uio2ip_tx_st1_prefix               ) ,                             
    .ed_tx_st2_prefix_o                (uio2ip_tx_st2_prefix               ) ,                             
    .ed_tx_st3_prefix_o                (uio2ip_tx_st3_prefix               ) ,                             
    .ed_tx_st0_payload_o               (uio2ip_tx_st0_data                 ) ,                             
    .ed_tx_st1_payload_o               (uio2ip_tx_st1_data                 ) ,                             
    .ed_tx_st2_payload_o               (uio2ip_tx_st2_data                 ) ,                             
    .ed_tx_st3_payload_o               (uio2ip_tx_st3_data                 ) ,                             
    .ed_tx_st0_sop_o                   (uio2ip_tx_st0_sop                  ) ,                             
    .ed_tx_st1_sop_o                   (uio2ip_tx_st1_sop                  ) ,                             
    .ed_tx_st2_sop_o                   (uio2ip_tx_st2_sop                  ) ,                             
    .ed_tx_st3_sop_o                   (uio2ip_tx_st3_sop                  ) ,                             
    .ed_tx_st0_dvalid_o                (uio2ip_tx_st0_dvalid               ) ,                             
    .ed_tx_st1_dvalid_o                (uio2ip_tx_st1_dvalid               ) ,                             
    .ed_tx_st2_dvalid_o                (uio2ip_tx_st2_dvalid               ) ,                             
    .ed_tx_st3_dvalid_o                (uio2ip_tx_st3_dvalid               ) ,                             
    .ed_tx_st0_pvalid_o                (uio2ip_tx_st0_pvalid               ) ,                             
    .ed_tx_st1_pvalid_o                (uio2ip_tx_st1_pvalid               ) ,                             
    .ed_tx_st2_pvalid_o                (uio2ip_tx_st2_pvalid               ) ,                             
    .ed_tx_st3_pvalid_o                (uio2ip_tx_st3_pvalid               ) ,                             
    .ed_tx_st0_hvalid_o                (uio2ip_tx_st0_hvalid               ) ,                             
    .ed_tx_st1_hvalid_o                (uio2ip_tx_st1_hvalid               ) ,                             
    .ed_tx_st2_hvalid_o                (uio2ip_tx_st2_hvalid               ) ,                             
    .ed_tx_st3_hvalid_o                (uio2ip_tx_st3_hvalid               ) ,                             
    .ed_tx_st0_data_parity             (uio2ip_tx_st0_data_parity          ) ,                               
    .ed_tx_st0_hdr_parity              (uio2ip_tx_st0_hdr_parity           ) ,                               
    .ed_tx_st0_prefix_parity           (uio2ip_tx_st0_prefix_parity        ) ,                               
    .ed_tx_st0_empty                   (uio2ip_tx_st0_empty                ) ,                               
    .ed_tx_st0_misc_parity             (uio2ip_tx_st0_misc_parity          ) ,                               
    .ed_tx_st1_data_parity             (uio2ip_tx_st1_data_parity          ) ,                               
    .ed_tx_st1_hdr_parity              (uio2ip_tx_st1_hdr_parity           ) ,                               
    .ed_tx_st1_prefix_parity           (uio2ip_tx_st1_prefix_parity        ) ,                               
    .ed_tx_st1_empty                   (uio2ip_tx_st1_empty                ) ,                               
    .ed_tx_st1_misc_parity             (uio2ip_tx_st1_misc_parity          ) ,                               
    .ed_tx_st2_data_parity             (uio2ip_tx_st2_data_parity          ) ,                               
    .ed_tx_st2_hdr_parity              (uio2ip_tx_st2_hdr_parity           ) ,                               
    .ed_tx_st2_prefix_parity           (uio2ip_tx_st2_prefix_parity        ) ,                               
    .ed_tx_st2_empty                   (uio2ip_tx_st2_empty                ) ,                               
    .ed_tx_st2_misc_parity             (uio2ip_tx_st2_misc_parity          ) ,                               
    .ed_tx_st3_data_parity             (uio2ip_tx_st3_data_parity          ) ,                               
    .ed_tx_st3_hdr_parity              (uio2ip_tx_st3_hdr_parity           ) ,                               
    .ed_tx_st3_prefix_parity           (uio2ip_tx_st3_prefix_parity        ) ,                               
    .ed_tx_st3_empty                   (uio2ip_tx_st3_empty                ) ,                               
    .ed_tx_st3_misc_parity             (uio2ip_tx_st3_misc_parity          ) ,                               
    .ed_tx_st_ready_i                  (ip2uio_tx_ready                  ) ,                             
   
    .rx_st_hcrdt_update_o              (uio2ip_rx_st_Hcrdt_update           ) ,                               
    .rx_st_hcrdt_update_cnt_o          (uio2ip_rx_st_Hcrdt_update_cnt       ) ,                               
    .rx_st_hcrdt_init_o                (uio2ip_rx_st_Hcrdt_init             ) ,                               
    .rx_st_hcrdt_init_ack_i            (ip2uio_rx_st_Hcrdt_init_ack         ) ,                               
    .rx_st_dcrdt_update_o              (uio2ip_rx_st_Dcrdt_update           ) ,                               
    .rx_st_dcrdt_update_cnt_o          (uio2ip_rx_st_Dcrdt_update_cnt       ) ,                               
    .rx_st_dcrdt_init_o                (uio2ip_rx_st_Dcrdt_init             ) ,                               
    .rx_st_dcrdt_init_ack_i            (ip2uio_rx_st_Dcrdt_init_ack         ) ,                               
   
    .tx_st_hcrdt_update_i              (ip2uio_tx_st_Hcrdt_update           ) ,                               
    .tx_st_hcrdt_update_cnt_i          (ip2uio_tx_st_Hcrdt_update_cnt       ) ,                               
    .tx_st_hcrdt_init_i                (ip2uio_tx_st_Hcrdt_init             ) ,                               
    .tx_st_hcrdt_init_ack_o            (uio2ip_tx_st_Hcrdt_init_ack         ) ,                               
    .tx_st_dcrdt_update_i              (ip2uio_tx_st_Dcrdt_update           ) ,                               
    .tx_st_dcrdt_update_cnt_i          (ip2uio_tx_st_Dcrdt_update_cnt       ) ,                               
    .tx_st_dcrdt_init_i                (ip2uio_tx_st_Dcrdt_init             ) ,                               
    .tx_st_dcrdt_init_ack_o            (uio2ip_tx_st_Dcrdt_init_ack         ) ,                               
   
    .ed_rx_st0_passthrough_i           (ip2uio_rx_st0_passthrough          ) ,                               
    .ed_rx_st1_passthrough_i           (ip2uio_rx_st1_passthrough          ) ,                               
    .ed_rx_st2_passthrough_i           (ip2uio_rx_st2_passthrough          ) ,                               
    .ed_rx_st3_passthrough_i           (ip2uio_rx_st3_passthrough          ) ,                               
    
    // External CSR <--> CXL-IP
   
      .cafu2ip_csr0_cfg_if              (cafu2ip_csr0_cfg_if  ),
      .ip2cafu_csr0_cfg_if              (ip2cafu_csr0_cfg_if  ),


  //mc_top 
    // DDRMC <--> CXL-IP
     // .hdm_size_256mb                   (hdm_size_256mb  ) ,    	 
      .mc2ip_memsize                    (mc2ip_memsize   ) ,      
 
    .usr2ip_qos_devload                     (usr2ip_qos_devload     ),

    //Channel-->0	  
    .mc2ip_0_sr_status                     (mc2ip_0_sr_status          ),
    .mc2ip_1_sr_status                     (mc2ip_1_sr_status          ),
        
 

//Channel-0
     /* write address channel
      */
   .ip2hdm_aximm0_awvalid   ( ip2hdm_aximm0_awvalid   ) ,       
   .ip2hdm_aximm0_awid      ( ip2hdm_aximm0_awid      ) ,       
   .ip2hdm_aximm0_awaddr    ( ip2hdm_aximm0_awaddr    ) ,       
   .ip2hdm_aximm0_awlen     ( ip2hdm_aximm0_awlen     ) ,       
   .ip2hdm_aximm0_awregion  ( ip2hdm_aximm0_awregion  ) ,       
   .ip2hdm_aximm0_awuser    ( ip2hdm_aximm0_awuser    ) ,       
   .ip2hdm_aximm0_awsize    ( ip2hdm_aximm0_awsize    ) ,      
   .ip2hdm_aximm0_awburst   ( ip2hdm_aximm0_awburst   ) ,      
   .ip2hdm_aximm0_awprot    ( ip2hdm_aximm0_awprot    ) ,      
   .ip2hdm_aximm0_awqos     ( ip2hdm_aximm0_awqos     ) ,      
   .ip2hdm_aximm0_awcache   ( ip2hdm_aximm0_awcache   ) ,      
   .ip2hdm_aximm0_awlock    ( ip2hdm_aximm0_awlock    ) ,      
   .hdm2ip_aximm0_awready   ( hdm2ip_aximm0_awready   ) ,
     /* write data channel
      */
   .ip2hdm_aximm0_wvalid    ( ip2hdm_aximm0_wvalid   ) ,          
   .ip2hdm_aximm0_wdata     ( ip2hdm_aximm0_wdata    ) ,           
   .ip2hdm_aximm0_wstrb     ( ip2hdm_aximm0_wstrb    ) ,           
   .ip2hdm_aximm0_wlast     ( ip2hdm_aximm0_wlast    ) ,           
   .ip2hdm_aximm0_wuser     ( ip2hdm_aximm0_wuser    ) ,           
   .hdm2ip_aximm0_wready  	( hdm2ip_aximm0_wready   ) ,
     /* write response channel
      */
   .hdm2ip_aximm0_bvalid    ( hdm2ip_aximm0_bvalid   ) ,
   .hdm2ip_aximm0_bid       ( hdm2ip_aximm0_bid      ) ,
   .hdm2ip_aximm0_buser     ( hdm2ip_aximm0_buser    ) ,
   .hdm2ip_aximm0_bresp     ( hdm2ip_aximm0_bresp    ) ,
   .ip2hdm_aximm0_bready    ( ip2hdm_aximm0_bready   ) ,               
     /* read address channel
      */
   .ip2hdm_aximm0_arvalid   ( ip2hdm_aximm0_arvalid  ) ,         
   .ip2hdm_aximm0_arid      ( ip2hdm_aximm0_arid     ) ,         
   .ip2hdm_aximm0_araddr    ( ip2hdm_aximm0_araddr   ) ,         
   .ip2hdm_aximm0_arlen     ( ip2hdm_aximm0_arlen    ) ,         
   .ip2hdm_aximm0_arregion  ( ip2hdm_aximm0_arregion ) ,         
   .ip2hdm_aximm0_aruser    ( ip2hdm_aximm0_aruser   ) ,         
   .ip2hdm_aximm0_arsize    ( ip2hdm_aximm0_arsize   ) ,         
   .ip2hdm_aximm0_arburst   ( ip2hdm_aximm0_arburst  ) ,         
   .ip2hdm_aximm0_arprot    ( ip2hdm_aximm0_arprot   ) ,         
   .ip2hdm_aximm0_arqos     ( ip2hdm_aximm0_arqos    ) ,         
   .ip2hdm_aximm0_arcache   ( ip2hdm_aximm0_arcache  ) ,         
   .ip2hdm_aximm0_arlock    ( ip2hdm_aximm0_arlock   ) ,         
   .hdm2ip_aximm0_arready   ( hdm2ip_aximm0_arready  ) , 
     /* read response channel
      */
   .hdm2ip_aximm0_rvalid    ( hdm2ip_aximm0_rvalid  )  ,
   .hdm2ip_aximm0_rlast       ( hdm2ip_aximm0_rlast    )  ,	   
   .hdm2ip_aximm0_rid       ( hdm2ip_aximm0_rid     )  ,
   .hdm2ip_aximm0_rdata     ( hdm2ip_aximm0_rdata   )  ,
   .hdm2ip_aximm0_ruser     ( hdm2ip_aximm0_ruser   )  ,
   .hdm2ip_aximm0_rresp     ( hdm2ip_aximm0_rresp   )  ,
   .ip2hdm_aximm0_rready    ( ip2hdm_aximm0_rready  )  ,   


//Channel-1
     /* write address channel
      */
   .ip2hdm_aximm1_awvalid   ( ip2hdm_aximm1_awvalid   ) ,       
   .ip2hdm_aximm1_awid      ( ip2hdm_aximm1_awid      ) ,       
   .ip2hdm_aximm1_awaddr    ( ip2hdm_aximm1_awaddr    ) ,       
   .ip2hdm_aximm1_awlen     ( ip2hdm_aximm1_awlen     ) ,       
   .ip2hdm_aximm1_awregion  ( ip2hdm_aximm1_awregion  ) ,       
   .ip2hdm_aximm1_awuser    ( ip2hdm_aximm1_awuser    ) ,       
   .ip2hdm_aximm1_awsize    ( ip2hdm_aximm1_awsize    ) ,      
   .ip2hdm_aximm1_awburst   ( ip2hdm_aximm1_awburst   ) ,      
   .ip2hdm_aximm1_awprot    ( ip2hdm_aximm1_awprot    ) ,      
   .ip2hdm_aximm1_awqos     ( ip2hdm_aximm1_awqos     ) ,      
   .ip2hdm_aximm1_awcache   ( ip2hdm_aximm1_awcache   ) ,      
   .ip2hdm_aximm1_awlock    ( ip2hdm_aximm1_awlock    ) ,      
   .hdm2ip_aximm1_awready   ( hdm2ip_aximm1_awready   ) ,
     /* write data channel
      */
   .ip2hdm_aximm1_wvalid    ( ip2hdm_aximm1_wvalid   ) ,          
   .ip2hdm_aximm1_wdata     ( ip2hdm_aximm1_wdata    ) ,           
   .ip2hdm_aximm1_wstrb     ( ip2hdm_aximm1_wstrb    ) ,           
   .ip2hdm_aximm1_wlast     ( ip2hdm_aximm1_wlast    ) ,           
   .ip2hdm_aximm1_wuser     ( ip2hdm_aximm1_wuser    ) ,           
   .hdm2ip_aximm1_wready  	( hdm2ip_aximm1_wready   ) ,
     /* write response channel
      */
   .hdm2ip_aximm1_bvalid    ( hdm2ip_aximm1_bvalid   ) ,
   .hdm2ip_aximm1_bid       ( hdm2ip_aximm1_bid      ) ,
   .hdm2ip_aximm1_buser     ( hdm2ip_aximm1_buser    ) ,
   .hdm2ip_aximm1_bresp     ( hdm2ip_aximm1_bresp    ) ,
   .ip2hdm_aximm1_bready    ( ip2hdm_aximm1_bready   ) ,               
     /* read address channel
      */
   .ip2hdm_aximm1_arvalid   ( ip2hdm_aximm1_arvalid  ) ,         
   .ip2hdm_aximm1_arid      ( ip2hdm_aximm1_arid     ) ,         
   .ip2hdm_aximm1_araddr    ( ip2hdm_aximm1_araddr   ) ,         
   .ip2hdm_aximm1_arlen     ( ip2hdm_aximm1_arlen    ) ,         
   .ip2hdm_aximm1_arregion  ( ip2hdm_aximm1_arregion ) ,         
   .ip2hdm_aximm1_aruser    ( ip2hdm_aximm1_aruser   ) ,         
   .ip2hdm_aximm1_arsize    ( ip2hdm_aximm1_arsize   ) ,         
   .ip2hdm_aximm1_arburst   ( ip2hdm_aximm1_arburst  ) ,         
   .ip2hdm_aximm1_arprot    ( ip2hdm_aximm1_arprot   ) ,         
   .ip2hdm_aximm1_arqos     ( ip2hdm_aximm1_arqos    ) ,         
   .ip2hdm_aximm1_arcache   ( ip2hdm_aximm1_arcache  ) ,         
   .ip2hdm_aximm1_arlock    ( ip2hdm_aximm1_arlock   ) ,         
   .hdm2ip_aximm1_arready   ( hdm2ip_aximm1_arready  ) , 
     /* read response channel
      */
   .hdm2ip_aximm1_rvalid    ( hdm2ip_aximm1_rvalid  )  ,
   .hdm2ip_aximm1_rlast       ( hdm2ip_aximm1_rlast     )  ,	   
   .hdm2ip_aximm1_rid       ( hdm2ip_aximm1_rid     )  ,
   .hdm2ip_aximm1_rdata     ( hdm2ip_aximm1_rdata   )  ,
   .hdm2ip_aximm1_ruser     ( hdm2ip_aximm1_ruser   )  ,
   .hdm2ip_aximm1_rresp     ( hdm2ip_aximm1_rresp   )  ,
   .ip2hdm_aximm1_rready    ( ip2hdm_aximm1_rready  )  , 
   
   

//end of 2 slice support
 
    // == DDR4 Interface ==
    .mem_refclk    ,                                                    // input,  EMIF PLL reference clock
    .mem_ck        ,                                                      // output, DDR4 interface signals
    .mem_ck_n      ,                                                      // output
    .mem_a         ,                                                      // output
    .mem_act_n     ,                                                      // output
    .mem_ba        ,                                                     // output
    .mem_bg        ,                                                      // output
    .mem_cke       ,                                                      // output
    .mem_cs_n      ,                                                      // output
    .mem_odt       ,                                                     // output
    .mem_reset_n   ,                                                      // output
    .mem_par       ,                                                     // output
    .mem_oct_rzqin ,                                                     // input
    .mem_alert_n   ,                                                     // input r_tbd  
    .mem_dqs       ,                                                      // inout r_tbd 
    .mem_dqs_n     ,                                                      // inout r_tbd 
    .mem_dq                                                              // inout r_tbd 
`ifdef ENABLE_DDR_DBI_PINS                                  //Micron DIMM
    ,.mem_dbi_n                                                               // inout
`endif  
  );

  
endmodule
//------------------------------------------------------------------------------------
//
//
// End cxl_memexp_top.sv
//
//------------------------------------------------------------------------------------



