#!/bin/bash

if ! xdpyinfo >/dev/null 2>/dev/null
then
    echo "ERROR: X11 display not available to nios2-bsp will fail.  Fix and retry"
    exit
fi

nios2-bsp hal bsp ../soc/soc.sopcinfo

pushd app
nios2-app-generate-makefile --app-dir=./ --bsp-dir=../bsp --src-files=main.c --elf-name=main.elf
popd

