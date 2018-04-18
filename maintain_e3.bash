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
#   date    : Wednesday, April 18 22:29:16 CEST 2018
#   version : 0.0.5


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

function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


declare -ga base_list=("e3-base")
declare -ga require_list=("e3-require")

declare -ga module_list=()


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


function read_file_get_string
{
    local FILENAME=$1
    local PREFIX=$2

    local val=""
    while read line; do
	if [[ $line =~ "${PREFIX}" ]] ; then
	    val=${line#$PREFIX}
	fi
    done < ${FILENAME}

    echo "$val"
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


function read_file_get_string
{
    local FILENAME=$1
    local PREFIX=$2

    local val=""
    while read line; do
	if [[ $line =~ "${PREFIX}" ]] ; then
	    val=${line#$PREFIX}
	fi
    done < ${FILENAME}

    echo "$val"
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
	    echo "${rep}"
	    printf "Release Branch : %40s\n"  "${release_branch}"
	    printf "Release tag    : %40s\n"  "${release_tag}"
	    printf "Release comment: %40s\n"  "${release_comments}"
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
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	
    done
}



function release_require
{
    local release_file="${1}";
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
	    echo "${rep}"
	    printf "Release Branch : %40s\n"  "${release_branch}"
	    printf "Release tag    : %40s\n"  "${release_tag}"
	    printf "Release comment: %40s\n"  "${release_comments}"
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
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	
    done
}


function release_modules
{
    local release_file="${1}";
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
	    echo "${rep}"
	    printf "Release Branch : %40s\n"  "${release_branch}"
	    printf "Release tag    : %40s\n"  "${release_tag}"
	    printf "Release comment: %40s\n"  "${release_comments}"
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
	else
	    die 1 "${FUNCNAME[*]} : ${rep} doesn't exist";
	fi
	
    done
}



function git_push_release_base
{
    local release_file="${1}";
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
	    echo "git push origin ${release_branch}"
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_tag}";
	    echo "git push origin ${release_tag}"
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
	    echo "git push origin ${release_branch}"
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_tag}";
	    echo "git push origin ${release_tag}"
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
	    echo "git push origin ${release_branch}"
	    printf "> -------------------------------------------------------------\n";
	    printf " * cmd : git push origin %s\n" "${release_tag}";
	    echo "git push origin ${release_tag}"
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


# this function has some issue to print array, beaware it.

# function print_list
# {
#     local array=$1; shift;
#     for a_list in ${array[@]}; do
# 	printf " %s\n" "$a_list";
#     done
# }


function print_list
{
    local a_list;
    for a_list in ${module_list[@]}; do
	printf " %s\n" "$a_list";
    done
}

function git_pull
{
    local rep;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	echo ""
	echo ">> git pull in ${rep}"
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
	echo ""
	echo ">> git add ${git_add_file} in ${rep}"
	git add ${git_add_file}
	popd
    done
}
   
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


function git_commit
{
    local rep;
    local git_commit_comment=$1; shift;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	echo ""
	echo ">> git commit -m ${git_commit_comment} in $rep"
	git commit -m "${git_commit_comment}"
	popd
    done
}


function git_push
{
    local rep;
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	echo ""
	echo ">> git push in $rep"
	git push
	popd
    done
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


function print_version_info
{
    local rep;
    local conf_mod="configure/CONFIG_MODULE";
    local epics_version=""
    local e3_version=""
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	epics_version="$(read_file_get_string   "${conf_mod}" "EPICS_MODULE_TAG:=")"
	e3_version="$(read_file_get_string      "${conf_mod}" "E3_MODULE_VERSION:=")"
	echo ""
	echo ">> ${rep}"
	echo "   EPICS_MODULE_TAG  : ${epics_version}"
	echo "   E3_MODULE_VERSION : ${e3_version}"
	popd
    done
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
	echo "           timing : mrf timing    modules";
	echo "           ifc    : ifc platform  related modules";
	echo "           ecat   : ethercat      related modules";
	echo "           area   : area detector related modules";
	echo "           test   : common, timing, ifc modules";
	echo "           jhlee  : common, timing, ifc, area modules";
	echo "           all    : common, timing, ifc, ecat, area modules";
	echo "";
	
	echo " < option > ";
	echo "";
      
	echo "           env     : Print all modules";
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
	echo "          $0 version";
	echo "          $0 -g common version";
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
    #  	usage
	;;
    # ;;
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
    env)
	echo ">> Vertical display for the selected modules :"
	echo ""
	print_list
	echo ""
	;;
    pull)
	# git pull for selected modules
	git_pull
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
    version)
	# print epics tags and e3 version for selected modules
	print_version_info
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
    *)
	usage
	;;
esac

exit 0;





