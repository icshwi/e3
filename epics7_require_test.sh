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
# Date    : Tuesday, September 18 13:09:06 CEST 2018
# version : 0.0.1

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -g TARGET="";

options="t:"


while getopts "${options}" opt; do
    case "${opt}" in
        t)
            TARGET=${OPTARG} ;
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

VERSION="7.0.1.1"
REQUIRE_VERSION="3.0.2"
SEQ_VERSION="2.2.6"


epics_base="${TARGET}/base-${VERSION}"

config_base="
E3_EPICS_PATH:=${TARGET}
EPICS_BASE_TAG:=tags/R${VERSION}
E3_BASE_VERSION:=${VERSION}
E3_CROSS_COMPILER_TARGET_ARCHS ="



cat > CONFIG_BASE.local <<EOF
$config_base
EOF

cat CONFIG_BASE.local


require_dev="
EPICS_BASE:=${epics_base}
E3_REQUIRE_VERSION:=${REQUIRE_VERSION}
#E3_SEQUENCER_NAME:=sequencer
E3_SEQUENCER_VERSION:=${SEQ_VERSION}"

cat > RELEASE_DEV.local <<EOF
$require_dev
EOF

cat RELEASE_DEV.local


release="
EPICS_BASE:=${epics_base}
E3_REQUIRE_VERSION:=${REQUIRE_VERSION}
#E3_SEQUENCER_NAME:=sequencer
E3_SEQUENCER_VERSION:=${SEQ_VERSION}"


cat > RELEASE.local <<EOF
$release
EOF

cat RELEASE.local


echo ""
echo "Replace sequencer from 2.1 to 2.2"

sed -i 's/#e3-seq/e3-seq/g'             configure/MODULES_COMMON
sed -i 's/e3-sequencer/#e3-sequencer/g' configure/MODULES_COMMON


echo "Please run the following commands"
echo "bash e3.bash base"
echo "bash e3.bash devreq"
echo "bash e3.bash -ctifealb mod"


git config --global url."git@bitbucket.org:".insteadOf https://bitbucket.org/
git config --global url."git@gitlab.esss.lu.se:".insteadOf https://gitlab.esss.lu.se/

