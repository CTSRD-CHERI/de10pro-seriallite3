#!/bin/bash

LM_LICENSE_FILE=;time quartus_pgm -m jtag -o "p;../../output_files/DE10_Pro.sof@1"
pushd ../;./swm_generate_bsp.sh;popd
make clean_all
make
