#!/bin/bash
#
#  Copyright (c) 2017 - Present European Spallation Source ERIC
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
#
#   author  : Jeong Han Lee
#   email   : jeonghan.lee@gmail.com
#   date    : Thursday, October 19 17:25:33 CEST 2017
#   version : 0.0.2


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"


declare -g  env="e3-env"
declare -ga require_list=("e3-base" "e3-require")
declare -ga module_list=()


function help
{
    echo "">&2
    echo " Usage: $0 <arg>  ">&2 
    echo ""
    echo "          <arg>   : info">&2 
    echo ""
    echo "           base    : Setup and Build Base and Require">&2
    echo "           modules : Setup and Build all modules">&2
    echo "           env     : Print all modules list">&2
    echo "">&2
    echo "">&2 	
}

function git_clone
{

    local rep_name=$1
    ${GIT_CMD} ${GIT_URL}/$rep_name
    
}


function get_module_list
{
    local i;
    let i=0
    while IFS= read -r line_data; do
	if [ "$line_data" ]; then
	    # Skip command #
	    [[ "$line_data" =~ ^#.*$ ]] && continue
	    entry[i]="${line_data}"
	    ((++i))
	fi
    done < $1
    echo ${entry[@]}
}



function setup_base_require
{

    for rep in  ${require_list[@]}; do
	git_clone ${rep}
	pushd ${rep}
	make init
	make env
	if [ "${rep}" = "e3-base" ]; then
	    make pkgs
	fi
	popd
    done
}

function build_base_require
{

    sudo -v
    
    
    for rep in  ${require_list[@]}; do
	pushd ${rep}
	make build
	if [ "${rep}" = "e3-require" ]; then
	    make install
	fi
	popd
    done
}


#
# Mandatory step in order to compile modules
# Since we have the global env variables,
# it should be OK to use them
#
  
function setup_env
{
    git_clone ${env}
    pushd ${env}
    source setE3Env.bash
    popd

}



function print_list
{
    local array=$1
    for a_list in ${array[@]}; do
	printf " %s\n" "$a_list";
    done
}

function setup_modules
{
    for rep in  ${module_list[@]}; do
	git_clone ${rep}
	pushd ${rep}
	make init
	make env
	popd
    done

}

function build_modules
{

    for rep in  ${module_list[@]}; do
	pushd ${rep}
	make build
	make install
	popd
    done
}


module_list=$(get_module_list ${SC_TOP}/configure/MODULES)


#module_list+="e3-iocStats";
#module_list+=" " ; module_list+="e3-devlib2";
#module_list+=" " ; module_list+="e3-mrfioc2";


case "$1" in
    all)
	setup_base_require
	build_base_require
	setup_env
	setup_modules
	build_modules
	;;
    base)
    	setup_base_require
	build_base_require
	;;
    modules)
	setup_env
	setup_modules
	build_modules
	;;
    env)
	print_list "${module_list[@]}"
	;;
    *)
	help
	;;
esac

exit 0;





