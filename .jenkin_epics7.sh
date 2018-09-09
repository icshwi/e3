
echo ">>> Linux"
uname -ar

echo ">>> rm -rf e3-*"
rm -rf e3-*

TARGET="/jenkins/epics"
VERSION="7.0.1.1"

epics_base="${TARGET}/base-${VERSION}"


echo ""
echo ">>> Creating CONFIG_BASE.local ... "
echo "E3_EPICS_PATH:=${TARGET}"       > CONFIG_BASE.local
echo "EPICS_BASE_TAG:=tags/R${VERSION}" >> CONFIG_BASE.local
echo "E3_BASE_VERSION:=${VERSION}" >> CONFIG_BASE.local

echo ""
echo ">>> Creating RELEASE.local ... "
echo "EPICS_BASE:=${epics_base}" > RELEASE.local


git config --global url."git@bitbucket.org:".insteadOf https://bitbucket.org/
git config --global url."git@gitlab.esss.lu.se:".insteadOf https://gitlab.esss.lu.se/
