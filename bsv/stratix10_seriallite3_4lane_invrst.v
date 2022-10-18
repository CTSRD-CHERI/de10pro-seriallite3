module stratix10_seriallite3_4lane_invrst (
		input  wire         user_clock_tx,            //            user_clock_tx.clk
		input  wire         user_clock_reset_tx_n,    //      user_clock_reset_tx.reset_n
		input  wire [255:0] data_tx,                  //                  data_tx.tx_data
		input  wire [0:0]   valid_tx,                 //                 valid_tx.tx_valid
		output wire [0:0]   ready_tx,                 //                 ready_tx.tx_ready
		input  wire [0:0]   start_of_burst_tx,        //        start_of_burst_tx.tx_start_of_burst
		input  wire [0:0]   end_of_burst_tx,          //          end_of_burst_tx.tx_end_of_burst
		output wire         link_up_tx,               //               link_up_tx.tx_link_up
		output wire [3:0]   error_tx,                 //                 error_tx.tx_error
		output wire         interface_clock_rx,       //       interface_clock_rx.clk
		output wire         interface_clock_reset_rx_n, // interface_clock_reset_rx.reset_n
		output wire [255:0] data_rx,                  //                  data_rx.rx_data
		output wire [0:0]   valid_rx,                 //                 valid_rx.rx_valid
		output wire [7:0]   sync_rx,                  //                  sync_rx.rx_sync
		input  wire [0:0]   ready_rx,                 //                 ready_rx.rx_ready
		output wire [0:0]   start_of_burst_rx,        //        start_of_burst_rx.rx_start_of_burst
		output wire [0:0]   end_of_burst_rx,          //          end_of_burst_rx.rx_end_of_burst
		output wire         link_up_rx,               //               link_up_rx.rx_link_up
		output wire [8:0]   error_rx,                 //                 error_rx.rx_error
		input  wire         phy_mgmt_clk,             //             phy_mgmt_clk.clk
		input  wire         phy_mgmt_clk_reset_n,     //       phy_mgmt_clk_reset.reset_n
		input  wire [3:0]   tx_serial_clk,            //            tx_serial_clk.clk
		input  wire         xcvr_pll_ref_clk,         //         xcvr_pll_ref_clk.clk
		input  wire [13:0]  phy_mgmt_address,         //                 phy_mgmt.address
		input  wire         phy_mgmt_read,            //                         .read
		output wire [31:0]  phy_mgmt_readdata,        //                         .readdata
		output wire         phy_mgmt_waitrequest,     //                         .waitrequest
		input  wire         phy_mgmt_write,           //                         .write
		input  wire [31:0]  phy_mgmt_writedata,       //                         .writedata
		input  wire         tx_pll_locked,            //            tx_pll_locked.pll_locked
		output wire         err_interrupt_tx,         //         err_interrupt_tx.irq
		output wire         err_interrupt_rx,         //         err_interrupt_rx.irq
		input  wire [3:0]   crc_error_inject,         //         crc_error_inject.tx_err_ins
		output wire [3:0]   tx_serial_data,           //           tx_serial_data.tx_serial_data
		input  wire [3:0]   rx_serial_data,           //           rx_serial_data.rx_serial_data
		input  wire [7:0]   sync_tx                   //                  sync_tx.tx_sync
	);


	stratix10_seriallite3_4lane u0 (
		.user_clock_tx            (user_clock_tx),            //   input,    width = 1,            user_clock_tx.clk
		.user_clock_reset_tx      (~user_clock_reset_tx_n),   //   input,    width = 1,      user_clock_reset_tx.reset
		.data_tx                  (data_tx),                  //   input,  width = 256,                  data_tx.tx_data
		.valid_tx                 (valid_tx),                 //   input,    width = 1,                 valid_tx.tx_valid
		.ready_tx                 (ready_tx),                 //  output,    width = 1,                 ready_tx.tx_ready
		.start_of_burst_tx        (start_of_burst_tx),        //   input,    width = 1,        start_of_burst_tx.tx_start_of_burst
		.end_of_burst_tx          (end_of_burst_tx),          //   input,    width = 1,          end_of_burst_tx.tx_end_of_burst
		.link_up_tx               (link_up_tx),               //  output,    width = 1,               link_up_tx.tx_link_up
		.error_tx                 (error_tx),                 //  output,    width = 4,                 error_tx.tx_error
		.interface_clock_rx       (interface_clock_rx),       //  output,    width = 1,       interface_clock_rx.clk
		.interface_clock_reset_rx (~interface_clock_reset_rx_n), //  output,    width = 1, interface_clock_reset_rx.reset
		.data_rx                  (data_rx),                  //  output,  width = 256,                  data_rx.rx_data
		.valid_rx                 (valid_rx),                 //  output,    width = 1,                 valid_rx.rx_valid
		.sync_rx                  (sync_rx),                  //  output,    width = 8,                  sync_rx.rx_sync
		.ready_rx                 (ready_rx),                 //   input,    width = 1,                 ready_rx.rx_ready
		.start_of_burst_rx        (start_of_burst_rx),        //  output,    width = 1,        start_of_burst_rx.rx_start_of_burst
		.end_of_burst_rx          (end_of_burst_rx),          //  output,    width = 1,          end_of_burst_rx.rx_end_of_burst
		.link_up_rx               (link_up_rx),               //  output,    width = 1,               link_up_rx.rx_link_up
		.error_rx                 (error_rx),                 //  output,    width = 9,                 error_rx.rx_error
		.phy_mgmt_clk             (phy_mgmt_clk),             //   input,    width = 1,             phy_mgmt_clk.clk
		.phy_mgmt_clk_reset       (~phy_mgmt_clk_reset_n),       //   input,    width = 1,       phy_mgmt_clk_reset.reset
		.tx_serial_clk            (tx_serial_clk),            //   input,    width = 4,            tx_serial_clk.clk
		.xcvr_pll_ref_clk         (xcvr_pll_ref_clk),         //   input,    width = 1,         xcvr_pll_ref_clk.clk
		.phy_mgmt_address         (phy_mgmt_address),         //   input,   width = 14,                 phy_mgmt.address
		.phy_mgmt_read            (phy_mgmt_read),            //   input,    width = 1,                         .read
		.phy_mgmt_readdata        (phy_mgmt_readdata),        //  output,   width = 32,                         .readdata
		.phy_mgmt_waitrequest     (phy_mgmt_waitrequest),     //  output,    width = 1,                         .waitrequest
		.phy_mgmt_write           (phy_mgmt_write),           //   input,    width = 1,                         .write
		.phy_mgmt_writedata       (phy_mgmt_writedata),       //   input,   width = 32,                         .writedata
		.tx_pll_locked            (tx_pll_locked),            //   input,    width = 1,            tx_pll_locked.pll_locked
		.err_interrupt_tx         (err_interrupt_tx),         //  output,    width = 1,         err_interrupt_tx.irq
		.err_interrupt_rx         (err_interrupt_rx),         //  output,    width = 1,         err_interrupt_rx.irq
		.crc_error_inject         (crc_error_inject),         //   input,    width = 4,         crc_error_inject.tx_err_ins
		.tx_serial_data           (tx_serial_data),           //  output,    width = 4,           tx_serial_data.tx_serial_data
		.rx_serial_data           (rx_serial_data),           //   input,    width = 4,           rx_serial_data.rx_serial_data
		.sync_tx                  (sync_tx)                   //   input,    width = 8,                  sync_tx.tx_sync
	);

