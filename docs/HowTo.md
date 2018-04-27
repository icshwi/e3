# E3 Module Management 


## Fresh install a module, which isn't in EPICS modules



```
$ git clone https://github.com/icshwi/e3-sscan 
$ cd e3-sscan/
e3-sscan (master)$ make init
e3-sscan (master)$ make env

EPICS_MODULE_SRC_PATH       : sscan
ESS_MODULE_MAKEFILE         : sscan.Makefile
EPICS_MODULE_TAG            : tags/R2-11
LIBVERSION                  : 2.11.0
PROJECT                     : sscan

----- >>>> EPICS BASE Information <<<< -----

EPICS_BASE_TAG              : R3.15.5

----- >>>> ESS EPICS Environment  <<<< -----

EPICS_LOCATION              : /epics/bases
EPICS_MODULES               : /epics/modules
DEFAULT_EPICS_VERSIONS      : 3.15.5
BASE_INSTALL_LOCATIONS      : /epics/bases/base-3.15.5
REQUIRE_VERSION             : 2.5.4
REQUIRE_PATH                : /epics/modules/require/2.5.4
REQUIRE_TOOLS               : /epics/modules/require/2.5.4/tools
REQUIRE_BIN                 : /epics/modules/require/2.5.4/bin

e3-sscan (master)$ make build
e3-sscan (master)$ make install


e3-sscan (master)$ tree -L 1 /epics/modules/sscan/2.11.0/R3.15.5/
/epics/modules/sscan/2.11.0/R3.15.5/
├── [root     4.0K]  db
├── [root     4.0K]  dbd
├── [root     4.0K]  include
└── [root     4.0K]  lib

```


## Uninstall the existent module

```
e3-sscan (master)$ make uninstall
make[1]: Entering directory '/home/jhlee/e3/e3-sscan/sscan'
rm -rf /epics/modules/sscan/2.11.0
make[1]: Leaving directory '/home/jhlee/e3/e3-sscan/sscan'
e3-sscan (master)$ tree -L 1 /epics/modules/sscan/2.11.0/R3.15.5/
/epics/modules/sscan/2.11.0/R3.15.5/ [error opening dir]

0 directories, 0 files

```

# How to install/uninstall the different version of modules within the same repository

* Edit configure/CONFIG to select the different version in tags, libversion, or both.

```
EPICS_MODULE_TAG : From tags/R2-11 to tags/R2-10-2  
LIBVERSION       : 2.11.0 to 2.10.2
```

* Checkout
```
e3-sscan (master)$ make checkout
cd sscan && git checkout tags/R2-10-2
Previous HEAD position was ddd3266... R2-11
HEAD is now at a7c779c... R2-10-2 tag
```

* Build and install 
```
e3-sscan (master)$ make rebuild
make[1]: Entering directory '/home/jhlee/e3/e3-sscan/sscan'
rm -rf O.*
....



e3-sscan (master)$ tree -L 3 /epics/modules/sscan/
/epics/modules/sscan/
├── [root     4.0K]  2.10.2
│   └── [root     4.0K]  R3.15.5
│       ├── [root     4.0K]  db
│       ├── [root     4.0K]  dbd
│       ├── [root     4.0K]  include
│       └── [root     4.0K]  lib
└── [root     4.0K]  2.11.0
    └── [root     4.0K]  R3.15.5
        ├── [root     4.0K]  db
        ├── [root     4.0K]  dbd
        ├── [root     4.0K]  include
        └── [root     4.0K]  lib

12 directories, 0 files


```

* Uninstall
```
 e3-sscan (master)$ make uninstall
make[1]: Entering directory '/home/jhlee/e3/e3-sscan/sscan'
rm -rf /epics/modules/sscan/2.10.2
make[1]: Leaving directory '/home/jhlee/e3/e3-sscan/sscan'

 e3-sscan (master)$ tree -L 3 /epics/modules/sscan/
/epics/modules/sscan/
└── [root     4.0K]  2.11.0
    └── [root     4.0K]  R3.15.5
        ├── [root     4.0K]  db
        ├── [root     4.0K]  dbd
        ├── [root     4.0K]  include
        └── [root     4.0K]  lib

6 directories, 0 files

```


