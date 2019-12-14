#!/bin/fish
#function parse_screen_layout
#    set -q screen_layout; or exit 3
#    set server_parts (string split '##' "$screen_layout")
#    set count_server_parts (count $server_parts)
#    test (math $count_server_parts % 2 ) -eq 0; or exit 6
#    set count_servers (math $count_server_parts / 2)
#    for i in (seq 1 (math "$count_servers"))
#        set from ( math "$i * 2 - 1" )
#        set to ( math "$i * 2" )
#        set servers $servers "$server_parts["$from".."$to"]"
#    end
#    for i in $servers
#        echo $i
#    end
#end
