#!/bin/bash

make || exit 1
nios2-download -r -g main.elf || exit 1
nios2-terminal || exit 1

