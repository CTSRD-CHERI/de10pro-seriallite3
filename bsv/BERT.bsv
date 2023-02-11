/*
 * Copyright (c) 2022 Simon W. Moore
 * All rights reserved.
 *
 * @BERI_LICENSE_HEADER_START@
 *
 * Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
 * license agreements.  See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership.  BERI licenses this
 * file to you under the BERI Hardware-Software License, Version 1.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 *   http://www.beri-open-systems.org/legal/license-1-0.txt
 *
 * Unless required by applicable law or agreed to in writing, Work distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * @BERI_LICENSE_HEADER_END@
 *
 * ----------------------------------------------------------------------------
 *
 * Bit Error Rate Tester (BERT)
 * Plus simple TX and RX FIFO channels
 */


package BERT;

import BlueAXI4   :: *;
import BlueBasics :: *;
import FIFOF      :: *;
import Clocks     :: *;
import ConfigReg  :: *;
import DReg       :: *;

`include "TimeStamp.bsv"
`include "QSF_Params.bsv"

interface BERT#(
  numeric type t_addr
, numeric type t_awuser, numeric type t_wuser, numeric type t_buser
, numeric type t_aruser, numeric type t_ruser
);

  // stream to transmit
  interface AXI4Stream_Master #(0, 256, 0, 9) txstream;
  // stream to receive
  interface AXI4Stream_Slave #(0, 256, 0, 9) rxstream;

  // memory slave for control/status registers
  interface AXI4Lite_Slave #( t_addr, 32
                            , t_awuser, t_wuser, t_buser
                            , t_aruser, t_ruser) mem_csrs;
endinterface


interface BERT_Sig#(
  numeric type t_addr
, numeric type t_awuser, numeric type t_wuser, numeric type t_buser
, numeric type t_aruser, numeric type t_ruser
);

  (* prefix = "axstrm_txstream" *)
  interface AXI4Stream_Master_Sig #(0, 256, 0, 9) txstream;
  (* prefix = "axstrs_rxstream" *)
  interface AXI4Stream_Slave_Sig  #(0, 256, 0, 9) rxstream;
  (* prefix = "axls_mem_csrs" *)
  interface AXI4Lite_Slave_Sig #( t_addr, 32
                                , t_awuser, t_wuser, t_buser
                                , t_aruser, t_ruser) mem_csrs;
endinterface


function Bit#(256) next_bert_test_correct(Bit#(256) current);
  Bit#(64)  prime_number = truncate(65'h1_00000000_00000000 - 65'd59); // 2^64-59 is prime
  Bit#(256) next;
  next[ 63:  0] = current[63:0] + prime_number;
  next[127: 64] = next[63:0] ^ 64'hffffffff_ffffffff;
  next[191:128] = next[63:0] & 64'haaaaaaaa_aaaaaaaa;
  next[255:192] = next[63:0] | 64'haaaaaaaa_aaaaaaaa; // note that it is imprtant that the top byte != 0 for routing to the BERT to work
  return next;
endfunction

//function Bit#(256) next_bert_test(Bit#(256) current) = (256'hff<<248) | 256'h12345678; // constant for initial testing
//function Bit#(256) next_bert_test(Bit#(256) current) = (256'hff<<248) | (current[247:0]+1); // for initial testing

function Bit#(256) next_bert_test(Bit#(256) current); // for initial testing
  Bit#(256) next;
  next[ 63:  0] = current[63:0] + 1;
  next[127: 64] = next[63:0] ^ 64'hffffffff_ffffffff;
  next[191:128] = next[63:0] & 64'haaaaaaaa_aaaaaaaa;
  next[255:192] = next[63:0] | 64'haaaaaaaa_aaaaaaaa; // note that it is imprtant that the top byte != 0 for routing to the BERT to work
  return next;
endfunction



