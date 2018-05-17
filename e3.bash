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
#   date    : Tuesday, May 15 22:56:10 CEST 2018
#   version : 0.5.3




GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -ga base_list=("e3-base")
declare -ga require_list=("e3-require")
declare -ga module_list=()

. ${SC_TOP}/.cfgs/.e3_functions.cfg
. ${SC_TOP}/.cfgs/.e3_modules_list.cfg



function git_clone
{

    local rep_name=$1 ; shift;
    printf ">> %s\n" "$rep_name";
    if [[ $(checkIfDir "${rep}") -eq "$NON_EXIST" ]]; then
	printf ">> No target directroy is found, Cloning...\n\n";
	${GIT_CMD} ${GIT_URL}/$rep_name  ||  die 1 "${FUNCNAME[*]} : Cloning Error at ${rep}: Please check the repository status" ;
    else
	printf ">> Target directory is found, Pulling instead of Cloning ... \n\n";
	pushd ${rep} 
	git pull ||  die 1 "${FUNCNAME[*]} : Pulling Error at ${rep}: Please check the repository status" ;
	popd
    fi
    printf "\n";
    
}

function make_init2
{
    git submodule update --init --recursive ;
    git submodule update --remote ;
    make checkout
}


# BASE
function init_base
{
    local rep="";
    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make init   ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ;
	    make env
	    make pkgs
	    make patch  ||  die 1 "${FUNCNAME[*]} : MAKE patch ERROR at ${rep}: Please check it" ;
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist. Please make sure \"make gbase\" first"
	fi
	printf "\n";
    done
}

# BASE
function init2_base
{
    local rep="";
    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    git submodule sync
	    git submodule update --init --recursive
	    make checkout
	    make env
	    make pkgs
	    make patch  ||  die 1 "${FUNCNAME[*]} : MAKE patch ERROR at ${rep}: Please check it" ;
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist. Please make sure \"make gbase\" first"
	fi
	printf "\n";
    done
}



# BASE
function setup_base
{
    local git_status=$1; shift;
    clone_base "${git_status}";
    init_base;
}

# BASE
function build_base
{
    local rep="";
    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make build ||  die 1 "${FUNCNAME[*]} : Building Error at ${rep}: Please check the building error" ;
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
    done
}



## REQUIRE
function init_require
{
    local rep="";
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make init ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ;
	    make env;
	    popd
	else
	    die 1 "${rep} doesn't exist. Please make sure \"make greq\" first"
	fi
	printf "\n";
    done
}



## REQUIRE
function init2_require
{
    local rep="";
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make_init2 ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ;
	    make env;
	    popd
	else
	    die 1 "${rep} doesn't exist. Please make sure \"make greq\" first"
	fi
	printf "\n";
    done
}


## REQUIRE
function devinit_require
{
    local rep="";
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make devinit ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ;
	    make devenv;
	    popd
	else
	    die 1 "${rep} doesn't exist. Please make sure \"make greq\" first"
	fi
	printf "\n";
    done
}



## REQUIRE
# $1 : "TRUE" : git clone
#    "        : skip clone
function setup_require
{
    local git_status=$1; shift;
    clone_require "${git_status}" ;
    init_require;
}


## REQUIRE
# $1 : "TRUE" : git clone
#    "        : skip clone
function devsetup_require
{
    local git_status=$1; shift;
    clone_require "${git_status}" ;
    devinit_require;
}



