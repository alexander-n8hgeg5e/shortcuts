#!/bin/bash

#xhost SI:localuser:firefox

RUNAS_USER=firefox
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


###############
## authorize ##
###############
if [[ -n "${XAUTHORITY}" ]];then
    auth_file_path="${XAUTHORITY}"
else
    auth_file_path="${HOME}/.Xauthority"
fi
[[ -e "${auth_file_path}" ]] || touch "${auth_file_path}"
runas_user_auth_file_path="/tmp/.Xauthority_${RUNAS_USER}_${DISPLAY}"
sudo cp "${auth_file_path}" "${runas_user_auth_file_path}"
sudo chown ":${RUNAS_USER}" "${runas_user_auth_file_path}"
sudo chmod g+r "${runas_user_auth_file_path}"

env_args="XAUTHORITY=${runas_user_auth_file_path}"

#####################
## setup cache dir ##
#####################
browser_cache_dir="/tmp/firefox/.cache"
browser_tmp_dir="/tmp/firefox"
if ! sudo stat -t "${browser_cache_dir}" > /dev/null ;then
    sudo mkdir -p "${browser_cache_dir}"
    sudo chown "${RUNAS_USER}:${RUNAS_USER}" "${browser_cache_dir}"
    sudo chown "${RUNAS_USER}:${RUNAS_USER}" "${browser_tmp_dir}"
fi

if [[ ${args["-vgl"]} -eq 1 ]] ; then
    cmd0="${cmd0} vglrun"
fi

cmd="${cmd0} env ${env_args} ${cmd1}"

echo "evaluating cmd: \"${cmd}\" ..."
eval "${cmd}"
