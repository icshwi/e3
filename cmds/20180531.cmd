##
## This is the example how to use $(E3_CMD_TOP)
##
## 
require iocStats,1856ef5
require autosave,5.9.0


epicsEnvSet(TOP, "$(E3_CMD_TOP)")

epicsEnvSet(P, "20180509")
epicsEnvSet(R, "E3Test")

epicsEnvSet("IOC",  "$(P):$(R)")
epicsEnvSet("IOCST", "$(IOC):IocStats")



dbLoadRecords("iocAdminSoft.db","IOC=${IOCST}")

< $(TOP)/save_restore_before_init.cmd

iocInit

< $(TOP)/save_restore_after_init.cmd


dbl > "$(TOP)/$(P)_$(R)_PVs.list"
