
require iocStats,ae5d083
require recsync,1.3.0
require autosave,5.9.0
require MCoreUtils,1.2.1


epicsEnvSet("SEC", "SEC")
epicsEnvSet("SUB", "SUB01")
epicsEnvSet("P", "$(SEC)-$(SUB):")
epicsEnvSet("DIS", "DIS")
epicsEnvSet("DEV", "DEV-01")
epicsEnvSet("R", "$(DIS)-$(DEV)")
epicsEnvSet("IOCNAME", "$(P)$(R)")


# need to define IOCNAME
# PV names
iocshLoad("$(iocStats_DIR)/iocStats.iocsh", "IOCNAME=$(IOCNAME)")
iocshLoad("$(recsync_DIR)/recsync.iocsh",  "IOCNAME=$(IOCNAME)")
iocshLoad("$(autosave_DIR)/autosave.iocsh", "IOCNAME=$(IOCNAME), AS_TOP=/tmp")


iocInit()

