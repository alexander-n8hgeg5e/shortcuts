#!/bin/fish
set args $argv
test $args[1] = commit
    and set args $args[2..-1]
git add .
git commit $args
