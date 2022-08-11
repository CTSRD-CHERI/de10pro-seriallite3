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
generate_ip: $(IP_SRC)
	quartus_ipgenerate --generate_project_ip_files -synthesis=verilog DE10_Pro.qpf --clear_ip_generation_dirs

#-----------------------------------------------------------------------------
# program the FPGA
.PHONY: program_fpga
program_fpga:
	./py/flashDE10 output_files/DE10_Pro.sof


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
