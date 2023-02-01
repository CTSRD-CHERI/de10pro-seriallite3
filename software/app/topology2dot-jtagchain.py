#!/usr/bin/env python3

# Outputs a dot format graph based on JTAG chain numbers rather than ChipIDs

import sys

print("digraph stratix10 {")
chipid2chain = {}
arcs = []
for line in sys.stdin:
    parts = line.split(":DOT:")
    chain = int(parts[0].split(".")[1])
    link = parts[1].replace(" ","")
    link = link.replace(";","")
    link = link.replace("\n","")
    label = link.split("[")
    path = label[0].split("->")
    path.append(label[1])
    arcs.append(path)
    chipid2chain[path[1]] = chain

for path in arcs:
    print("%d -> %d [%s;" % (chipid2chain[path[0]], chipid2chain[path[1]], path[2]))
        
print("}")


    
