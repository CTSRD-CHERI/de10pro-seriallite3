#!/usr/bin/env python3

import sys

print("digraph stratix10 {")
for line in sys.stdin:
    print(line.split("DOT:")[1], end="")
        
print("}")


    
