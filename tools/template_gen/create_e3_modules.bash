#!/bin/bash
#
#  Copyright (c) 2018 - Present Jeong Han Lee
#  Copyright (c) 2018 - Present European Spallation Source ERIC
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
#   date    : Friday, May  4 09:38:43 CEST 2018
#   version : 0.3.2

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"
declare -gr SC_USER="$(whoami)"
declare -gr SC_HASH="$(git rev-parse --short HEAD)"

declare -g  LOG=".MODULE_LOG"

declare -g  E3_MODULE_DEST=""
##
## The following GLOBAL variables should be updated according to
## main release. However, it can be changed after their creation also.
## 
## _VARIABLES are used in .create_e3_mod_functions.cfg
##
## Please see add_configure, add_readme, and so on
## 


declare -gr _E3_EPICS_PATH=/epics
declare -gr _E3_BASE_VERSION=3.15.5
declare -gr _E3_REQUIRE_NAME=require
declare -gr _E3_REQUIRE_VERSION=3.0.0
declare -gr _EPICS_BASE=${_E3_EPICS_PATH}/base-${_E3_BASE_VERSION}

declare -g  _EPICS_MODULE_NAME=""
declare -g  _E3_MODULE_SRC_PATH=""
declare -g  _E3_MOD_NAME=""
declare -g  _E3_TGT_URL_FULL=""
declare -g  _E3_MODULE_GITURL_FULL=""


. ${SC_TOP}/.create_e3_mod_functions.cfg




function usage
{
    {
	echo "";
	echo "Usage    : $0 [-m <module_configuraton_file>] [-d <module_destination_path>] " ;
	echo "";
	echo "               -m : mandatory"
	echo "               -d : option ( \$PWD if not ) "
	echo "";
	echo "Examples in modules_conf  : ";
	echo "";
	echo " bash create_e3_modules.bash -m  snmp3.conf"
	echo " bash create_e3_modules.bash -m  snmp3.conf -d ~/testing"
	echo ""
	
    } 1>&2;
    exit 1; 
}

function help
{
    {
	printf "\n\n";
        printf ">>>> Skipping add the remote repository url. \n";
	printf "     And skipping push the ${_E3_MOD_NAME} to the remote also.\n";
	printf "\n";
	printf "In case, one would like to push this e3 module to git repositories,\n"
	printf "Please use the following commands within ${_E3_MOD_NAME}/ :\n"
	printf "\n";
	printf "   * git remote add origin ${_E3_TGT_URL_FULL}\n";
	printf "   * git commit -m \"First commit\"\n";
	printf "   * git push -u origin master\n";
    } 1>&2;
}

function module_info
{

    printf ">> \n";
    printf "EPICS_MODULE_NAME  : %64s\n" "${_EPICS_MODULE_NAME}"
    printf "E3_MODULE_SRC_PATH : %64s\n" "${_E3_MODULE_SRC_PATH}"
    printf "EPICS_MODULE_URL   : %64s\n" "${epics_mod_url}"
    printf "E3_TARGET_URL      : %64s\n" "${e3_target_url}"

    printf ">> \n";
    printf "e3 module name     : %64s\n" "${_E3_MOD_NAME}"
    printf "e3 module url full : %64s\n" "${_E3_MODULE_GITURL_FULL}"
    printf "e3 target url full : %64s\n" "${_E3_TGT_URL_FULL}"
    printf ">> \n";

    
}

while getopts " :m:d:" opt; do
    case "${opt}" in
	m)  MODULE_CONF=${OPTARG} ;;
	d)  E3_MODULE_PATH=${OPTARG}   ;;
	*)  usage                 ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${MODULE_CONF}" ] ; then
    usage
fi

if [ -z "${E3_MODULE_PATH}" ]; then
    E3_MODULE_PATH=${PWD}
fi


if [[ $(checkIfFile "${MODULE_CONF}") -eq "NON_EXIST" ]]; then
    die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
fi


