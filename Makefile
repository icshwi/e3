#
#  Copyright (c) 2017 - Present  Jeong Han Lee
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
# Author  : Jeong Han Lee
# email   : han.lee@esss.se
# Date    : Sunday, April 15 22:06:10 CEST 2018
# version : 0.1.0

TOP:=$(CURDIR)

PHONY:=

ifndef VERBOSE
  QUIET := @
endif

ifdef DEBUG_SHELL
  SHELL = /bin/sh -x
endif


DEFAULT_GROUPNAME="test3"


# help is defined in 
# https://gist.github.com/rcmachado/af3db315e31383502660
help:
	$(info --------------------------------------- )	
	$(info Available targets)
	$(info --------------------------------------- )
	$(QUIET) echo ""
	$(QUIET) echo "Please look at e3.bash for more rich control"
	$(QUIET) echo ""
	$(QUIET) awk '/^[a-zA-Z\-\_0-9]+:/ {            \
	  nb = sub( /^## /, "", helpMsg );              \
	  if(nb == 0) {                                 \
	    helpMsg = $$0;                              \
	    nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
	  }                                             \
	  if (nb)                                       \
	    print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts:	


default: help


PHONY+=base
## Setup and Build Base
base:
	$(QUIET) bash e3.bash base

PHONY+=req
## Setup and Build Require
req:
	$(QUIET) bash e3.bash req

PHONY+=mod
## Setup and Build Require
mod:
	$(QUIET) bash e3.bash -g $(DEFAULT_GROUPNAME)  mod

PHONY+=clean
## Clean all e3-* with the test group (COMMON,TIMING,IFC)
clean:
	$(QUIET) bash ./e3.bash -g $(DEFAULT_GROUPNAME) call

PHONY+=build
## Build all  with the test group  (COMMON,TIMING,IFC)
build: 
	$(QUIET) bash e3.bash -g $(DEFAULT_GROUPNAME) all

PHONY+=env
## Print modules list with the test group  (COMMON,TIMING,IFC)
env:
	$(QUIET) bash e3.bash -g $(DEFAULT_GROUPNAME) env


PHONY+=timing
## Setup and Build Common and Timing Modules
timing:
	$(QUIET) bash e3.bash -g timing mod

PHONY+=ecat
## Setup and Build Common and EtherCAT Modules
ecat:
	$(QUIET) bash e3.bash -g ecat mod

PHONY+=ifc
## Setup and Build Common and IFC Modules
ifc:
	$(QUIET) bash e3.bash -g ifc mod

PHONY+=area
## Setup and Build Common and AreaDetector Modules
area:
	$(QUIET) bash e3.bash -g area mod


PHONY+=load
## Existent Modules Loading Test
load:
	$(QUIET) bash e3.bash -g $(DEFAULT_GROUPNAME) load

PHONY+=pull
# Other rules for debugging..
pull:
	$(QUIET) bash e3.bash pull


.PHONY: help $(PHONY)
