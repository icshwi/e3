
echo ">>> Linux"
uname -ar

echo ">>> rm -rf e3-*"
rm -rf e3-*


echo ">>> Creating CONFIG_BASE.local ... "

echo "E3_EPICS_PATH:=/tmp" > CONFIG_BASE.local

echo ">>> Creating RELEASE.local ... "
echo "EPICS_BASE:=/tmp/base-3.15.5" > RELEASE.local


git config --global url."git@bitbucket.org:".insteadOf https://bitbucket.org/
git config --global url."git@gitlab.esss.lu.se:".insteadOf https://gitlab.esss.lu.se/
