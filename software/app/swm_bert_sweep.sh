#!/usr/bin/bash

FPGA_IMAGES="../../output_files/explore_taps*.sof"
for f in $FPGA_IMAGES
do
    log_file="${f/sof/log}"
    log_file="${log_file/..\/..\/output_files\//}"
    echo "Downloading $f and logging tests to $log_file"
    ../../py/progallde10pro.py $f > $log_file
    echo "Running FPGA image $f" >> $log_file
    date >> $log_file
    ./swm_enable_berts_8.sh >> $log_file
    ./swm_zero_berts_8.sh >> $log_file
    date >> $log_file
    ./swm_bert_8.sh >> $log_file
    sleep 3600
    date >> $log_file
    ./swm_bert_8.sh >> $log_file
done

