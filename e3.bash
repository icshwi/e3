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
#   date    : Thursday, April 19 17:17:34 CEST 2018
#   version : 0.3.0



declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"


GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"
BOOL_GIT_CLONE="TRUE"


declare -ga base_list=("e3-base")
declare -ga require_list=("e3-require")
declare -ga module_list=()

. ${SC_TOP}/.cfgs/.e3_functions.cfg
. ${SC_TOP}/.cfgs/.e3_modules_list.cfg



function git_clone
{

    local rep_name=$1 ; shift;
    ${GIT_CMD} ${GIT_URL}/$rep_name
    
}



# BASE
function setup_base
{
    local git_status=$1; shift;
    for rep in  ${base_list[@]}; do
	if [ "${BOOL_GIT_CLONE}" = "$git_status" ]; then
	    git_clone ${rep} ||  die 1 "${FUNCNAME[*]} : git clone ERROR at ${rep}: the target ${rep} may be exist, Please check it" ;
	fi
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
#	    checkout_e3_tags "target_path_test"
	    make init   ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ;
	    make env
	    make pkgs
	    make patch  ||  die 1 "${FUNCNAME[*]} : MAKE patch ERROR at ${rep}: Please check it" ;
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	
    done
}

function build_base
{

    sudo -v
    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
#	    checkout_e3_tags "target_path_test"
	    make build ||  die 1 "${FUNCNAME[*]} : Building Error at ${rep}: Please check the building error" ;
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
    done
}


function clean_base
{

    local rep;
    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    echo "Cleaning .... $rep"
	    sudo rm -rf ${SC_TOP}/${rep}
	else
	    printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	fi
    done
}



function git_checkout_base
{
    local rep;
    local checkout_target=$1; shift;

    if [[ $(checkIfVar "${checkout_target}") -eq "$EXIST" ]]; then
	for rep in  ${base_list[@]}; do
	    if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
		pushd ${rep}
		git checkout ${checkout_target}
		popd
	    else
		printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	    fi  
	done
    else
	printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
    fi
        
}





## REQUIRE
function setup_require
{
    local git_status=$1; shift;
    for rep in  ${require_list[@]}; do
	if [ "${BOOL_GIT_CLONE}" = "$git_status" ]; then
	    git_clone ${rep}  ||  die 1 "${FUNCNAME[*]} : git clone ERROR at ${rep}: the target ${rep} may be exist, Please check it" ;
	fi
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make init ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ;
	    make env
	    popd
	else
	    die 1 "${rep} doesn't exist";
	fi
    done
}



function build_require
{

    sudo -v
    
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make build   ||  die 1 "${FUNCNAME[*]} : Building Error at ${rep}: Please check the building error" ;
	    make install ||  die 1 "${FUNCNAME[*]} : MAKE INSTALL ERROR at ${rep}: Please check it" ;
	    popd
	else
	    die 1 "${rep} doesn't exist";
	fi
    done
}


function clean_require
{
    local rep;
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    echo "Cleaning .... $rep"
	    make uninstall 
	    sudo rm -rf ${SC_TOP}/${rep}
	else
	    printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	fi
    done
}


function git_checkout_require
{
 
    local checkout_target=$1; shift;
    if [[ $(checkIfVar "${checkout_target}") -eq "$EXIST" ]]; then
	local rep ="";
	for rep in  ${require_list[@]}; do
	    if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
		pushd ${rep}
		git checkout ${checkout_target}
		popd
	    else
		printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	    fi  
	done
    else
	printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
    fi  
}


## MODULES

function setup_modules
{
    local git_status=$1; shift;
    local rep;
    for rep in  ${module_list[@]}; do
	if [ "${BOOL_GIT_CLONE}" = "$git_status" ]; then
	    git_clone ${rep}  ||  die 1 "${FUNCNAME[*]} : git clone ERROR at ${rep}: the target ${rep} may be exist, Please check it" ;
	fi
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make init ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ; 
	    make env
	    make patch
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
    done

}

function build_modules
{

    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make build    ||  die 1 "${FUNCNAME[*]} : Building Error at ${rep}: Please check the building error" ;
	    make install  ||  die 1 "${FUNCNAME[*]} : MAKE INSTALL ERROR at ${rep}: Please check it" ;
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
    done
}


