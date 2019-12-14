#!/bin/fish
git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME add .
git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME commit $argv
