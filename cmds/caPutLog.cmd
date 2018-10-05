require ess,0.0.1
require caPutLog,3.6.0
require iocStats,ae5d083


epicsEnvSet("SEC", "SEC")
epicsEnvSet("SUB", "SUB01")
epicsEnvSet("P", "$(SEC)-$(SUB):")
epicsEnvSet("DIS", "DIS")
epicsEnvSet("DEV", "DEV-01")
epicsEnvSet("R", "$(DIS)-$(DEV)")
epicsEnvSet("IOCNAME", "$(P)$(R)")

epicsEnvSet("TOP",          "$(E3_CMD_TOP)/..")
epicsEnvSet("CALOGPUT_TOP", "$(TOP)/e3-caPutLog")
epicsEnvSet("ESS_TOP",      "$(TOP)/e3-ess")



loadIocsh("accessSecurityGroup.iocsh", "ASG_PATH=$(ESS_TOP)/template, ASG_FILE=unrestricted_access.asg")
loadIocsh("iocStats.iocsh", "IOCNAME=$(P)")
#loadIocsh("iocLog.iocsh", "IOCNAME=$(IOCNAME), LOG_INET=10.0.6.172")
loadIocsh("$(CALOGPUT_TOP)/iocsh/caPutLog.iocsh", "IOCNAME=$(IOCNAME), LOG_INET=10.0.6.172")

iocInit()

dbl > "${IOCNAME}_PVs.list"


