// This is a place holder insantiation template that needs to be replaced with generation of Serial Lite III IP

	soc_sl3_0 u0 (
		.user_clock_tx            (_connected_to_user_clock_tx_),            //   input,    width = 1,            user_clock_tx.clk
		.user_clock_reset_tx      (_connected_to_user_clock_reset_tx_),      //   input,    width = 1,      user_clock_reset_tx.reset
		.data_tx                  (_connected_to_data_tx_),                  //   input,  width = 256,                  data_tx.tx_data
		.valid_tx                 (_connected_to_valid_tx_),                 //   input,    width = 1,                 valid_tx.tx_valid
		.ready_tx                 (_connected_to_ready_tx_),                 //  output,    width = 1,                 ready_tx.tx_ready
		.start_of_burst_tx        (_connected_to_start_of_burst_tx_),        //   input,    width = 1,        start_of_burst_tx.tx_start_of_burst
		.end_of_burst_tx          (_connected_to_end_of_burst_tx_),          //   input,    width = 1,          end_of_burst_tx.tx_end_of_burst
		.link_up_tx               (_connected_to_link_up_tx_),               //  output,    width = 1,               link_up_tx.tx_link_up
		.error_tx                 (_connected_to_error_tx_),                 //  output,    width = 4,                 error_tx.tx_error
		.interface_clock_rx       (_connected_to_interface_clock_rx_),       //  output,    width = 1,       interface_clock_rx.clk
		.interface_clock_reset_rx (_connected_to_interface_clock_reset_rx_), //  output,    width = 1, interface_clock_reset_rx.reset
		.data_rx                  (_connected_to_data_rx_),                  //  output,  width = 256,                  data_rx.rx_data
		.valid_rx                 (_connected_to_valid_rx_),                 //  output,    width = 1,                 valid_rx.rx_valid
		.sync_rx                  (_connected_to_sync_rx_),                  //  output,    width = 8,                  sync_rx.rx_sync
		.ready_rx                 (_connected_to_ready_rx_),                 //   input,    width = 1,                 ready_rx.rx_ready
		.start_of_burst_rx        (_connected_to_start_of_burst_rx_),        //  output,    width = 1,        start_of_burst_rx.rx_start_of_burst
		.end_of_burst_rx          (_connected_to_end_of_burst_rx_),          //  output,    width = 1,          end_of_burst_rx.rx_end_of_burst
		.link_up_rx               (_connected_to_link_up_rx_),               //  output,    width = 1,               link_up_rx.rx_link_up
		.error_rx                 (_connected_to_error_rx_),                 //  output,    width = 9,                 error_rx.rx_error
		.phy_mgmt_clk             (_connected_to_phy_mgmt_clk_),             //   input,    width = 1,             phy_mgmt_clk.clk
		.phy_mgmt_clk_reset       (_connected_to_phy_mgmt_clk_reset_),       //   input,    width = 1,       phy_mgmt_clk_reset.reset
		.tx_serial_clk            (_connected_to_tx_serial_clk_),            //   input,    width = 4,            tx_serial_clk.clk
		.xcvr_pll_ref_clk         (_connected_to_xcvr_pll_ref_clk_),         //   input,    width = 1,         xcvr_pll_ref_clk.clk
		.phy_mgmt_address         (_connected_to_phy_mgmt_address_),         //   input,   width = 14,                 phy_mgmt.address
		.phy_mgmt_read            (_connected_to_phy_mgmt_read_),            //   input,    width = 1,                         .read
		.phy_mgmt_readdata        (_connected_to_phy_mgmt_readdata_),        //  output,   width = 32,                         .readdata
		.phy_mgmt_waitrequest     (_connected_to_phy_mgmt_waitrequest_),     //  output,    width = 1,                         .waitrequest
		.phy_mgmt_write           (_connected_to_phy_mgmt_write_),           //   input,    width = 1,                         .write
		.phy_mgmt_writedata       (_connected_to_phy_mgmt_writedata_),       //   input,   width = 32,                         .writedata
		.tx_pll_locked            (_connected_to_tx_pll_locked_),            //   input,    width = 1,            tx_pll_locked.pll_locked
		.err_interrupt_tx         (_connected_to_err_interrupt_tx_),         //  output,    width = 1,         err_interrupt_tx.irq
		.err_interrupt_rx         (_connected_to_err_interrupt_rx_),         //  output,    width = 1,         err_interrupt_rx.irq
		.crc_error_inject         (_connected_to_crc_error_inject_),         //   input,    width = 4,         crc_error_inject.tx_err_ins
		.tx_serial_data           (_connected_to_tx_serial_data_),           //  output,    width = 4,           tx_serial_data.tx_serial_data
		.rx_serial_data           (_connected_to_rx_serial_data_),           //   input,    width = 4,           rx_serial_data.rx_serial_data
		.sync_tx                  (_connected_to_sync_tx_)                   //   input,    width = 8,                  sync_tx.tx_sync
	);

