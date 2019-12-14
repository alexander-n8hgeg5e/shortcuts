#!/bin/fish
git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME status -s $argv