function clean_modules
{
    local rep;
    sudo -v;
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    echo "Cleaning .... $rep"
	    pushd ${rep}
	    make uninstall 
	    popd
	    sudo rm -rf ${SC_TOP}/${rep}
	else
	    printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	fi
    done
}



function git_checkout_modules
{
 
    local checkout_target=$1; shift;
    if [[ $(checkIfVar "${checkout_target}") -eq "$EXIST" ]]; then

	for rep in  ${module_list[@]}; do
	    if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
		pushd ${rep}
		git checkout ${checkout_target}
		popd
	    else
		printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	    fi  
	done
    else
	printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
    fi  
}



#
# module name, configure/MODULES,
# sometimes is different in EPICS_MODULE_NAME in module/configure/CONFIG
# for example, sequencer
# module name       is sequencer
# EPICS_MODULE_NAME is seq

function module_loading_test_on_iocsh
{
    source ${SC_TOP}/e3-require/tools/setE3Env.bash

    local IOC_TEST=/tmp/module_loading_test.cmd
    
    {
	local PREFIX_MODULE="EPICS_MODULE_NAME:="
	local PREFIX_LIBVERSION="E3_MODULE_VERSION:="
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
	    done < ${SC_TOP}/${rep}/configure/CONFIG_MODULE
	    if [ "${mod}" = "StreamDevice" ]; then
		mod="stream"
	    fi
	    printf "#\n#\n"
	    printf "# >>>>>\n";
	    printf "# >>>>> MODULE Loading ........\n";
	    printf "# >>>>> MODULE NAME ..... ${mod}\n";
	    printf "# >>>>>        VER  ..... ${ver}\n";
	    printf "# >>>>>\n";

	    if [[ ${mod} == AD* ]]; then
		printf "#--------------------------------------- \n";
		printf "# In ADSupport, ADCore, and ADSimDector, \n";
		printf "# Simply ignore the following errors : \n";
		printf " epicsEnvSet(\"TOP\",\"${SC_TOP}/${rep}\")\n"
		printf " cd ${SC_TOP}/${rep}\n"
		printf " < ${SC_TOP}/${rep}/cmds/load_libs.cmd\n"
		printf "#--------------------------------------- \n";
	    fi
	    printf "require ${mod},${ver}\n";
	    printf "# >>>>>\n";
	    printf "#\n#\n"
	done
	
    }  > ${IOC_TEST}

    exec iocsh.bash ${IOC_TEST}
}

function base_all
{
    clean_base;
    setup_base "TRUE";
    build_base;
}

function req_all
{
    clean_require;
    setup_require "TRUE";
    build_require;
}

function mod_all
{
    clean_modules;
    setup_modules  "TRUE";
    build_modules;
}



function git_checkout_all
{
    local checkout_target=$1; shift;
    if [[ $(checkIfVar "${checkout_target}") -eq "$EXIST" ]]; then
	git_checkout_base    "${checkout_target}"
	git_checkout_require "${checkout_target}"
	git_checkout_modules "${checkout_target}"
    else
	printf " %20s: SKIP all checkout, we cannot find it\n"  "${FUNCNAME[*]}" 
    fi  
}





