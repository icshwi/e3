require iocStats,ae5d083

epicsEnvSet("TOP", "$(E3_CMD_TOP)")

system "bash $(TOP)/random.bash"

iocshLoad "$(TOP)/random.cmd"

epicsEnvSet("P", "IOC-$(NUM)")
epicsEnvSet("IOCNAME", "$(P)")

iocshLoad("$(iocStats_DIR)/iocStats.iocsh", "IOCNAME=$(IOCNAME)")

iocInit()

dbl > "$(TOP)/../${IOCNAME}_PVs.list"
