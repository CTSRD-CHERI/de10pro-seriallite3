module swm_rx_adapter
  (
   input 	 clk_in_clk,
   input 	 reset_in_rst,
   
   output [31:0] avalonst_source_data,
   output 	 avalonst_source_valid,
   output 	 avalonst_source_startofpacket,
   output 	 avalonst_source_endofpacket,
   input 	 avalonst_source_ready,
   
   input [255:0] data_rx,
   input 	 valid_rx,
   input 	 start_of_burst_rx,
   input 	 end_of_burst_rx,
   input [8:0] 	 error_rx,
   input [7:0] 	 sync_rx,
   output 	 ready_rx
   );

   assign avalonst_source_data = data_rx[31:0];
   assign avalonst_source_valid = valid_rx;
   assign avalonst_source_startofpacket = start_of_burst_rx;
   assign avalonst_source_endofpacket = end_of_burst_rx;
   assign ready_rx = avalonst_source_ready;
   
endmodule
		    
