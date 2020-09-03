# Deprecation notice

2020-08-26: This remote has been deprecated. Moved to https://gitlab.esss.lu.se/e3/e3.

e3 developing environment
======
[![Build Status](https://github.com/icshwi/e3/workflows/E3%20Building/badge.svg)](https://github.com/icshwi/e3/actions?workflow=E3+Building)

This is the setup and maintenance scripts for the ESS EPICS Environment (E3). 

## Notice
This repository was developed in order to check each module compatibility easily and quickly within E3. Therefore it has no purpose to serve as a production environment. If one would like to see a reproducable single point release of E3, please check https://github.com/icshwi/e3-manifest . By this manifest repository the exactly same E3 can be built in many different places. However, the manifest E3 doesn't have any convenient tools. 



## Tested Platforms

* Building, requiring (loading), and running modules should be tested carefully if one would like to run an EPICS IOC within e3.
* The following Linux distributions cover Building and Requiring Tests.

### Building and Requiring Tests
* Debian     
* CentOS 
* Ubuntu 


## Procedure to duplicate the minimal E3 in your system.

* This procedure has many assumptions, so it most likely doesn't work "out of the box". 

* However, if one would like to challenge this, please follow the below basic instructions.

* This script, e3.bash, is not the proper tool to deploy the E3 in any production environment, but it is a system with which one can design, develop, and debug E3 in many different scenarios.  One can use it to duplicate the E3 in most Linux flavor without any difficulties. 

Note that the user account should be in sudo group. And please install "git" and "make" first.

### Get e3

```
$ git clone https://github.com/icshwi/e3
```

### Install base within the e3 directory

**NOTICE**, before going to run the next command, **PLEASE INSTALL ALL REQUIRED PACKAGES FIRST**. For CentOS **8**, one should carefully install all necessary packages with their various repositories and with source codes first. If not, one **CANNOT** install and run e3. One can see the e3 training workbook for the up-to-date information [1]. For example, the following packages mostly are needed to compile e3 and some additional services in CentOS and Debian. Note that one may not need them all according to one's configuration.

* CentOS **7**
```  
* Note there is also a temporary internal mirror of CentOS packages required for E3 available inside ESS network.*  
For configruation details look here: https://gitlab.esss.lu.se/icshwi/centos_mirror_proxy.  

Otherwise the required packages can be installed manually from CentOS community mirrors as below:  
$ sudo yum --enablerepo=extras install epel-release  
$ sudo yum install -y git tree ipmitool autoconf libtool automake m4 re2c tclx \
coreutils graphviz patch readline-devel libXt-devel libXp-devel libXmu-devel \
libXpm-devel lesstif-devel gcc-c++ ncurses-devel perl-devel net-snmp net-snmp-utils \
net-snmp-devel libxml2-devel libpng12-devel libzip-devel libusb-devel \
python-devel darcs hdf5-devel boost-devel pcre-devel opencv-devel \
libcurl-devel blosc-devel libtiff-devel libjpeg-turbo-devel \
libusbx-devel systemd-devel libraw1394.x86_64 hg libtirpc-devel \
liberation-fonts-common liberation-narrow-fonts \
liberation-mono-fonts liberation-serif-fonts liberation-sans-fonts \
logrotate xorg-x11-fonts-misc cpan kernel-devel symlinks \
dkms procServ curl netcdf netcdf-devel
```

* Debian
```
git tree emacs ipmitool autoconf libtool automake m4 re2c tclx coreutils graphviz build-essential libreadline-dev libxt-dev x11proto-print-dev libxmu-headers libxmu-dev libxmu6 libxpm-dev libxmuu-dev libxmuu1 libpcre++-dev libmotif-dev libsnmp-dev re2c darcs python-dev libnetcdf-dev libhdf5-dev libbz2-dev libxml2-dev libblosc-dev libtiff-dev libusb-dev libusb-1.0-0-dev libudev-dev libsystemd-dev linux-source mercurial libboost-dev libboost-regex-dev libboost-filesystem-dev libopencv-dev libpng-dev libraw1394-11 libtirpc-dev fonts-liberation logrotate curl netcdf netcdf-devel symlinks dkms procserv linux-headers-$(uname -r)
```


```
$ bash e3_building_config.bash -t ${HOME}/epics setup

$ bash e3.bash base
```


### Install require within the e3 directory
```
$ bash e3.bash req
```


### Install common modules within the e3 directory

One should install base and require first before each modules's configuration.

```
$ bash e3.bash -c vars

>> Vertical display for the selected modules :

 Modules List 
    0 : e3-ess
    1 : e3-autosave
    2 : e3-caPutLog
    3 : e3-asyn
    4 : e3-busy
    5 : e3-modbus
    6 : e3-ipmiComm
    7 : e3-seq
    8 : e3-sscan
    9 : e3-std
   10 : e3-ip
   11 : e3-calc
   12 : e3-iocStats
   13 : e3-delaygen
   14 : e3-pcre
   15 : e3-StreamDevice
   16 : e3-s7plc
   17 : e3-recsync
   18 : e3-MCoreUtils


e3 (master)$ bash e3.bash -c mod

e3 (master)$ bash e3.bash -c load
```

If you see the clean ioc shell prompt, e3 is ready to use. Please exit this test ioc.


### Enable e3 in only current terminal

Technically, one can have multiple e3 and community EPICS environments in a single host. To enable e3, please use the following command:

```
e3 (master)$ source tools/setenv 
```
The above environment file will be generated automatically by the building procedure. 

After this, you can run the example ioc through

```
e3 (master)$  iocsh.bash cmds/iocStats.cmd 
```

Open another terminal, set the environment via source first, then
run the caget_pvs.bash with the generated pv list file.

```
e3 (master)$ bash caget_pvs.bash -l IOC-9999_PVs.list 
.............
.............

IOC-9999-IocStats:ACCESS       Running
IOC-9999-IocStats:APP_DIR 160 47 104 111 109 101 47 106 104 108 101 101 47 101 51 45 51 46 49 53 46 53 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
IOC-9999-IocStats:APP_DIR1     /home/jhlee/e3-3.15.5
IOC-9999-IocStats:APP_DIR2     
IOC-9999-IocStats:CA_ADDR_LIST 
IOC-9999-IocStats:CA_AUTO_ADDR YES
IOC-9999-IocStats:CA_BEAC_TIME 15.0
IOC-9999-IocStats:CA_CLNT_CNT  0
IOC-9999-IocStats:CA_CONN_CNT  0
IOC-9999-IocStats:CA_CONN_TIME 30.0
IOC-9999-IocStats:CA_MAX_ARRAY 16384
IOC-9999-IocStats:CA_RPTR_PORT 5065
IOC-9999-IocStats:CA_SRCH_TIME 300.0
IOC-9999-IocStats:CA_SRVR_PORT 5064
IOC-9999-IocStats:CA_UPD_TIME  15
IOC-9999-IocStats:CPU_CNT      4
IOC-9999-IocStats:ENGINEER     jhlee
IOC-9999-IocStats:EPICS_VERS   EPICS R3.15.5-E3-3.15.5-patch
IOC-9999-IocStats:FD_CNT       7
IOC-9999-IocStats:FD_FREE      1017
IOC-9999-IocStats:FD_MAX       1024
IOC-9999-IocStats:FD_UPD_TIME  20
IOC-9999-IocStats:GTIM_CUR_SRC OS Clock
IOC-9999-IocStats:GTIM_ERR_CNT 0
IOC-9999-IocStats:GTIM_EVT_SRC No working providers
IOC-9999-IocStats:GTIM_HI_SRC  OS Clock
IOC-9999-IocStats:GTIM_RESET   Reset
IOC-9999-IocStats:GTIM_TIME    9.18241e+08
IOC-9999-IocStats:HEARTBEAT    17
IOC-9999-IocStats:HOSTNAME     faiserver
IOC-9999-IocStats:IOC_CPU_LOAD 0
IOC-9999-IocStats:IOC_LOG_INET 
IOC-9999-IocStats:IOC_LOG_PORT 7004
IOC-9999-IocStats:KERNEL_VERS  Linux 4.9.0-8-amd64 x86_64
IOC-9999-IocStats:LOAD         0
.............
```

```
e3 (master)$   bash caget_pvs.bash -l IOC-9999_PVs.list -f "LOAD"

>> Selected PV and its value with caget
IOC-9999-IocStats:IOC_CPU_LOAD 0.0250242
IOC-9999-IocStats:LOAD         0.0250242
IOC-9999-IocStats:LOAD_UPD_TIME 10
IOC-9999-IocStats:SYS_CPU_LOAD 30.2042

```

The most useful option is the fake watch with `-w` option such as 

```
$ bash caget_pvs.bash -l IOC-9999_PVs.list -f "HEARTBEAT" -w 1
```
```
$ watch -n 1 "bash caget_pvs.bash -l IOC-9999_PVs.list -f "HEARTBEAT"
```

If you would like to do more, please visit https://github.com/icshwi/e3training


## Outside the e3 directory

Each base, Require module, and other modules have its own MAKEFILE and its own configuration files. Thus, one can put e3-base, e3-require, and all other e3-modules in any directories where one would like to keep them.



## 
## Usage for e3.bash
```
e3 (master)$ ./e3.bash 

Usage    : ./e3.bash [ -ctpifealb4do ] <option> 


           -c     : common       : epics modules
           -t     : timing       : mrf timing modules
           -4     : epics v4     : EPICS V4 modules (testing)
           -p{c}  : psi          : PSI modules
           -i{c}  : ifc free     : ifc modules without user accounts
           -f{ic}  : ifc nonfree : ifc modules with user accounts
           -e{c}  : ecat         : ethercat modules
           -a{c}  : area         : area detector modules / BI Modules
           -l{c}  : llrf         : LLRF modules
           -b{ca} : bi           : beam instrumentation modules (based on AD)
           -d     : developing   : no dependency, one should installl all before
           {c,ci} : dep modules  : enable by default if not defined (dependent modules)
             -o   : only         : ignore dependent modules
                                   the option -e is actually -ec. And -eo means -e.


 < option > 

           env    : Print enabled Modules

           call   : Clean all (base, require, selected module group)
           gall   : Clone all (base, require, selected module group)
            all   : call, gall, ibase, bbase, ireq, breq, imod, bmod

           cbase  : Clean Base
           gbase  : Clone Base
           ibase  : Init  Base 
           bbase  : Build, Install Base
            base  : cbase, gbase, ibase, bbase

           creq   : Clean Require
           greq   : Clone Require
           ireq   : Init  Require
           breq   : Build, Install Require
            req   : creq, gbase ireq, breq

           cmod   : Clean Modules (selected module group)
           gmod   : Clone Modules (selected module group)
           imod   : Init  Modules (selected module group)
           bmod   : Build, Install Modules (selected module group)
            mod   : cmod, mod, imod, bmod

        co_base "_check_out_name_" : Checkout Base
         co_req "_check_out_name_" : Checkout Require
         co_mod "_check_out_name_" : Checkout Modules  (selected module group)
         co_all "_check_out_name_" : co_base, co_req, co_mod

          vbase   : Print BASE    Version Information in e3-*
           vreq   : Print REQUIRE Version Information in e3-*
           vmod   : Print MODULES Version Information in e3-*
           vall   : Print ALL     Version Information in e3-*
           vins   : Print INSTALLED Version Information for locally installed e3 modules

         allall   : Print ALL Version Information in e3-* by using "make vars"

           load   : Load all installed Modules into iocsh.bash
           cmd    : create .cmd file in /home/jhlee/e3-7.0.3.1
        setenv    : create setenv in /home/jhlee/e3-7.0.3.1/tools

           vers   : Print Source Tag / Module Versions
            dep   : Print DEP_VERSION information
        plotdep   : Plot the naive module depdendency drawing
      closeplot   : Close all active opened plots

           tags   : Print the latest tag for a repo manifest



  Examples : 

          ./e3.bash creq 
          ./e3.bash -ctpifealb cmod
          ./e3.bash -t env
          ./e3.bash base
          ./e3.bash req
          ./e3.bash -e cmod
          ./e3.bash -t load


```

## SSH KEY Usage

One needs to have the ESS bitbucket/gitlab accout in order to use  *ifc nonfree* and *llrf* modules. The procedure **make init** will ask the ESS user name and its password several times. In order not to type account and password many time, one can add the ssh key in the account configurations in bitbucket and gitlab. After that, the following command should be executed in order to use the different url instead of the default one. **Note that ESS gitlab repository cannot be accessible outside the ESS network. Several modules (in the group t and b) cannot be cloned**. 

```
source tools/use_sshkey.sh
```


## Customized e3 Building Configuration

To build EPICS 7 with e3

```
$ bash e3_building_config.bash -t /epics/test -b 7.0.3.1 setup 
$ bash e3.bash base
$ bash e3.bash req
$ bash e3.bash -ctpiao mod
```
Note that the -4 option is not necessary, but **-o** option is, because EPICS 7 has the "EPICS 4" modules (pvAccess, etc) already in base.


Please look at [README_developing.md](./README_developing.md) for more details. 


----
[1] https://github.com/icshwi/e3training/blob/master/workbook/chapter1.md
