#!/bin/bash

declare -ga require_list=("e3-base" "e3-require")


function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }




GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"
BOOL_GIT_CLONE="TRUE"

declare -ga require_list=("e3-base" "e3-require")

declare -ga module_list=()

declare -g  env="e3-env"



function git_clone
{

    local rep_name=$1 ; shift;
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

function print_list
{
    local array=$1; shift;
    for a_list in ${array[@]}; do
	printf " %s\n" "$a_list";
    done
}

function setup_base_require
{
    local git_status=$1; shift;
    for rep in  ${require_list[@]}; do
	if [ "${BOOL_GIT_CLONE}" = "$git_status" ]; then
	    git_clone ${rep}
	fi
	pushd ${rep}
	make init || die 1 "Init ERROR : Please check your ${rep}"  ;
	make env
	if [ "${rep}" = "e3-base" ]; then
	    make pkgs || die 2 "PKGS ERROR : Please check your pkgs "  ;
	fi
	popd
    done
}


module_list=$(get_module_list ../configure/MODULES)

print_list "${module_list[@]}"
setup_base_require "TRUE"
