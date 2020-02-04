#!/usr/bin/env python3
# coding: utf-8
import sys
from os.path import expanduser
#sys.path.append(expanduser("~/code/pylib/pylib/run_utils"))
from argparse import ArgumentParser
from os import cpu_count as get_cpu_count,get_terminal_size
from time import sleep
from random import randint
from subprocess import check_call,Popen,STDOUT,PIPE
from sys import exit,stderr

try:
   cpu_count=get_cpu_count()
except:
   cpu_count=1

a=ArgumentParser()

a.add_argument("-w1",'--wait-load-1m',action='store',type=float,default=cpu_count)
a.add_argument("-w2",'--wait-load-5m',action='store',type=float,default=None)
a.add_argument("-w3",'--wait-load-15m',action='store',type=float,default=None)
a.add_argument("-wl1",'--wait-loop-load-1m',default=None)
a.add_argument("-wl2",'--wait-loop-load-5m',default=None)
a.add_argument("-wl3",'--wait-loop-load-15m',default=cpu_count)
a.add_argument("-t",'--sleep-time',action='store',type=int, default=180)
a.add_argument("-v",'--verbose',action='store_true',default=True)
a.add_argument("-mio","--max-iowait-halt",action='store',type=float,default=None)
a.add_argument("-iop","--io-priority",action='store',type=str,default='c3')
a.add_argument("-u","--update-divider",action='store',type=int,default=10)
a.add_argument("-i","--control_interval",action='store',type=int,default=3)
a.add_argument("-n","--niceness",action='store',type=int,default=19)
a.add_argument("--stdout",action='store',type=str,default=None)
a.add_argument("--stderr",action='store',type=str,default=None)
a.add_argument(dest='cmd', type=str,nargs="?", help="cmd to run")
a.add_argument(dest='args',nargs="*", type=str,help="args passed to the cmd")
a.add_argument('-l','--loop',default=False,action="store_true")
a.add_argument('-D','--debug',default=False,action="store_true")
b=a.add_mutually_exclusive_group()
b.add_argument("--print-defaults",action="store_true")

args=a.parse_args()

if args.print_defaults:
    cols=get_terminal_size().columns
    from pylib.argparse_utils import get_default_args
    prl=[]
    maxw=0
    for line in get_default_args(a):
        tpl=(" ".join(line[0]), str(line[1]))
        maxw=max(maxw,len(tpl[0]))
        prl.append(tpl)
    colf0=str(maxw+2)+"."+str(maxw+2)
    colf1=str(min(cols-len(colf0),int(cols/2)))
    fstr="{:"+colf0+"} {:"+colf1+"."+colf1+"}"
    print(fstr)
    for l0,l1 in prl:
        print(fstr.format(l0,l1))
    exit(0)

if args.debug:
    args.verbose=True

def get_wait_avg():
    for i in ("1m","5m","15m"):
        load=getattr( args , "wait_"+("loop_" if args.loop else "")+"load_"+i)
        if not load is None:
            return float(load),i

def get_load(ltype):
        num={'1m':0,'5m':1,'15m':2}[ltype]
        with open('/proc/loadavg') as lf:
            l=lf.read()
        return float(l.split()[num].strip())

cmd=[args.cmd]+args.args

stdout,stderr=None,None
if not args.stdout is None:
    stdout=open(args.stdout,'wb')
if not args.stderr is None:
    stderr=open(args.stderr,'wb')

if args.verbose:
    print("cmd="+str(cmd),file=stderr)

if not args.max_iowait_halt is None:

    from pylib.run_utils.run import ConditionRunThrottler
    from pylib.stat_utils import gen_max_iowait_checker
    cr=ConditionRunThrottler(   cmd,
                                [gen_max_iowait_checker(args.max_iowait_halt,debug=args.debug,verbose=args.verbose)],
                                ioprio=args.io_priority,
                                niceness=args.niceness,
                                popenkwargs={'stdout':stdout,'stderr':stderr},
                                control_interval=args.control_interval,
                                debug=args.debug,verbose=args.verbose,
                                update_divider=args.update_divider
                            )
    def run_cmd():
        global cr
        cr.run()
    def stop_cmd():
        global cr
        cr.__del__()

else:
    cmd_=['nice',"-n"+str(args.niceness),'ionice', '-'+args.io_priority ] + cmd
    print(cmd_,file=stderr)
    def run_cmd():
        check_call( cmd_ )
    def stop_cmd():
        pass

done=[]
while True:
    wait_load,ltype=get_wait_avg()
    lavg=get_load(ltype)
    if lavg <= wait_load:
        try:
            if args.debug:
                print("running cmd:"+str(cmd),file=stderr)
            run_cmd()
            if not args.loop:
                break
        except KeyboardInterrupt:
            exit()
        except Exception as e:
            print("cmd failed",file=stderr)
            raise
            continue
        finally:
            stop_cmd()

    else:
        if args.verbose:
            print("waiting for loadavg "+ltype+"="+str(wait_load)+" to run cmd: "+str(cmd),file=stderr)
    sleep_time=int(args.sleep_time*randint(1,1000)/1000)
    if args.verbose:
        print("sleep time = "+str(sleep_time)+"[s]",file=stderr)
    sleep(sleep_time)
