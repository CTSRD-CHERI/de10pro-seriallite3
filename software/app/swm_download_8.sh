#!/bin/bash

make || exit 1
for cable in {1..8}
do
    nios2-download --cable $cable -r -g main.elf || exit 1
done



