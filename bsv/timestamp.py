#!/usr/bin/env python3
##############################################################################
# Copyright (c) 2023 Simon W. Moore
# All rights reserved.
# License: BSD-2-Clause
##############################################################################
# Hack: generate Bluespec library containing a timestamp as a 64b hex number
# with digits representing: YYYYMMDDHHMMSS
# i.e. (year, month, day, hours, minutes, seconds)
# Use: regenerate this library everytime a Bluespec system is rebuilt and
# include the 64b timestamp so that it is checkable at runtime

from datetime import date, time, datetime

current_date = datetime.now()

print("package TimeStamp;\n")
print("(* always_enabled *)")
print("interface TimeStamp;")
print("  method Bit#(64) datetime;")
print("endinterface\n")
print("(* synthesize *)")
print("module mkTimeStamp(TimeStamp ifc);")
print("  method datetime = 64'h",int(current_date.strftime("%Y%m%d%H%M%S")),";")
print("endmodule\n")
print("endpackage")

exit(0)
