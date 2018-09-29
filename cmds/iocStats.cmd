require iocStats, ae5d083

epicsEnvSet("PREF", "E3Test")
epicsEnvSet("IOCST", "IocStat")
epicsEnvSet("IOC",  ${PREF})

#dbLoadRecords("moduleversion.db", "IOC=${IOC}")
dbLoadRecords("iocAdminSoft.db","IOC=${PREF}:${IOCST}")
dbl > "${IOC}_PVs.list"
