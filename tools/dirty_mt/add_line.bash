#!/bin/bash

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


module_a=$1

pushd $module_a

emacs configure/E3/RULES_E3

git diff

make

git add configure/E3/RULES_E3
git commit -m "add default rule"
git push

popd


