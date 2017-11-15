## Global E3 Env
* https://github.com/icshwi/e3-env

## EPICS BASE
* https://github.com/icshwi/e3-base

## REQUIRE

https://github.com/icshwi/e3-require

## Kernel Modules

* mrfioc2
* etherlab mater


## EPICS MODULES

This section show fundamental EPICS modules, which ESS can access through mostly github.com. The first release goal is to implement them all and to do minimal tests with at least minimal HW and SW configuration

* [+] : Implemented
* [@] : In progress
* [&] : Plan



### DEVLIB2 [+]
* https://github.com/epics-modules/devlib2
* Dep : BASE
* https://github.com/icshwi/e3-devlib2

### IOCSTATS [+]
* https://github.com/epics-modules/iocStats
* Dep : BASE, SENSEQ#
* https://github.com/icshwi/e3-iocStats

### AUTOSAVE [+]
* https://github.com/epics-modules/autosave
* Dep : BASE 
* https://github.com/icshwi/e3-autosave

### MRFIOC2 [+]
* https://github.com/epics-modules/mrfioc2
* Dep : BASE, DEVLIB2, AUTOSAVE#, IOCSTATS#
* https://github.com/icshwi/e3-mrfioc2

### ASYN [@]
* https://github.com/epics-modules/asyn
* Dep : BASE, SNCSEQ#, IPAC#
* https://github.com/icshwi/e3-asyn

### SNCSEQ [@]
* http://www-csr.bessy.de/control/SoftDist/sequencer/repo/branch-2-2.git
* https://github.com/icshwi/e3-seq

### SSCAN [&]
* https://github.com/epics-modules/sscan
* Dep : BASE, SNCSEQ

### MODBUS [&]
* https://github.com/epics-modules/modbus
* Dep : BASE, ASYN

### BUSY [&]
* https://github.com/epics-modules/busy
*Dep : BASE, ASYN

### MOTOR [&]
* https://github.com/epics-modules/motor
* Dep : BASE, ASYN, SNCSEQ#, BUSY#, IPAC# 

### STREAM [&]
* https://github.com/epics-modules/stream
* Dep : BASE, ASYN, SSCAN, CALC

### LUA [&]
* https://github.com/epics-modules/lua
* Dep : BASE, ASYN

### CALC [&]
* https://github.com/epics-modules/calc
* Dep : BASE, SSCAN# , SNCSEQ#

### IPAC [&]
* https://github.com/epics-modules/ipac
* Dep : BASE

### DELAYGEN [&]
*https://github.com/epics-modules/delaygen
* Dep : BASE, ASYN, CALC, IPAC, IP, AUTOSAVE

### IP [&]
* https://github.com/epics-modules/ip
* Dep : BASE, ASYN, IPAC, SENSEQ



### IPMICOMM [&]
* https://github.com/icshwi/ipmiComm

### SNMP2 or SNMP3 [&]

### ECAT2 [+]

### ECAT2DB [+]

* https://github.com/icshwi/e3-ecat2db
