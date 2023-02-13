/*
 * Copyright (c) 2023 Simon W. Moore
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
 * Bluespec wrapper around Intel's dcfifo primative, i.e. a memory based
 * clock-crossing FIFO.
 * 
 * N.B. this comes with a generic constraints file (SDC file) that is needed
 * for correct timing analysis
 */


package S10FIFO;

import Clocks     :: *;

/* The following modules comply with the existing SyncFIFOIfc:
 *    interface SyncFIFOIfc #(type a_type) ;
 *      method Action enq ( a_type sendData ) ;
 *      method Action deq () ;
 *      method a_type first () ;
 *      method Bool notFull () ;
 *      method Bool notEmpty () ;
 *   endinterface
 */

import "BVI" s10dcfifo =
module mkS10DCFIFO
  (Integer depth,
   Clock dClkIn, Reset dRstIn_n,
   SyncFIFOIfc#(a) ifc)
  provisos (Bits#(a,a_width));

  parameter WIDTH = valueOf(a_width);
  parameter DEPTH = depth;

  default_clock sClkIn (wrclk, (*unused*) wrclk_gate);
  default_reset sRstIn_n (wrrst_n);
  input_clock (rdclk, (*unused*) rdclk_gate) = dClkIn;
  input_reset (rdrst_n)  clocked_by (dClkIn) = dRstIn_n;
  
  method enq(data) enable (wrreq) ready (wrfull_n) clocked_by (sClkIn) reset_by (sRstIn_n);
  method wrfull_n notFull() clocked_by (sClkIn) reset_by (sRstIn_n);
  
  method deq() enable (rdreq) ready (rdempty_n) clocked_by (dClkIn) reset_by (dRstIn_n);
  method q first() ready (rdempty_n) clocked_by (dClkIn) reset_by (dRstIn_n);
  method rdempty_n notEmpty() clocked_by (dClkIn) reset_by (dRstIn_n);
  
  schedule enq C enq;
  schedule notFull SB enq;
  schedule notFull CF notFull;
  
  schedule first SB deq;
  schedule first CF first;
  schedule first CF notEmpty;
  schedule notEmpty SB deq;
  schedule notEmpty CF notEmpty;
  schedule deq C deq;
    
  schedule (enq, notFull) CF (deq, first, notEmpty);
endmodule


module mkS10DCFIFOfromCC
 #(Integer depth)
  (Clock dClkIn,
   Reset dRstIn_n,
   SyncFIFOIfc#(a) ifc)
  provisos (Bits#(a,a_width));  

  SyncFIFOIfc#(a)   fifo <- mkS10DCFIFO(depth, dClkIn, dRstIn_n);
  return fifo;
endmodule

  
module mkS10DCFIFOtoCC
   #(Integer depth)
   (Clock sClkIn, Reset sRstIn_n,
    SyncFIFOIfc#(a) ifc)
  provisos (Bits#(a,a_width));  

  Clock           dClkIn <- exposeCurrentClock;
  Reset         dRstIn_n <- exposeCurrentReset;
  SyncFIFOIfc#(a)   fifo <- mkS10DCFIFO(depth, dClkIn, dRstIn_n, clocked_by sClkIn, reset_by sRstIn_n);
  return fifo;
endmodule

  
endpackage
