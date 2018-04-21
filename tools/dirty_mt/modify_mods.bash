#!/bin/bash
#
#  Copyright (c) 2018 - Present  Jeong Han Lee
#  Copyright (c) 2018 - Present  European Spallation Source ERIC
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
#   date    : Tuesday, February 20 16:42:54 CET 2018
#   version : 0.0.1



declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


declare -ga module_list=()


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

function git_diff
{
    local rep;
    local git_add_file=$1; shift;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	git diff ${git_add_file}
	popd
    done
}

function git_add
{
    local rep;
    local git_add_file=$1; shift;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	git add ${git_add_file}
	popd
    done
}
   

function git_commit
{
    local rep;
    local git_commit_comment=$1; shift;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	git commit -m "${git_commit_comment}"
	popd
    done
}


function git_push
{
    local rep;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	git push
	popd
    done
}


function add_string_first
{
    local rep;
    local filename = $1;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	sed  -i '1 s/^/.DEFAULT_GOAL \:=help\n/' ${filename}
	popd
    done
}

module_list=$(get_module_list ${SC_TOP}/../configure/MODULES)



print_list "${module_list[@]}"


add_string_first "configure/E3/RULES_E3"


git_diff
