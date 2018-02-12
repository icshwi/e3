# e3 : European Spallation Source EPICS Environment

This is the e3 initial setup script. It is now testing while I am working on individual epics modules e3-somethings.

## Tested Platforms
* Debian 8 (Jessie)
* Debian 9 (Stretch)
* Raspbian Stretch
* CentOS 7.4
* Ubuntu 16.04.3 LTS (Xenial Xerus)
* Ubuntu 17.10 (Artful Aardvark)
* LinuxMint 18.3 (sylvia)
* Fedora 27 (Workstation Edition)

##

NOTE that if one has the pre-existed EPICS environment, please run the following command first:
```
 e3 (master)$ source env_reset.sh 
```


The following command guides us to lead the first glimpse of E3. SUDO permission is needed to setup it.

```
 e3 (master)$ make build
```

After finishing the installation, one can test all compiled modules loading via
```
 e3 (master)$ make load
```

If one see the clean ioc shell, the enviornment is ready to use. However, one should source the dynamic environment via

```
e3 (master)$ source e3-env/setE3Env.bash
```
, because it gives us more flexiable way to have more than one EPICS environment in a host machine. Since then, one can run the example ioc through 
```
e3 (master)$ iocsh.bash iocStats.cmd
```

Open another terminal, set the environment via source first, then
run the caget_pvs.bash with the generated pv list file.

```
e3 (master)$ bash caget_pvs.bash E3Test_PVs.list
.............
E3Test:IocStat:GTIM_TIME       8.77333e+08
E3Test:IocStat:IOC_CPU_LOAD    0
E3Test:IocStat:LOAD            0
E3Test:IocStat:MEM_FREE        7.60112e+09
E3Test:IocStat:MEM_MAX         1.67588e+10
E3Test:IocStat:MEM_USED        6.16858e+06
E3Test:IocStat:PARENT_ID       32164
E3Test:IocStat:PROCESS_ID      32183
E3Test:IocStat:RECORD_CNT      64
E3Test:IocStat:SUSP_TASK_CNT   0
E3Test:IocStat:SYS_CPU_LOAD    29.779
jhlee@kaffee: e3 (master)$ bash caget_pvs.bash E3Test_PVs.list "LOAD"
E3Test:IocStat:LOAD_UPD_TIME   10
E3Test:IocStat:IOC_CPU_LOAD    0
E3Test:IocStat:LOAD            0
E3Test:IocStat:SYS_CPU_LOAD    33.3701
```

The useful options are

```
$ bash caget_pvs.bash E3Test_PVs.list EPICS_VERS
$ watch -n 1 "bash caget_pvs.bash E3Test_PVs.list HEARTBEAT"

```


