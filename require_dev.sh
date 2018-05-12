
echo ">>> Linux"
uname -ar

echo ">>> rm -rf e3-*"
rm -rf e3-*

TARGET="/epics/devreq"
epics_base="${TARGET}/base-3.15.5"

echo ">>> Creating CONFIG_BASE.local ... "

echo "E3_EPICS_PATH:=${TARGET}" > CONFIG_BASE.local

echo ">>> Creating RELEASE.local ... "
echo "EPICS_BASE:=${epics_base}" > RELEASE.local
echo "E3_REQUIRE_VERSION:=0.0.1" >> RELEASE.local


echo ">>> Creating RELEASE_DEV.local for require... "
echo "EPICS_BASE:=${epics_base}" > RELEASE_DEV.local
echo "E3_REQUIRE_VERSION:=0.0.1" >> RELEASE_DEV.local


bash e3.bash base
bash e3.bash devreq
bash e3.bash -ctifea mod

