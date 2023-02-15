//
// SPDX-License-Identifier: BSD-2-Clause
//
// Copyright (c) 2021 Simon W. Moore
// Copyright (c) 2019 A. Theodore Markettos
// All rights reserved.
//
// This software was developed at the University of Cambridge Computer
// Laboratory (Department of Computer Science and Technology) based
// upon work supported by the DoD Information Analysis Center Program
// Management Office (DoD IAC PMO), sponsored by the Defense
// Technical Information Center (DTIC) under Contract
// No. FA807518D0004.
// AND
// This software was developed by SRI International, the University of
// Cambridge Computer Laboratory (Department of Computer Science and
// Technology), and ARM Research under DARPA contract HR0011-18-C-0016
// ("ECATS"), as part of the DARPA SSITH research programme.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//


//`define ENABLE_FLASH
//`define ENABLE_DDR4A
//`define ENABLE_DDR4B
//`define ENABLE_DDR4C
//`define ENABLE_DDR4D
//`define ENABLE_SI5340
`define ENABLE_FAN_I2C
//`define ENABLE_POWER_MONITOR_I2C
//`define ENABLE_TEMP_I2C
//`define ENABLE_GPIO
//`define ENABLE_PCIE
//`define ENABLE_QSFP28A
`define ENABLE_QSFP28B
`define ENABLE_QSFP28C
//`define ENABLE_QSFP28D
//`define ENABLE_HPS

