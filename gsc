#!/bin/fish
git checkout $argv[1]
and git submodule init
and git submodule sync --recursive
and git submodule foreach --recursive fish -c "git checkout $argv[1]"
