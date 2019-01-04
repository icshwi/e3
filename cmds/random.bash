#!/bin/bash

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="${SC_SCRIPT%/*}"

#  
#system "tr -cd 0-9 </dev/urandom | head -c 8 > $(TOP)/random_tmp"
#system "C=`cat $(TOP)/random_tmp` && /bin/sed -e "s:_random_:$C:g" < $(TOP)/random.in > $(TOP)/random.cmd"


C=$(tr -cd 0-9 </dev/urandom | head -c 8)
sed -e "s:_random_:$C:g" < ${SC_TOP}/random.in > ${SC_TOP}/random.cmd

