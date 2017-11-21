## Global E3 Env
* https://github.com/icshwi/e3-env

## EPICS BASE
* https://github.com/icshwi/e3-base

## REQUIRE

https://github.com/icshwi/e3-require

## Kernel Modules

* mrfioc2         : https://github.com/epics-modules/mrfioc2
* etherlab mater  : https://github.com/jeonghanlee/ecat_setup
* sis8300 ?       : 
* ioxos (tosca ?) : 


## Generic Libs
* libusb1.0 : asyn


## EPICS MODULES

This section show fundamental EPICS modules, which ESS can access through mostly github.com. The first release goal is to implement them all and to do minimal tests with at least minimal HW and SW configuration

* [+] : Implemented (at least compiled, and loaded within iocsh.bash without errors)
* [@] : In progress
* [&] : Plan
* [OMG] : Plan with @.@
* [-] : Not Plan


### ECAT2 [+]
* https://github.com/icshwi/e3-ecat2

### ECAT2DB [+]
* https://github.com/icshwi/e3-ecat2db

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

### ASYN [+]
* https://github.com/epics-modules/asyn
* Dep : BASE, SNCSEQ#, IPAC#
* https://github.com/icshwi/e3-asyn

### BUSY [+]
* https://github.com/epics-modules/busy
* Dep : BASE, ASYN
* https://github.com/icshwi/e3-busy

### MODBUS [+]
* https://github.com/epics-modules/modbus
* Dep : BASE, ASYN
* https://github.com/icshwi/e3-modbus

### LUA [+]
* https://github.com/epics-modules/lua
* Dep : BASE, ASYN
* https://github.com/icshwi/e3-lua

### ipmiComm [+]
* https://github.com/icshwi/ipmiComm
* DEP : BASE, ASYN, IOCSTATS
* https://github.com/icshwi/e3-ipmiComm

### IPAC [-]
* https://github.com/epics-modules/ipac
* Dep : BASE


### SNCSEQ [@]
* http://www-csr.bessy.de/control/SoftDist/sequencer/repo/branch-2-2.git
* https://github.com/icshwi/e3-seq

### SSCAN [&]
* https://github.com/epics-modules/sscan
* Dep : BASE, SNCSEQ

### MOTOR [&]
* https://github.com/epics-modules/motor
* Dep : BASE, ASYN, SNCSEQ#, BUSY#, IPAC# 

### STREAM [&]
* https://github.com/epics-modules/stream
* Dep : BASE, ASYN, SSCAN, CALC

### CALC [&]
* https://github.com/epics-modules/calc
* Dep : BASE, SSCAN# , SNCSEQ#

### DELAYGEN [&]
*https://github.com/epics-modules/delaygen
* Dep : BASE, ASYN, CALC, IPAC#, IP, AUTOSAVE

### IP [&]
* https://github.com/epics-modules/ip
* Dep : BASE, ASYN, IPAC#, SENSEQ


### SNMP2 or SNMP3 [&]


### AREA DETECTOR [OMG]

* https://github.com/areaDetector
https://github.com/areaDetector/areaDetector

