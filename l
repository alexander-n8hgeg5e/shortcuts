#!/bin/fish
# init
set -g screen_on_file '/tmp/screen_on'

set -g lock_cmd xtrlock 
#xset lock_cmd xlock -mode blank -echokeys -echokey x -font 12x24 -planfont 12x24 -bg black

set -g displays "$DISPLAY"

set -g display_var_backup $DISPLAY

if test "$hostnamE" = esadc
    sudo rc-service -q skyscraper status
    if test $status -eq 0
        set displays ":0" "skyscraper:0"
    end
    if not contains ':0' $displays
        set displays ":0" $displays
    end
end
# init end

function is_hhpc_running
    ps -C hhpc  -o comm | grep -q hhpc 
end

function hhpc_stop
    #hhpc check and kill
    is_hhpc_running ; set -g hhpc_status_backup $status
    set pids ( ps -C hhpc  -o pid --no-headers | head -n1 )
    if test $hhpc_status_backup -eq 0
        for pid in $pids
            kill -sINT $pid
        end
        sleep 0.001
        for pid in $pids
            kill -sTERM $pid
        end
        sleep 0.001
        for pid in $pids
            kill -sKILL $pid
        end
    end
end

function hhpc_restore_on_display -a display
    set -x DISPLAY $display
	rind hhpc
    set -x DISPLAY $display_var_backup
end

function hhpc_restore
    if test $hhpc_status_backup -eq 0
        for i in $displays
            hhpc_restore_on_display $i
        end
    end
end
        

function screen_on_stop
    set -q screen_on_status_backup ; and return 46
    test -f $screen_on_file ;and set -g screen_on_status_backup 0;or set -g screen_on_status_backup 1
    test $screen_on_status_backup -eq 0; and rm $screen_on_file
    # need to immediately enable dpms to proceed
    for i in $displays
        set -x DISPLAY $i
        xset +dpms
    end
    set -x DISPLAY $display_var_backup
end
function screen_on_restore
    set -q screen_on_status_backup;or return 57
    echo
    echo restoreing screen on,...
    if test $screen_on_status_backup -eq 0
        echo "    " touching $screen_on_file
        touch $screen_on_file
    else
        echo status was off, no file need to be restored
        echo
    end
    set -e screen_on_status_backup
end

function synergy_stop
    # unconditionally kill synergy-core, because is wrong version
    set out ( ps -e -o pid,cmd --no-headers | grep -E '^[ ]*[1-9][0-9]*[ ]+synergy[-]core)[ ]')
    set pids (for i in $out ; echo $i | grep -Eo "^[ ]*[0-9]+" ; end)
    for p in $pids
        warn "running synergy-core "'(=synergy-2.*)'" processes detected"
        kill $p
        kill -s9 $p
    end

    # get synergys to restore
    set out (ps -e -o pid,cmd --no-headers | grep -E '^[ ]*[1-9][0-9]*[ ]+synergy[sc][ ]'|grep -vF '<defunct>')
    #for i in $out
    #echo $i
    #end
    # ps -o cmd -> full cmdline
    # ps -o comm -> only cmds bin name without path
    
    # get state of running servers
    set server_out (for i in $out ; echo $i | grep synergys ; end)
    set -g synergys_cmds_status_backup (for i in $server_out ; echo $i | sed -r 's/^[ ]*[0-9]+[ ]*//' ; end)

    # get state of running clients
    set client_out (for i in $out ; echo $i | grep synergyc ;end)
    set -g synergyc_cmds_status_backup (for i in $client_out ; echo $i | sed -r 's/^[ ]*[0-9]+[ ]*//' ; end)
    
    set pids_to_stop (for i in $out ; echo $i | sed -E 's/^[ ]*([1-9][0-9]*).*$/\1/' ; end)
    #stop em 
    for pid in $pids_to_stop
        kill $pid
    end
end

function get_display_md5sum_of_cmd -a cmd
        set display (string trim -c' ' (echo $cmd|grep -Eo ' \-\-display\s+\S*'|sed -E 's/--display\s+(\S*)/\1/'))
        set display_md5sum (string match -r '^\w+' (echo $display | md5sum))
        echo $display_md5sum
end

function has_started_already -a name -a key
   set storevarname "$name"_started_already
   if not contains "$key" $$storevarname
       set -g $storevarname $$storevarname $key
       return 1
    end
end

function warn
    echo
    echo "WARNING $argv[1]"
    for i in (seq 2 (count $argv))
        echo $argv[$i]
    end
    echo
end

function restore_cmd -a name

    echo 
    echo $name restore ...
    
    set varname "$name"_cmds_status_backup

    set cmd_base sudo nice -n-20 ionice -c1 -n3 chrt -rr 30 sudo -u "$USER"
    
    for c in $$varname
        set cmd $cmd_base $c
        set display_md5sum (get_display_md5sum_of_cmd $cmd)
        if not has_started_already $name $display_md5sum
            echo running cmd $cmd
            eval rind $cmd
            echo
        else
            set storevarname "$name"_started_already
            warn "$name"" already started on same display" "key: ""$display_md5sum" "already: ""$$storevarname"
        end
    end
end
    
function synergy_restore
    restore_cmd synergys 
    restore_cmd synergyc
end

function screen_off
    screen_on_stop
    for i in $displays
        set -x DISPLAY $i
        xset +dpms
        xset dpms force off
    end
    set -x DISPLAY $display_var_backup
end

function screen_on
    screen_on_restore
    for i in $displays
        set -x DISPLAY $i
        xset dpms force on
        xset -dpms
    end
    set -x DISPLAY $display_var_backup
end

function lock
    echo
    echo cleanup by useing unlock function...
    unlock
    echo
    echo locking screen now... $displays
    for i in (seq (count $displays) -1 1)
        set -x DISPLAY $displays[$i]
        set lock_cmd_bg "$lock_cmd""&"
        eval $lock_cmd_bg
    end
    set -x DISPLAY $display_var_backup
    wait --any
end

function unlock
    echo
    echo unlocking ...
    set pids ( ps -e -o pid,comm|grep -F "$lock_cmd" | sed -r 's/^\s*([1-9]+[0-9]*).*$/\1/' )
    for p in $pids
        kill $p 2>/dev/null
    end
    sleep 0.05
    for p in $pids
        sudo kill -s9 $p 2>/dev/null
    end
end

function stop_conflicting_things_and_save_state
    hhpc_stop
    synergy_stop
    screen_on_stop
end

#function restore_state --on-signal HUP
function restore_state
    echo
    echo restoring state ...
    hhpc_restore
    synergy_restore
    screen_on_restore
end

# main part
stop_conflicting_things_and_save_state
screen_off
lock
unlock
screen_on
restore_state
exit
