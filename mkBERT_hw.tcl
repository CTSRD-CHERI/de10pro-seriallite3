# TCL File Generated by Component Editor 22.1
# Mon Jan 16 17:16:32 UTC 2023
# DO NOT MODIFY


# 
# mkBERT_Instance "mkBERT_Instance" v1.0
#  2023.01.16.17:16:32
# 
# 

# 
# request TCL package from ACDS 22.1
# 
package require -exact qsys 22.1


# 
# module mkBERT_Instance
# 
set_module_property DESCRIPTION ""
set_module_property NAME mkBERT_Instance
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME mkBERT_Instance
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property LOAD_ELABORATION_LIMIT 0


# 
# file sets
# 
add_fileset mkBERT_Instance_fileset QUARTUS_SYNTH "" ""
set_fileset_property mkBERT_Instance_fileset TOP_LEVEL mkBERT_Instance
set_fileset_property mkBERT_Instance_fileset ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property mkBERT_Instance_fileset ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file mkBERT_Instance.v VERILOG PATH bsv/output/mkBERT_Instance.v TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point CLK
# 
add_interface CLK clock end
set_interface_property CLK ENABLED true
set_interface_property CLK EXPORT_OF ""
set_interface_property CLK PORT_NAME_MAP ""
set_interface_property CLK CMSIS_SVD_VARIABLES ""
set_interface_property CLK SVD_ADDRESS_GROUP ""
set_interface_property CLK IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port CLK CLK clk Input 1


# 
# connection point CLK_csi_rx_clk
# 
add_interface CLK_csi_rx_clk clock end
set_interface_property CLK_csi_rx_clk ENABLED true
set_interface_property CLK_csi_rx_clk EXPORT_OF ""
set_interface_property CLK_csi_rx_clk PORT_NAME_MAP ""
set_interface_property CLK_csi_rx_clk CMSIS_SVD_VARIABLES ""
set_interface_property CLK_csi_rx_clk SVD_ADDRESS_GROUP ""
set_interface_property CLK_csi_rx_clk IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port CLK_csi_rx_clk CLK_csi_rx_clk clk Input 1


# 
# connection point CLK_csi_tx_clk
# 
add_interface CLK_csi_tx_clk clock end
set_interface_property CLK_csi_tx_clk ENABLED true
set_interface_property CLK_csi_tx_clk EXPORT_OF ""
set_interface_property CLK_csi_tx_clk PORT_NAME_MAP ""
set_interface_property CLK_csi_tx_clk CMSIS_SVD_VARIABLES ""
set_interface_property CLK_csi_tx_clk SVD_ADDRESS_GROUP ""
set_interface_property CLK_csi_tx_clk IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port CLK_csi_tx_clk CLK_csi_tx_clk clk Input 1


# 
# connection point RST_N
# 
add_interface RST_N reset end
set_interface_property RST_N associatedClock CLK
set_interface_property RST_N synchronousEdges DEASSERT
set_interface_property RST_N ENABLED true
set_interface_property RST_N EXPORT_OF ""
set_interface_property RST_N PORT_NAME_MAP ""
set_interface_property RST_N CMSIS_SVD_VARIABLES ""
set_interface_property RST_N SVD_ADDRESS_GROUP ""
set_interface_property RST_N IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port RST_N RST_N reset_n Input 1


# 
# connection point RST_N_csi_rx_rst_n
# 
add_interface RST_N_csi_rx_rst_n reset end
set_interface_property RST_N_csi_rx_rst_n associatedClock CLK_csi_rx_clk
set_interface_property RST_N_csi_rx_rst_n synchronousEdges DEASSERT
set_interface_property RST_N_csi_rx_rst_n ENABLED true
set_interface_property RST_N_csi_rx_rst_n EXPORT_OF ""
set_interface_property RST_N_csi_rx_rst_n PORT_NAME_MAP ""
set_interface_property RST_N_csi_rx_rst_n CMSIS_SVD_VARIABLES ""
set_interface_property RST_N_csi_rx_rst_n SVD_ADDRESS_GROUP ""
set_interface_property RST_N_csi_rx_rst_n IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port RST_N_csi_rx_rst_n RST_N_csi_rx_rst_n reset_n Input 1


# 
# connection point RST_N_csi_tx_rst_n
# 
add_interface RST_N_csi_tx_rst_n reset end
set_interface_property RST_N_csi_tx_rst_n associatedClock CLK_csi_rx_clk
set_interface_property RST_N_csi_tx_rst_n synchronousEdges DEASSERT
set_interface_property RST_N_csi_tx_rst_n ENABLED true
set_interface_property RST_N_csi_tx_rst_n EXPORT_OF ""
set_interface_property RST_N_csi_tx_rst_n PORT_NAME_MAP ""
set_interface_property RST_N_csi_tx_rst_n CMSIS_SVD_VARIABLES ""
set_interface_property RST_N_csi_tx_rst_n SVD_ADDRESS_GROUP ""
set_interface_property RST_N_csi_tx_rst_n IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port RST_N_csi_tx_rst_n RST_N_csi_tx_rst_n reset_n Input 1


