#!/bin/bash

date
pids=""
for cable in {1..8}
do
    echo "JTAG chain number: " $cable > swm_enable_berts_log.$cable
    ( echo '0' | ./swm_run.sh $cable | grep 'BERT enable'  >> swm_enable_berts_log.$cable ) &
    pids="$pids $!"
done
wait $pids
for cable in {1..8}
do
    cat swm_enable_berts_log.$cable
    rm swm_enable_berts_log.$cable
done

