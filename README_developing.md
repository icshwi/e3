e3 building configuration
===


# Configuration 

```
 e3 (master)$ ./e3_building_config.bash 

Usage    : ./e3_building_config.bash [-t <target_path>] [-b <base_version>] [-r <require_version>] [-c <base_tag>] setup

               -t : default /epics
               -b : default 3.15.5
               -r : default 3.0.2
               -c : default 3.15.5

 bash ./e3_building_config.bash -t /epics/test/ -r 3.0.0

```


## Case 1

* Base 3.15.5 with tags/R3.15.5
* Require 3.0.2
* Installation Path : /epics

```
e3 (master)$ ./e3_building_config.bash -t /epics -b 3.15.5 -r 3.0.2 setup
>> 
  The following configuration for e3 installation
  will be generated :

>> Set the global configuration as follows:
>>
  EPICS TARGET        : /epics
  EPICS_BASE VERSION  : 3.15.5
  E3_REQUIRE_VERSION  : 3.0.2
  EPICS_MODULE_TAG    : 3.15.5
  EPICS_BASE          : /epics/base-3.15.5
  E3_REQUIRE_LOCATION : /epics/base-3.15.5/require/3.0.2

>> Do you want to continue (y/N)? 

```

## Case 2

* Base 3.15.6 with tags/R3.15.6-rc1
* Require 3.0.2
* Installation Path : /epics

```
 e3 (master)$ ./e3_building_config.bash -t /epics -b 3.15.6 -c 3.15.6-rc1  -r 3.0.2 setup
>> 
  The following configuration for e3 installation
  will be generated :

>> Set the global configuration as follows:
>>
  EPICS TARGET        : /epics
  EPICS_BASE VERSION  : 3.15.6
  E3_REQUIRE_VERSION  : 3.0.2
  EPICS_MODULE_TAG    : 3.15.6-rc1
  EPICS_BASE          : /epics/base-3.15.6
  E3_REQUIRE_LOCATION : /epics/base-3.15.6/require/3.0.2

>> Do you want to continue (y/N)? 
```

## Case 3

* Base 7.0.1.1 with tags/R7.0.1.1
* Require 3.0.2
* Installation Path : /epics7


```
e3 (master)$ ./e3_building_config.bash -t /epics7 -b 7.0.1.1  -r 3.0.2 setup
>> 
  The following configuration for e3 installation
  will be generated :

>> Set the global configuration as follows:
>>
  EPICS TARGET        : /epics7
  EPICS_BASE VERSION  : 7.0.1.1
  E3_REQUIRE_VERSION  : 3.0.2
  EPICS_MODULE_TAG    : 7.0.1.1
  EPICS_BASE          : /epics7/base-7.0.1.1
  E3_REQUIRE_LOCATION : /epics7/base-7.0.1.1/require/3.0.2

>> Do you want to continue (y/N)? 
```


# Build e3


## Build BASE and require
```
$ bash e3.bash base
$ bash e3.bash req
```

## Build Modules
```
$ base e3.bash -c mod
```