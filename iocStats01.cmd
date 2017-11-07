require iocStats, 1856ef5

epicsEnvSet("PREF", "E3Test")
epicsEnvSet("IOCST", "IocStat")
epicsEnvSet("IOC",  ${PREF})

#dbLoadTemplate(moduleversion.template, "IOC=${IOC}")
dbLoadTemplate(iocAdminSoft.substitutions, "IOC=${PREF}:${IOCST}")
dbl > "${IOC}_PVs.list"
