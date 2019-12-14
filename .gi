#!/bin/fish
for i in (.g|grep ' m '|cut -d' ' -f3)
      fish -iC "cd $i"
end