module DE10_Pro
  (
   input 	 CLK_100_B3I,
   input 	 CLK_50_B2C,
   input 	 CLK_50_B2L,
   input 	 CLK_50_B3C,
   input 	 CLK_50_B3I,
   input 	 CLK_50_B3L,
   input 	 CPU_RESET_n,
   input [1:0] 	 BUTTON,
   input [1:0] 	 SW,
   output [3:0]  LED,
`ifdef ENABLE_FLASH
   output 	 FLASH_CLK,
   output [27:1] FLASH_A,
   inout [15:0]  FLASH_D,
   output 	 FLASH_CE_n,
   output 	 FLASH_WE_n,
   output 	 FLASH_OE_n,
   output 	 FLASH_ADV_n,
   output 	 FLASH_RESET_n,
   input 	 FLASH_RDY_BSY_n,
`endif // ENABLE_FLASH
`ifdef ENABLE_DDR4A
   input 	 DDR4A_REFCLK_p,
   output [16:0] DDR4A_A,
   output [1:0]  DDR4A_BA,
   output [1:0]  DDR4A_BG,
   output 	 DDR4A_CK,
   output 	 DDR4A_CK_n,
   output 	 DDR4A_CKE,
   inout [8:0] 	 DDR4A_DQS,
   inout [8:0] 	 DDR4A_DQS_n,
   inout [71:0]  DDR4A_DQ,
   inout [8:0] 	 DDR4A_DBI_n,
   output 	 DDR4A_CS_n,
   output 	 DDR4A_RESET_n,
   output 	 DDR4A_ODT,
   output 	 DDR4A_PAR,
   input 	 DDR4A_ALERT_n,
   output 	 DDR4A_ACT_n,
   input 	 DDR4A_EVENT_n,
   inout 	 DDR4A_SCL,
   inout 	 DDR4A_SDA,
   input 	 DDR4A_RZQ,
`endif // ENABLE_DDR4A
`ifdef ENABLE_DDR4B
   input 	 DDR4B_REFCLK_p,
   output [16:0] DDR4B_A,
   output [1:0]  DDR4B_BA,
   output [1:0]  DDR4B_BG,
   output 	 DDR4B_CK,
   output 	 DDR4B_CK_n,
   output 	 DDR4B_CKE,
   inout [8:0] 	 DDR4B_DQS,
   inout [8:0] 	 DDR4B_DQS_n,
   inout [71:0]  DDR4B_DQ,
   inout [8:0] 	 DDR4B_DBI_n,
   output 	 DDR4B_CS_n,
   output 	 DDR4B_RESET_n,
   output 	 DDR4B_ODT,
   output 	 DDR4B_PAR,
   input 	 DDR4B_ALERT_n,
   output 	 DDR4B_ACT_n,
   input 	 DDR4B_EVENT_n,
   inout 	 DDR4B_SCL,
   inout 	 DDR4B_SDA,
   input 	 DDR4B_RZQ,
`endif // ENABLE_DDR4B
`ifdef ENABLE_DDR4C
   input 	 DDR4C_REFCLK_p,
   output [16:0] DDR4C_A,
   output [1:0]  DDR4C_BA,
   output [1:0]  DDR4C_BG,
   output 	 DDR4C_CK,
   output 	 DDR4C_CK_n,
   output 	 DDR4C_CKE,
   inout [8:0] 	 DDR4C_DQS,
   inout [8:0] 	 DDR4C_DQS_n,
   inout [71:0]  DDR4C_DQ,
   inout [8:0] 	 DDR4C_DBI_n,
   output 	 DDR4C_CS_n,
   output 	 DDR4C_RESET_n,
   output 	 DDR4C_ODT,
   output 	 DDR4C_PAR,
   input 	 DDR4C_ALERT_n,
   output 	 DDR4C_ACT_n,
   input 	 DDR4C_EVENT_n,
   inout 	 DDR4C_SCL,
   inout 	 DDR4C_SDA,
   input 	 DDR4C_RZQ,
`endif // ENABLE_DDR4C
`ifdef ENABLE_DDR4D
   input 	 DDR4D_REFCLK_p,
   output [16:0] DDR4D_A,
   output [1:0]  DDR4D_BA,
   output [1:0]  DDR4D_BG,
   output 	 DDR4D_CK,
   output 	 DDR4D_CK_n,
   output 	 DDR4D_CKE,
   inout [8:0] 	 DDR4D_DQS,
   inout [8:0] 	 DDR4D_DQS_n,
   inout [71:0]  DDR4D_DQ,
   inout [8:0] 	 DDR4D_DBI_n,
   output 	 DDR4D_CS_n,
   output 	 DDR4D_RESET_n,
   output 	 DDR4D_ODT,
   output 	 DDR4D_PAR,
   input 	 DDR4D_ALERT_n,
   output 	 DDR4D_ACT_n,
   input 	 DDR4D_EVENT_n,
   inout 	 DDR4D_SCL,
   inout 	 DDR4D_SDA,
   input 	 DDR4D_RZQ,
`endif // ENABLE_DDR4D
`ifdef ENABLE_SI5340
   inout 	 SI5340A0_I2C_SCL,
   inout 	 SI5340A0_I2C_SDA,
   input 	 SI5340A0_INTR,
   output 	 SI5340A0_OE_n,
   output 	 SI5340A0_RST_n,
   inout 	 SI5340A1_I2C_SCL,
   inout 	 SI5340A1_I2C_SDA,
   input 	 SI5340A1_INTR,
   output 	 SI5340A1_OE_n,
   output 	 SI5340A1_RST_n,
`endif // ENABLE_SI5340
`ifdef ENABLE_FAN_I2C
   inout 	 FAN_I2C_SCL,
   inout 	 FAN_I2C_SDA,
   input 	 FAN_ALERT_n,
`endif // ENABLE_FAN_I2C
`ifdef ENABLE_POWER_MONITOR_I2C
   inout 	 POWER_MONITOR_I2C_SCL,
   inout 	 POWER_MONITOR_I2C_SDA,
   input 	 POWER_MONITOR_ALERT_n,
`endif // ENABLE_POWER_MONITOR_I2C
`ifdef ENABLE_TEMP_I2C
   inout 	 TEMP_I2C_SCL,
   inout 	 TEMP_I2C_SDA,
`endif // ENABLE_TEMP_I2C
`ifdef ENABLE_GPIO
   inout [1:0] 	 GPIO_CLK,
   inout [3:0] 	 GPIO_P,
`endif // ENABLE_GPIO
`ifdef ENABLE_PCIE
   inout 	 PCIE_SMBCLK,
   inout 	 PCIE_SMBDAT,
   input 	 PCIE_REFCLK_p,
   output [15:0] PCIE_TX_p,
   input [15:0]  PCIE_RX_p,
   input 	 PCIE_PERST_n,
   output 	 PCIE_WAKE_n,
`endif // ENABLE_PCIE
`ifdef ENABLE_QSFP28A
   input 	 QSFP28A_REFCLK_p,
   output [3:0]  QSFP28A_TX_p,
   input [3:0] 	 QSFP28A_RX_p,
   input 	 QSFP28A_INTERRUPT_n,
   output 	 QSFP28A_LP_MODE,
   input 	 QSFP28A_MOD_PRS_n,
   output 	 QSFP28A_MOD_SEL_n,
   output 	 QSFP28A_RST_n,
   inout 	 QSFP28A_SCL,
   inout 	 QSFP28A_SDA,
`endif // ENABLE_QSFP28A
`ifdef ENABLE_QSFP28B
   input 	 QSFP28B_REFCLK_p,
   output [3:0]  QSFP28B_TX_p,
   input [3:0] 	 QSFP28B_RX_p,
   input 	 QSFP28B_INTERRUPT_n,
   output 	 QSFP28B_LP_MODE,
   input 	 QSFP28B_MOD_PRS_n,
   output 	 QSFP28B_MOD_SEL_n,
   output 	 QSFP28B_RST_n,
   inout 	 QSFP28B_SCL,
   inout 	 QSFP28B_SDA,
`endif // ENABLE_QSFP28B
`ifdef ENABLE_QSFP28C
   input 	 QSFP28C_REFCLK_p,
   output [3:0]  QSFP28C_TX_p,
   input [3:0] 	 QSFP28C_RX_p,
   input 	 QSFP28C_INTERRUPT_n,
   output 	 QSFP28C_LP_MODE,
   input 	 QSFP28C_MOD_PRS_n,
   output 	 QSFP28C_MOD_SEL_n,
   output 	 QSFP28C_RST_n,
   inout 	 QSFP28C_SCL,
   inout 	 QSFP28C_SDA,
`endif // ENABLE_QSFP28C
`ifdef ENABLE_QSFP28D
   input 	 QSFP28D_REFCLK_p,
   output [3:0]  QSFP28D_TX_p,
   input [3:0] 	 QSFP28D_RX_p,
   input 	 QSFP28D_INTERRUPT_n,
   output 	 QSFP28D_LP_MODE,
   input 	 QSFP28D_MOD_PRS_n,
   output 	 QSFP28D_MOD_SEL_n,
   output 	 QSFP28D_RST_n,
   inout 	 QSFP28D_SCL,
   inout 	 QSFP28D_SDA,
`endif // ENABLE_QSFP28D
`ifdef ENABLE_HPS
   input 	 HPS_USB0_CLK,
   output 	 HPS_USB0_STP,
   input 	 HPS_USB0_DIR,
   inout [7:0] 	 HPS_USB0_DATA,
   input 	 HPS_USB0_NXT,
   output 	 HPS_EMAC0_TX_CLK,
   output 	 HPS_EMAC0_TX_CTL,
   input 	 HPS_EMAC0_RX_CLK,
   input 	 HPS_EMAC0_RX_CTL,
   output [3:0]  HPS_EMAC0_TXD,
   input [3:0] 	 HPS_EMAC0_RXD,
   inout 	 HPS_EMAC0_MDIO,
   output 	 HPS_EMAC0_MDC,
   output 	 HPS_UART0_TX,
   input 	 HPS_UART0_RX,
   output 	 HPS_FPGA_UART1_TX,
   input 	 HPS_FPGA_UART1_RX,
   output 	 HPS_SD_CLK,
   inout 	 HPS_SD_CMD,
   inout [3:0] 	 HPS_SD_DATA,
   input 	 HPS_OSC_CLK,
   inout 	 HPS_LED,
   inout 	 HPS_KEY,
   inout 	 HPS_CARD_PRSNT_n,
`endif
   input 	 EXP_EN,
   inout 	 UFL_CLKIN_p,
   inout 	 UFL_CLKIN_n
   );

   wire    clk_100;
   assign  clk_100 = CLK_100_B3I;

   // Intel reset release IP to guarantee the FPGA is fully programmed
   // before starting our design
   wire    init_done_n;
   reset_release reset_release
     (
      .ninit_done(init_done_n)
      );

   reg    reset_n_100;
   reg    reset_n_metastable_100;
   //   assign	reset_n = CPU_RESET_n && init_done_n;
   assign  reset_n = !init_done_n;

   // Ensure that the reset is synchronised with the clock we're going
   // to use
   always @(posedge clk_100)
     begin
       reset_n_metastable_100 <= reset_n;
		 reset_n_100 <= reset_n_metastable_100;
     end
   
   wire 	htile_fast_clk_B0;
   wire 	htile_fast_clk_B1;
   wire 	htile_fast_lock_B0;
   wire 	htile_fast_lock_B1;
   wire 	htile_fast_clk_C0;
   wire 	htile_fast_clk_C1;
   wire 	htile_fast_lock_C0;
   wire 	htile_fast_lock_C1;
   wire [15:0] 	status;
   reg [15:0] 	status_metastable /* synthesis preserve */; // preserve net name for timing closure
   reg [15:0] 	status_latched;

   always @(posedge clk_100)
     begin
	status_metastable <= status;
	status_latched <= status_metastable;
     end

   assign QSFP28B_LP_MODE = 0;
   assign QSFP28B_RST_n = 1;
   assign QSFP28B_SCL = 0;
   assign QSFP28B_SDA = 0;
   assign QSFP28B_MOD_SEL_n = 1;

   assign QSFP28C_LP_MODE = 0;
   assign QSFP28C_RST_n = 1;
   assign QSFP28C_SCL = 0;
   assign QSFP28C_SDA = 0;
   assign QSFP28C_MOD_SEL_n = 1;

   assign status[7:4] = {htile_fast_lock_C1, htile_fast_lock_C0, htile_fast_lock_B1, htile_fast_lock_B0};
   assign status[15:12] = 4'hf;
   
   soc mainsoc
      (
       .clk_clk(clk_100),
       .reset_reset(!reset_n_100),
       .pio_status_input_export                   (status_latched),                  //   input,    width = 16,                           pio_status_input.export

       .sl3_0_link_up_tx_tx_link_up               (status[0]),                               //  output,    width = 1,        sl3_0_link_up_tx.tx_link_up
       .sl3_0_link_up_rx_rx_link_up               (status[1]),                               //  output,    width = 1,        sl3_0_link_up_rx.rx_link_up
//       .sl3_0_tx_serial_clk_clk                   ({htile_fast_clk_B1,htile_fast_clk_B1,htile_fast_clk_B0,htile_fast_clk_B0}), //   input,    width = 4,     sl3_0_tx_serial_clk.clk
       .sl3_0_tx_serial_clk_clk                   ({htile_fast_clk_B0,htile_fast_clk_B0,htile_fast_clk_B1,htile_fast_clk_B1}), //   input,    width = 4,     sl3_0_tx_serial_clk.clk
       .sl3_0_xcvr_pll_ref_clk_clk                (QSFP28B_REFCLK_p),                        //   input,    width = 1,  sl3_0_xcvr_pll_ref_clk.clk
       .sl3_0_tx_pll_locked_pll_locked            (htile_fast_lock_B0 && htile_fast_lock_B1), //   input,    width = 1,     sl3_0_tx_pll_locked.pll_locked
       .sl3_0_crc_error_inject_tx_err_ins         (4'd0),                                      //   input,    width = 4,  sl3_0_crc_error_inject.tx_err_ins
       .sl3_0_tx_serial_data_tx_serial_data       (QSFP28B_TX_p),                           //  output,    width = 4,    sl3_0_tx_serial_data.tx_serial_data
       .sl3_0_rx_serial_data_rx_serial_data       (QSFP28B_RX_p),                           //   input,    width = 4,    sl3_0_rx_serial_data.rx_serial_data

       .sl3_1_link_up_tx_tx_link_up               (status[2]),                    //  output,    width = 1,                           sl3_1_link_up_tx.tx_link_up
       .sl3_1_link_up_rx_rx_link_up               (status[3]),                    //  output,    width = 1,                           sl3_1_link_up_rx.rx_link_up
//       .sl3_1_tx_serial_clk_clk                   ({htile_fast_clk_C1,htile_fast_clk_C1,htile_fast_clk_C0,htile_fast_clk_C0}),                        //   input,    width = 4,                        sl3_1_tx_serial_clk.clk
       .sl3_1_tx_serial_clk_clk                   ({htile_fast_clk_C0,htile_fast_clk_C0,htile_fast_clk_C1,htile_fast_clk_C1}),                        //   input,    width = 4,                        sl3_1_tx_serial_clk.clk
       .sl3_1_xcvr_pll_ref_clk_clk                (QSFP28C_REFCLK_p),                     //   input,    width = 1,                     sl3_1_xcvr_pll_ref_clk.clk
       .sl3_1_tx_pll_locked_pll_locked            (htile_fast_lock_C0 && htile_fast_lock_C1),                 //   input,    width = 1,                        sl3_1_tx_pll_locked.pll_locked
       .sl3_1_crc_error_inject_tx_err_ins         (4'd0),              //   input,    width = 4,                     sl3_1_crc_error_inject.tx_err_ins
       .sl3_1_tx_serial_data_tx_serial_data       (QSFP28C_TX_p),            //  output,    width = 4,                       sl3_1_tx_serial_data.tx_serial_data
       .sl3_1_rx_serial_data_rx_serial_data       (QSFP28C_RX_p),            //   input,    width = 4,                       sl3_1_rx_serial_data.rx_serial_data

       .xcvr_atx_pll_s10_htile_0_pll_refclk0_clk       (QSFP28B_REFCLK_p),                  //   input,    width = 1,                       xcvr_atx_pll_refclk0.clk
       .xcvr_atx_pll_s10_htile_0_tx_serial_clk_gxt_clk (htile_fast_clk_B0),                 //  output,    width = 1, xcvr_atx_pll_s10_htile_0_tx_serial_clk_gxt.clk
       .xcvr_atx_pll_s10_htile_0_pll_locked_pll_locked (htile_fast_lock_B0),                //  output,    width = 1,        xcvr_atx_pll_s10_htile_0_pll_locked.pll_locked
       .xcvr_atx_pll_s10_htile_0_pll_cal_busy_pll_cal_busy (status[8]),                     //  output,   width = 1,      xcvr_atx_pll_s10_htile_0_pll_cal_busy.pll_cal_busy
       
       .xcvr_atx_pll_s10_htile_1_pll_refclk0_clk       (QSFP28B_REFCLK_p),                  //   input,    width = 1,       xcvr_atx_pll_s10_htile_1_pll_refclk0.clk
       .xcvr_atx_pll_s10_htile_1_tx_serial_clk_gxt_clk (htile_fast_clk_B1),                 //  output,    width = 1, xcvr_atx_pll_s10_htile_1_tx_serial_clk_gxt.clk
       .xcvr_atx_pll_s10_htile_1_pll_locked_pll_locked (htile_fast_lock_B1),                 //  output,    width = 1,        xcvr_atx_pll_s10_htile_0_pll_locked.pll_locked
       .xcvr_atx_pll_s10_htile_1_pll_cal_busy_pll_cal_busy (status[9]),                     //  output,   width = 1,      xcvr_atx_pll_s10_htile_1_pll_cal_busy.pll_cal_busy

       .xcvr_atx_pll_s10_htile_2_pll_refclk0_clk       (QSFP28C_REFCLK_p),       //   input,    width = 1,       xcvr_atx_pll_s10_htile_2_pll_refclk0.clk
       .xcvr_atx_pll_s10_htile_2_tx_serial_clk_gxt_clk (htile_fast_clk_C0), //  output,    width = 1, xcvr_atx_pll_s10_htile_2_tx_serial_clk_gxt.clk
       .xcvr_atx_pll_s10_htile_2_pll_locked_pll_locked (htile_fast_lock_C0), //  output,    width = 1,        xcvr_atx_pll_s10_htile_2_pll_locked.pll_locked
       .xcvr_atx_pll_s10_htile_2_pll_cal_busy_pll_cal_busy (status[10]),                     //  output,   width = 1,      xcvr_atx_pll_s10_htile_2_pll_cal_busy.pll_cal_busy

       .xcvr_atx_pll_s10_htile_3_pll_refclk0_clk       (QSFP28C_REFCLK_p),       //   input,    width = 1,       xcvr_atx_pll_s10_htile_3_pll_refclk0.clk
       .xcvr_atx_pll_s10_htile_3_tx_serial_clk_gxt_clk (htile_fast_clk_C1), //  output,    width = 1, xcvr_atx_pll_s10_htile_3_tx_serial_clk_gxt.clk
       .xcvr_atx_pll_s10_htile_3_pll_locked_pll_locked (htile_fast_lock_C1),  //  output,    width = 1,        xcvr_atx_pll_s10_htile_3_pll_locked.pll_locked
       .xcvr_atx_pll_s10_htile_3_pll_cal_busy_pll_cal_busy (status[11])                     //  output,   width = 1,      xcvr_atx_pll_s10_htile_3_pll_cal_busy.pll_cal_busy
       );
   
   
   // Instantiate fan controller logic so that the fan doesn't run
   // full blast all the time
   wire [13:0] 	 HEX_DATA0;
   wire [13:0] 	 HEX_DATA1;
   wire [12:0] 	 Speed_Switch;
   wire 	 Fan_MAX;
   wire 	Fan_MIN;
   wire 	Fan_TACH;
   wire 	Fan_GPIO1;

   reg [25:0] 	ctr;
   assign  LED[3:0]     = {SW[0],!BUTTON[0],ctr[24],ctr[24]};

   always @(posedge clk_100)
     ctr <= ctr + 26'd1;

   assign  Speed_Switch = (SW[0]==BUTTON[0])?13'd2000:13'd5000;

   Fan_Control u0
     (
      .CLK              ( CLK_50_B2C  ),
      .Speed_Set        ( Speed_Switch),//need set more than 1500rpm
      .FAN0_Speed       ( HEX_DATA0   ),//FAN0 Speed response . no use ; connect to HEX display 
      .FAN1_Speed       ( HEX_DATA1   ),//FAN1 Speed response . no use ; connect to HEX display 
      .Alert_Clear      ( BUTTON[1]   ),
      .Alert_Type       ( {Fan_GPIO1,Fan_TACH,Fan_MIN,Fan_MAX}),
      .Alert            ( FAN_ALERT_n ),
      .FAN_I2C_SCL      ( FAN_I2C_SCL ),
      .FAN_I2C_SDA      ( FAN_I2C_SDA )
      );

endmodule