## REQUIRE
function build_require
{
    local rep="";
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

## REQUIRE
function devbuild_require
{
    local rep="";
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make devbuild   ||  die 1 "${FUNCNAME[*]} : Building Error at ${rep}: Please check the building error" ;
	    make devinstall ||  die 1 "${FUNCNAME[*]} : MAKE INSTALL ERROR at ${rep}: Please check it" ;
	    popd
	else
	    die 1 "${rep} doesn't exist";
	fi
    done
}




function init_modules
{
    local rep="";
    # git credential cache set to 30 mins (enough) in order to minimize the same password, and username again again
    # in bitbucket and gitlab.esss.se
    git config credential.helper 'cache --timeout=1800'
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make init ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ; 
	    make env
	    make patch
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist. Please make sure \"make -g all gmod\" first";
	fi
	printf "\n";
    done
    # git credential exit, so we clear 30 mins cache
    git credential-cache exit
    
}


function init2_modules
{
    local rep="";
    # git credential cache set to 30 mins (enough) in order to minimize the same password, and username again again
    # in bitbucket and gitlab.esss.se
    git config credential.helper 'cache --timeout=1800'
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make_init2 ||  die 1 "${FUNCNAME[*]} : MAKE init ERROR at ${rep}: Please check it" ; 
	    make env
	    make patch
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist. Please make sure \"make -g all gmod\" first";
	fi
	printf "\n";
    done
    # git credential exit, so we clear 30 mins cache
    git credential-cache exit
    
}



function setup_modules
{
    local git_status=$1; shift;
    clone_modules "${git_status}";
    init_modules;
}

function build_modules
{
    local rep="";
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    make build    ||  die 1 "${FUNCNAME[*]} : Building Error at ${rep}: Please check the building error" ;
	    make install  ||  die 1 "${FUNCNAME[*]} : MAKE INSTALL ERROR at ${rep}: Please check it" ;
	    popd
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	printf "\n";
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

#    sleep 30s;
#    kill -SIGINT ${APP_PID};
# stty sane > /dev/null 2>&1
    
}

function all_base
{
    clean_base;
    setup_base;
    build_base;
}

function all_require
{
    clean_require;
    setup_require;
    build_require;
}


function devall_require
{
    clean_require;
    devsetup_require;
    devbuild_require;
}



function all_modules
{
    clean_modules;
    setup_modules;
    build_modules;
}

function init_all
{
    init_base;
    init_require;
    init_modules;
}


function init2_all
{
    init2_base;
    init2_require;
    init2_modules;
}


function build_all
{
    build_base;
    build_require;
    build_modules;
}

function all2_all
{
    clean_all;
    clone_all;
    init2_all;
    build_all;
}


function all_all
{
    clean_all;
    clone_all;
    init_all;
    build_all;
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
	echo "           gall   : Clone all (base, require, selected module group)";
	echo "           iall   : Init  all (base, require, selected module group)";
	echo "           ball   : Build, Install all (base, require, selected module group)";
	echo "            all   : call, gall, iall, ball";
	echo ""
	echo "           cbase  : Clean Base";
	echo "           gbase  : Clone Base";
	echo "           ibase  : Init  Base ";
	echo "           bbase  : Build, Install Base";
	echo "            base  : cbase, gbase, ibase, bbase";
	echo ""           
	echo "           creq   : Clean Require";
	echo "           greq   : Clone Require";
	echo "           ireq   : Init  Require";
	echo "           breq   : Build, Install Require";
	echo "            req   : creq, gbase ireq, breq";
	echo ""           
	echo "           cmod   : Clean Modules (selected module group)";
	echo "           gmod   : Clone Modules (selected module group)";
	echo "           imod   : Init  Modules (selected module group)";
	echo "           bmod   : Build, Install Modules (selected module group)";
	echo "            mod   : cmod, mod, imod, bmod";
	echo ""
	echo "        co_base \"_check_out_name_\" : Checkout Base";
	echo "         co_req \"_check_out_name_\" : Checkout Require";
	echo "         co_mod \"_check_out_name_\" : Checkout Modules  (selected module group)";
	echo "         co_all \"_check_out_name_\" : co_base, co_req, co_mod";
	echo ""
	echo "          vbase   : Print BASE    Version Information in e3-*";
	echo "           vreq   : Print REQUIRE Version Information in e3-*";
	echo "           vmod   : Print MODULES Version Information in e3-*";
	echo "           vall   : Print ALL     Version Information in e3-*";
	echo "";
	echo "         allall   : Print ALL Version Information in e3-* by using \"make vars\"";
	echo "";
       	echo "           load   : Load all installed Modules into iocsh.bash";
	echo ""
	echo ""           
	echo ""    
	
	echo "  Examples : ";
	echo ""
	echo "          $0 creq "
	echo "          $0 -ctifeal cmod";
	echo "          $0 -t env";
	echo "          $0 base";
        echo "          $0 req";
	echo "          $0 -e cmod";
	echo "          $0 -t load";
	echo "   ";       
	echo "";
	
    } 1>&2;
    exit 1; 
}




