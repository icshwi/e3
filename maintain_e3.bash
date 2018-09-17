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
#   date    : Monday, September 17 11:24:47 CEST 2018
#   version : 0.3.6

# Example, how to use
#
# This script is used to copy a file to all modules directory, and
# prepare all git commands together.
# 

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

declare -ga base_list=("e3-base")
declare -ga require_list=("e3-require")
declare -ga module_list=()


. ${SC_TOP}/.cfgs/.e3_functions.cfg
. ${SC_TOP}/.cfgs/.e3_modules_list.cfg

   


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
		git branch -D ${release_branch}
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
		git branch -D ${release_branch}
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
		git branch -D ${release_branch}
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
    
    local i;
    let i=0
    
    for rep in  ${module_list[@]}; do
	pushd ${rep}
	echo ""
	echo "$i : Copy ../${afile} to ${target}/ in $rep"
	cp ../${afile} ${target}/
	popd
	((++i))
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


function usage
{
    usage_title;
    usage_mod;
    {
	
	echo " < option > ";
	echo "";
      
	echo "           env    : Print enabled Modules";
	echo "";
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
	echo "           others: LOOK at $0 for Examples"
	echo ""
	echo "  Examples : ";
	echo ""    
	echo "          $0 env";
	echo "          $0 -ctifealb env";
	echo "   ";       
	echo "";
	
    } 1>&2;
    exit 1; 
}


while getopts "${options}" opt; do
    case "${opt}" in
	c) common="1"  ;;
	t) timing="1"  ;;
	i) ifcfree="1" ;;
	f) ifcnfree="1";;
	e) ecat="1"    ;;
	a) area="1"    ;;
	l) llrf="1"    ;;
	b) bi="1"      ;;
	4) epicsv4="1" ;;
	d) develop="1" ;;
	o) only="1"    ;;
	*) usage ;;
    esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list

module_list_func

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
    env) print_module_list ;;
    # git pull for selected modules
    pull) git_pull_modules ;;
    # ./maintain_e3.bash -g all cat configure/E3/RULES_PATCH
    cat)      cat_file "$2"     ;;
    diff)     git_diff "$2"  	;;
    checkout) git_checkout "$2" ;;
    add)      git_add "$2"      ;;
    rm)       git_rm "$2"       ;;
    commit)   git_commit "$2" 	;;
    # git push for selected modules
    push)       git_push            ;;
    # merge_ours) git_merge_ours_donot_use ;;
    status)       git_status            ;;
    # merge_ours) git_merge_ours_donot_use ;;
    # Disable it, because it is not general purpose
    #    delete_lines) delete_lines_starting_from "$2"  ;;
    copy)
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
    # Relaese 
    r_base)   release_base    "$2" ;;
    r_req)    release_require "$2" ;;
    r_mod)    release_modules "$2" ;;
    # Delete Release 
    rd_base)  release_base    "$2" "delete" ;;
    rd_req)   release_require "$2" "delete" ;;
    rd_mod)   release_modules "$2" "delete" ;;
    # git push release 
    gpr_base) git_push_release_base    "$2" ;;
    gpr_req)  git_push_release_require "$2" ;;
    gpr_mod)  git_push_release_modules "$2" ;;
    # 
    r_e3)     release_e3 "$2"  ;; 
    rd_e3)    release_e3 "$2" "delete" ;;
    gpr_e3)   git_push_release_e3 "$2" ;;

    # Git Checkout 
    co_base) git_checkout_base    "$2";;
    co_req)  git_checkout_require "$2";;
    co_mod)  git_checkout_modules "$2";;
    co_all)  git_checkout_all     "$2";;
    # Print Version Information in e3-* directory
     vbase)  print_version_info_base    ;;
      vreq)  print_version_info_require ;;
      vmod)  print_version_info_modules ;;
      vall)  print_version_info_all     ;;
    # Call *make vars in each e3-* directory
    allall)  print_version_really_everything   ;;
       ve3)  print_version_info_e3      ;;
         *)  usage                      ;;
esac

exit 0;





