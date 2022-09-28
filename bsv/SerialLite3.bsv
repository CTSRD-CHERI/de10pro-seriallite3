package SerialLite3;

import BlueAXI4 :: *;
import BlueBasics :: *;
import Clocks :: *;
import FIFO :: *;

// This package provides types / interfaces for the SerialLite3 interface
// Note: the following signals are not currently provided:
// - method Bool err_interrupt_tx;
// - method Bool err_interrupt_rx;
// - method Action crc_error_inject (Bit #(4) x);

// This flit structure can be used as payload for the rx/tx channels in the
// SerialLite3 interface. Note that the valid / ready signals are abstracted
// away and expected to be handled, here, using Source and Sink interfaces
typedef struct {
  Bit #(256) data;
  Bool start_of_burst;
  Bool end_of_burst;
  Bit #(8) sync;
} SerialLite3_StreamFlit deriving (Bits);

function SerialLite3_StreamFlit axs2sl3 (AXI4Stream_Flit #(0, 256, 0, 9) axs) =
  SerialLite3_StreamFlit { data: axs.tdata
                         , start_of_burst: unpack (msb (axs.tuser))
                         , end_of_burst: axs.tlast
                         , sync: truncate (axs.tuser) };

function AXI4Stream_Flit #(0, 256, 0, 9) sl32axs (SerialLite3_StreamFlit sl3) =
  AXI4Stream_Flit { tdata: sl3.data
                  , tstrb: ~0
                  , tkeep: ~0
                  , tlast: sl3.end_of_burst
                  , tid  : ?
                  , tdest: ?
                  , tuser: {pack (sl3.start_of_burst), sl3.sync} };

typedef struct {
   Bit #(5) error_rx;
   Bit #(4) error_tx;
   Bool link_up_tx;
   Bool link_up_rx;
} SerialLite3_LinkStatus deriving (Bits);

// The SerialLite3 external signals
(* always_enabled *) // implies always_ready
interface SerialLite3_ExternalPins;
  method Bit #(4) qsfp28_tx_pins;
  method Action qsfp28_rx_pins (Bit #(4) x);
endinterface

// The SerialLite3 internal signals
interface SerialLite3 #(
  // data to send stream parameters
//  type tx_payload // use SerialLite3_StreamFlit
  // data received stream parameters
//, type rx_payload // use SerialLite3_StreamFlit
  // Physical management memory-mapped AXI4 subordinate port parameters
  numeric type t_addr
, numeric type t_data
, numeric type t_awuser, numeric type t_wuser, numeric type t_buser
, numeric type t_aruser, numeric type t_ruser
);

  // data to send stream
  interface AXI4Stream_Slave #(0, 256, 0, 9) tx;
  // data received stream
  interface AXI4Stream_Master #(0, 256, 0, 9) rx;

  // export receive stream clock
  interface Clock rx_clk;
  interface Reset rx_rst;

  // link status
  (* always_ready, always_enabled *)
  method SerialLite3_LinkStatus link_status;

  // Physical management memory-mapped AXI4 subordinate
  // This interface covers the following signals:
  // - phy_mgmt_address
  // - phy_mgmt_read
  // - phy_mgmt_readdata
  // - phy_mgmt_waitrequest
  // - phy_mgmt_write
  // - phy_mgmt_writedata
  interface AXI4Lite_Slave #( t_addr, t_data
                            , t_awuser, t_wuser, t_buser
                            , t_aruser, t_ruser) management_subordinate;

  interface SerialLite3_ExternalPins pins;

endinterface

// The SerialLite3 "Sig" version of the interface
interface SerialLite3_Sig #(
  numeric type t_addr
, numeric type t_data
, numeric type t_awuser, numeric type t_wuser, numeric type t_buser
, numeric type t_aruser, numeric type t_ruser
);

  (* prefix = "axs_txstream" *)
  interface AXI4Stream_Slave_Sig #(0, 256, 0, 9) tx;
  (* prefix = "axm_rxstream" *)
  interface AXI4Stream_Master_Sig #(0, 256, 0, 9) rx;
  interface Clock rx_clk;
  interface Reset rx_rst;
  (* result = "coe_link_status", always_ready, always_enabled *)
  method SerialLite3_LinkStatus link_status;
  (* prefix = "axls_management" *)
  interface AXI4Lite_Slave_Sig #( t_addr, t_data
                                , t_awuser, t_wuser, t_buser
                                , t_aruser, t_ruser) management_subordinate;
  (* prefix = "coe" *)
  interface SerialLite3_ExternalPins pins;
endinterface