```
[submodule "ADADSC"]
	path = ADADSC
	url = https://github.com/areaDetector/ADADSC.git
[submodule "ADAndor"]
	path = ADAndor
	url = https://github.com/areaDetector/ADAndor.git
[submodule "ADAndor3"]
	path = ADAndor3
	url = https://github.com/areaDetector/ADAndor3.git
[submodule "ADBruker"]
	path = ADBruker
	url = https://github.com/areaDetector/ADBruker.git
[submodule "ADCSimDetector"]
	path = ADCSimDetector
	url = https://github.com/areaDetector/ADCSimDetector.git
[submodule "ADCameraLink"]
	path = ADCameraLink
	url = https://github.com/areaDetector/ADCameraLink.git
[submodule "ADCore"]
	path = ADCore
	url = https://github.com/areaDetector/ADCore.git
[submodule "ADDexela"]
	path = ADDexela
	url = https://github.com/areaDetector/ADDexela.git
[submodule "ADFastCCD"]
	path = ADFastCCD
	url = https://github.com/areaDetector/ADFastCCD.git
[submodule "ADFireWireWin"]
	path = ADFireWireWin
	url = https://github.com/areaDetector/ADFireWireWin.git
[submodule "ADLambda"]
	path = ADLambda
	url = https://github.com/areaDetector/ADLambda.git
[submodule "ADLightField"]
	path = ADLightField
	url = https://github.com/areaDetector/ADLightField.git
[submodule "ADMerlin"]
	path = ADMerlin
	url = https://github.com/areaDetector/ADMerlin.git
[submodule "ADMythen"]
	path = ADMythen
	url = https://github.com/areaDetector/ADMythen.git
[submodule "ADPCO"]
	path = ADPCO
	url = https://github.com/areaDetector/ADPCO.git
[submodule "ADPICam"]
	path = ADPICam
	url = https://github.com/areaDetector/ADPICam.git
[submodule "ADPSL"]
	path = ADPSL
	url = https://github.com/areaDetector/ADPSL.git
[submodule "ADPerkinElmer"]
	path = ADPerkinElmer
	url = https://github.com/areaDetector/ADPerkinElmer.git
[submodule "ADPhotonII"]
	path = ADPhotonII
	url = https://github.com/areaDetector/ADPhotonII
[submodule "ADPilatus"]
	path = ADPilatus
	url = https://github.com/areaDetector/ADPilatus.git
[submodule "ADPixirad"]
	path = ADPixirad
	url = https://github.com/areaDetector/ADPixirad.git
[submodule "ADPluginEdge"]
	path = ADPluginEdge
	url = https://github.com/areaDetector/ADPluginEdge.git
[submodule "ADPointGrey"]
	path = ADPointGrey
	url = https://github.com/areaDetector/ADPointGrey.git
[submodule "ADProsilica"]
	path = ADProsilica
	url = https://github.com/areaDetector/ADProsilica.git
[submodule "ADPvCam"]
	path = ADPvCam
	url = https://github.com/areaDetector/ADPvCam.git
[submodule "ADQImaging"]
	path = ADQImaging
	url = https://github.com/areaDetector/ADQImaging.git
[submodule "ADRoper"]
	path = ADRoper
	url = https://github.com/areaDetector/ADRoper.git
[submodule "ADSimDetector"]
	path = ADSimDetector
	url = https://github.com/areaDetector/ADSimDetector.git
[submodule "ADSupport"]
	path = ADSupport
	url = https://github.com/areaDetector/ADSupport.git
[submodule "ADURL"]
	path = ADURL
	url = https://github.com/areaDetector/ADURL.git
[submodule "ADViewers"]
	path = ADViewers
	url = https://github.com/areaDetector/ADViewers.git
[submodule "ADmar345"]
	path = ADmar345
	url = https://github.com/areaDetector/ADmar345.git
[submodule "ADmarCCD"]
	path = ADmarCCD
	url = https://github.com/areaDetector/ADmarCCD.git
[submodule "ADnED"]
	path = ADnED
	url = https://github.com/areaDetector/ADnED.git
[submodule "NDDriverStdArrays"]
	path = NDDriverStdArrays
	url = https://github.com/areaDetector/NDDriverStdArrays.git
[submodule "aravisGigE"]
	path = aravisGigE
	url = https://github.com/areaDetector/aravisGigE.git
[submodule "ffmpegServer"]
	path = ffmpegServer
	url = https://github.com/areaDetector/ffmpegServer.git
[submodule "ffmpegViewer"]
	path = ffmpegViewer
	url = https://github.com/areaDetector/ffmpegViewer.git
[submodule "firewireDCAM"]
	path = firewireDCAM
	url = https://github.com/areaDetector/firewireDCAM.git
[submodule "pvaDriver"]
	path = pvaDriver
	url = https://github.com/areaDetector/pvaDriver.git
	
```


### IOxOS [OMG]

### ESS Site-Specific MODULES [OMG]
