#!/bin/bash
#
#  Copyright (c) 2016 - Present Jeong Han Lee
#  Copyright (c) 2016 - Present European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author  : Jeong Han Lee
# email   : han.lee@esss.se
# Date    : Friday, October 20 09:39:11 CEST 2017
# version : 0.0.2



if [ -z "$1" ]; then
     printf "\n";
     printf "usage: %16s \"pv list file\"\n\n" "$0"

     exit 1;
fi

declare -a pvlist=();
declare cmd="caget"

function pvs_from_list()
{
    local i
    let i=0
    while IFS= read -r line_data; do
	if [ "$line_data" ]; then
	    [[ "$line_data" =~ ^#.*$ ]] && continue
	    pvlist[i]="${line_data}"
	    ((++i))
	fi
    done < $1
}


export _HOST_IP="$(ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n')";
export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_ADDR_LIST=${_HOST_IP}

pvs_from_list $1


substring=$2

if [ -z "$substring" ]; then

    for pv in ${pvlist[@]}; do
	$cmd $pv
    done

else
    for pv in ${pvlist[@]}; do
	if test "${pv#*$substring}" != "$pv"; then
	    $cmd $pv
	fi
    done
fi




