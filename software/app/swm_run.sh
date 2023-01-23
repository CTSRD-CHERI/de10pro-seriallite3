#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 cable_number"
    exit 1
fi

make || exit 1

cable=$1
nios2-download --cable $cable -r -g main.elf || exit 1
nios2-terminal --cable $cable || exit 1