module toSerialLite3_Sig #(SerialLite3 #(a,b,c,d,e,f,g) ifc
                          , Clock tx_clk, Reset tx_rst)
                          (SerialLite3_Sig #(a,b,c,d,e,f,g));
  let sigAXI4LitePort <- toAXI4Lite_Slave_Sig (ifc.management_subordinate);
  let sigTXPort <- toAXI4Stream_Slave_Sig (ifc.tx, clocked_by tx_clk, reset_by tx_rst);
  let sigRXPort <- toAXI4Stream_Master_Sig (ifc.rx, clocked_by ifc.rx_clk, reset_by ifc.rx_rst);
  return interface SerialLite3_Sig;
    interface tx = sigTXPort;
    interface rx = sigRXPort;
    interface rx_clk = ifc.rx_clk;
    interface rx_rst = ifc.rx_rst;
    method link_status = ifc.link_status;
    interface management_subordinate = sigAXI4LitePort;
    interface pins = ifc.pins;
  endinterface;
endmodule

// Interface to Stratix 10 SerialLite3 IP block insantiated with 4 lanes
interface Stratix10_SerialLite3_4Lane;
  // export receive stream clock
  interface Clock rx_clk;
  interface Reset rx_rst;
  // data received stream
  method Bit#(256) data_rx;
  method Bit#(1) start_of_burst_rx;
  method Bit#(1) end_of_burst_rx;
  method Bit#(8) sync_rx;
  method Bit#(9) error_rx;
  method Bit#(1) error_interrupt_rx;
  method Bit#(1) valid_rx;
  method Bit#(1) link_up_rx;
  method Action rx_drop();
  // data transmit stream
  method Action tx(Bit#(256) data_tx, Bit#(1) start_of_burst_tx, Bit#(1) end_of_burst_tx, Bit#(8) sync_tx);
  method Bit#(4) error_tx;
  method Bit#(1) tx_pll_locked;
  method Bit#(1) error_interrupt_tx;
  method Bit#(1) ready_tx;
  method Bit#(1) link_up_tx;
  // memory mapped interface to control/status registers
  method Action bus_request(Bit#(14) addr, Bit#(1) read_enable, Bit#(1) write_enable, Bit#(32) write_data);
  method Bit#(32) bus_read_data();
  method Bit#(1) bus_waitrequest();
  // export high-speed serial pins
  (* always_ready, always_enabled *) method Bit#(4) qsfp28_tx_pins;
  (* always_ready, always_enabled *) method Action qsfp28_rx_pins(Bit#(4) a);
  // test ports
  (* always_ready, always_enabled *) method Action crc_error_inject(Bit#(4) error_inject);
endinterface

import "BVI" stratix10_seriallite3_4lane =
module mkStratix10_SerialLite3_4Lane (Clock tx_clk, Reset tx_rst, Clock qsfp_refclk, Stratix10_SerialLite3_4Lane sl3);
  // Clocks
  default_clock clk (phy_mgmt_clk, (*unused*) phy_mgmt_clk_gate);
  default_reset rst (phy_mgmt_clk_reset);
  output_clock rx_clk(interface_clock_rx);
  output_reset rx_rst(interface_clock_reset_rx) clocked_by (rx_clk);
  input_clock (user_clock_tx, (*unused*) user_clock_tx_gate) = tx_clk;
  input_reset tx_rst(user_clock_reset_tx) clocked_by (tx_clk) = tx_rst;
  // High-speed transmitter clock that must be physically connected to the same H-tile as the tx/rx pins
  input_clock (xcvr_pll_ref_clk, (*unused*) xcvr_pll_ref_clk_gate) = qsfp_refclk;

  // Transmit stream
  method tx(data_tx, start_of_burst_tx, end_of_burst_tx, sync_tx)
            enable (valid_tx) ready (ready_tx) clocked_by(tx_clk) reset_by(tx_rst);
  method         error_tx error_tx()           clocked_by(tx_clk) reset_by(tx_rst);
  method       link_up_tx link_up_tx()         clocked_by(tx_clk) reset_by(tx_rst);
  method    tx_pll_locked tx_pll_locked()      clocked_by(tx_clk) reset_by(tx_rst);
  method err_interrupt_tx error_interrupt_tx() clocked_by(tx_clk) reset_by(tx_rst);
  method         ready_tx ready_tx()           clocked_by(tx_clk) reset_by(tx_rst);

  // Receive stream
  method             data_rx data_rx()            clocked_by(rx_clk) reset_by(rx_rst);
  method   start_of_burst_rx start_of_burst_rx()  clocked_by(rx_clk) reset_by(rx_rst);
  method     end_of_burst_rx end_of_burst_rx()    clocked_by(rx_clk) reset_by(rx_rst);
  method             sync_rx sync_rx()            clocked_by(rx_clk) reset_by(rx_rst);
  method            error_rx error_rx()           clocked_by(rx_clk) reset_by(rx_rst);
  method          link_up_rx link_up_rx()         clocked_by(rx_clk) reset_by(rx_rst);
  method    err_interrupt_rx error_interrupt_rx() clocked_by(rx_clk) reset_by(rx_rst);
  method            valid_rx valid_rx()           clocked_by(rx_clk) reset_by(rx_rst);
  method rx_drop() enable(ready_rx) ready(valid_rx) clocked_by(rx_clk) reset_by(rx_rst);

  // Memory mapped interface (uses the default clock and reset)
  // ***********TODO not using phy_mgmt_valid but may need to to generate phy_mgmt_read and phy_mgmt_write correctly
  method bus_request(phy_mgmt_addr, phy_mgmt_read, phy_mgmt_write, phy_mgmt_writedata) enable(phy_mgmt_valid);
  method phy_mgmt_readdata bus_read_data();
  method phy_mgmt_waitreques bus_waitrequest();

  // High-speed serial pins (no clock domain)
  method qsfp28_tx_pins qsfp28_tx_pins();
  method qsfp28_rx_pins(qsfp28_rx_pins) enable((*inhigh*) EN_rx_serial_data);

  // Test/monitor ports (TODO: correct clock domain?)
  method crc_error_inject(crc_error_inject) enable((*inhigh*) EN_crc_error_inject) clocked_by(tx_clk) reset_by(tx_rst);

  // Scheduling
  schedule ( data_rx, start_of_burst_rx, end_of_burst_rx, valid_rx, error_rx, link_up_rx, sync_rx, error_interrupt_rx, rx_drop
           , link_up_rx, link_up_tx, error_tx, tx_pll_locked, error_interrupt_tx, ready_tx
           , bus_request, bus_read_data, bus_waitrequest, crc_error_inject, tx, qsfp28_tx_pins, qsfp28_rx_pins)
        CF (data_rx, start_of_burst_rx, end_of_burst_rx, valid_rx, error_rx, link_up_rx, sync_rx, error_interrupt_rx, rx_drop
           , link_up_rx, link_up_tx, error_tx, tx_pll_locked, error_interrupt_tx, ready_tx
           , bus_request, bus_read_data, bus_waitrequest, crc_error_inject, tx, qsfp28_tx_pins, qsfp28_rx_pins);
endmodule

module mkSerialLite3
  (
   Clock tx_clk, Reset tx_rst, Clock qsfp_refclk,
   SerialLite3#(t_addr, t_data, t_awuser, t_wuser, t_buser, t_aruser, t_ruser) sl3_ifc
  )
  provisos ( Add#(14,_na,t_addr)
           , Add#(32,_nd,t_data)
           , Alias#(t_bus_req, Tuple4#(Bit#(14), Bit#(1), Bit#(1), Bit#(32))) );

  Clock local_clk <- exposeCurrentClock();
  Stratix10_SerialLite3_4Lane sl3 <- mkStratix10_SerialLite3_4Lane(tx_clk, tx_rst, qsfp_refclk);
  CrossingReg#(Bit#(4)) sync_error_tx <- mkNullCrossingReg(local_clk, 0, clocked_by tx_clk, reset_by tx_rst);
  CrossingReg#(Bit#(5)) sync_error_rx <- mkNullCrossingReg(local_clk, 0, clocked_by sl3.rx_clk, reset_by sl3.rx_rst);
  SyncBitIfc#(Bool) sync_link_up_tx <- mkSyncBitToCC(tx_clk, tx_rst);
  SyncBitIfc#(Bool) sync_link_up_rx <- mkSyncBitToCC(sl3.rx_clk, sl3.rx_rst);
  AXI4Lite_Shim#( t_addr, t_data
                , t_awuser, t_wuser, t_buser
                , t_aruser, t_ruser) axi4LiteShim <- mkAXI4LiteShimFF;

  rule do_sync_from_tx_clk_domain;
    sync_link_up_tx.send(sl3.link_up_tx==1);
    sync_error_tx <= sl3.error_tx;
  endrule
  rule do_sync_from_rx_clk_domain;
    sync_link_up_rx.send(sl3.link_up_rx==1);
    sync_error_rx <= sl3.error_rx[4:0];
  endrule
  rule no_crc_error_testing;
    sl3.crc_error_inject(0);
  endrule

  //----------------------------------------------------------------------------
  // TODO: need help!!!
  // from @aj443 to @swm11:
  // I make the assumption that
  // - when bus_request is called for a write, there is no impact on the
  //   behaviour of bus_read_data or bus_waitrequest
  // - when bus_request is called for a read, bus_waitrequest goes hi on the
  //   next cycle and goes low when the bus_read_data corresponds to the data to
  //   be returned

  FIFO#(t_bus_req) busReqFF <- mkFIFO1; // for bus access from a single rule
  FIFO#(Bit#(0))   rdRspFF <- mkFIFO1; // for flow control
  rule forward_bus_req (sl3.bus_waitrequest == 1'b0);
    match {.addr, .rd, .wr, .data} = busReqFF.first;
    busReqFF.deq;
    sl3.bus_request (addr, rd, wr, data);
    if (rd == 1'b1) rdRspFF.enq(?);
  endrule

  // XXX proposed implementation for AXI4Lite reads, rely on the bus eventually
  //     providing a response
  (* descending_urgency = "axi4Lite_read_request, axi4Lite_write" *)
  rule axi4Lite_read_request;
    let arflit <- get (axi4LiteShim.master.ar);
    // TODO assert that the requested size is indeed 32 bits?
    busReqFF.enq (tuple4 (truncate (arflit.araddr), 1'b1, 1'b0, ?));
  endrule
  rule axi4Lite_read_response (sl3.bus_waitrequest == 1'b0);
    rdRspFF.deq;
    axi4LiteShim.master.r.put(AXI4Lite_RFlit { rdata: zeroExtend (sl3.bus_read_data)
                                             , rresp: OKAY
                                             , ruser: ? });
  endrule

  // XXX proposed implementation for AXI4Lite writes (fire and forget)
  rule axi4Lite_write;
    let awflit <- get (axi4LiteShim.master.aw);
    let wflit <- get (axi4LiteShim.master.w);
    // TODO assert that the writen size is indeed 32 bits?
    // TODO consider w.wstrb?
    //      would imply a read first to get the value to merge with?
    //      or maybe assert that it is always 'b1111
    busReqFF.enq (tuple4 (truncate (awflit.awaddr), 1'b0, 1'b1, truncate (wflit.wdata)));
    axi4LiteShim.master.b.put(AXI4Lite_BFlit { bresp: OKAY
                                             , buser: ? });
  endrule

  //----------------------------------------------------------------------------
  Sink #(SerialLite3_StreamFlit) rawTX = interface Sink;
    method canPut = sl3.ready_tx==1; // clocked_by tx_clk reset_by tx_rst
    method Action put(d); // clocked_by tx_clk reset_by tx_rst;
      sl3.tx(d.data, pack(d.start_of_burst), pack(d.end_of_burst), d.sync);
    endmethod
  endinterface;

  Source #(SerialLite3_StreamFlit) rawRX = interface Source;
    method Bool canPeek = sl3.valid_rx()==1; // clocked_by rx_clk reset_by rx_rst;
    method SerialLite3_StreamFlit peek(); // if (sl3.valid_rx); // clocked_by rx_clk reset_by rx_rst =
      return SerialLite3_StreamFlit{data:sl3.data_rx(), start_of_burst:sl3.start_of_burst_rx()==1, end_of_burst:sl3.end_of_burst_rx()==1, sync:sl3.sync_rx()};
    endmethod
    method Action drop = sl3.rx_drop; // clocked_by rx_clk reset_by rx_rst;
  endinterface;

  //----------------------------------------------------------------------------

  interface Clock rx_clk = sl3.rx_clk;
  interface Reset rx_rst = sl3.rx_rst;

  interface SerialLite3_ExternalPins pins;
    method qsfp28_tx_pins = sl3.qsfp28_tx_pins;
    method qsfp28_rx_pins = sl3.qsfp28_rx_pins;
  endinterface

  interface tx = mapSink (axs2sl3, rawTX);
  interface rx = mapSource (sl32axs, rawRX);

  method SerialLite3_LinkStatus link_status =
    SerialLite3_LinkStatus{error_rx:sync_error_rx.crossed(),
                           error_tx:sync_error_tx.crossed(),
                           link_up_tx:sync_link_up_tx.read(),
                           link_up_rx:sync_link_up_rx.read()};

  interface management_subordinate = axi4LiteShim.slave;

endmodule


// Create a stand-alone instance that could be imported into Platform Designer as a component
(* synthesize, default_clock_osc = "csi_clk", default_reset = "rsi_rst"
             , clock_prefix = "cso", reset_prefix= "rso" *)
module mkSerialLite3_Instance ( (* osc = "csi_tx_clk" *) Clock tx_clk
                              , (* reset = "rsi_tx_rst" *) Reset tx_rst
                              , (* osc = "csi_qsfp_refclk" *) Clock qsfp_refclk
                              , SerialLite3_Sig#(/*SerialLite3_StreamFlit, SerialLite3_StreamFlit,*/
                                                 //  t_addr, t_data, t_awuser, t_wuser, t_buser, t_aruser, t_ruser
                                                         14,     32,     0,        0,       0,       0,        0) sl3);

  let sl3 <- mkSerialLite3(tx_clk, tx_rst, qsfp_refclk);
  let sl3_sig <- toSerialLite3_Sig (sl3, tx_clk, tx_rst);
  return sl3_sig;

endmodule

endpackage: SerialLite3
