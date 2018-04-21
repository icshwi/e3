
module_a=$1

cd $module_a
emacs configure/E3/RULES_E3

make init

make rebuild

ls /testing/epics/base-3.15.5/require/0.0.0/siteLibs/linux-x86_64/lib*

