
## Copy : Update a config file

The following example shows how to update one file (DEFINES_FT) through all modules. This example was from the real modification of DEFINES_FT in e3-StreamDevice. 


```
e3 (master)$ scp e3-StreamDevice/configure/E3/DEFINES_FT .
e3 (master)$ bash e3.bash -ctifealb gmod
e3 (master)$ bash maintain_e3.bash -ctifealb copy "configure/E3/DEFINES_FT"
e3 (master)$ bash maintain_e3.bash -ctifealb diff "configure/E3/DEFINES_FT"
e3 (master)$ bash maintain_e3.bash -ctifealb add "configure/E3/DEFINES_FT"
e3 (master)$ bash maintain_e3.bash -ctifealb commit "update DEFINES_FTfor Patch"
e3 (master)$ bash maintain_e3.bash -ctifealb push

```

bash e3.bash -ctifeao gmod
bash maintain_e3.bash -ctifeao copy "configure/RELEASE"
bash maintain_e3.bash -ctifeao diff "configure/RELEASE"
bash maintain_e3.bash -ctifeao add "configure/RELEASE"

## Commit changed files

Edit all *.Makefile in the following repositories, and commit their changes to its own repositories.

```
$ ./maintain_e3.bash -eo env

>> Vertical display for the selected modules :

 Modules List 
    0 : e3-exprtk
    1 : e3-motor
    2 : e3-ecmc
    3 : e3-ethercatmc
    4 : e3-ecmctraining

$ ./maintain_e3.bash -eo diff "*.Makefile"
$ ./maintain_e3.bash -eo add "*.Makefile"
$ ./maintain_e3.bash -eo commit " clean circular includes in makefile "
$ ./maintain_e3.bash -eo push

```


## Compare what difference in different forms

* Show all difference in all changed files

```
./maintain_e3.bash -io diff
```

* Show only the difference with the --stat option

```
./maintain_e3.bash -io diff "--stat"

```

* Show only the difference of a specific file with the --stat option

```
./maintain_e3.bash -io diff "--stat *Makefile"

```

## Replace "a string" in all Makefile

```
$ grep -r  EthercatMC_VERSION= *
...
sfs/sysfs.Makefile:ethercatmc_VERSION=

$ grep -rl ethercatmc_VERSION .
...

./e3-sscan/sscan.Makefile
./e3-recsync/recsync.Makefile

$ grep -rl ethercatmc_VERSION . | xargs sed -i 's/ethercatmc_VERSION/EthercatMC_VERSION/g'
$ bash maintain_e3.bash -ctileo diff "--stat"
$ bash maintain_e3.bash -ctileo add "*.Makefile"
$ bash maintain_e3.bash -ctileo diff "--stat"
$ bash maintain_e3.bash -ctileo commit "even if EthercatMC has no include, use the correct name"
$  bash maintain_e3.bash -ctileo push


```
## Insert a string to a file the after a specific string
```
$ ./maintain_e3.bash -c insert "configure/RELEASE" "# The definitions shown*" "-include \$(TOP)/../../RELEASE.local"
$ ./maintain_e3.bash -ctifeabl4d diff "--stat configure/RELEASE"
$ ./maintain_e3.bash -ctifeabl4d insert "configure/RELEASE_DEV" "# The definitions shown*" "-include \$(TOP)/../../RELEASE_DEV.local"
./maintain_e3.bash -ctifeabl4d diff "--stat"


```
