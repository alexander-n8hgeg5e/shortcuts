argparse(){

    del1=0
    del2=0
    tmux_i=0
    tmux_ii=0
    tmux_session_name=0
    new_nvim=0

    while test $# -gt 0
    do
        case "$1" in
            del1)   del1=1

                ;;
            del2)   del2=1
                ;;
            -n)   new_nvim=1
                ;;
            -t)      [[ ${where_to_go} = "go_mirror"  ]] && tmux_ii=1
                     [[ ${where_to_go} = "go_prefix" ]] && tmux_i=1
                ;;
            -s*)      [[ "${1::2}" == "-s" ]]&&[[  -n "${1:2}" ]]&&tmux_session_name="${1:2}"
                ;;

    
        esac
        shift
    done

    typeset -g del1
    typeset -g del2
    typeset -g tmux_i
    typeset -g tmux_ii
    typeset -g tmux_session_name
    typeset -g new_nvim

}


message(){
    echo 
    echo    '##################################'
    echo -e "##  stage""${1}"" : ""${2}"
    echo    '##################################'
}
