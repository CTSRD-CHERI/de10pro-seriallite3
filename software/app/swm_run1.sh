#!/bin/bash

make || exit 1
nios2-download --cable 1 -r -g main.elf || exit 1
nios2-terminal --cable 1 || exit 1

