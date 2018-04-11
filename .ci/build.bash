#!/bin/bash

declare -ga require_list=("e3-base" "e3-require")


function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }




GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"
BOOL_GIT_CLONE="TRUE"

declare -ga require_list=("e3-base" "e3-require")

declare -ga module_list=()

declare -g  env="e3-env"



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

function print_list
{
    local array=$1; shift;
    for a_list in ${array[@]}; do
	printf " %s\n" "$a_list";
    done
}




module_list=$(get_module_list configure/MODULES)

print_list "${module_list[@]}"

git clone ${GIT_URL}/e3-base
cd e3-base
git submodule init e3-env
git submodule update --init --recursive e3-env
git submodule update --remote --merge e3-env

git submodule init pkg_automation
git submodule update --init --recursive pkg_automation
git submodule update --remote --merge pkg_automation


git submodule init epics-base
git submodule update --init --recursive epics-base


make env
make build || die 3 "$BUILD ERROR : ${rep} "  ;
make install || die 4 "INSTALLL ERROR : Please check ${rep} "  ;
