#!/bin/fish
#xlock -mode blank -echokeys -echokey x -font 12x24 -planfont 12x24 -bg black

#hhpc check and kill
ps -C hhpc  -o comm|grep -q hhpc;set hhpc_was_running $status
if test $hhpc_was_running -eq 0; killall -s HUP hhpc; end

#synergy check and kill
ps -C synergy-core h -o comm |grep synergy-core -q;set was_running $status
ps -C synergy-core h -o cmd |grep -q '\-\-client';set is_client $status
ps -C synergy-core h -o cmd |grep -q '\-\-server';set is_server $status
if test $was_running -eq 0; killall -s HUP synergy-core;end

xtrlock

if test $was_running -eq 0

	if test $is_client -eq 0
		synergy_tmrl_esadc_client
	end

	if test $is_server -eq 0
		synergy_tmrl_esadc_server
	end

end
if test $hhpc_was_running -eq 0
	rind hhpc
end
exit 0
