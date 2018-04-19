#!/bin/bash
#
#  Copyright (c) 2018 - Present  Jeong Han Lee
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
#   date    : Thursday, April 19 17:17:25 CEST 2018
#   version : 0.1.0


# Example, how to use
#
# This script is used to copy a file to all modules directory, and
# prepare all git commands together.
# 
# $ bash maintain_e3.bash pull
# copy the right file in TOP
# for example, RULES_E3
# $ scp e3-autosave/configure/E3/RULES_E3 .
# Define the target directory in each module
# e3+ $ scp  e3-iocStats/configure/E3/DEFINES_FT .
# e3+ $ ./maintain_e3.bash -g ifc copy "configure/E3/DEFINES_FT"
# e3+ $ ./maintain_e3.bash -g ifc diff "configure/E3/DEFINES_FT"
# e3+ $ ./maintain_e3.bash -g ifc add "configure/E3/DEFINES_FT"
# e3+ $ ./maintain_e3.bash -g ifc commit "fix patch function"
# e3+ $ ./maintain_e3.bash -g ifc push

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"



declare -ga base_list=("e3-base")
declare -ga require_list=("e3-require")
declare -ga module_list=()


. ${SC_TOP}/.e3_functions.cfg
. ${SC_TOP}/.e3_modules_list.cfg

   

function git_diff
{
    local rep;
    local git_add_file=$1; shift;
     for rep in  ${module_list[@]}; do
	pushd ${rep}
	echo ""
	echo ">> git diff in ${rep}"
	git diff ${git_add_file}
	popd
    done
}




function git_branch_tag_status
{
    printf "\n\n"
    printf ">> Branch info : \n"
    git branch -v
    printf "\n>> Tag info  : \n"
    git tag -l
    printf "\n"
}

# git checkout ${release_branch}
# $ git push origin ${release_branch}
# $ git tag -a ${release_tag} -m "${release_comment} ${release_branch}
# $git push origin ${release_tag}

function release_base
{
    local release_file="${1}";
    
    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
    
    local delete_release="${2}"; 
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    local release_comments="$(read_file_get_string "${release_file}" "RELEASE_COMMENTS:=")";
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}
    
    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    printf "\n> -------------------------------------------------------------\n";
	    printf ">> %2d : Entering into %s\n" "$i" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    printf "* Release Branch and Tag to the remote .... \n";
	    printf "  Branch  : %20s\n"  "${release_branch}"
	    printf "  Tag     : %20s\n"  "${release_tag}"
	    printf "  Comment : %40s\n"  "${release_comments}"
	    printf "  Delete  : %20s\n"  "${delete_release}"
	    printf "> -------------------------------------------------------------\n";
	    if [[ ${delete_release} == "delete" ]]; then
		git checkout master
		git tag -d ${release_tag}
		git branch -d ${release_branch}
		git_branch_tag_status
	    else
		git checkout -b ${release_branch}
		git tag -a ${release_tag} -m "${release_comments}"
		git_branch_tag_status
	    fi
	    popd
	    printf "> -------------------------------------------------------------\n";
	    printf ">> Exiting from %s\n" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	
    done
}



function release_require
{
    local release_file="${1}";
    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
	
    local delete_release="${2}"; 
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    local release_comments="$(read_file_get_string "${release_file}" "RELEASE_COMMENTS:=")";
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}
    
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    printf "\n> -------------------------------------------------------------\n";
	    printf ">> %2d : Entering into %s\n" "$i" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    printf "* Release Branch and Tag to the remote .... \n";
	    printf "  Branch  : %20s\n"  "${release_branch}"
	    printf "  Tag     : %20s\n"  "${release_tag}"
	    printf "  Comment : %40s\n"  "${release_comments}"
	    printf "  Delete  : %20s\n"  "${delete_release}"
	    printf "> -------------------------------------------------------------\n";
	    if [[ ${delete_release} == "delete" ]]; then
		git checkout master
		git tag -d ${release_tag}
		git branch -d ${release_branch}
		git_branch_tag_status
	    else
		git checkout -b ${release_branch}
		git tag -a ${release_tag} -m "${release_comments}"
		git_branch_tag_status
	    fi
	    popd
	    printf "> -------------------------------------------------------------\n";
	    printf ">> Exiting from %s\n" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	
    done
}


