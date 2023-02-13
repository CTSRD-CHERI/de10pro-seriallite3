// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  s10dcfifo 
  (
   data,
   rdclk,
   rdrst_n, // reset ignored
   rdreq,
   wrclk,
   wrrst_n,
   wrreq,
   q,
   rdempty_n,
   wrfull_n);

   parameter WIDTH=1;
   parameter DEPTH=2;

   input  [WIDTH:0] data;
   input  	    rdclk;
   input  	    rdrst_n;
   input  	    rdreq;
   input  	    wrclk;
   input            wrrst_n;
   input   	    wrreq;
   output [WIDTH:0] q;
   output 	    rdempty_n;
   output 	    wrfull_n;

   wire 	    rdempty;
   wire 	    wrfull;
   assign rdempty_n = !rdempty;
   assign wrfull_n = !wrfull;
   
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
        dcfifo_component.lpm_showahead  = "ON",
        dcfifo_component.lpm_type  = "dcfifo",
        dcfifo_component.lpm_width  = WIDTH,
        dcfifo_component.lpm_widthu  = 5,
        dcfifo_component.overflow_checking  = "ON",
        dcfifo_component.rdsync_delaypipe  = 4,
        dcfifo_component.read_aclr_synch  = "OFF",
        dcfifo_component.underflow_checking  = "ON",
        dcfifo_component.use_eab  = "ON",
        dcfifo_component.write_aclr_synch  = "ON",
        dcfifo_component.wrsync_delaypipe  = 4;

endmodule


