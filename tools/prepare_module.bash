#!/bin/bash
#
#  Copyright (c) 2017 - Present European Spallation Source ERIC
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
#   date    : Wednesday, October 25 13:30:08 CEST 2017
#   version : 0.0.2

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"
declare -gr SC_USER="$(whoami)"
declare -gr SC_HASH="$(git rev-parse HEAD)"


function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


ICS_GIT_URL="https://github.com/icshwi"
PSI_GIT_URL="https://github.com/paulscherrerinstitute"
EPICS_GIT_URL="https://github.com/epics-modules"
# SEQ is very special module, we cannot access the master one.
# 
BESSY_GIT_URL="http://www-csr.bessy.de/control/SoftDist/sequencer/repo/branch-2-2.git"

GIT_CMD="git"
ENV_MOD_NAME="e3-env"


function git_clone {

    local rep_name=$1
    ${GIT_CMD} clone ${GIT_URL}/$rep_name
    
}


function submodule_add {

    local rep_url=$1
    ${GIT_CMD} submodule add ${rep_url}
    
}


if [[ -z $1 ]]; then
    echo "Usage: $0 *module_name*"
    echo "First create e3-*module_name* in https://github.com/icshwi"
    exit 0;
fi

MODULE_NAME=$1

env_url=${ICS_GIT_URL}/${ENV_MOD_NAME}
mod_url=""
psi_url=${PSI_GIT_URL}/${MODULE_NAME}
epics_url=${EPICS_GIT_URL}/${MODULE_NAME}
bessy_url=${BESSY_GIT_URL}
bessy_url+=" ${MODULE_NAME}"

${GIT_CMD} clone ${ICS_GIT_URL}/e3-${MODULE_NAME}


pushd e3-${MODULE_NAME}

echo $PWD
printf "${env_url} is adding as submodule...\n";
submodule_add "${env_url}"

if [ "${MODULE_NAME}" = "ecat2" ]; then
    mod_url=${psi_url}
elif [ "${MODULE_NAME}" = "seq" ]; then
    mod_url=${bessy_url}
else
    mod_url=${epics_url}
fi

printf "${mod_url} is adding as submodule...\n";
submodule_add "${mod_url}"

sed -i~ "/\\/${ENV_MOD_NAME}/a\\\tignore = dirty" .gitmodules
sed -i~ "/\\/${MODULE_NAME}/a\\\tignore = all" .gitmodules

${GIT_CMD} submodule update --init --recursive --recursive


mkdir -p configure

cat > configure/CONFIG <<EOF
EPICS_MODULE_NAME:=${MODULE_NAME}
# This is the module source tag
# *) individual tags
#    export EPICS_MODULE_TAG:=tags/1.1.1
# *) master branch 
#    export EPICS_MODULE_TAG:=master
# *) individual hash 
export EPICS_MODULE_TAG:=master
export EPICS_MODULE_SRC_PATH:=\$(EPICS_MODULE_NAME)
ESS_MODULE_MAKEFILE:=\$(EPICS_MODULE_NAME).Makefile
export PROJECT:=\$(EPICS_MODULE_NAME)
export LIBVERSION:=0.0.1
export E3_ENV_NAME:=e3-env
#export USR_DEPENDENCIES += xxx,1.1.1
EOF


cat > ${MODULE_NAME}.Makefile <<EOF

#where_am_I := \$(dir \$(abspath \$(lastword \$(MAKEFILE_LIST))))

include \${REQUIRE_TOOLS}/driver.makefile

# 
USR_CFLAGS   += -Wno-unused-variable
USR_CFLAGS   += -Wno-unused-function
USR_CPPFLAGS += -Wno-unused-variable
USR_CPPFLAGS += -Wno-unused-function

#
#
# The following lines must be updated according to your ${MODULE_NAME}
#
# Examples...
# 
# USR_CFLAGS += -fPIC
# USR_CFLAGS   += -DDEBUG_PRINT
# USR_CPPFLAGS += -DDEBUG_PRINT
# USR_CPPFLAGS += -DUSE_TYPED_RSET
# USR_INCLUDES += -I/usr/include/libusb-1.0
# USR_LDFLAGS += -lusb-1.0