function release_modules
{
    local release_file="${1}";
    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
    local delete_release="${2}";
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    local release_comments="$(read_file_get_string "${release_file}" "RELEASE_COMMENTS:=")";
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}
    
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    printf "\n> -------------------------------------------------------------\n";
	    printf ">> %2d : Entering into %s\n" "$i" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    printf "* Release Branch and Tag to the remote .... \n";
	    printf "  Branch  : %20s\n"  "${release_branch}"
	    printf "  Tag     : %20s\n"  "${release_tag}"
	    printf "  Comment : %40s\n"  "${release_comments}"
	    printf "  Delete  : %20s\n"  "${delete_release}"
	    printf "> -------------------------------------------------------------\n";

	    if [[ ${delete_release} == "delete" ]]; then
		git checkout master
		git tag -d ${release_tag}
		git branch -d ${release_branch}
		git_branch_tag_status
	    else
		git checkout -b ${release_branch}
		git tag -a ${release_tag} -m "${release_comments}"
		git_branch_tag_status
	    fi
	    
	    popd

	    printf "> -------------------------------------------------------------\n";
	    printf ">> Exiting from %s\n" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	
    done
}


function release_e3
{
    local release_file="${1}";
    
    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
    
    local delete_release="${2}"; 
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    local release_comments="$(read_file_get_string "${release_file}" "RELEASE_COMMENTS:=")";
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}
    local dep=${SC_TOP};
    
    pushd ${dep}
    printf "\n> -------------------------------------------------------------\n";
    printf ">> %2d : Entering into %s\n" "$i" "${dep}";
    printf "> -------------------------------------------------------------\n";
    printf "* Release Branch and Tag to the remote .... \n";
    printf "  Branch  : %20s\n"  "${release_branch}"
    printf "  Tag     : %20s\n"  "${release_tag}"
    printf "  Comment : %40s\n"  "${release_comments}"
    printf "  Delete  : %20s\n"  "${delete_release}"
    printf "> -------------------------------------------------------------\n";
    if [[ ${delete_release} == "delete" ]]; then
	git checkout master
	git tag -d ${release_tag}
	git branch -d ${release_branch}
	git_branch_tag_status
    else
	git checkout -b ${release_branch}
	git tag -a ${release_tag} -m "${release_comments}"
	git_branch_tag_status
    fi
    popd
    printf "> -------------------------------------------------------------\n";
    printf ">> Exiting from %s\n" "${dep}";
    printf "> -------------------------------------------------------------\n";

}





function git_push_release_base
{
    local release_file="${1}";

    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
    
    #    local delete_release="${2}";
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    #   local release_comments="$(read_file_get_string "${release_file}" "RELEASE_COMMENTS:=")";
    
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}

    local i;
    let i=0
	
    for rep in  ${base_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    printf "\n> -------------------------------------------------------------\n";
	    printf ">> %2d : Entering into %s\n" "$i" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    printf "* Release Branch and Tag to the remote .... \n";
	    printf "  Branch : %20s\n"  "${release_branch}"
	    printf "  Tag    : %20s\n"  "${release_tag}"
	    printf "> -------------------------------------------------------------\n";
	    printf "* Remote Information :\n";
	    git remote -v
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_branch}";
	    git push origin ${release_branch}
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_tag}";
	    git push origin ${release_tag}
	    printf "> -------------------------------------------------------------\n";
	    printf ">> Exiting from %s\n" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    popd
	    ((++i))
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
    done
    
}






function git_push_release_require
{
    local release_file="${1}";

    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
    #    local delete_release="${2}";
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    #   local release_comments="$(read_file_get_string "${release_file}" "RELEASE_COMMENTS:=")";
    
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}

    local i;
    let i=0
    
    for rep in  ${require_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    printf "\n> -------------------------------------------------------------\n";
	    printf ">> %2d : Entering into %s\n" "$i" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    printf "* Release Branch and Tag to the remote .... \n";
	    printf "  Branch : %20s\n"  "${release_branch}"
	    printf "  Tag    : %20s\n"  "${release_tag}"
	    printf "> -------------------------------------------------------------\n";
	    printf "* Remote Information :\n";
	    git remote -v
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_branch}";
	    git push origin ${release_branch}
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_tag}";
	    git push origin ${release_tag}
	    printf "> -------------------------------------------------------------\n";
	    printf ">> Exiting from %s\n" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    popd
	    ((++i))
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
    done
    
}




