#!/usr/bin/env python3

import sys

print("digraph stratix10 {")
print('graph [fontname = "Arial", fontsize="14pt"]')
print('node [fontname = "Arial", fontsize="14pt"]')
print('edge [fontname = "Arial", fontsize="10pt", arrowsize=0.5]')

for line in sys.stdin:
    print(line.split("DOT:")[1], end="")
        
print("}")


    