common=""
timing=""
ifcfree=""
ifcnfree=""
ecat=""
area=""
llrf=""
only=""


while getopts "ctifealo" opt; do
    case "${opt}" in
	c) common="1"  ;;
	t) timing="1"  ;;
	i) ifcfree="1" ;;
	f) ifcnfree="1";;
	e) ecat="1"    ;;
	a) area="1"    ;;
	l) llrf="1"    ;;
	o) only="1"    ;;
	*) usage ;;
    esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list


if ! [ -z "${common}" ]; then
    module_list+=( "${modules_common}" )
fi

if ! [ -z "${timing}" ]; then
    module_list+=( "${modules_timing}" )
fi


if ! [ -z "${ifcfree}" ]; then
    if [ -z "${only}" ] && [ -z "${common}" ]; then
	    module_list+=( "${modules_common}" );
	    common="2"
    fi
    module_list+=( "${modules_ifc_free}" )
fi

if ! [ -z "${ifcnfree}" ]; then
    if [ -z "${only}" ] && [ -z "${common}" ]; then
	module_list+=( "${modules_common}" )
	common="2"
    fi
     if [ -z "${only}" ] && [ -z "${ifcfree}" ]; then
	module_list+=( "${modules_ifc_free}" )
	ifcfree="2"
    fi
    module_list+=( "${modules_ifc_nonfree}" )
fi


if ! [ -z "${ecat}" ]; then
    if [ -z "${only}" ] && [ -z "${common}" ]; then
	module_list+=( "${modules_common}" )
	common="2"
    fi
    module_list+=( "${modules_ecat}" )
fi

if ! [ -z "${area}" ]; then
    if [ -z "${only}" ] && [ -z "${common}" ]; then
	module_list+=( "${modules_common}" )
	common="2"
    fi
    module_list+=( "${modules_area}" )
fi


if ! [ -z "${llrf}" ]; then
    if [ -z "${only}" ] && [ -z "${common}" ]; then
	module_list+=( "${modules_common}" )
	common="2"
    fi
    module_list+=( "${modules_llrf}" )
fi




# print_list




# while getopts " :g:" opt; do
#     case "${opt}" in
# 	g)
# 	    GROUP_NAME=${OPTARG}
# 	    ;;
# 	*)
# 	    usage
# 	    ;;
#     esac
# done
# shift $((OPTIND-1))