_EPICS_MODULE_NAME="$(read_file_get_string   "${MODULE_CONF}" "EPICS_MODULE_NAME:=")";
_E3_MODULE_SRC_PATH="$(read_file_get_string  "${MODULE_CONF}" "E3_MODULE_SRC_PATH:=")";
epics_mod_url="$(read_file_get_string        "${MODULE_CONF}" "EPICS_MODULE_URL:=")";
e3_target_url="$(read_file_get_string        "${MODULE_CONF}" "E3_TARGET_URL:=")";


_E3_MOD_NAME=e3-${_EPICS_MODULE_NAME}

_E3_MODULE_GITURL_FULL=${epics_mod_url}/${_E3_MODULE_SRC_PATH}
_E3_TGT_URL_FULL=${e3_target_url}/${_E3_MOD_NAME}


E3_MODULE_DEST=${E3_MODULE_PATH}/${_E3_MOD_NAME};


module_info;

## Create the entire directory once

mkdir -p ${E3_MODULE_DEST}/{configure/E3,patch/Site,docs}  ||  die 1 "We cannot create directories : Please check it" ;



## Copy its original Module configuration file in docs
cp ${MODULE_CONF} ${E3_MODULE_DEST}/docs/   ||  die 1 "We cannot copy ${MODULE_CONF} to ${E3_MODULE_DEST}/docs : Please check it" ;


touch ${LOG}
{
    printf ">>\n";
    printf "Script is used     : ${SC_SCRIPTNAME}\n";
    printf "Script Path        : ${SC_TOP}\n";
    printf "User               : ${SC_USER}\n";
    printf "Log Time           : ${SC_LOGDATE}\n";
    printf "e3 repo Hash       : ${SC_HASH}\n";
    
    module_info;
    
} >> ${E3_MODULE_DEST}/docs/${LOG}



## Going into ${E3_MODULE_DEST}
pushd ${E3_MODULE_DEST}

git init ||  die 1 "We cannot git init in ${_E3_MOD_NAME} : Please check it" ;

## add submodule
add_submodule "${_E3_MODULE_GITURL_FULL}" "${_E3_MODULE_SRC_PATH}" ||  die 1 "We cannot add ${_E3_MODULE_GITURL_FULL} as git submodule ${_E3_MOD_NAME} : Please check it" ;

## add the default .gitignore
add_gitignore

## add README.md
add_readme

## add Makefile for E3 front-end
add_e3_makefile

## add ${_E3_MOD_NAME}.Makefile for E3
## This is the template file. One should change it accroding to their
## corresponding module
add_module_makefile  "${_EPICS_MODULE_NAME}"

pushd patch/Site # Enter in patch/Site
## add patch path and readme and so on
add_patch
popd             # Back to ${m_name}


pushd configure  # Enter in configure
add_configure 
popd             # Back to ${m_name}


pushd configure/E3 # Enter in configure/E3
add_configure_e3
popd               # Back in ${m_name}


# # git init
git add .


printf "\n";
printf  ">>>> Do you want to add the URL ${_E3_TGT_URL_FULL} for the remote repository?\n";
printf  "     In that mean, you already create an empty repository at ${_E3_TGT_URL_FULL}.\n";
printf  "\n";
read -p "     If yes, the script will push the local ${_E3_MOD_NAME} to the remote repository. (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes|YES )
	printf ">>>> We are going to the further process ...... ";
	git remote add origin ${_E3_TGT_URL_FULL} ||  die 1 "Cannot add ${_E3_TGT_URL_FULL} in origin: Please check your git env!" ;
	git commit -m "Init..${_E3_MOD_NAME}" ||  die 1 "We cannot commit, maybe you need to run git config user and so on." ;
	git push -u origin master ||  die 1 "Repository is not at ${_E3_TGT_URL_FULL} : Please create it first!" ;
	
	;;
    * )
	help;
	;;
esac


## Going out from ${E3_MODULE_DEST}
popd


echo "";
echo "The following files should be modified according to the module : "
echo "";
echo "   * ${E3_MODULE_DEST}/configure/CONFIG_MODULE"
echo "   * ${E3_MODULE_DEST}/configure/RELEASE"
echo "";
echo "One can check the e3- template works via ";
echo "   cd ${E3_MODULE_DEST}"
echo "   make init"
echo "   make vars"
echo "";
echo "";

	

exit

