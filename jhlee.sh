
echo ">>> Linux"
uname -ar

echo ">>> rm -rf e3-*"
rm -rf e3-*


echo ">>> Creating CONFIG_BASE.local ... "

echo "E3_EPICS_PATH:=/tmp/e3_jhlee" > CONFIG_BASE.local

echo ">>> Creating RELEASE.local ... "
echo "EPICS_BASE:=/tmp/e3_jhlee/base-3.15.5" > RELEASE.local
echo "E3_REQUIRE_VERSION:=0.0.1" >> RELEASE.local


echo ">>> Creating RELEASE_DEV.local for require... "
echo "EPICS_BASE:=/tmp/e3_jhlee/base-3.15.5" > RELEASE_DEV.local
echo "E3_REQUIRE_VERSION:=0.0.1" >> RELEASE_DEV.local


#
bash e3.bash -g common base
bash e3.bash -g common devreq
bash e3.bash -g common mod