# # ifc_free should be installed before ifc_nonfree
# case "${GROUP_NAME}" in
#     common)
# 	module_list+=( "${modules_common}" )
# 	;;
#     timing*)
# 	module_list+=( "${modules_timing}" )
# 	;;
#     ifc)
# 	module_list+=( "${modules_ifc_free}"    )
# 	module_list+=( "${modules_ifc_nonfree}" )
# 	;;
#     ifc1)
# 	module_list+=( "${modules_ifc_free}"    )
# 	;;
#     ifc2)
# 	module_list+=( "${modules_ifc_nonfree}" )
# 	;;
#     ecat)
# 	module_list+=( "${modules_ecat}"   )
# 	;;
#     area)
# 	module_list+=( "${modules_area}"   )
# 	;;
#     test)
# 	module_list+=( "${modules_common}" )
# 	module_list+=( "${modules_timing}" )
# 	;;
#     test2)
# 	module_list+=( "${modules_common}" )
# 	module_list+=( "${modules_timing}" )
# 	module_list+=( "${modules_ifc_free}"   )
# 	module_list+=( "${modules_area}"   )
# 	;;
#     test3)
# 	module_list+=( "${modules_common}" )
# 	module_list+=( "${modules_timing}" )
# 	module_list+=( "${modules_ifc_free}"   )
# 	;;
#     test4)
# 	module_list+=( "${modules_timing}" )
# 	module_list+=( "${modules_ifc_free}"    )
# 	module_list+=( "${modules_ifc_nonfree}"   )
# 	module_list+=( "${modules_area}"   )
# 	module_list+=( "${modules_ecat}"   )
# 	;;
#     test5)
# 	module_list+=( "${modules_common}" )
# 	module_list+=( "${modules_timing}" )
# 	module_list+=( "${modules_ifc_free}"    )
# 	module_list+=( "${modules_ifc_nonfree}"   )
# 	module_list+=( "${modules_area}"   )
# 	;;
#     test6)
# 	module_list+=( "${modules_common}" )
# 	module_list+=( "${modules_timing}" )
# 	module_list+=( "${modules_area}"   )
# 	;;
#     jhlee)
# 	module_list+=( "${modules_common}" )
# 	module_list+=( "${modules_timing}" )
# 	module_list+=( "${modules_ifc_free}"   )
# 	module_list+=( "${modules_area}"   )
# 	;;
#     all)
# 	module_list+=( "${modules_common}" )
# 	module_list+=( "${modules_timing}" )
# 	module_list+=( "${modules_ifc_free}"   )
# 	module_list+=( "${modules_ifc_nonfree}"   )
# 	module_list+=( "${modules_area}"   )
# 	module_list+=( "${modules_ecat}"   )
# 	;;
#     * )
# 	module_list+=( "" )
	
# 	;;
    
# esac


case "$1" in

    *mod) 
	echo ">> Selected Modules are :"
	echo ${module_list[@]}
	echo ""
	;;
    *all) 
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
	print_module_list
	;;
    vars)
	print_module_list
	;; 
    # all : clean, clone, init, build, and all
    clean) clean_all     ;;
    call)  clean_all     ;;
    gall)  clone_all     ;;
    iall)  init_all      ;;
    i2all) init2_all     ;;
    ball)  build_all     ;;
    all)   all_all       ;;
    all2)  all2_all      ;;
    # BASE : clean, clone, init, build, and all
    cbase) clean_base    ;;
    gbase) clone_base    ;;
    ibase)  init_base    ;;
    i2base)  init2_base  ;;
    bbase) build_base    ;;
    base)    all_base    ;;
    # REQUIRE : clean, clone, init, build, and all
    creq)      clean_require ;;
    greq)      clone_require ;;
    ireq)       init_require ;;
    i2req)     init2_require ;;
    devireq) devinit_require ;;
    breq)      build_require ;;
    req)         all_require ;;
    devreq)   devall_require ;;
    # MODULES : clean, clone, init, build, and all
    cmod)  clean_modules ;;
    gmod)  clone_modules ;;
    imod)   init_modules ;;
    i2mod)  init2_modules ;;
    bmod)  build_modules ;;
    mod)     all_modules ;;
    pmod)    git_pull_modules ;;
    # Git Checkout 
    co_base) git_checkout_base    "$2";;
    co_req)  git_checkout_require "$2";;
    co_mod)  git_checkout_modules "$2";;
    co_all)  git_checkout_all     "$2";;
    # GIT Commands 
    pull)   git_pull_all    ;;
    add)    git_add    "$2" ;;
    commit) git_commit "$2" ;;
    push)   git_push        ;;
    # Module Loading Test
    load) module_loading_test_on_iocsh;;
    # Print Version Information in e3-* directory
    vbase) print_version_info_base    ;;
    vreq)  print_version_info_require ;;
    vmod)  print_version_info_modules ;;
    vall)  print_version_info_all     ;;
    # Call *make vars in each e3-* directory
    allall)  print_version_really_everything   ;;
    *)    usage;;
esac

exit 0;





