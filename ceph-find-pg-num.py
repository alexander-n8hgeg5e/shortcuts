#!/usr/bin/env python3
from subprocess import check_output
from pprint import pprint

output = eval(check_output('ceph osd pool autoscale-status|tail -n+2|column  -H- -N name,size,f -t|tail -n+2 | column -J -N name,size,f',shell=True).decode())["table"]
m=[[float(x['f']),x['size']] for x in output]

for entry in m:
    while True:
        a = entry[1].find("G")
        if len(entry[1]) == a+1:
            entry[1] = float(entry[1][:a])
            break
        a = entry[1].find("M")
        if len(entry[1]) == a+1:
            entry[1] = float(entry[1][:a]) / 1024
            break
        a = entry[1].find("k")
        if len(entry[1]) == a+1:
            entry[1] = float(entry[1][:a]) / 1024 /1024
            break
        break

pprint(m)
total0=sum(i[0]*i[1] for i in m)
total1=sum(i[1] for i in m)
print(f'{total0:.0f}  , ',f'{total1:.0f}')
f=total0/total1
print(f)
num_osds=11
pg_num=100*num_osds/f
print("pg_num:",pg_num)
pg_num=384
s=0
from math import inf,sqrt
while True:
    if (pg_num - 2**(s+1)) **2 < (pg_num - 2**s    ) **2 :
        s+=1
    else:
        break
print(2**s)

