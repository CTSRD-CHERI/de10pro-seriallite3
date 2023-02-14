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
 * Wrapper around Intel's dual-clock FIFO (dcfifo) primitive in pipeline
 * mode.  This version turns off lpm_showahead resulting in rdreq
 * requesting data to be dequeued and presented in the next clock cycle.
 * According to Intel's documentation, this results in a faster FIFO but
 * you can no longer look at the data without dequeuing it. As a result
 * the usual Bluespec FIFO "first" method cannot be implemented.
 * 
 * For the "show-ahead" mode documentation, see:
 * https://www.intel.com/content/www/us/en/docs/programmable/683522/18-0/scfifo-and-dcfifo-show-ahead-mode.html
 * 
 * TODO: also turn off overflow and underflow checking?
 */


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  s10dcfifopipelined
  (
   data,
   rdclk,
   rdrst_n, // read reset ignored but makes BSV wrapper simpler
   rdreq,
   wrclk,
   wrrst_n,
   wrreq,
   q,
   q_valid,
   rdempty_n,
   wrfull_n);

   parameter WIDTH=1;
   parameter DEPTH=2;

   input  [WIDTH-1:0] data;
   input    	      rdclk;
   input  	      rdrst_n;
   input  	      rdreq;
   input  	      wrclk;
   input              wrrst_n;
   input   	      wrreq;
   output [WIDTH-1:0] q;
   output             q_valid;
   output 	      rdempty_n;
   output 	      wrfull_n;

   wire 	      rdempty;
   wire 	      wrfull;
   assign rdempty_n = !rdempty;
   assign wrfull_n = !wrfull;

   // reset comes from writer, so synchronise it
   reg [1:0] 	      sync_wrrst_n;
   always @(posedge rdclk)
     sync_wrrst_n <= {sync_wrrst_n[0], wrrst_n};
   // generate a q_valid signal
   reg 		      q_valid_r;
   assign q_valid = q_valid_r;
   always @(posedge rdclk, posedge sync_wrrst_n[1])
     if(!sync_wrrst_n[1])
       q_valid_r <= 0;
     else
       q_valid_r <= rdreq;
   
/*
 `ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
    tri0     aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif
    wire [255:0] sub_wire0;
    wire  sub_wire1;
    wire  sub_wire2;
    wire [255:0] q = sub_wire0[255:0];
    wire  rdempty = sub_wire1;
    wire  wrfull = sub_wire2;
*/
   
    dcfifo  dcfifo_component (
                .aclr (!wrrst_n),
                .data (data),
                .rdclk (rdclk),
                .rdreq (rdreq),
                .wrclk (wrclk),
                .wrreq (wrreq),
                .q (q),
                .rdempty (rdempty),
                .wrfull (wrfull),
                .eccstatus (),
                .rdfull (),
                .rdusedw (),
                .wrempty (),
                .wrusedw ());
    defparam
        dcfifo_component.enable_ecc  = "FALSE",
        dcfifo_component.intended_device_family  = "Stratix 10",
        dcfifo_component.lpm_hint  = "DISABLE_DCFIFO_EMBEDDED_TIMING_CONSTRAINT=TRUE",
        dcfifo_component.lpm_numwords  = DEPTH,
        dcfifo_component.lpm_showahead  = "OFF",
        dcfifo_component.lpm_type  = "dcfifo",
        dcfifo_component.lpm_width  = WIDTH,
        dcfifo_component.lpm_widthu  = 5,
        dcfifo_component.overflow_checking  = "OFF",
        dcfifo_component.rdsync_delaypipe  = 4,
        dcfifo_component.read_aclr_synch  = "OFF",
        dcfifo_component.underflow_checking  = "OFF",
        dcfifo_component.use_eab  = "ON",
        dcfifo_component.write_aclr_synch  = "ON",
        dcfifo_component.wrsync_delaypipe  = 4;

endmodule