function usage
{
    usage_title;
    usage_mod;

    {
	echo " < option > ";
	echo "";
      	echo "           env    : Print enabled Modules";
	echo ""
	echo "           call   : Clean all (base, require, selected module group)";
	echo "           iall   : Init  all (base, require, selected module group)";
	echo "           ball   : Build, Install all (base, require, selected module group)";
	echo "            all   : call, iall, ball";
	echo "          clean   : call";
	echo ""
	echo "           cbase  : Clean Base";
	echo "           ibase  : Init  Base ";
	echo "           bbase  : Build, Install Base";
	echo "            base  : cbase, ibase, bbase";
	echo ""           
	echo ""
	echo "           creq   : Clean Require";
	echo "           ireq   : Init  Require";
	echo "           breq   : Build, Install Require";
	echo "            req   : creq, ireq, breq";
	echo ""           
	echo ""
	echo "           cmod   : Clean Modules (selected module group)";
	echo "           imod   : Init  Modules (selected module group)";
	echo "           bmod   : Build, Install Modules (selected module group)";
	echo "            mod   : cmod, imod, bmod";
	echo ""
	echo "           load   : Load all installed Modules into iocsh.bash";
	echo ""
	echo "     ckout_base  : Checkout Base";
	echo "      ckout_req  : Checkout Require";
	echo "      ckout_mod  : Checkout Modules  (selected module group)";
	echo "      ckout_all  : ckout_base, ckout_req, ckout_mod";
       
	echo ""           
	echo ""    
	
	echo "  Examples : ";
	echo ""
	echo "          $0 -g all env";
	echo "          $0 -g all iall";
	echo "          $0 -g timing env";
	echo "          $0 base";
        echo "          $0 req";
	echo "          $0 -g ecat cmod";
	echo "          $0 -g timing load";
	echo "   ";       
	echo "";
	
    } 1>&2;
    exit 1; 
}

 
while getopts " :g:" opt; do
    case "${opt}" in
	g)
	    GROUP_NAME=${OPTARG}
	    ;;
	*)
	    usage
	    ;;
    esac
done
shift $((OPTIND-1))

case "${GROUP_NAME}" in
    common)
	module_list+=( "${modules_common}" )
	;;
    timing*)
	module_list+=( "${modules_timing}" )
	;;
    ifc)
	module_list+=( "${modules_ifc}"    )
	;;
    ecat)
	module_list+=( "${modules_ecat}"   )
	;;
    area)
	module_list+=( "${modules_area}"   )
	;;
    test)
	module_list+=( "${modules_common}" )
	module_list+=( "${modules_timing}" )
	module_list+=( "${modules_ifc}"    )
	;;
    test2)
	module_list+=( "${modules_common}" )
	module_list+=( "${modules_timing}" )
	module_list+=( "${modules_area}"   )
	;;
    jhlee)
	module_list+=( "${modules_common}" )
	module_list+=( "${modules_timing}" )
	module_list+=( "${modules_ifc}"    )
	module_list+=( "${modules_area}"   )
	;;
    all)
	module_list+=( "${modules_common}" )
	module_list+=( "${modules_timing}" )
	module_list+=( "${modules_ifc}"    )
	module_list+=( "${modules_area}"   )
	module_list+=( "${modules_ecat}"   )
	;;
    * )
	module_list+=( "" )
	;;
esac


case "$1" in

    *mod) 
	echo ">> Selected Modules are :"
	echo ${module_list[@]}
	echo ""
	;;
    *)
	echo ""
	;;

esac


case "$1" in
    env)
	echo ">> Vertical display for the selected modules :"
	echo ""
	print_list
	echo ""
	;;
    
    call)
	clean_base;
	clean_require;
	clean_modules;
	;;
    iall)
	setup_base "TRUE";
	setup_require "TRUE";
	setup_modules  "TRUE"
	;;
    ball)
	build_base;
	build_require;
	build_modules;
	;;
    all)
	base_all;
	req_all;
	mod_all;
	;;
    cbase)
	clean_base;
	;;
    ibase)
	setup_base "TRUE";
	;;
    bbase)
	build_base;
	;;
    base)
	base_all;
	;;
    creq)
	clean_require
	;;
    ireq)
	setup_require "TRUE";
	;;
    breq)
	build_require;
	;;
    req)
	req_all;
	;;
    cmod)
	clean_modules
	;;
    imod)
	setup_modules  "TRUE"
	;;
    bmod)
	build_modules
	;;
    mod)
	mod_all
	;;
    pull)
	git_pull_all
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
    db)
	install_db
	;;
    load)
	module_loading_test_on_iocsh
	;;
    ckout_base)
	git_checkout_base "$2"
	;;
    ckout_req)
	git_checkout_require "$2"
	;;
    ckout_mod)
	git_checkout_modules "$2"
	;;
    ckout_all)
	git_checkout_all "$2"
	;;
    *)
	usage
	;;
esac

exit 0;