function git_push_release_modules
{
    local release_file="${1}";

    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
	
    #    local delete_release="${2}";
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    #   local release_comments="$(read_file_get_string "${release_file}" "RELEASE_COMMENTS:=")";
    
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}

    local i;
    let i=0
	
    for rep in  ${module_list[@]}; do
	if [[ $(checkIfDir "${rep}") -eq "$EXIST" ]]; then
	    pushd ${rep}
	    printf "\n> -------------------------------------------------------------\n";
	    printf ">> %2d : Entering into %s\n" "$i" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    printf "* Release Branch and Tag to the remote .... \n";
	    printf "  Branch : %20s\n"  "${release_branch}"
	    printf "  Tag    : %20s\n"  "${release_tag}"
	    printf "> -------------------------------------------------------------\n";
	    printf "* Remote Information :\n";
	    git remote -v
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_branch}";
	    git push origin ${release_branch}
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_tag}";
	    git push origin ${release_tag}
	    printf "> -------------------------------------------------------------\n";
	    printf ">> Exiting from %s\n" "${rep}";
	    printf "> -------------------------------------------------------------\n";
	    popd
	    ((++i))
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
    done
    
}




function git_push_release_e3
{
    local release_file="${1}";

    if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
	die 1 "ERROR at ${FUNCNAME[*]} : we cannot find the input file >>${release_file}<<";
    fi
    
    local e3_version="$(read_file_get_string       "${release_file}" "E3_VERSION:=")";
    local e3_revision="$(read_file_get_string      "${release_file}" "E3_REVISION:=")";
    local e3_modification="$(read_file_get_string  "${release_file}" "E3_MODIFICATION:=")";
    local e3_patch_level="$(read_file_get_string   "${release_file}" "E3_PATCH_LEVEL:=")";
    
    local release_branch=R${e3_version}.${e3_revision};
    local release_tag=${release_branch}.${e3_modification}.${e3_patch_level}
    local rep=${SC_TOP};
    
    pushd ${rep}
    printf "\n> -------------------------------------------------------------\n";
    printf ">> %2d : Entering into %s\n" "$i" "${rep}";
    printf "> -------------------------------------------------------------\n";
    printf "* Release Branch and Tag to the remote .... \n";
    printf "  Branch : %20s\n"  "${release_branch}"
    printf "  Tag    : %20s\n"  "${release_tag}"
    printf "> -------------------------------------------------------------\n";
    printf "* Remote Information :\n";
    git remote -v
    printf "> -------------------------------------------------------------\n";
    printf " * cmd : git push origin %s\n" "${release_branch}";
    git push origin ${release_branch}
    printf "> -------------------------------------------------------------\n";
    printf " * cmd : git push origin %s\n" "${release_tag}";
    git push origin ${release_tag}
    printf "> -------------------------------------------------------------\n";
    printf ">> Exiting from %s\n" "${rep}";
    printf "> -------------------------------------------------------------\n";
    popd
    
}



