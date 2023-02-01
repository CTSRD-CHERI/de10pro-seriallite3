#!/bin/bash

make || exit 1
date
pids=""
for cable in {1..8}
do
    nios2-download --cable $cable -r -g main.elf >/dev/null || exit 1
    echo "JTAG chain number: " $cable > swm_enable_berts_log.$cable
    ( echo '1' | nios2-terminal --cable $cable | grep 'BERT enable'  >> swm_enable_berts_log.$cable ) &
    pids="$pids $!"
done
wait $pids
for cable in {1..8}
do
    cat swm_enable_berts_log.$cable
    rm swm_enable_berts_log.$cable
done

