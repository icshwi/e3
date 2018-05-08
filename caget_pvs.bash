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
# Date    : Saturday, April 21 21:56:44 CEST 2018
# version : 0.1.0



if [ -z "$1" ]; then
     printf "\n";
     printf "usage: %16s \"pv list file\"\n\n" "$0"

     exit 1;
fi

declare -a pvlist=();
declare cmd="caget"

function print_ca_addr
{
    printf ">> Print ... \n"
    echo "EPICS_CA_ADDR_LIST      : $EPICS_CA_ADDR_LIST"
    echo "EPICS_CA_AUTO_ADDR_LIST : $EPICS_CA_AUTO_ADDR_LIST"
}


function unset_ca_addr
{
    printf ">> Unset ... EPICS_CA_ADDR_LIST and EPICS_CA_AUTO_ADDR_LIST\n"
    unset EPICS_CA_ADDR_LIST
    unset EPICS_CA_AUTO_ADDR_LIST
}

function set_ca_addr
{
    printf "Set ... EPICS_CA_ADDR_LIST and EPICS_CA_AUTO_ADDR_LIST \n";
    export EPICS_CA_ADDR_LIST="$1"
    export EPICS_CA_AUTO_ADDR_LIST="$2";
    print_ca_addr
}



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


_HOST_IP="$(ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n')";


unset_ca_addr

set_ca_addr "$_HOST_IP" "YES"

pvs_from_list $1

substring=$2

printf ">> Get PVs .... \n"
printf "\n";
printf "\n";

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




