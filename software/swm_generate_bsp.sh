#!/bin/bash

nios2-bsp hal bsp ../soc/soc.sopcinfo

pushd app
nios2-app-generate-makefile --app-dir=./ --bsp-dir=../bsp --src-files=main.c --elf-name=main.elf
popd

