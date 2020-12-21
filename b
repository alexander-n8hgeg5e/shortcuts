#!/bin/bash

xhost SI:localuser:firefox


declare -A args

args["-vgl"]=0
args["-h"]=0


#echo "${!args[@]}"

# gen usage help
args_string=""
for thing in "${!args[@]}" ; do
    args_string="$args_string [${thing}]"
done
usage_help="usage:
${args_string[@]} [PROFILE_NAME | PROFILE_NAME followed by more args ]"

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
#echo "${args[@]}"

if [[ "${args["-h"]}" -eq 1 ]] ; then
    echo $usage_help
    exit
fi

# extract positional args "profile" followed by "other args"
#echo "all args=$@"
#echo "last=$last"
read -a pargs -r <<< "${@}"
read -a pargs -r <<< "${pargs[@]:$last}"
lpargs="${#pargs[@]}"
#echo "pargs = ${pargs[@]}"
#echo len pargs = $lpargs

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



cmd0="rind sudo -iu firefox"
cmd1="firefox -P ${profile} ${more_args}"


if [[ ${args["-vgl"]} -eq 1 ]] ; then
    cmd="${cmd0} vglrun ${cmd1}"
else
    cmd="${cmd0} ${cmd1}"
fi

echo "${cmd}"
eval "${cmd}"
