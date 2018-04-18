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
#   date    : Wednesday, April 18 09:36:32 CEST 2018
#   version : 0.2.3



declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"


function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"
BOOL_GIT_CLONE="TRUE"


declare -ga base_list=("e3-base")
declare -ga require_list=("e3-require")
declare -ga module_list=()
declare -ga m_list=()


function die
{
    error=${1:-1}
    ## exits with 1 if error number not given
    shift
    [ -n "$*" ] &&
	printf "%s%s: %s\n" "$scriptname" ${version:+" ($version)"} "$*" >&2
    exit "$error"
}

EXIST=1
NON_EXIST=0


function checkIfDir
{
    
    local dir=$1
    local result=""
    if [ ! -d "$dir" ]; then
	result=$NON_EXIST
	# doesn't exist
    else
	result=$EXIST
	# exist
    fi
    echo "${result}"
};


function checkout_e3_tags
{
    local tags=$1;
    git checkout $tags;
}


function git_clone
{

    local rep_name=$1 ; shift;
    ${GIT_CMD} ${GIT_URL}/$rep_name
    
}

function get_module_list
{
    local empty_string="";
    declare -a entry=();
 
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





function setup_require
{
    local git_status=$1; shift;
    for rep in  ${require_list[@]}; do
	if [ "${BOOL_GIT_CLONE}" = "$git_status" ]; then
	    git_clone ${rep}  ||  die 1 "${FUNCNAME[*]} : git clone ERROR at ${rep}: the target ${rep} may be exist, Please check it" ;
	fi
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
#	    checkout_e3_tags "target_path_test"
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
#	    checkout_e3_tags "target_path_test"
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






function print_list
{
    local a_list;
    for a_list in ${module_list[@]}; do
	printf " %s\n" "$a_list";
    done
}

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
#	    checkout_e3_tags "target_path_test"
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
#	    checkout_e3_tags "target_path_test"
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



function git_pull
{
    local rep;

    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    git pull
	    popd
	fi
    done
    
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    git pull
	    popd
	fi
    done

    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    git pull
	    popd
	fi
    done
}
   


function git_add
{
    local rep;
    local git_add_file=$1; shift;
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    git add ${git_add_file}
	    popd
	else
	    printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	fi
    done
}
   

function git_commit
{
    local rep;
    local git_commit_comment=$1; shift;
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    git commit -m "${git_commit_comment}"
	    popd
	else
	    printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	fi
    done
}


function git_push
{
    local rep;
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    git push
	    popd
	else
	    printf " %20s: SKIP %20s, we cannot find it\n"  "${FUNCNAME[*]}"  "${rep}"
	fi  
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

function usage
{
    {
	echo "";
	echo "Usage    : $0 [ -g <group_name> ] <option> ";
	echo "";
	echo " < group_name > ";
	echo ""
	echo "           common : epics modules"
	echo "           timing : mrf timing    related modules";
	echo "           ifc    : ifc platform  related modules";
	echo "           ecat   : ethercat      related modules";
	echo "           area   : area detector related modules";
	echo "           test   : common, timing, ifc modules";
	echo "           test2  : common, timing, area modules";
	echo "           jhlee  : common, timing, ifc, area modules";
	echo "           all    : common, timing, ifc, ecat, area modules";
	echo "";
	echo " < option > ";
	echo "";
      
	echo "           env    : Print enabled Modules";
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
	echo "           cmod   : Clean Modules";
	echo "           imod   : Init  Modules";
	echo "           bmod   : Build, Install Modules";
	echo "            mod   : cmod, imod, bmod";
	echo ""
	echo "           load   : Load all installed Modules into iocsh.bash";
	echo ""           
	echo ""    
	
	echo "  Examples : ";
	echo ""    
	echo "          $0 env";
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
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_COMMON)" )
	;;
    timing*)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_TIMING)" )
	;;
    ifc)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_IFC)" )
	;;
    ecat)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_ECAT)" )
	;;
    area)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_AD)" )
	;;
    test)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_COMMON)" )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_TIMING)" )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_IFC)"    )
#	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_AD)"     )
	;;
    test2)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_COMMON)" )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_TIMING)" )
#	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_IFC)"    )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_AD)"     )
	;;
    jhlee)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_COMMON)" )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_TIMING)" )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_IFC)"    )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_AD)"     )
	echo ""
	;;
    all)
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_COMMON)" )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_TIMING)" )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_IFC)"    )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_ECAT)"   )
	module_list+=( "$(get_module_list ${SC_TOP}/configure/MODULES_AD)"     )
	;;
    * )
	module_list+=( "e3-iocStats" )
	;;
esac


case "$1" in
    *base)
	echo ""
	;;
    *req)
	echo ""
	;;
    clean)
	echo ""
	;;
    *) 
	echo ">> Selected Modules are :"
	echo ${module_list[@]}
	echo ""
	;;

esac


case "$1" in
    all)
	base_all;
	req_all;
	mod_all;
	;;
    clean)
	clean_base;
	clean_require;
	clean_modules;
	;;
    env)
	echo ">> Vertical display for the selected modules :"
	echo ""
	print_list
	echo ""
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
    db)
	install_db
	;;
    load)
	module_loading_test_on_iocsh
	;;
    *)
	usage
	;;
esac

exit 0;





