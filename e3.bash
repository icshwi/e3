#!/bin/bash
#
#  Copyright (c) 2017 - Present  Jeong Han Lee
#  Copyright (c) 2017 - Present  European Spallation Source ERIC
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
#   date    : Monday, February 12 15:39:11 CET 2018
#   version : 0.0.8


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"
BOOL_GIT_CLONE="TRUE"

declare -g  env="e3-env"
declare -ga require_list=("e3-base" "e3-require")
declare -ga module_list=()
declare -ga db_module_list=()

db_module_list+=("e3-iocStats");
db_module_list+=("e3-mrfioc2");
db_module_lits+=("e3-ipmiComm");

function die()
{
    error=${1:-1}
    ## exits with 1 if error number not given
    shift
    [ -n "$*" ] &&
	printf "%s%s: %s\n" "$scriptname" ${version:+" ($version)"} "$*" >&2
    exit "$error"
}


function env_reset {
    
    PATH=/usr/local/bin:/usr/bin:/bin
    unset EPICS_MODULES_PATH
    unset EPICS_ENV_PATH
    unset EPICS_BASE
    unset EPICS_BASES_PATH
    unset EPICS_HOST_ARCH
    unset PYTHONPATH
    
    unset EPICS_CA_AUTO_ADDR_LIST
}




function yes_or_no_to_go() {

    printf "\n";
    printf  ">>>> $1\n";
    read -p ">>>> Do you want to continue (y/n)? " answer
    case ${answer:0:1} in
	y|Y )
	    printf ">>>> We are installing modules ...... \n";
	    ;;
	* )
            printf "Stop here.\n";
	    exit;
    ;;
    esac

}

function install_db
{
    local rep;
    for rep in  ${db_module_list[@]}; do
	pushd ${rep}
	make db
	make install
	popd
    done
}

function help
{
    echo "">&2
    echo " Usage: $0 <arg>  ">&2 
    echo ""
    echo "          <arg>    : info">&2 
    echo ""
    echo "           all     : Setup and Build ALL">&2
    echo "           base    : Setup and Build Base and Require">&2
    echo "           modules : Setup and Build all modules">&2
    echo "           env     : Print all modules list">&2
    echo "">&2
    echo "">&2 	
}

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

function build_base_require
{

    sudo -v
    
    
    for rep in  ${require_list[@]}; do
	pushd ${rep}
	make build || die 3 "$BUILD ERROR : ${rep} "  ;
	if [ "${rep}" = "e3-require" ]; then
	    make install || die 4 "INSTALLL ERROR : Please check ${rep} "  ;
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
    local git_status=$1;  shift;
    
    if [ "${BOOL_GIT_CLONE}" = "$git_status" ]; then
	git_clone ${env}
    fi

    source ${env}/setE3Env.bash

}



function print_list
{
    local array=$1; shift;
    for a_list in ${array[@]}; do
	printf " %s\n" "$a_list";
    done
}

function setup_modules
{
    local git_status=$1; shift;
    local rep;
    for rep in  ${module_list[@]}; do
	if [ "${BOOL_GIT_CLONE}" = "$git_status" ]; then
	    git_clone ${rep}
	fi
	pushd ${rep}
	make init ||  die 1 "Init ERROR : Please check your ${rep}"  ;  
	make env
	popd
    done

}

function build_modules
{
    yes_or_no_to_go "SUDO is required"

    sudo -v
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	make build || die 3 "$BUILD ERROR : ${rep} "  ;
	sudo make install  || die 4 "INSTALLL ERROR : Please check ${rep} "  ;
	popd
    done
}

function build_modules_without_question
{

    sudo -v
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	make build
	sudo make install
	popd
    done
}



function clean_env
{
    echo "Cleaning .... e3-env"
    sudo rm -rf ${SC_TOP}/e3-env
}


function clean_base_require
{

    local rep;
    for rep in  ${require_list[@]}; do
	echo "Cleaning .... $rep"
	sudo rm -rf ${SC_TOP}/${rep}
    done
}



function clean_modules
{
    local rep;
    sudo -v;
    for rep in  ${module_list[@]}; do
	echo "Cleaning .... $rep"
	pushd ${rep}
	make uninstall
	popd
	sudo rm -rf ${SC_TOP}/${rep}
    done
}



function git_pull
{
    local rep;
    for rep in  ${require_list[@]}; do
	pushd ${rep}
	git pull
	popd
    done

    pushd ${env}
    git pull
    popd
   
    
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	git pull
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





#
# module name, configure/MODULES,
# sometimes is different in EPICS_MODULE_NAME in module/configure/CONFIG
# for example, sequencer
# module name       is sequencer
# EPICS_MODULE_NAME is seq

function module_loading_test_on_iocsh
{
    source ${SC_TOP}/e3-env/setE3Env.bash

    local IOC_TEST=/tmp/module_loading_test.cmd
    
    {
	local PREFIX_MODULE="EPICS_MODULE_NAME:="
	local PREFIX_LIBVERSION="export LIBVERSION:="
	local mod=""
	local ver=""
	printf "var requireDebug 1\n";
	for rep in  ${module_list[@]}; do
	    while read line; do
		if [[ $line =~ "${PREFIX_LIBVERSION}" ]] ; then
		    ver=${line#$PREFIX_LIBVERSION}
		elif [[ $line =~ "${PREFIX_MODULE}" ]] ; then
		    mod=${line#$PREFIX_MODULE}
		fi
	    done < ${SC_TOP}/${rep}/configure/CONFIG
	    printf "#\n#\n"
	    printf "# >>>>>\n";
	    printf "# >>>>> MODULE Loading ........\n";
	    printf "# >>>>> MODULE NAME ..... ${mod}\n";
	    printf "# >>>>>        VER  ..... ${ver}\n";
	    printf "# >>>>>\n";
	    printf "require ${mod}, ${ver}\n";
	    printf "# >>>>>\n";
	    printf "#\n#\n"
	done
	
    }  > ${IOC_TEST}

    exec iocsh.bash ${IOC_TEST}
}


env_reset

module_list=$(get_module_list ${SC_TOP}/configure/MODULES)


case "$1" in
    all)
	setup_base_require "TRUE"
	build_base_require
	setup_env          "TRUE"
	setup_modules      "TRUE"
	build_modules
	setup_env
	install_db
	;;
    travis)
	setup_base_require "TRUE"
	build_base_require
	setup_env          "TRUE"
	setup_modules      "TRUE"
	build_modules_without_question
	setup_env
	install_db
	;;
    base)
    	setup_base_require "TRUE"
	build_base_require
	;;
    modules)
	setup_env     "TRUE"
	setup_modules "TRUE"
	build_modules
	;;
    env)
	print_list "${module_list[@]}"
	;;
    bmod)
	setup_env  
	build_modules
	;;
    pull)
	git_pull
	;;
    add)
	git_add "$2"
	;;
    commit)
	git_commit "$2"
	;;
    push)
	git_push
	;;
    rmod)
	clean_modules
	setup_env      "TRUE"
	setup_modules  "TRUE"
	build_modules
	;;
    clean)
	clean_base_require
	clean_env
	clean_modules
	;;
    cmod)
	clean_modules
	;;
    db)
	setup_env
	install_db
	;;
    load)
	module_loading_test_on_iocsh
	;;
    *)
	help
	;;
esac

exit 0;





