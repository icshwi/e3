# e3 

This is the e3 initial setup script. It is now testing while I am working on individual epics modules e3-somethings.

##

The following command guides us to lead the first glimpse of E3. SUDO permission is needed to setup it.

```
 e3 (master)$ bash e3.bash
```

After finishing the installation, source the dynamic environment via

```
e3 (master)$ source e3-env/setE3Env.bash
```

Then,
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
