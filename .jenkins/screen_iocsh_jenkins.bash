#!/bin/bash

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"


E3_PATH=$1
BASE=$2
REQUIRE=$3

SESSION="${BASE}-${REQUIRE}"

. ${E3_PATH}/base-${BASE}/require/${REQUIRE}/bin/setE3Env.bash

bash ${SC_TOP}/screen_jenkins.bash ${SESSION} ${SC_TOP}/../.cmd
