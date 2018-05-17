
echo ">>> Linux"
uname -ar

echo ">>> rm -rf e3-*"
rm -rf e3-*

TARGET="/jenkins/epics"
epics_base="${TARGET}/base-3.15.5"


echo ""
echo ">>> Creating CONFIG_BASE.local ... "
echo "E3_EPICS_PATH:=${TARGET}" > CONFIG_BASE.local

echo ""
echo ">>> Creating RELEASE.local ... "
echo "EPICS_BASE:=${epics_base}" > RELEASE.local


git config --global url."git@bitbucket.org:".insteadOf https://bitbucket.org/
git config --global url."git@gitlab.esss.lu.se:".insteadOf https://gitlab.esss.lu.se/
