module swm_tx_adapter
  (
   input 	  clk_in_clk,
   input 	  reset_in_rst,
   
   input [31:0]   avalonst_sink_data,
   input 	  avalonst_sink_valid,
   input 	  avalonst_sink_startofpacket,
   input 	  avalonst_sink_endofpacket,
   output 	  avalonst_sink_ready,
   
   output [255:0] data_tx,
   output 	  valid_tx,
   output 	  start_of_burst_tx,
   output 	  end_of_burst_tx,
   input  [3:0]   error_tx,
   output [7:0]   sync_tx,
   input 	  ready_tx
   );

   wire [7:0] num_64b_words_per_cycle = 8'd4;

   assign data_tx[31:0] = avalonst_sink_data;
   // fill unused bits with the word alignment pattern
   assign data_tx[255:32] = 224'hbcbcbcbc_bcbcbcbc_bcbcbcbc_bcbcbcbc_bcbcbcbc_bcbcbcbc_bcbcbcbc; 
   assign valid_tx = avalonst_sink_valid;
   assign start_of_burst_tx = avalonst_sink_startofpacket;
   assign end_of_burst_tx = avalonst_sink_endofpacket;
   assign sync_tx = num_64b_words_per_cycle;
   assign avalonst_sink_ready = ready_tx;
   
endmodule
		    
