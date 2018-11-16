require iocStats,ae5d083


epicsEnvSet("TOP", "$(E3_CMD_TOP)")

system "tr -cd 0-9 </dev/urandom | head -c 8 > $(TOP)/random_tmp"
system "C=`cat random_tmp` && /bin/sed -e "s:_random_:$C:g" < $(TOP)/random.in > $(TOP)/random.cmd"

< $(TOP)/random.cmd

epicsEnvSet("P", "IOC-$(NUM)")
epicsEnvSet("IOCNAME", "$(P)")


loadIocsh("iocStats.iocsh", "IOCNAME=$(IOCNAME)")

iocInit()

dbl > "$(TOP)/../${IOCNAME}_PVs.list"
