#!/bin/fish
sudo git --git-dir=/.root.git add .
sudo git --git-dir=/.root.git commit $argv
