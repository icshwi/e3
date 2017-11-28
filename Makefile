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
# Date    : Monday, November 20 21:24:08 CET 2017
# version : 0.0.4

TOP:=$(CURDIR)


ifndef VERBOSE
  QUIET := @
endif

ifdef DEBUG_SHELL
  SHELL = /bin/sh -x
endif


# help is defined in 
# https://gist.github.com/rcmachado/af3db315e31383502660
help:
	$(info --------------------------------------- )	
	$(info Available targets)
	$(info --------------------------------------- )
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

#
## Clean all e3-*
clean:
	$(QUIET) bash e3.bash clean
#
## Build all 
build: 
	$(QUIET) bash e3.bash all

## Print modules list
env:
	$(QUIET) bash e3.bash env

## Setup Base and Require
base:
	$(QUIET) bash e3.bash base

## Setup Modules
modules:
	$(QUIET) bash e3.bash modules

# Other rules for debugging..
pull:
	$(QUIET) bash e3.bash pull

## Rebuild modules from scratch 
rmodule:
	$(QUIET) bash e3.bash rmod

## Inflating and install DB files
db:
	$(QUIET) bash e3.bash db

## Existent Modules Loading Test
load:
	$(QUIET) bash e3.bash load



.PHONY: help clean build env base modules pull  rmodule
