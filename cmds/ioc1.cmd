##
## This is the example how to use $(E3_CMD_TOP)
##
## 
require iocStats,3.1.16

epicsEnvSet(TOP, "$(E3_CMD_TOP)/..")
epicsEnvSet(IOCSTATS_CMD_TOP, "$(TOP)/e3-iocStats/cmds")

epicsEnvSet(P, "IOC1")
epicsEnvSet(R, "Test")

epicsEnvSet("IOC",  "$(P):$(R)")

iocshLoad "$(IOCSTATS_CMD_TOP)/iocStats.cmd" "IOC=$(IOC):IocStats"

iocInit


dbl > "$(TOP)/$(P)_$(R)_PVs.list"