# USR_LDFLAGS += -L /opt/etherlab/lib
# USR_LDFLAGS += -lethercat
# USR_LDFLAGS += -Wl,-rpath=/opt/etherlab/lib
#
#
# PCIAPP:= pciApp
#
# HEADERS += \$(PCIAPP)/devLibPCI.h
# HEADERS += \$(PCIAPP)/devLibPCIImpl.h

# SOURCES += \$(wildcard \$(PCIAPP)/devLib*.c)
# SOURCES += \$(PCIAPP)/pcish.c
# SOURCES_Linux += \$(PCIAPP)/os/Linux/devLibPCIOSD.c

# DBDS += \$(PCIAPP)/epicspci.dbd

# MRMSHARED:= mrmShared
# MRMSHAREDSRC:=\${MRMSHARED}/src
# MRMSHAREDDB:=\${MRMSHARED}/Db
# TEMPLATES += \$(wildcard \$(MRMSHAREDDB)/*.db)
# TEMPLATES += \$(wildcard \$(MRMSHAREDDB)/*.template)
# TEMPLATES += \$(wildcard \$(MRMSHAREDDB)/*.substitutions)

EOF


cat > Makefile <<EOF
#
#  Copyright (c) 2017 - Present  European Spallation Source ERIC
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
# Author  : ${SC_USER}
# email   : @esss.se
# Date    : generated by ${SC_LOGDATE}
# version : 0.0.0 
#
# template file is generated by $0 with ${SC_HASH}
#


TOP:=\$(CURDIR)

include \$(TOP)/configure/CONFIG

-include \$(TOP)/\$(E3_ENV_NAME)/\$(E3_ENV_NAME)
-include \$(TOP)/\$(E3_ENV_NAME)/epics-community-env

# Keep always the module up-to-date
define git_update =
@git submodule deinit -f \$@/
git submodule deinit -f \$@/
sed -i '/submodule/,\$\$d'  \$(TOP)/.git/config
rm -rf \$(TOP)/.git/modules/\$@
git submodule init \$@/
git submodule update --init --recursive --recursive \$@/.
git submodule update --remote --merge \$@/
endef

ifndef VERBOSE
  QUIET := @
endif

ifdef DEBUG_SHELL
  SHELL = /bin/sh -x
endif


# Pass necessary driver.makefile variables through makefile options
#
M_OPTIONS := -C \$(EPICS_MODULE_SRC_PATH)
M_OPTIONS += -f \$(ESS_MODULE_MAKEFILE)
M_OPTIONS += LIBVERSION="\$(LIBVERSION)"
M_OPTIONS += PROJECT="\$(EPICS_MODULE_NAME)"
M_OPTIONS += EPICS_MODULES="\$(EPICS_MODULES)"
M_OPTIONS += EPICS_LOCATION="\$(EPICS_LOCATION)"
M_OPTIONS += DEFAULT_EPICS_VERSIONS="\$(DEFAULT_EPICS_VERSIONS)"
M_OPTIONS += BUILDCLASSES="Linux"


# # help is defined in 
# # https://gist.github.com/rcmachado/af3db315e31383502660
help:
	\$(info --------------------------------------- )	
	\$(info Available targets)
	\$(info --------------------------------------- )
	\$(QUIET) awk '/^[a-zA-Z\-\_0-9]+:/ {            \\
	  nb = sub( /^## /, "", helpMsg );              \\
	  if(nb == 0) {                                 \\
	    helpMsg = \$\$0;                              \\
	    nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \\
	  }                                             \\
	  if (nb)                                       \\
	    print  \$\$1 "\t" helpMsg;                    \\
	}                                               \\
	{ helpMsg = \$\$0 }'                              \\
	\$(MAKEFILE_LIST) | column -ts:	



