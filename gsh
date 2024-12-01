#!/bin/sh
# git sign head
git commit -S"$(cat ~/.git_gpg_sign_key)" -C HEAD --amend
