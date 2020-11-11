#!/bin/bash
[[ -z "${1}" ]] && a=default || a="${1}"
sudo cp --preserve=ownership  ~/.config/pulse/cookie /tmp/pulseaudio.cookie
sudo chmod g=r,o=              /tmp/pulseaudio.cookie
sudo chown :firefox            /tmp/pulseaudio.cookie
xhost SI:localuser:"${1}"
export PULSE_COOKIE="/tmp/pulseaudio.cookie"
echo rind sudo -iu firefox env PULSE_COOKIE=$PULSE_COOKIE env PULSE_SERVER=$PULSE_SERVER firefox -P "${1}"
rind sudo -iu firefox env PULSE_COOKIE=$PULSE_COOKIE env PULSE_SERVER=$PULSE_SERVER firefox -P "${1}"

