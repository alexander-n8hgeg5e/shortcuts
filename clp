#!/usr/bin/python3
from sys import stdin as si
from sys import argv
from os import linesep as lsep
from subprocess import Popen,PIPE,check_output
outp=check_output(['pass',argv[1]]).split(lsep.encode())
if len(argv) > 1:
    outp=outp[int(argv[2])]
elif len(argv) > 2:
    outp=outp[int(argv[3]):]
elif len(argv) > 3:
    outp=outp[int(argv[3]):int(argv[4])]
print(outp)
p=Popen(['clipster','-c'],stdin=PIPE)
p.communicate(input=outp,timeout=5)
p.wait()