# 
# connection point mem_csrs
# 
add_interface mem_csrs axi4lite end
set_interface_property mem_csrs associatedClock CLK
set_interface_property mem_csrs associatedReset RST_N
set_interface_property mem_csrs readAcceptanceCapability 1
set_interface_property mem_csrs writeAcceptanceCapability 1
set_interface_property mem_csrs combinedAcceptanceCapability 1
set_interface_property mem_csrs bridgesToMaster ""
set_interface_property mem_csrs ENABLED true
set_interface_property mem_csrs EXPORT_OF ""
set_interface_property mem_csrs PORT_NAME_MAP ""
set_interface_property mem_csrs CMSIS_SVD_VARIABLES ""
set_interface_property mem_csrs SVD_ADDRESS_GROUP ""
set_interface_property mem_csrs IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port mem_csrs axls_mem_csrs_rready rready Input 1
add_interface_port mem_csrs axls_mem_csrs_rvalid rvalid Output 1
add_interface_port mem_csrs axls_mem_csrs_rresp rresp Output 2
add_interface_port mem_csrs axls_mem_csrs_rdata rdata Output 32
add_interface_port mem_csrs axls_mem_csrs_arready arready Output 1
add_interface_port mem_csrs axls_mem_csrs_arprot arprot Input 3
add_interface_port mem_csrs axls_mem_csrs_araddr araddr Input 8
add_interface_port mem_csrs axls_mem_csrs_arvalid arvalid Input 1
add_interface_port mem_csrs axls_mem_csrs_bready bready Input 1
add_interface_port mem_csrs axls_mem_csrs_bvalid bvalid Output 1
add_interface_port mem_csrs axls_mem_csrs_bresp bresp Output 2
add_interface_port mem_csrs axls_mem_csrs_wready wready Output 1
add_interface_port mem_csrs axls_mem_csrs_wstrb wstrb Input 4
add_interface_port mem_csrs axls_mem_csrs_wdata wdata Input 32
add_interface_port mem_csrs axls_mem_csrs_wvalid wvalid Input 1
add_interface_port mem_csrs axls_mem_csrs_awready awready Output 1
add_interface_port mem_csrs axls_mem_csrs_awprot awprot Input 3
add_interface_port mem_csrs axls_mem_csrs_awaddr awaddr Input 8
add_interface_port mem_csrs axls_mem_csrs_awvalid awvalid Input 1


# 
# connection point rxstream
# 
add_interface rxstream axi4stream end
set_interface_property rxstream associatedClock CLK_csi_rx_clk
set_interface_property rxstream associatedReset RST_N_csi_rx_rst_n
set_interface_property rxstream ENABLED true
set_interface_property rxstream EXPORT_OF ""
set_interface_property rxstream PORT_NAME_MAP ""
set_interface_property rxstream CMSIS_SVD_VARIABLES ""
set_interface_property rxstream SVD_ADDRESS_GROUP ""
set_interface_property rxstream IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port rxstream axstrs_rxstream_tready tready Output 1
add_interface_port rxstream axstrs_rxstream_tuser tuser Input 9
add_interface_port rxstream axstrs_rxstream_tlast tlast Input 1
add_interface_port rxstream axstrs_rxstream_tkeep tkeep Input 32
add_interface_port rxstream axstrs_rxstream_tstrb tstrb Input 32
add_interface_port rxstream axstrs_rxstream_tdata tdata Input 256
add_interface_port rxstream axstrs_rxstream_tvalid tvalid Input 1


# 
# connection point txstream
# 
add_interface txstream axi4stream start
set_interface_property txstream associatedClock CLK_csi_tx_clk
set_interface_property txstream associatedReset RST_N_csi_tx_rst_n
set_interface_property txstream ENABLED true
set_interface_property txstream EXPORT_OF ""
set_interface_property txstream PORT_NAME_MAP ""
set_interface_property txstream CMSIS_SVD_VARIABLES ""
set_interface_property txstream SVD_ADDRESS_GROUP ""
set_interface_property txstream IPXACT_REGISTER_MAP_VARIABLES ""

add_interface_port txstream axstrm_txstream_tready tready Input 1
add_interface_port txstream axstrm_txstream_tvalid tvalid Output 1
add_interface_port txstream axstrm_txstream_tuser tuser Output 9
add_interface_port txstream axstrm_txstream_tlast tlast Output 1
add_interface_port txstream axstrm_txstream_tkeep tkeep Output 32
add_interface_port txstream axstrm_txstream_tstrb tstrb Output 32
add_interface_port txstream axstrm_txstream_tdata tdata Output 256