# Mantatory 'afile' should be in e3 directory
# input arg should 'target_path/afile'
# For exmaple, 
# ./maintain_e3.bash copy "configure/E3/DEFINES_FT"
# in this case,
# DEFINES_FT should be in E3
# 
function copy_a_file
{
    local rep;
    local input=$1; shift;
    local afile=${input##*/};
    local target=${input%/*}
    
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	echo ""
	echo "copy ../${afile} to ${target}/ in $rep"
	cp ../${afile} ${target}/
	popd
    done
}

function append_afile_to_bfile
{
    local rep;
    local afile=$1; shift;
    local bfile=$1; shift;

    for rep in  ${module_list[@]}; do
	pushd ${rep}
	echo ""
	echo ">> append $afile to $bfile in $rep"
	cat ${SC_TOP}/$afile >> $bfile
	popd
    done  
}



function print_version_info_base
{
    local rep;
    local conf_mod="";
    local epics_base_tag=""
    local e3_base_version="";
    local base_prefix="R";
    if [[ $(checkIfFile "${conf_mod}") -eq "$NON_EXIST" ]]; then
	conf_mod="e3-env/e3-env";
    else
	conf_mod="configure/CONFIG_BASE";
    fi	

    for rep in  ${base_list[@]}; do
	pushd ${rep}
	if [[ $(checkIfFile "configure/CONFIG_BASE") -eq "$NON_EXIST" ]]; then
	    epics_base_tag="$(read_file_get_string   "${conf_mod}" "EPICS_BASE_TAG=")"
	    e3_base_version=${epics_base_tag%${base_prefix}}
	else
	    epics_base_tag="$(read_file_get_string   "${conf_mod}" "EPICS_BASE_TAG:=")"
	    e3_base_version="$(read_file_get_string    "${conf_mod}" "E3_BASE_VERSION:=")"
	fi	    					    
	printf "\n"
	printf ">> %s\n" "${rep}"
	printf "   EPICS_BASE_TAG  : %s\n" "${epics_base_tag}"
	printf "   E3_BASE_VERSION : %s\n" "${e3_base_version}"
	branch_info=$(git rev-parse --abbrev-ref HEAD);
	printf "   E3 Branch         : %s\n" "${branch_info}"
	tag_info=$(git tag --points-at HEAD)
	printf "   E3 Tag            : %s\n" "${tag_info}"
	popd
    done
}




function print_version_info_require
{
    local rep;
    local conf_mod="";
    local epics_version=""
    local epics_module_tag=""
    local e3_version="0";
    if [[ $(checkIfFile "${conf_mod}") -eq "$NON_EXIST" ]]; then
	conf_mod="e3-env/e3-env";
    else
	conf_mod="configure/CONFIG_MODULE";
    fi	

    for rep in  ${require_list[@]}; do
	pushd ${rep}
	if [[ $(checkIfFile "configure/CONFIG_MODULE") -eq "$NON_EXIST" ]]; then
	    epics_module_tag="$(read_file_get_string   "${conf_mod}" "REQUIRE_MODULE_TAG:=")"
	    e3_version="$(read_file_get_string      "${conf_mod}" "REQUIRE_VERSION:=")"
	else
	    epics_module_tag="$(read_file_get_string   "${conf_mod}" "EPICS_MODULE_TAG:=")"
	    e3_version="$(read_file_get_string      "${conf_mod}" "E3_MODULE_VERSION:=")"
	fi	    					    
	printf "\n"
	printf ">> %s\n" "${rep}"
	printf "   EPICS_MODULE_TAG  : %s\n" "${e3_module_tag}"
	printf "   E3_MODULE_VERSION : %s\n" "${e3_version}"
	branch_info=$(git rev-parse --abbrev-ref HEAD);
	printf "   E3 Branch         : %s\n" "${branch_info}"
	tag_info=$(git tag --points-at HEAD)
	printf "   E3 Tag            : %s\n" "${tag_info}"
	popd
    done
}





function print_version_info_modules
{
    local rep;
    local conf_mod="";
    local epics_module_tag=""
    local e3_version=""
    local e3_version="0";
    if [[ $(checkIfFile "${conf_mod}") -eq "$NON_EXIST" ]]; then
	conf_mod="configure/CONFIG";
    else
	conf_mod="configure/CONFIG_MODULE";
    fi	

    for rep in  ${module_list[@]}; do
	pushd ${rep}
	if [[ $(checkIfFile "configure/CONFIG_MODULE") -eq "$NON_EXIST" ]]; then
	    epics_module_tag="$(read_file_get_string   "${conf_mod}" "export EPICS_MODULE_TAG:=")"
	    e3_version="$(read_file_get_string      "${conf_mod}" "export LIBVERSION:=")"
	else
	    epics_module_tag="$(read_file_get_string   "${conf_mod}" "EPICS_MODULE_TAG:=")"
	    e3_version="$(read_file_get_string      "${conf_mod}" "E3_MODULE_VERSION:=")"
	fi	    					    
	printf "\n"
	printf ">> %s\n" "${rep}"
	printf "   EPICS_MODULE_TAG  : %s\n" "${epics_module_tag}"
	printf "   E3_MODULE_VERSION : %s\n" "${e3_version}"
	branch_info=$(git rev-parse --abbrev-ref HEAD);
	printf "   E3 Branch         : %s\n" "${branch_info}"
	tag_info=$(git tag --points-at HEAD)
	printf "   E3 Tag            : %s\n" "${tag_info}"
	popd
    done
}



function print_version_info_e3
{
    local rep=${SC_TOP};
    
    pushd ${rep}
    printf ">> %s\n" "${rep}"
    branch_info=$(git rev-parse --abbrev-ref HEAD);
    printf "   E3 Branch         : %s\n" "${branch_info}"
    tag_info=$(git tag --points-at HEAD)
    printf "   E3 Tag            : %s\n" "${tag_info}"
    printf "   E3 Release        : \n";
    tree -L 2 release_*
    popd
}





function usage
{
    usage_title;
    usage_mod;
    {
	
	echo " < option > ";
	echo "";
      
	echo "           env     : Print enabled Modules";
	echo "           version : Print all module versions";
       	echo "           pull    : git pull in all modules"           
	echo "           push    : git push in all modules"
	echo " "
	echo "           others  : LOOK at $0 for Examples"
	echo ""
	echo "  Examples : ";
	echo ""    
	echo "          $0 env";
	echo "          $0 -g all env";
	echo "          $0 ver";
	echo "          $0 -g common ver";
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
    pull)
	# git pull for selected modules
	git_pull_modules
	;;
    diff)
	# check diff $2
	# git diff $2 for selected modules
	git_diff "$2" 
	;;
    add)
	# add $2 into repo for selected modules
	# git add $2
	git_add "$2"
	;;
    commit)
	# write commit messages for selected modules
	# git commit -m "$2"
	git_commit "$2"
	;;
    push)
	# git push for selected modules
	git_push
	;;
    copy)
	# Example, for copy
	# 
	# Define the target directory in each module
	# $ scp  e3-iocStats/configure/E3/DEFINES_FT .
	# $ ./maintain_e3.bash -g ifc copy "configure/E3/DEFINES_FT"
	# $ ./maintain_e3.bash -g ifc diff "configure/E3/DEFINES_FT"
	# $ ./maintain_e3.bash -g ifc add "configure/E3/DEFINES_FT"
	# $ ./maintain_e3.bash -g ifc commit "fix patch function"
	# $ ./maintain_e3.bash -g ifc push
	copy_a_file "$2"
	;;
    append)
	# Example, for append
	#
	# $ ./maintain_e3.bash -g ecat append template/configure_module_local.txt "configure/CONFIG_MODULE"
	# $ ./maintain_e3.bash -g ecat append template/configure_module_dev_local.txt "configure/CONFIG_MODULE_DEV"
	# $ ./maintain_e3.bash -g ecat append template/release_local.txt "configure/RELEASE"
	# $ ./maintain_e3.bash -g ecat append template/release_dev_local.txt "configure/RELEASE_DEV"
	#
	# $ ./maintain_e3.bash -g ecat diff "configure/RELEASE_DEV"
	# OR
	# $ ./maintain_e3.bash -g ecat diff
	#
	# $ ./maintain_e3.bash -g ecat add "configure/CONFIG_MODULE"
	# $ ./maintain_e3.bash -g ecat add "configure/CONFIG_MODULE_DEV"
	# $ ./maintain_e3.bash -g ecat add "configure/RELEASE"
	# $ ./maintain_e3.bash -g ecat add "configure/RELEASE_DEV"
	#
	# $ ./maintain_e3.bash -g ecat  commit  "support local release, release_dev, config_module, and config_module_dev"
	#
	# $ ./maintain_e3.bash -g ecat push
	append_afile_to_bfile "$2" "$3"
	;;
    ver)
	# print epics tags and e3 version for selected modules
	print_version_info_e3
	print_version_info_base
	print_version_info_require
	print_version_info_modules
	;;
    ver_base)
	print_version_info_base
	;;
    ver_req)
	print_version_info_require
	;;
    ver_mod)
	print_version_info_modules
	;;
    ver_e3)
	print_version_info_e3
	;;
    r_base)
	release_base "$2" 
	;;
    rd_base)
	release_base "$2" "delete"
	;;
    gpr_base)
	git_push_release_base "$2"
	;;
    r_req)
	release_require "$2" 
	;;
    rd_req)
	release_require "$2" "delete"
	;;
    gpr_req)
	git_push_release_require "$2"
	;;
    r_mod)
	release_modules "$2" 
	;;
    rd_mod)
	release_modules "$2" "delete"
	;;
    gpr_mod)
	git_push_release_modules "$2"
	;;
    r_e3)
	release_e3 "$2" 
	;;
    rd_e3)
	release_e3 "$2" "delete"
	;;
    gpr_e3)
	git_push_release_e3 "$2";
	;;
    *)
	usage
	;;
esac

exit 0;





