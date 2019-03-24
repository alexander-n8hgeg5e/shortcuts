#!/bin/fish

function b -s 1 -s 2 -s 3 -s 15 
   echo done
   xset +dpms
   exit 0
end

xset dpms force on
xset -dpms

xclock &

set sleeptime 5

function movemouse
    while true; for i in (seq 103);xdotool mousemove_relative 10 0;sleep 5;end;for i in (seq 60);xdotool mousemove_relative 0 10;sleep 5;end;for i in (seq 103);xdotool mousemove_relative -- -10 0;sleep 5;end;for i in (seq 60);xdotool mousemove_relative -- 0 -10;sleep 5;end;end
end

movemouse &

while true
    for j in (seq -6 6)
        for i in (seq 0 +1 110) (seq 110 -1 0)
            xdotool search --class xclock  windowmove --sync (math "4 * $i" ) (math "$j * 5")
	        sleep $sleeptime
	end
	sleep $sleeptime
    end
    xset -dpms
end


