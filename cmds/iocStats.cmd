require iocStats,3.1.16

epicsEnvSet("TOP", "$(E3_CMD_TOP)")

epicsEnvSet("NUM", "9999")

epicsEnvSet("P", "IOC-$(NUM)")
epicsEnvSet("IOCNAME", "$(P)")

iocshLoad("$(iocStats_DIR)/iocStats.iocsh", "IOCNAME=$(IOCNAME)")

iocInit()

dbl > "$(TOP)/../${IOCNAME}_PVs.list"
