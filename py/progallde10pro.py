#!/usr/bin/env python3

import subprocess as sp
import sys, os, time
import re, argparse

def find_de10pro_devices():
    devices = {}
    dev = None
    jtagchain = []
    try:
        proc = sp.run(["jtagconfig"], stdout=sp.PIPE, stderr=sys.stderr, timeout=5, check=True)
    except:
        return {}
    proc_stdout = proc.stdout.decode()
    for line in proc_stdout.split('\n'):
        if(dev==None):
            d = re.match("^(\d+)[\)]\WDE10-Pro\W(\S+)", line)
            if(d != None):
                dev = "DE10-Pro "+d.group(2)
        else:
            jtag = re.match("^\W+(\S+)\W+([\w\(\)\/\.\|]+)", line)
            if(jtag==None):  # end of jtag chain
                devices[dev] = jtagchain
                dev = None
                jtagchain = []
            else:
                jtagchain.append(jtag.groups())
    return devices

def spawn_quartus_pgm(devices,sof):
    process_list = []
    no_license_env = os.environ.copy()
    no_license_env['LM_LICENSE_FILE']=''
    for d in devices.keys():
        print("usb-to-jtag=", d, " jtag =", devices[d])
        id = 0
        j=0
        for chain in devices[d]:
            j=j+1
            if(re.match("1SX280HH1",chain[1])):
                id=j
        cmd = ['quartus_pgm', '-m', 'jtag', '-c', d, '-o', 'p;%s@%d'%(sof,id)]
        print(' '.join(cmd))
        process_list.append(sp.Popen(cmd, stdout=sp.PIPE, stderr=sys.stderr, env=no_license_env))
    return process_list

def report_process_status(devices, process_list):
    for d in devices.keys():
        proc = process_list.pop(0)
        try:
            proc.wait(timeout=30)
        except:
            print("%s: ERROR: Process programming timed out"%(d))
            proc.kill()
        else:
            report=[]
            so = proc.communicate()[0].decode()
            for l in so.split('\n'):
                if(   re.match("Info: Quartus Prime Programmer was", l)
                   or re.match("\W+Info: Elapsed time", l)
                   or re.match("\W+Error", l)):
                    report.append(d+": "+l)
            print('\n'.join(report))

def main():
    parser = argparse.ArgumentParser(prog='progallde10pro.py',
                                     description='Program all DE10Pro FPGA boards')
    parser.add_argument('-n', '--numfpga', type=int, action='store', default=8, help='number of FPGAs in the system (default: 8)')
    parser.add_argument('sof', type=str, action='store', help='SOF file to program the FPGA')
    args = parser.parse_args()
    num_to_program = args.numfpga
    sof = args.sof
    if(not(os.path.exists(sof))):
        print("SOF file %s does not exist"%(sof))
        return(1)
    devices = []
    timeout = 4
    while((len(devices)!=num_to_program) and (timeout>0)):
        devices = find_de10pro_devices()
        timeout = timeout-1
    if(timeout==0):
        print("Found %d FPGAs but you asked to program %d. Exiting."%(len(devices),num_to_program))
        return(1)
    process_list = spawn_quartus_pgm(devices,sof)
    report_process_status(devices, process_list)

    
if __name__ == '__main__':
    start = time.time()
    status = main()
    end = time.time()
    print("Real time: %2.3fs"%(end-start))
    sys.exit(status)
