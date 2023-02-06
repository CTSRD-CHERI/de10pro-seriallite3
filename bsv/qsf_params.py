#!/usr/bin/env python3
##############################################################################
# Copyright (c) 2023 Simon W. Moore
# All rights reserved.
# License: BSD-2-Clause
##############################################################################
# Hack: generate Bluespec functions with project build parameters of interest
# from the QSF file

qsf = "../DE10_Pro.original_qsf"
param = ("pma_tx_buf_pre_emp_switching_ctrl_pre_tap_1t",
         "pma_tx_buf_pre_emp_switching_ctrl_1st_post_tap")

def find_in_qsf(qsf_file,param):
    with open(qsf_file, 'r') as fin:
        lines = fin.readlines()
        for l in lines:
            if(param in l):
                parts=l.split('"')
                for p in parts:
                    if(param in p):
                        a=p.split('=')
                        return a[1]
        return ""

for p in param:
    print("function Bit#(32) %s() = %s;" % (p,find_in_qsf(qsf,p)))
    
exit(0)

