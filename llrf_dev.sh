
echo ">>> Linux"
uname -ar

echo ">>> rm -rf e3-*"
rm -rf e3-*

TARGET="/epics/llrf"
epics_base="${TARGET}/base-3.15.5"

echo ">>> Creating CONFIG_BASE.local ... "

echo "E3_EPICS_PATH:=${TARGET}" > CONFIG_BASE.local

echo ">>> Creating RELEASE.local ... "
echo "EPICS_BASE:=${epics_base}" > RELEASE.local




bash e3.bash base
bash e3.bash req


bash e3.bash -cl cmod
bash e3.bash -cl gmod

bash e3.bash -c imod
bash e3.bash -c bmod


cd e3-asyn

echo ">>> Creating CONFIG_MODULE.local for ASYN ... "

echo "EPICS_MODULE_TAG:=tags/R4-27"  > configure/CONFIG_MODULE.local
echo "E3_MODULE_VERSION:=4.27.0"    >> configure/CONFIG_MODULE.local

make init
make env
make rebuild

cd ..

echo ">>"
echo ">>"

bash e3.bash -lo imod
bash e3.bash -lo bmod



