
#- save_restore setup
#- Define the autosave PREFIX in the similar way as others
epicsEnvSet(AS_NAME,   "autosave")
epicsEnvSet(AS_PREFIX, "$(P):$(R):$(AS_NAME):")
epicsEnvSet(AS_PATH,   "$(TOP)/$(AS_NAME)")

#- Debug-output level
save_restoreSet_Debug(0)


#- Set the PREFIX 
save_restoreSet_status_prefix("$(AS_PREFIX)")

#- ok to restore a save set that had missing values (no CA connection to PV)?
#- ok to save a file if some CA connections are bad?
save_restoreSet_IncompleteSetsOk(1)

#- In the restore operation, a copy of the save file will be written.  The
#- file name can look like "auto_settings.sav.bu", and be overwritten every
#- reboot, or it can look like "auto_settings.sav_020306-083522" (this is what
#- is meant by a dated backup file) and every reboot will write a new copy.
save_restoreSet_DatedBackupFiles(1)

#- specify where save files should be
set_savefile_path    ("$(AS_PATH)", "/save")
set_requestfile_path ("$(AS_PATH)", "/req")

#- In case, there are no directories.
#- system command is not enabled by default.
#- registrar(iocshSystemCommand) should be defined in *.dbd of the IOC application

system("install -d $(AS_PATH)/save")
system("install -d $(AS_PATH)/req")

set_pass0_restoreFile("$(IOC)_values.sav")
set_pass0_restoreFile("$(IOC)_settings.sav")
set_pass1_restoreFile("$(IOC)_values.sav")

#- Number of sequenced backup files (e.g., 'auto_settings.sav0') to write
save_restoreSet_NumSeqFiles(3)


dbLoadRecords("save_restoreStatus.db", "P=$(AS_PREFIX)")
