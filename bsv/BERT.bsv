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

  interface AXI4Stream_Master_Sig #(0, 256, 0, 9) txstream;
  interface AXI4Stream_Slave_Sig  #(0, 256, 0, 9) rxstream;
  
  interface AXI4Lite_Slave_Sig #( t_addr, 32
				, t_awuser, t_wuser, t_buser
				, t_aruser, t_ruser) mem_csrs;
endinterface


module mkBERT(BERT#(t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser) ifc);

  AXI4Stream_Shim#(0, 256, 0, 9) txfifo <- mkAXI4StreamShimUGSizedFIFOF32();
  AXI4Stream_Shim#(0, 256, 0, 9) rxfifo <- mkAXI4StreamShimUGSizedFIFOF32();
  let axiShim <- mkAXI4LiteShimFF;

  rule read_req;
    let r <- get (axiShim.master.ar);
    Bit#(32) d = 32'hdeaddead;
    if((r.araddr[2]==1'b0) && rxfifo.master.canPeek)
      begin
	let f = rxfifo.master.peek;
	d = truncate(f.tdata);
	rxfifo.master.drop;
      end
    if(r.araddr[2]==1'b1)
      d = zeroExtend({pack(rxfifo.master.canPeek), pack(txfifo.slave.canPut)});
    let rsp = AXI4Lite_RFlit { rdata: d
                             , rresp: OKAY
                             , ruser: ? };
    axiShim.master.r.put (rsp);
  endrule

  // write requests handling, i.e. always ignnore write and return success
  rule write_req;
    let aw <- get (axiShim.master.aw);
    let w <- get (axiShim.master.w);
    if((aw.awaddr[2]==1'b0) && txfifo.slave.canPut())
      txfifo.slave.put(AXI4Stream_Flit{ tdata: zeroExtend(w.wdata)
				      , tstrb: ~0
				      , tkeep: ~0
				      , tlast: True
				      , tid: ?
				      , tdest: ?
				      , tuser: 0} );
    // if (aw.awaddr[1]==1'b1) - use this to control testing?
    let rsp = AXI4Lite_BFlit { bresp: OKAY, buser: ? };
    axiShim.master.b.put (rsp);
  endrule
  // interface
  interface mem_csrs = axiShim.slave;
  interface txstream = txfifo.master;
  interface rxstream = rxfifo.slave;
endmodule



module toBERT_Sig#(BERT#(t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser) ifc)
   		         (BERT_Sig#(t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser));
  let sigAXI4LitePort <- toAXI4Lite_Slave_Sig(ifc.mem_csrs);
  let sigTXport <- toAXI4Stream_Master_Sig(ifc.txstream);
  let sigRXport <- toAXI4Stream_Slave_Sig(ifc.rxstream);
  return interface BERT_Sig;
    interface mem_csrs = sigAXI4LitePort;
    interface txstream = sigTXport;
    interface rxstream = sigRXport;
  endinterface;
endmodule
  

(* synthesize *)
module mkBERT_Inst(BERT_Sig#(// t_addr, t_awuser, t_wuser, t_buser, t_aruser, t_ruser
			             3,        0,       0,       0,        0,       0) pg);
  let pg <- mkBERT();
  let pg_sig <- toBERT_Sig(pg);
  return pg_sig;
endmodule


endpackage
