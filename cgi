#!/bin/fish
for i in (rg|grep ' m '|cut -d' ' -f3)
      fish -iC "cd $i"
end
