#!/bin/bash
if [[ -z "${1}" ]] ;then
    echo error: need host argument
    exit 1
fi
ssh -tt \
	-o ControlMaster=no \
	-o ControlPersist=no \
	-o ControlPath=None \
	-o ServerAliveInterval=1 \
	-o ServerAliveCountMax=1 \
    -L 127.0.0.1:7777:/tmp/vncsocket_"%r" "${1}" \
x11vnc -noipv6 -noipv4 -rfbport 0 -rfbauth \~/.vnc/passwd -display :0 -unixsock /tmp/vncsocket_'${USER}' -clear_all -nomodtweak -repeat
