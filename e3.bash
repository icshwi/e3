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

function git_clone {

    local rep_name=$1
    ${GIT_CMD} ${GIT_URL}/$rep_name
    
}

declare -g  env="e3-env"
declare -ga require_list=("e3-base" "e3-require")
declare -ga module_list=()

module_list+="e3-iocStats";
module_list+=" " ; module_list+="e3-devlib2";
#module_list+=" " ; module_list+="e3-mrfioc2";


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


sudo -v


for rep in  ${require_list[@]}; do
   pushd ${rep}
   make build
   make install
   popd
done


#
# Mandatory step in order to compile modules
# Since we have the global env variables,
# it should be OK to use them
#
git_clone ${env}
pushd ${env}
source setE3Env.bash
popd



for rep in  ${module_list[@]}; do
    git_clone ${rep}
    pushd ${rep}
    make init
    make env
    popd
done

for rep in  ${module_list[@]}; do
    pushd ${rep}
    make build
    make install
    popd
done