module mkBERT(Clock csi_rx_clk, Reset csi_rx_rst_n,
	      Clock csi_tx_clk, Reset csi_tx_rst_n,
	      BERT#(t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser) ifc);

  AXI4Stream_Shim#(0, 256, 0, 9)                  rxfifo <- mkAXI4StreamShimUGSizedFIFOF32();
  AXI4Stream_Shim#(0, 256, 0, 9)            rx_fast_fifo <- mkAXI4StreamShimUGSizedFIFOF32(clocked_by csi_rx_clk, reset_by csi_rx_rst_n);
  SyncFIFOIfc#(AXI4Stream_Flit#(0,256,0,9)) rx_sync_fifo <- mkSyncFIFOToCC(32, csi_rx_clk, csi_rx_rst_n);

  AXI4Stream_Shim#(0, 256, 0, 9)            tx_fast_fifo <- mkAXI4StreamShimSizedFIFOF32(clocked_by csi_tx_clk, reset_by csi_tx_rst_n);
  SyncFIFOIfc#(AXI4Stream_Flit#(0,256,0,9)) tx_sync_fifo <- mkSyncFIFOFromCC(32, csi_tx_clk);

  FIFOF#(Bit#(32))                            data_to_tx <- mkUGFIFOF();
  Reg#(Bit#(32))                                 testreg <- mkReg(0);
  FIFOF#(Bit#(256))                            bert_fifo <- mkUGFIFOF();
  Reg#(Bit#(256))                              bert_test <- mkReg(0);
  Reg#(Bool)                             bert_test_valid <- mkReg(False);
  Reg#(Bit#(256))                               bert_gen <- mkReg(next_bert_test(13)); // TODO dynamically set to some "random value", e.g. based on ChipID?
  Reg#(Bool)                            bert_gen_enabled <- mkConfigReg(False);
  Reg#(Bit#(64))                      bert_correct_flits <- mkConfigReg(0);
  Reg#(Bit#(64))                        bert_error_flits <- mkConfigReg(0);
  Reg#(Bool)                          bert_zero_counters <- mkDReg(False);
  Reg#(Bool)                            bert_inc_correct <- mkDReg(False);
  Reg#(Bool)                              bert_inc_error <- mkDReg(False);
  Reg#(Bit#(10))                           tx_rate_limit <- mkDReg(1);

  FIFOF#(Bit#(0))                              ping_send <- mkUGFIFOF1;
  FIFOF#(Bit#(0))                             ping_reply <- mkUGFIFOF1;
  FIFOF#(Bit#(0))                         ping_in_flight <- mkUGFIFOF1;
  FIFOF#(Bit#(0))                        ping_zero_timer <- mkUGFIFOF1;
  Reg#(Bit#(32))                              ping_timer <- mkReg(0);
  
  let axiShim <- mkAXI4LiteShimFF;
  
  // rule runs in csi_rx_clk domain to forward data to the main clock domain
  rule clock_cross_rx_data(rx_fast_fifo.master.canPeek());
    rx_sync_fifo.enq(rx_fast_fifo.master.peek());
    rx_fast_fifo.master.drop;
  endrule

  rule clock_crossed_rx_data_to_axi4_stream(rx_sync_fifo.notEmpty());
    AXI4Stream_Flit#(0,256,0,9) flit = rx_sync_fifo.first;
    
    // Always deq even if the corresponding receiving FIFO is full
    // since we cannot stop the receiver.  Also, if the rxfifo is full
    // we must not delay receiving BERT flits that will come
    // afterwards otherwise we'll get BERT errors.
    rx_sync_fifo.deq;
    
    // TODO: use the sync byte stored in the ruser field to stear where the flit should go?
    // At present we're going to use the top byte of the tdata field to route the flit
    if((flit.tdata[255:248]==8'h00) && rxfifo.slave.canPut())
      begin
        if(flit.tdata[33:32]==1) // ping flit
	    ping_reply.enq(?);
        else if(flit.tdata[33:32]==2) // ping reply flit
	  ping_in_flight.deq;
	else
	  rxfifo.slave.put(flit); // forward to NIOS monitor port
      end
    if((flit.tdata[255:248]!=8'h00) && bert_fifo.notFull)
      begin
	bert_fifo.enq(flit.tdata); // forward to BERT checker
      end
  endrule
  
  // rule runs in csi_tx_clk domain to forward data from the main clock domain
  rule clock_cross_tx_data(tx_sync_fifo.notEmpty);
    tx_fast_fifo.slave.put(tx_sync_fifo.first);
    tx_sync_fifo.deq;
  endrule
  
  
  rule do_ping_timer(ping_in_flight.notEmpty || ping_zero_timer.notEmpty);
    if(ping_zero_timer.notEmpty)
      begin
	ping_timer <= 0;
	ping_zero_timer.deq;
      end
    else if(ping_in_flight.notEmpty)
      ping_timer <= ping_timer+1;
  endrule

  rule read_req;
    let r <- get (axiShim.master.ar);
    Bit#(32) d = 32'hdeaddead;
    if((r.araddr[7:3]==0) && rxfifo.master.canPeek)
      begin
        let a = rxfifo.master.peek;
	d = truncate(a.tdata);
        rxfifo.master.drop;
      end
    if(r.araddr[7:3]==1)
      d = zeroExtend({pack(rxfifo.master.canPeek), pack(tx_sync_fifo.notFull)});
    if(r.araddr[7:3]==2)
      d = ping_in_flight.notEmpty ? 0 : ping_timer;
    if(r.araddr[7:3]==4)
      d = bert_correct_flits[31:0];
    if(r.araddr[7:3]==5)
      d = bert_correct_flits[63:32];
    if(r.araddr[7:3]==6)
      d = bert_error_flits[31:0];
    if(r.araddr[7:3]==7)
      d = bert_error_flits[63:32];
    if(r.araddr[7:3]==5'h10)
      d = testreg;
    if(r.araddr[7:3]==5'h11)
      d = bert_gen_enabled ? 1 : 0;
    if(r.araddr[7:3]==5'h12)
      d = timestamp()[31:0];
    if(r.araddr[7:3]==5'h13)
      d = timestamp()[63:32];
    if(r.araddr[7:3]==5'h14)
      d = pma_tx_buf_pre_emp_switching_ctrl_pre_tap_1t();
    if(r.araddr[7:3]==5'h15)
      d = pma_tx_buf_pre_emp_switching_ctrl_1st_post_tap();
    let rsp = AXI4Lite_RFlit { rdata: d
                             , rresp: OKAY
                             , ruser: ? };
    axiShim.master.r.put (rsp);
  endrule

  // write requests handling, i.e. always ignnore write and return success
  // stop the bert_generator on any write to multiplex access to the tx_sync_fifo
  rule write_req;
    let aw <- get (axiShim.master.aw);
    let w <- get (axiShim.master.w);
    if((aw.awaddr[7:3]==0) && data_to_tx.notFull)
      data_to_tx.enq(w.wdata);

    if(aw.awaddr[7:3]==2)
      ping_send.enq(?);

    if((aw.awaddr[7:3]>=4) && (aw.awaddr[7:3]<=7))
      bert_zero_counters <= True;
    
    if (aw.awaddr[7:3]==5'h10)
      testreg <= ~w.wdata;
    
    if (aw.awaddr[7:3]==5'h11)
      bert_gen_enabled <= w.wdata[0]==1;
    
    let rsp = AXI4Lite_BFlit { bresp: OKAY, buser: ? };
    axiShim.master.b.put (rsp);
  endrule

  rule tx_data_mux(tx_rate_limit!=0);
    Maybe#(Bit#(256)) d = tagged Invalid;
    
    if(ping_reply.notEmpty)
      begin
	ping_reply.deq;
	d = tagged Valid (2<<32);
      end
    else if (ping_send.notEmpty)
      begin
	ping_send.deq;
	ping_in_flight.enq(?);
	ping_zero_timer.enq(?);
	d = tagged Valid (1<<32);
      end
    else if(data_to_tx.notEmpty)
      begin
	data_to_tx.deq;
	d = tagged Valid zeroExtend(data_to_tx.first);
      end
    else if(bert_gen_enabled)
      begin
	bert_gen <= next_bert_test(bert_gen);
	d = tagged Valid bert_gen;
      end
    
    // tuser: transfers to {start_of_burst (1b), sync_vector (8b)} of Serial Lite III link
    //        for end_of_flit the sync_vector contains the number of INVAID 64b words sent
    if(isValid(d))
      begin
	tx_sync_fifo.enq(AXI4Stream_Flit{ tdata: fromMaybe(?, d)
					, tstrb: ~0
					, tkeep: ~0
					, tlast: True
				        , tid: ?
				        , tdest: ?
				        , tuser: 9'h100} );
	// DReg assignment (defaults to 1) to ensure that we don't transmit every single
	// cycle since the receiver running nominally at the same clock frequency on
	// another FPGA may be a fraction slower.
	tx_rate_limit <= tx_rate_limit + 1; 
      end
  endrule
  
  
  rule bert_tester(bert_fifo.notEmpty());
    Bit#(256) flit = bert_fifo.first;
    bert_fifo.deq;
    // always update the bert_test to predict the next value
    bert_test <= next_bert_test(flit);
    Bool pass = flit == bert_test;
    bert_inc_correct <= bert_test_valid &&  pass; // DReg update
    bert_inc_error   <= bert_test_valid && !pass; // DReg update
    bert_test_valid  <= !bert_test_valid || pass; // Reg update
  endrule
  // pipeine updates to counters of correct and error flits from BERT test
  rule bert_increment_correct(bert_inc_correct || bert_zero_counters);
    bert_correct_flits <= bert_zero_counters ? 0 : bert_correct_flits+1;
  endrule
  rule bert_increment_error(bert_inc_error || bert_zero_counters);
    bert_error_flits <= bert_zero_counters ? 0 : bert_error_flits+1;
  endrule  
  // interface
  interface mem_csrs = axiShim.slave;
  interface txstream = tx_fast_fifo.master;
  interface rxstream = rx_fast_fifo.slave;
endmodule



module toBERT_Sig#(Clock csi_rx_clk, Reset csi_rx_rst_n,
		   Clock csi_tx_clk, Reset csi_tx_rst_n,
		   BERT#(t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser) ifc)
                  (BERT_Sig#(t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser));
  let sigAXI4LitePort <- toAXI4Lite_Slave_Sig(ifc.mem_csrs);
  let sigTXport <- toAXI4Stream_Master_Sig(ifc.txstream, clocked_by csi_tx_clk, reset_by csi_tx_rst_n);
  let sigRXport <- toAXI4Stream_Slave_Sig(ifc.rxstream, clocked_by csi_rx_clk, reset_by csi_rx_rst_n);
  return interface BERT_Sig;
    interface mem_csrs = sigAXI4LitePort;
    interface txstream = sigTXport;
    interface rxstream = sigRXport;
  endinterface;
endmodule


(* synthesize *)
module mkBERT_Instance(Clock csi_rx_clk, Reset csi_rx_rst_n,
		       Clock csi_tx_clk, Reset csi_tx_rst_n,
		       BERT_Sig#(// t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser
                                         8,        0,       0,       0,        0,       0) pg);
  let pg <- mkBERT(csi_rx_clk, csi_rx_rst_n, csi_tx_clk, csi_tx_rst_n);
  let pg_sig <- toBERT_Sig(csi_rx_clk, csi_rx_rst_n, csi_tx_clk, csi_tx_rst_n, pg);
  return pg_sig;
endmodule


endpackage
