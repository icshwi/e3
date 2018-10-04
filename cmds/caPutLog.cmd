require caPutLog,3.6.0
require iocStats,ae5d083


epicsEnvSet("SEC", "SEC")
epicsEnvSet("SUB", "SUB01")
epicsEnvSet("P", "$(SEC)-$(SUB):")
epicsEnvSet("DIS", "DIS")
epicsEnvSet("DEV", "DEV-01")
epicsEnvSet("R", "$(DIS)-$(DEV)")
epicsEnvSet("IOCNAME", "$(P)$(R)caPutLog")

epicsEnvSet("TOP", "$(E3_CMD_TOP)/../")
epicsEnvSet("CALOGPUT_TOP", "$(TOP)/e3-caPutLog/iocsh")

#loadIocsh("iocStats.iocsh", "IOCNAME=$(IOCNAME)")

loadIocsh("$(CALOGPUT_TOP)/caPutLog.iocsh", "IOCNAME=$(IOCNAME), LOG_INET=10.0.6.172")

iocInit()

dbl > "${IOCNAME}_PVs.list"


