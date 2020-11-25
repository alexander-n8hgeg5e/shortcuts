#!/bin/bash

sudo cp --preserve=ownership  ~/.config/pulse/cookie /tmp/pulseaudio.cookie
sudo chmod g=r,o=              /tmp/pulseaudio.cookie
sudo chown :firefox            /tmp/pulseaudio.cookie
xhost SI:localuser:firefox
export PULSE_COOKIE="/tmp/pulseaudio.cookie"

# args look like this:
# -axy -b -cxyz profile_name followed by more args ...


declare -A args

args["-vgl"]=0
args["-h"]=0


echo "${!args[@]}"

last=0
count=0

for i in "${@}"; do
    count=$(( $count + 1 ))
    for arg in "${!args[@]}"; do
        if [[ "${i}" = "${arg}" ]];then
            args[$arg]=1
            last=$count
        fi
    done
done
echo "${args[@]}"

# extract positional args "profile" followed by "other args"
echo "all args=$@"
echo "last=$last"
read -a pargs -r <<< "${@}"
read -a pargs -r <<< "${pargs[@]:$last}"
lpargs="${#pargs[@]}"
echo "pargs = ${pargs[@]}"
echo len pargs = $lpargs

if [[ $lpargs -gt 0 ]];then
    profile="${pargs[0]}"
else
    profile="default"
fi

if [[ $lpargs -gt 1 ]];then
    more_args="${pargs[@]:1}"
else
    more_args=""
fi



cmd0="rind sudo -iu firefox env PULSE_COOKIE=$PULSE_COOKIE env PULSE_SERVER=$PULSE_SERVER"
cmd1="firefox -P ${profile} ${more_args}"


if [[ $vglrun -eq 1 ]] ; then
    cmd="${cmd0} vglrun ${cmd1}"
else
    cmd="${cmd0} ${cmd1}"
fi

echo "${cmd}"
#eval "${cmd}"
