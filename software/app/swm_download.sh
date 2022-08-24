#!/bin/bash

make
nios2-download -r -g main.elf
nios2-terminal
