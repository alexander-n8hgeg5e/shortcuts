#!/bin/fish
git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME checkout $argv[1]
and git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME submodule init
and git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME submodule sync --recursive
and git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME submodule foreach --recursive fish -c "git checkout $argv[1]"
