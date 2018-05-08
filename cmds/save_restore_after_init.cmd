#- Save other things every thirty seconds

makeAutosaveFileFromDbInfo("$(AS_PATH)/req/$(IOC)_settings.req", "autosaveFields_pass0")
makeAutosaveFileFromDbInfo("$(AS_PATH)/req/$(IOC)_values.req",   "autosaveFields")


create_monitor_set("$(IOC)_settings.req", 5, "P=$(AS_PREFIX)")
create_monitor_set("$(IOC)_values.req",   5, "P=$(AS_PREFIX)")

