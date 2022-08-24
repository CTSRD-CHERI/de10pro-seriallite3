#!/bin/bash

make

for((j=1; j<9; j++)); do
(nios2-download -c $j -r -g main.elf;nios2-terminal -c $j > log.$j) &
done
