# Copyright (c) 2021 Simon W. Moore
# All rights reserved.
#
# @BERI_LICENSE_HEADER_START@
#
# Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  BERI licenses this
# file to you under the BERI Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.beri-open-systems.org/legal/license-1-0.txt
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @BERI_LICENSE_HEADER_END@
#
# ----------------------------------------------------------------------------
# Build FPGA image and test software for the embedded NIOS-V

VERILOG_SRC = DE10_Pro.v			\
	      $(wildcard Fan/*.v)

IP_SRC = soc.qsys				\
	 $(wildcard *.ip)			\
	 $(wildcard ip/soc/*.ip)

VIPBUNDLEDIR ?= $(CURDIR)/vipbundle
VIPBUNDLE ?= $(VIPBUNDLEDIR)/vipbundle
SERIALLITE3_HW_TCL = $(CURDIR)/mkSerialLite3_hw.tcl
SERIALLITE3_BSV_DIR = $(CURDIR)/S10FPGA
SERIALLITE3_RTL = $(SERIALLITE3_BSV_DIR)/output/mkSerialLite3_Instance.v
BERT_HW_TCL = $(CURDIR)/mkBERT_hw.tcl
BERT_BSV_DIR = $(CURDIR)/S10FPGA
BERT_RTL = $(BERT_BSV_DIR)/output/mkBERT_Instance.v
STATUSDEV_HW_TCL = $(CURDIR)/mkStatusDevice_hw.tcl
STATUSDEV_BSV_DIR = $(CURDIR)/S10FPGA
STATUSDEV_RTL = $(STATUSDEV_BSV_DIR)/output/mkStatusDevice_Instance.v
STATUSDEV15_HW_TCL = $(CURDIR)/mkStatusDevice_Status15_hw.tcl
STATUSDEV15_BSV_DIR = $(CURDIR)/S10FPGA
STATUSDEV15_RTL = $(STATUSDEV_BSV_DIR)/output/mkStatusDevice_Instance_Status15.v

.PHONY: help
help:
	@echo "This Makefile is typically started by a ../tests/*/Makefile"
	@echo "Build steps:"
	@echo "0. Clean up: make clean"
	@echo "1. Compile Bluespec design under test (DUT): compile_dut"
	@echo "2. Generate the FPGA image (also does step 1): make fpga_image"
	@echo "3. Program FPGA: make program_fpga"
	@echo "4. Run test: make test"
	@echo "Alternatively, do all of the above in one go (without make clean): make all"

.PHONY: all
all: fpga_image niosv_software
# program_fpga test

#-----------------------------------------------------------------------------
# build the FPGA image
#  - also generates IP required by DE10_Pro.qsf
.PHONY: fpga_image
fpga_image: output_files/DE10_Pro.sof

output_files/DE10_Pro.sof: $(VERILOG_SRC) generate_ip
	quartus_sh --flow compile DE10_Pro.qpf

.PHONY: generate_ip
generate_ip: $(IP_SRC) $(STATUSDEV_HW_TCL) $(BERT_HW_TCL) $(SERIALLITE3_HW_TCL)
	$(MAKE) -C $(SERIALLITE3_BSV_DIR) all    # a bit of a hack?
	quartus_ipgenerate --generate_project_ip_files -synthesis=verilog DE10_Pro.qpf --clear_ip_generation_dirs

#-----------------------------------------------------------------------------
# get the tcl for the serial lite 3 rtl
$(SERIALLITE3_HW_TCL): $(VIPBUNDLE) $(SERIALLITE3_RTL)
	$(VIPBUNDLE) -f quartus_ip_tcl -o $@ $(SERIALLITE3_RTL)
.PHONY: generate_seriallite3_tcl clean_seriallite3_tcl
generate_seriallite3_tcl: $(SERIALLITE3_HW_TCL)
clean_seriallite3_tcl:
	rm -f $(SERIALLITE3_HW_TCL)

#-----------------------------------------------------------------------------
# Build the RTL for the Serial lite 3 module
$(SERIALLITE3_RTL):
	$(MAKE) -C $(SERIALLITE3_BSV_DIR) mkSerialLite3_Instance
.PHONY: generate_seriallite3_rtl clean_seriallite3_rtl mrproper_seriallite3_rtl
generate_seriallite3_rtl: $(SERIALLITE3_RTL)
clean_seriallite3_rtl:
	$(MAKE) -C $(SERIALLITE3_BSV_DIR) clean
mrproper_seriallite3_rtl:
	$(MAKE) -C $(SERIALLITE3_BSV_DIR) mrproper

#-----------------------------------------------------------------------------
# get the tcl for the bit error rate tester
$(BERT_HW_TCL): $(VIPBUNDLE) $(BERT_RTL)
	$(VIPBUNDLE) -f quartus_ip_tcl -o $@ $(BERT_RTL)
.PHONY: generate_bert_tcl clean_bert_tcl
generate_bert_tcl: $(BERT_HW_TCL)
clean_bert_tcl:
	rm -f $(BERT_HW_TCL)

#-----------------------------------------------------------------------------
# Build the RTL for the bit error rate tester
$(BERT_RTL):
	$(MAKE) -C $(BERT_BSV_DIR) mkBERT_Instance
.PHONY: generate_bert_rtl clean_bert_rtl mrproper_bert_rtl
generate_bert_rtl: $(BERT_RTL)
clean_bert_rtl:
	$(MAKE) -C $(BERT_BSV_DIR) clean
mrproper_bert_rtl:
	$(MAKE) -C $(BERT_BSV_DIR) mrproper

#-----------------------------------------------------------------------------
# get the tcl for the status device
$(STATUSDEV_HW_TCL): $(VIPBUNDLE) $(STATUSDEV_RTL)
	$(VIPBUNDLE) -f quartus_ip_tcl -o $@ $(STATUSDEV_RTL)
.PHONY: generate_status_dev_tcl clean_status_dev_tcl
generate_status_dev_tcl: $(STATUSDEV_HW_TCL)
clean_status_dev_tcl:
	rm -f $(STATUSDEV_HW_TCL)

# get the tcl for the status device
$(STATUSDEV15_HW_TCL): $(VIPBUNDLE) $(STATUSDEV15_RTL)
	$(VIPBUNDLE) -f quartus_ip_tcl -o $@ $(STATUSDEV15_RTL)
.PHONY: generate_status_dev_15_tcl clean_status_dev_15_tcl
generate_status_dev_15_tcl: $(STATUSDEV15_HW_TCL)
clean_status_dev_15_tcl:
	rm -f $(STATUSDEV15_HW_TCL)

#-----------------------------------------------------------------------------
# Build the RTL for the status device
$(STATUSDEV_RTL):
	$(MAKE) -C $(STATUSDEV_BSV_DIR) mkStatusDevice_Instance
.PHONY: generate_status_dev_rtl clean_status_dev_rtl mrproper_status_dev_rtl
generate_status_dev_rtl: $(STATUSDEV_RTL)
clean_status_dev_rtl:
	$(MAKE) -C $(STATUSDEV_BSV_DIR) clean
mrproper_status_dev_rtl:
	$(MAKE) -C $(STATUSDEV_BSV_DIR) mrproper

$(STATUSDEV15_RTL):
	$(MAKE) -C $(STATUSDEV15_BSV_DIR) mkStatusDevice_Instance_Status15
.PHONY: generate_status_dev_15_rtl clean_status_dev_15_rtl mrproper_status_dev_15_rtl
generate_status_dev_15_rtl: $(STATUSDEV15_RTL)
clean_status_dev_15_rtl:
	$(MAKE) -C $(STATUSDEV15_BSV_DIR) clean
mrproper_status_dev_15_rtl:
	$(MAKE) -C $(STATUSDEV15_BSV_DIR) mrproper

#-----------------------------------------------------------------------------
# build vipbundle
$(VIPBUNDLE):
	$(MAKE) -C $(VIPBUNDLEDIR) vipbundle

.PHONY: vipbundle clean-vipbundle
vipbundle: $(VIPBUNDLE)
clean_vipbundle:
	$(MAKE) -C $(VIPBUNDLEDIR) clean

#-----------------------------------------------------------------------------
# program the FPGA
.PHONY: program_fpga
program_fpga:
	./py/flashDE10 output_files/DE10_Pro.sof

.PHONY: program_fpga
program_all_fpgas:
	./py/progallde10pro.py output_files/DE10_Pro.sof

#-----------------------------------------------------------------------------
# build the software for the NIOS-V soft core
.PHONY: niosv_software
niosv_software:
	make -C software/app

#-----------------------------------------------------------------------------
# boot the niosv
.PHONE: boot_niosv
boot_niosv:
	niosv-download -g software/app/main.elf


#-----------------------------------------------------------------------------
# start a jtag terminal in a separate window
.PHONE: open_jtag_terminal
open_jtag_terminal:
	xterm -e juart-terminal &

#-----------------------------------------------------------------------------
# run a test
.PHONY: test
test:	program_fpga open_jtag_terminal boot_niosv

#-----------------------------------------------------------------------------
# clean up
clean:
	rm -rf output_files tmp-clearbox qdb synth_dumps
	quartus_ipgenerate --clear_ip_generation_dirs DE10_Pro.qpf
	make -C software/app clean
