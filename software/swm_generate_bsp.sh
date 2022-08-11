#!/bin/bash

pushd bsp
niosv-bsp -g settings.bsp
popd

pushd app
niosv-app --dir=./ --bsp-dir=../bsp --srcs=main.c --elf-name=main.elf
popd

