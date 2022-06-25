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
bash -c \''
stty isig intr ^C ; trap "/bin/true" SIGINT
x0vncserver -useipv4=0 -useipv6=0 -rfbunixpath=/tmp/vncsocket_"${USER}" -passwordfile ~/.vnc/passwd -display :0
'\'
