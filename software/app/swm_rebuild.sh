#!/bin/bash

# LM_LICENSE_FILE=;time quartus_pgm -m jtag -o "p;../../output_files/DE10_Pro.sof@1" || exit 1
pushd ../
./swm_generate_bsp.sh || exit 1
popd
make clean_all || exit 1
make -j || exit 1
