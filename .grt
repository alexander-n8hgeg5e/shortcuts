#!/bin/fish
#'2f '-> u
#5c '-> 2f '
#u' -> 5c '

git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME log --simplify-by-decoration --decorate --oneline --all --graph --color=always |tac |xxd -g1 |cut -d' ' -f 2-17|tr  \n ' ' |sed -E 's/20 /z/g '|sed -E ' s/z(1b 5b 33 33 6d [^z]{21})/x\1/g '|sed -E ' s/0a /y/g '|sed -E ' s/(y[^x]*)(2f )/\1u/g '|sed -E ' s/(y[^x]*)(5c )/\12f /g '|sed -E ' s/u/5c /g '|sed -E ' s/y/0a /g '|sed -E ' s/x/20 /g '|sed -E ' s/z/20 /g '|xxd -r -p|sed -E ' s/x//g '
