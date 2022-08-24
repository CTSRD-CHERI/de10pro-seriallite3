#!/bin/bash

pushd ../;./swm_generate_bsp.sh;popd
make clean_all
make
