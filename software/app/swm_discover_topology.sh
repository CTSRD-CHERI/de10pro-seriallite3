#!/bin/bash

# ensure that the software is built
make || exit 1

# Download software to every board (assumes FPGAs are already programmed)
for cable in {1..8}
do
    nios2-download --cable $cable -r -g main.elf || exit 1
done

for cable in {1..7}
do
    echo 'd' | nios2-terminal --cable $cable > log.$cable &
done
# Use the last nios2-terminal to time everything
echo 'd' | nios2-terminal --cable 8 > log.8

grep "DOT:" log.? > topology.txt
cat topology.txt | ./topology2dot.py > topology.dot
cat topology.dot
cat topology.txt | ./topology2dot-jtagchain.py > topologyjtag.dot
dot -Tpdf -Glabel="Stratix 10 Topology (ChipIDs)" -Kcirco topology.dot -o topology.pdf
dot -Tpdf -Glabel="Stratix 10 Topology (JTAG chain numbers)" -Kcirco topologyjtag.dot -o topologyjtag.pdf
echo "Created topology.pdf and topologyjtag.pdf"





