#!/bin/bash
#
#  Copyright (c) 2018 Jeong Han Lee
#  Copyright (c) 2018 European Spallation Source ERIC
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
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Tuesday, September 18 19:51:22 CEST 2018
# version : 0.0.2

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -g TARGET="";

options="t:b:r:s:"


while getopts "${options}" opt; do
    case "${opt}" in
        t)
            TARGET=${OPTARG} ;
            ;;
	b)
	    BASE_VERSION=${OPTARG} ;
            ;;
	r)
	    REQUIRE_VERSION=${OPTARG} ;
            ;;
	s)
	    SQU_VERSION=${OPTARG} ;
            ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit
	    ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$TARGET" ]; then
    TARGET="/epics"
fi

if [ -z "$BASE_VERSION" ]; then
    BASE_VERSION="3.15.5"
fi

if [ -z "$REQUIRE_VERSION" ]; then
    REQUIRE_VERSION="3.0.0"
fi


epics_base="${TARGET}/base-${BASE_VERSION}"

config_base="
E3_EPICS_PATH:=${TARGET}
EPICS_BASE_TAG:=tags/R${BASE_VERSION}
E3_BASE_VERSION:=${BASE_VERSION}
#E3_CROSS_COMPILER_TARGET_ARCHS =
"



cat > CONFIG_BASE.local <<EOF
$config_base
EOF

cat CONFIG_BASE.local


epics7string="7."
epics315string="3.15."
printf "EPICS %s is detected\n" "${BASE_VERSION}"
printf "\n";

if test "${BASE_VERSION#*$epics7string}" != "$BASE_VERSION"; then

 
    printf "Switch sequrencer to 2.2\n"
    
    sed -i 's/^#e3-seq/e3-seq/g'             ${SC_TOP}/configure/MODULES_COMMON
    sed -i 's/^e3-sequencer/#e3-sequencer/g' ${SC_TOP}/configure/MODULES_COMMON

    cat ${SC_TOP}/configure/MODULES_COMMON
    if [ -z "$SEQ_VERSION" ]; then
	SEQ_VERSION="2.2.6"
    fi
elif test "${BASE_VERSION#*$epics315string}" != "$BASE_VERSION"; then
    printf "EPICS %s is detected\n" "${BASE_VERSION}"
    printf "\n";
    printf "Switch sequrencer to 2.1\n"
    
    sed -i 's/^e3-seq/#e3-seq/g'             ${SC_TOP}/configure/MODULES_COMMON
    sed -i 's/^#e3-sequencer/e3-sequencer/g' ${SC_TOP}/configure/MODULES_COMMON

    cat ${SC_TOP}/configure/MODULES_COMMON
      if [ -z "$SEQ_VERSION" ]; then
	  SEQ_VERSION="2.1.21"
      fi
else
    printf "Don't support it\n";
    exit
fi





release="
EPICS_BASE:=${epics_base}
E3_REQUIRE_VERSION:=${REQUIRE_VERSION}
#E3_SEQUENCER_NAME:=sequencer
E3_SEQUENCER_VERSION:=${SEQ_VERSION}
"


cat > RELEASE.local <<EOF
$release
EOF

cat RELEASE.local




git config --global url."git@bitbucket.org:".insteadOf https://bitbucket.org/
git config --global url."git@gitlab.esss.lu.se:".insteadOf https://gitlab.esss.lu.se/



echo "Please run the following commands"
echo "bash e3.bash base"
echo "bash e3.bash req"
echo "bash e3.bash -ctifealb mod"


exit
