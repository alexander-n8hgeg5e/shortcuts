#!/bin/fish
head -n(math $LINES - 2) |cut -c-$COLUMNS
