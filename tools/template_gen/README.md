E3 Module Template Builder
====

# Requirements

## Template Confiugration File
One should define and understand the following variables first. It is important to understand what differences are

* ```EPICS_MODULE_NAME```  : used for the E3 module name, where one use it as its name
* ```EPICS_MODULE_URL```   : shown as the module source repoistory URL
* ```E3_MODULE_SRC_PATH``` : shown as the source code directory name in EPICS_MODULE_URL
* ```E3_TARGET_URL```      : used for the E3 module repository 

For example, one has the following EPICS source code :
```
https://github.com/jeonghanlee/snmp3
```
And we would like to keep e3 module in the following:
```
https://github.com/icshwi/e3-snmp3
```

In this case, one should define the Module Configuration File as 

```
EPICS_MODULE_NAME:=snmp3
EPICS_MODULE_URL:=https://github.com/jeonghanlee
E3_MODULE_SRC_PATH:=snmp3
E3_TARGET_URL:=https://github.com/icshwi
```

The second example, the EPICS source code : 
```
https://bitbucket.org/europeanspallationsource/m-epics-sis8300
```
And we would like to keep this in :
```
https://github.com/icshwi/e3-sis8300
```

In this case, one should define the Module Configuration File as 

```
EPICS_MODULE_NAME:=sis8300
EPICS_MODULE_URL:=https://bitbucket.org/europeanspallationsource
E3_MODULE_SRC_PATH:=m-epics-sis8300
E3_TARGET_URL:=https://github.com/icshwi
```

## Target Git Repository (E3_TARGET_URL)

One should create the empty respository, which has the e3-${EPICS_MODULE_NAME} name  in ${E3_TARGET_URL}.


# Procedure 

```
template_gen (master)$ bash create_e3_modules.bash -m modules_conf/snmp3.conf
>> 
EPICS_MODULE_NAME  :                                                         snmp3
E3_MODULE_SRC_PATH :                                                         snmp3
EPICS_MODULE_URL   :                                https://github.com/jeonghanlee
E3_TARGET_URL      :                                     https://github.com/icshwi
>> 
e3 module name     :                                                      e3-snmp3
e3 module url full :                          https://github.com/jeonghanlee/snmp3
e3 target url full :                            https://github.com/icshwi/e3-snmp3
>> 
Initialized empty Git repository in /home/jhlee/e3/tools/template_gen/e3-snmp3/.git/
https://github.com/jeonghanlee/snmp3 is adding as submodule...
Cloning into 'snmp3'...
remote: Counting objects: 327, done.
remote: Total 327 (delta 0), reused 0 (delta 0), pack-reused 327
Receiving objects: 100% (327/327), 1.64 MiB | 776.00 KiB/s, done.
Resolving deltas: 100% (128/128), done.
Checking connectivity... done.
add ignore = all ... 


>>>> Do you want to add the URL https://github.com/icshwi/e3-snmp3 for the remote repository?
>>>> In that mean, you already create an empty repository at https://github.com/icshwi/e3-snmp3. (y/n)? n


>>>> We are skipping add the remote repository url now. 
>>>> You can do this later with the following commands. 
>>>> $ git remote add origin https://github.com/icshwi/e3-snmp3 

The following files should be modified according to the module : 

   * e3-snmp3/configure/CONFIG_MODULE
   * e3-snmp3/configure/RELEASE

One can check the e3- template works via 
   cd e3-snmp3
   make init
   make vars


In case, one would like to push this e3 module to git repositories
Please use the following commands  in e3-snmp3/:

   * git remote add origin https://github.com/icshwi/e3-snmp3
   * git commit -m "First commit"
   * git push -u origin master

```