default: help


install: uninstall
	\$(QUIET) sudo -E bash -c 'make \$(M_OPTIONS) install'

## Uninstall "Require" Module in order not to use it
uninstall: conf
	\$(QUIET) sudo -E bash -c 'make \$(M_OPTIONS) uninstall'



## Build the EPICS Module
build: conf
	\$(QUIET) make \$(M_OPTIONS) build

## clean, build, and install again.
rebuild: clean build install

## Clean the EPICS Module
clean: conf
	\$(QUIET) make \$(M_OPTIONS) clean

## Show driver.makefile help
help2:
	\$(QUIET) make \$(M_OPTIONS) help

#
## Initialize EPICS BASE and E3 ENVIRONMENT Module
init: git-submodule-sync \$(EPICS_MODULE_SRC_PATH) \$(E3_ENV_NAME)

git-submodule-sync:
	\$(QUIET) git submodule sync


\$(EPICS_MODULE_SRC_PATH): 
	\$(QUIET) \$(git_update)
	cd \$@ && git checkout \$(EPICS_MODULE_TAG)


\$(E3_ENV_NAME): 
	\$(QUIET) \$(git_update)


## Print EPICS and ESS EPICS Environment variables
env:
	\$(QUIET) echo ""

	\$(QUIET) echo "EPICS_MODULE_SRC_PATH       : "\$(EPICS_MODULE_SRC_PATH)
	\$(QUIET) echo "ESS_MODULE_MAKEFILE         : "\$(ESS_MODULE_MAKEFILE)
	\$(QUIET) echo "EPICS_MODULE_TAG            : "\$(EPICS_MODULE_TAG)
	\$(QUIET) echo "LIBVERSION                  : "\$(LIBVERSION)
	\$(QUIET) echo "PROJECT                     : "\$(PROJECT)

	\$(QUIET) echo ""
	\$(QUIET) echo "----- >>>> EPICS BASE Information <<<< -----"
	\$(QUIET) echo ""
	\$(QUIET) echo "EPICS_BASE_TAG              : "\$(EPICS_BASE_TAG)
#	\$(QUIET) echo "CROSS_COMPILER_TARGET_ARCHS : "\$(CROSS_COMPILER_TARGET_ARCHS)
	\$(QUIET) echo ""
	\$(QUIET) echo "----- >>>> ESS EPICS Environment  <<<< -----"
	\$(QUIET) echo ""
	\$(QUIET) echo "EPICS_LOCATION              : "\$(EPICS_LOCATION)
	\$(QUIET) echo "EPICS_MODULES               : "\$(EPICS_MODULES)
	\$(QUIET) echo "DEFAULT_EPICS_VERSIONS      : "\$(DEFAULT_EPICS_VERSIONS)
	\$(QUIET) echo "BASE_INSTALL_LOCATIONS      : "\$(BASE_INSTALL_LOCATIONS)
	\$(QUIET) echo "REQUIRE_VERSION             : "\$(REQUIRE_VERSION)
	\$(QUIET) echo "REQUIRE_PATH                : "\$(REQUIRE_PATH)
	\$(QUIET) echo "REQUIRE_TOOLS               : "\$(REQUIRE_TOOLS)
	\$(QUIET) echo "REQUIRE_BIN                 : "\$(REQUIRE_BIN)
	\$(QUIET) echo ""

conf:
	\$(QUIET) install -m 644 \$(TOP)/\$(ESS_MODULE_MAKEFILE)  \$(EPICS_MODULE_SRC_PATH)/


.PHONY: env \$(E3_ENV_NAME) \$(EPICS_MODULE_NAME) git-submodule-sync init help help2 build clean install uninstall conf rebuild




EOF

popd


cd e3-${MODULE_NAME}


git add .gitmodules
git add configure/*
git add ${MODULE_NAME}.Makefile
git add Makefile


printf "\n"
printf "Please edit ${MODULE_NAME}.Makefile for matching ${MODULE_NAME}\n";
printf "\n"
