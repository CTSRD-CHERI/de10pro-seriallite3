#!/bin/bash

make || exit 1
for cable in {1..8}
do
    nios2-download --cable $cable -r -g main.elf >/dev/null || exit 1
done

pids=""
log=swm_bert_8_log
for cable in {1..8}
do
    echo "JTAG chain number: " $cable > $log.$cable
    ( echo 'b' | nios2-terminal --cable $cable | grep 'BERT - Channel' >> $log.$cable ) &
    pids="$pids $!"
done

wait $pids
for cable in {1..8}
do
    cat $log.$cable
    rm $log.$cable
done


