
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