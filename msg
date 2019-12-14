#!/bin/bash
while true; do
	sleep 10
    loadavg=$(cat /proc/loadavg|cut -d' ' -f1)
    while [[ $(echo "${loadavg} < 3 "| bc -l ) -eq 1 ]];do
        loadavg=$(cat /proc/loadavg|cut -d' ' -f1)
        for i in {1..10000};do
            c=( $i + 1 )
        done
    done
done
