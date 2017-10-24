* crete e3-devlib2 in github

* clone in 
```
$ git clone https://github.com/icshwi/e3-devlib2

$ cd e3-devlib2

$ git submodule add https://github.com/icshwi/e3-env
$ git submodule add https://github.com/epics-modules/devlib2
```

* Edit .gitmodule

from
```
[submodule "e3-env"]
        path = e3-env
        url = https://github.com/icshwi/e3-env
[submodule "devlib2"]
        path = devlib2
        url = https://github.com/epics-modules/devlib2
```
to 
```
[submodule "e3-env"]
        path = e3-env
        url = https://github.com/icshwi/e3-env
        ignore=dirty
[submodule "devlib2"]
        path = devlib2
        url = https://github.com/epics-modules/devlib2
        ignore=all
```

* Update submodules

```
$ git submodule update --init --recursive --recursive
```

* configure

Add the environment variable for these module


```
$ mkdir -p configure
$ emacs configure/CONFIG

EPICS_MODULE_NAME:=devlib2
export EPICS_MODULE_TAG:=tags/2.9
export EPICS_MODULE_SRC_PATH:=$(EPICS_MODULE_NAME)
ESS_MODULE_MAKEFILE:=$(EPICS_MODULE_NAME).Makefile
export PROJECT:=$(EPICS_MODULE_NAME)
export LIBVERSION:=2.9.0
export E3_ENV_NAME:=e3-env
```

* prepare devlib2.Makefile

```
include ${REQUIRE_TOOLS}/driver.makefile


PCIAPP:= pciApp

HEADERS += $(PCIAPP)/devLibPCI.h
HEADERS += $(PCIAPP)/devLibPCIImpl.h

SOURCES += $(wildcard $(PCIAPP)/devLib*.c)
SOURCES += $(PCIAPP)/pcish.c
SOURCES_Linux += $(PCIAPP)/os/Linux/devLibPCIOSD.c

DBDS += $(PCIAPP)/epicspci.dbd


VMEAPP:= vmeApp

HEADERS += $(VMEAPP)/devcsr.h
HEADERS += $(VMEAPP)/vmedefs.h

SOURCES += $(VMEAPP)/devcsr.c
SOURCES += $(VMEAPP)/iocreg.c
SOURCES += $(VMEAPP)/vmesh.c
SOURCES += $(VMEAPP)/devlib_compat.c

DBDS += $(VMEAPP)/epicsvme.dbd
```


* prepare Makefile (It is the generic one, which is the same as others)
```
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
# Author  : Jeong Han Lee
# email   : han.lee@esss.se
# Date    : Thursday, October 19 11:36:26 CEST 2017
# version : 0.2.0
#


TOP:=$(CURDIR)

include $(TOP)/configure/CONFIG

-include $(TOP)/$(E3_ENV_NAME)/$(E3_ENV_NAME)


# Keep always the module up-to-date
define git_update =
@git submodule deinit -f $@/
git submodule deinit -f $@/
sed -i '/submodule/,$$d'  $(TOP)/.git/config
rm -rf $(TOP)/.git/modules/$@
git submodule init $@/
git submodule update --init --recursive --recursive $@/.
git submodule update --remote --merge $@/
endef

ifndef VERBOSE
  QUIET := @
endif

ifdef DEBUG_SHELL
  SHELL = /bin/sh -x
endif


# Pass necessary driver.makefile variables through makefile options
#
M_OPTIONS := -C $(EPICS_MODULE_SRC_PATH)
M_OPTIONS += -f $(ESS_MODULE_MAKEFILE)
M_OPTIONS += LIBVERSION="$(LIBVERSION)"
M_OPTIONS += PROJECT="$(EPICS_MODULE_NAME)"
M_OPTIONS += EPICS_MODULES="$(EPICS_MODULES)"
M_OPTIONS += EPICS_LOCATION="$(EPICS_LOCATION)"
M_OPTIONS += DEFAULT_EPICS_VERSIONS="$(DEFAULT_EPICS_VERSIONS)"
M_OPTIONS += BUILDCLASSES="Linux"


# # help is defined in 
# # https://gist.github.com/rcmachado/af3db315e31383502660
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




install: uninstall
	$(QUIET) sudo -E bash -c 'make $(M_OPTIONS) install'

## Uninstall "Require" Module in order not to use it
uninstall: conf
	$(QUIET) sudo -E bash -c 'make $(M_OPTIONS) uninstall'



## Build the EPICS Module
build: conf
	$(QUIET) make $(M_OPTIONS) build

## clean, build, and install again.
rebuild: clean build install

## Clean the EPICS Module
clean: conf
	$(QUIET) make $(M_OPTIONS) clean

## Show driver.makefile help
help2:
	$(QUIET) make $(M_OPTIONS) help

#
## Initialize EPICS BASE and E3 ENVIRONMENT Module
init: git-submodule-sync $(EPICS_MODULE_NAME) $(E3_ENV_NAME)

git-submodule-sync:
	$(QUIET) git submodule sync


$(EPICS_MODULE_NAME): 
	$(QUIET) $(git_update)
	cd $@ && git checkout $(EPICS_MODULE_TAG)


$(E3_ENV_NAME): 
	$(QUIET) $(git_update)


## Print EPICS and ESS EPICS Environment variables
env:
	$(QUIET) echo ""

	$(QUIET) echo "EPICS_MODULE_SRC_PATH       : "$(EPICS_MODULE_SRC_PATH)
	$(QUIET) echo "ESS_MODULE_MAKEFILE         : "$(ESS_MODULE_MAKEFILE)
	$(QUIET) echo "EPICS_MODULE_TAG            : "$(EPICS_MODULE_TAG)
	$(QUIET) echo "LIBVERSION                  : "$(LIBVERSION)
	$(QUIET) echo "PROJECT                     : "$(PROJECT)

	$(QUIET) echo ""
	$(QUIET) echo "----- >>>> EPICS BASE Information <<<< -----"
	$(QUIET) echo ""
	$(QUIET) echo "EPICS_BASE_TAG              : "$(EPICS_BASE_TAG)
#	$(QUIET) echo "CROSS_COMPILER_TARGET_ARCHS : "$(CROSS_COMPILER_TARGET_ARCHS)
	$(QUIET) echo ""
	$(QUIET) echo "----- >>>> ESS EPICS Environment  <<<< -----"
	$(QUIET) echo ""
	$(QUIET) echo "EPICS_LOCATION              : "$(EPICS_LOCATION)
	$(QUIET) echo "EPICS_MODULES               : "$(EPICS_MODULES)
	$(QUIET) echo "DEFAULT_EPICS_VERSIONS      : "$(DEFAULT_EPICS_VERSIONS)
	$(QUIET) echo "BASE_INSTALL_LOCATIONS      : "$(BASE_INSTALL_LOCATIONS)
	$(QUIET) echo "REQUIRE_VERSION             : "$(REQUIRE_VERSION)
	$(QUIET) echo "REQUIRE_PATH                : "$(REQUIRE_PATH)
	$(QUIET) echo "REQUIRE_TOOLS               : "$(REQUIRE_TOOLS)
	$(QUIET) echo "REQUIRE_BIN                 : "$(REQUIRE_BIN)
	$(QUIET) echo ""

conf:
	$(QUIET) install -m 644 $(TOP)/$(ESS_MODULE_MAKEFILE)  $(EPICS_MODULE_SRC_PATH)/


.PHONY: env $(E3_ENV_NAME) $(EPICS_MODULE_NAME) git-submodule-sync init help help2 build clean install uninstall conf rebuild
```


