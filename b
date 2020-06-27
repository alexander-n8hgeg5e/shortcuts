#!/bin/bash
[[ -z "${1}" ]] && a=default || a="${1}"
rind saau firefox firefox -P "${a}"

