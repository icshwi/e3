require iocStats,ae5d083
require caPutLog,3.6.0

epicsEnvSet("SEC", "SEC")
epicsEnvSet("SUB", "SUB01")
epicsEnvSet("P", "$(SEC)-$(SUB):")
epicsEnvSet("DIS", "DIS")
epicsEnvSet("DEV", "DEV-01")
epicsEnvSet("R", "$(DIS)-$(DEV)")
epicsEnvSet("IOCNAME", "$(P)$(R)")



#loadIocsh("iocStats.iocsh", "IOCNAME=$(IOCNAME)")
loadIocsh("caPutLog.iocsh", "IOCNAME=$(IOCNAME)")


iocInit()

dbl > "${IOC}_PVs.list"


