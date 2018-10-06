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
# Date    : Saturday, October  6 14:12:45 CEST 2018
# version : 0.0.7

#           0.0.7 : seperate BASE_VERSION and BASE_TAG in order to handle Release Candidate (RC)
#                 

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -g TARGET="";
declare -g BASE_VERSION="";
declare -g REQUIRE_VERSION="";
declare -g SQU_VERSION="";
declare -g BASE_TAG="";



declare -gr DEFAULT_TARGET_PATH="/epics"
declare -gr DEFAULT_BASE_VERSION="3.15.5"
declare -gr DEFAULT_REQ_VERSION="3.0.2"
declare -gr DEFAULT_SEQ_VERSION="2.1.21"


function yes_or_no_to_go() {

    printf  "> \n";
    printf  "> This procedure could help users to setup \n"
    printf  "> configuration for e3 installation.\n"
    printf  "> \n";
    read -p ">> Do you want to continue (y/n)? " answer
    case ${answer:0:1} in
	y|Y )
	    print_options
	    ;;
	* )
            printf ">> Stop here. \n";
	    exit;
    ;;
    esac

}



function usage
{
    {
	echo "";
	echo "Usage    : $0 [-t <target_path>] [-b <base_version>] [-r <require_version>] [-c <base_tag>] setup" ;
	echo "";
	echo "               -t : default ${DEFAULT_TARGET_PATH}"
	echo "               -b : default ${DEFAULT_BASE_VERSION}"
	echo "               -r : default ${DEFAULT_REQ_VERSION}"
	echo "               -c : default ${DEFAULT_BASE_VERSION}"
	echo "";
	echo " bash $0 -t /epics/test/ -r 3.0.0"
	echo ""
	
    } 1>&2;
    exit 1; 
}


function print_options
{
    printf "\n"
    printf ">> Set the global configuration as follows:\n";
    printf ">>\n";
    printf "  EPICS TARGET        : %s\n" "${TARGET}"
    printf "  EPICS_BASE VERSION  : %s\n" "${BASE_VERSION}"
    printf "  E3_REQUIRE_VERSION  : %s\n" "${REQUIRE_VERSION}"
    printf "  EPICS_MODULE_TAG    : %s\n" "${BASE_TAG}"
    printf "  EPICS_BASE          : %s\n" "${EPICS_BASE_TARGET}"
    printf "  E3_REQUIRE_LOCATION : %s\n" "${REQUIRE_TARGET}"
#    printf "  SEQ VERSION     : %s\n" "${SQU_VERSION}"
}


options=":t:b:r:s:c:h:y"
ANSWER="NO"



while getopts "${options}" opt; do
    case "${opt}" in
        t) TARGET=${OPTARG}       ;;
	b) BASE_VERSION=${OPTARG} ;;
      	r) REQUIRE_VERSION=${OPTARG} ;;
       	s) SQU_VERSION=${OPTARG} ;;
      	c) BASE_TAG=${OPTARG} ;;
	y) ANSWER="YES" ;;
   	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	h)
	    usage
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit
	    ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$TARGET" ]; then
#    printf ">> No TARGET PATH is defined, use the default one %s\n" "${DEFAULT_TAGET_PATH}"
    TARGET=${DEFAULT_TARGET_PATH}
fi

if [ -z "$BASE_VERSION" ]; then
#    printf ">> No BASE version is defined, use the default one %s\n" "${DEFAULT_BASE_VERSION}"
    BASE_VERSION=${DEFAULT_BASE_VERSION}
fi

if [ -z "$REQUIRE_VERSION" ]; then
#    printf ">> No REQUIRE version is defined, use the default one %s\n" "${DEFAULT_REQ_VERSION}"
    REQUIRE_VERSION=${DEFAULT_REQ_VERSION}
fi

if [ -z "$BASE_TAG" ]; then
#    printf ">> No BASE_TAG is defined, use the same as BASE_VERSION %s\n" "${BASE_VERSION}"
    BASE_TAG=${BASE_VERSION}
fi

EPICS_BASE_TARGET=${TARGET}/base-${BASE_VERSION}
REQUIRE_TARGET=${EPICS_BASE_TARGET}/require/${REQUIRE_VERSION}

case "$1" in

    setup)
	if [ "$ANSWER" == "NO" ]; then
	    yes_or_no_to_go
	else
	    print_options
	fi
	;;
    *)
	usage
	;;

esac


exit

epics_base="${TARGET}/base-${BASE_VERSION}"

config_base="
E3_EPICS_PATH:=${TARGET}
EPICS_BASE_TAG:=tags/R${BASE_TAG}
E3_BASE_VERSION:=${BASE_VERSION}
#E3_CROSS_COMPILER_TARGET_ARCHS =
"

rm ${SC_TOP}/CONFIG_BASE.local
cat > ${SC_TOP}/CONFIG_BASE.local <<EOF
$config_base
EOF

echo ""
echo ">>> EPICS BASE Configuration "
echo ""
echo ">>> CONFIG_BASE.local"
cat ${SC_TOP}/CONFIG_BASE.local
echo ">>>"

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
    printf "Switch sequrencer to 2.1\n"
    
    sed -i 's/^e3-seq/#e3-seq/g'             ${SC_TOP}/configure/MODULES_COMMON
    sed -i 's/^#e3-sequencer/e3-sequencer/g' ${SC_TOP}/configure/MODULES_COMMON

    cat ${SC_TOP}/configure/MODULES_COMMON
      if [ -z "$SEQ_VERSION" ]; then
	  SEQ_VERSION=${DEFAULT_SEQ_VERSION}
      fi
else
    printf "Don't support it\n";
    exit
fi


config_require="
EPICS_MODULE_TAG:=tags/v${REQUIRE_VERSION}
"

rm -f ${SC_TOP}/REQUIRE_CONFIG_MODULE.local
cat > ${SC_TOP}/REQUIRE_CONFIG_MODULE.local <<EOF
$config_require
EOF

echo ">>> REQUIRE_CONFIG_MODULE"
cat ${SC_TOP}/REQUIRE_CONFIG_MODULE.local
echo ">>>"



release="
EPICS_BASE:=${epics_base}
E3_REQUIRE_VERSION:=${REQUIRE_VERSION}
#E3_SEQUENCER_NAME:=sequencer
E3_SEQUENCER_VERSION:=${SEQ_VERSION}
"

rm ${SC_TOP}/RELEASE.local
cat > ${SC_TOP}/RELEASE.local <<EOF
$release
EOF
echo ">>> RELEASE.local"
cat ${SC_TOP}/RELEASE.local
echo ">>>"



echo ""
echo ">>> Run the following..."
echo "bash e3.bash base"
echo "bash e3.bash req"
echo "bash e3.bash -c mod"


exit $?