* Make
```
$ make init
$ make env

EPICS_MODULE_SRC_PATH       : devlibs2
ESS_MODULE_MAKEFILE         : devlibs2.Makefile
EPICS_MODULE_TAG            : tags/2.9
LIBVERSION                  : 2.9.0
PROJECT                     : devlibs2

----- >>>> EPICS BASE Information <<<< -----

EPICS_BASE_TAG              : R3.15.4 R3.15.5

----- >>>> ESS EPICS Environment  <<<< -----

EPICS_LOCATION              : /epics/bases
EPICS_MODULES               : /epics/modules
DEFAULT_EPICS_VERSIONS      : 3.15.4 3.15.5
BASE_INSTALL_LOCATIONS      : /epics/bases/base-3.15.4 /epics/bases/base-3.15.5
REQUIRE_VERSION             : 0.0.1
REQUIRE_PATH                : /epics/modules/require/0.0.1
REQUIRE_TOOLS               : /epics/modules/require/0.0.1/tools
REQUIRE_BIN                 : /epics/modules/require/0.0.1/bin
```

* 
```
$ make rebuild
```

* Check your bulidng systems
```
$ tree -L 5 /epics/modules/devlib2/
/epics/modules/devlib2/
└── [root     4.0K]  2.9.0
    ├── [root     4.0K]  R3.15.4
    │   ├── [root     4.0K]  dbd
    │   │   └── [root      175]  devlib2.dbd
    │   ├── [root     4.0K]  include
    │   │   ├── [root      14K]  devcsr.h
    │   │   ├── [root      13K]  devLibPCI.h
    │   │   ├── [root     2.3K]  devLibPCIImpl.h
    │   │   └── [root     5.3K]  vmedefs.h
    │   └── [root     4.0K]  lib
    │       ├── [root     4.0K]  linux-ppc64e6500
    │       │   ├── [root       31]  devlib2.dep
    │       │   └── [root      88K]  libdevlib2.so
    │       └── [root     4.0K]  linux-x86_64
    │           ├── [root       31]  devlib2.dep
    │           └── [root     180K]  libdevlib2.so
    └── [root     4.0K]  R3.15.5
        ├── [root     4.0K]  dbd
        │   └── [root      175]  devlib2.dbd
        ├── [root     4.0K]  include
        │   ├── [root      14K]  devcsr.h
        │   ├── [root      13K]  devLibPCI.h
        │   ├── [root     2.3K]  devLibPCIImpl.h
        │   └── [root     5.3K]  vmedefs.h
        └── [root     4.0K]  lib
            ├── [root     4.0K]  linux-ppc64e6500
            │   ├── [root       31]  devlib2.dep
            │   └── [root      88K]  libdevlib2.so
            └── [root     4.0K]  linux-x86_64
                ├── [root       31]  devlib2.dep
                └── [root     180K]  libdevlib2.so

13 directories, 18 files
```



*  add all changes into git repostory, and push them to remote site.



