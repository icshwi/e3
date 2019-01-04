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
# Date    : Friday, January  4 15:00:11 CET 2019
# version : 1.0.0

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -a pvlist=();

function usage
{
    {
	echo "";
	echo "Usage    : $0 -l pvlist_file [-f <filter_string>] [-w <watch_interval_sec>]"
	echo "";
	echo "               -l : mandatory"
	echo "               -f : default select all"
	echo "               -w : default no watch interval"
	echo "";
	echo " bash $0 -l pvlist_file"
	echo " bash $0 -l pvlist_file -f \"RB\" "
	echo " bash $0 -l pvlist_file -w 5 "
	echo ""
	
    } 1>&2;
    exit 1; 
}


function print_ca_addr
{
    local msg="$1"
    printf ">> %s : EPICS CA ADDR Info ... \n" "$msg"
    echo "   EPICS_CA_ADDR_LIST      : $EPICS_CA_ADDR_LIST"
    echo "   EPICS_CA_AUTO_ADDR_LIST : $EPICS_CA_AUTO_ADDR_LIST"
}


function unset_ca_addr
{
#    printf ">> Unset ... EPICS CA ADDR Info\n"
    unset EPICS_CA_ADDR_LIST
    unset EPICS_CA_AUTO_ADDR_LIST
}

function set_ca_addr
{
#    printf ">> Set   ... EPICS CA ADDR Info \n";
    export EPICS_CA_ADDR_LIST="$1"
    export EPICS_CA_AUTO_ADDR_LIST="$2";
 }


function reset_ca_addr
{
    printf ">> Reset EPICS CA ADDR ..... \n";
    print_ca_addr "Before Reset"
    _HOST_IP="$(ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n')";
    unset_ca_addr 
    set_ca_addr "$_HOST_IP" "YES"
    print_ca_addr "After  Reset"
}


function pvs_from_list
{
    local i=0;
    local j=0;
    local pv;
    local filename="$1"
    local filter="$2"
    local raw_pvlist=();
    local temp_pvlist=();
    let i=0
    while IFS= read -r line_data; do
	if [ "$line_data" ]; then
	    [[ "$line_data" =~ ^#.*$ ]] && continue
	    raw_pvlist[i]="${line_data}"
	    ((++i))
	fi
    done < "${filename}"

    # https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
    IFS=$'\n' read -d '' -r -a temp_pvlist < <(printf '%s\n' "${raw_pvlist[@]}" | sort)

    if [ -z "$filter" ]; then
	let i=0;
	for pv in ${temp_pvlist[@]}; do
	    pvlist[i]="$pv"
	    ((++i))
	done
    else
	let j=0
	for pv in ${temp_pvlist[@]}; do
	    if test "${pv#*$filter}" != "$pv"; then
		pvlist[j]="$pv"
		((++j))
	    fi
	done
    fi
    
}

function caget_list
{
    local pv;
    printf "\n>> Selected PV and its value\n"
    for pv in ${pvlist[@]}; do
	caget $pv
    done
    printf "\n";
}


options=":l:f:w:c"
RESETCA="NO"

while getopts "${options}" opt; do
    case "${opt}" in
        l) LIST=${OPTARG}    ;;
	f) FILTER=${OPTARG}  ;;
      	w) WATCH=${OPTARG}   ;;
	c) RESETCA="YES" ;;
   	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    usage
	    ;;
	h)
	    usage
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    usage
	    ;;
    esac
done
shift $((OPTIND-1))


if [ -z "$LIST" ]; then
    usage;
fi

if [ "$RESETCA" == "YES" ]; then
    reset_ca_addr;
fi

pvs_from_list "${LIST}" "${FILTER}"

if [ -z "$WATCH" ]; then
    caget_list
else
    # This is the fake watch
    offset=0.1
    interval=$(echo "${WATCH}-${offset}" | bc)
    while true; do
	LOG_DATE=$(date)
	CAGET_LIST=$(caget_list)
	clear;
	printf "Fake watch with the sleep interval %s (The offset %s is introduced). \n" "${interval}" "${offset}"
	printf "%s\n" "$LOG_DATE";
	printf "$CAGET_LIST";
	sleep ${interval}
    done;
    
fi
