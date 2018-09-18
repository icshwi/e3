

TARGET="/epics"
VERSION="7.0.1.1"

epics_base="${TARGET}/base-${VERSION}"


echo ""
echo ">>> Creating CONFIG_BASE.local ... "
echo "E3_EPICS_PATH:=${TARGET}" 
echo "EPICS_BASE_TAG:=tags/R${VERSION}"
echo "E3_BASE_VERSION:=${VERSION}"     
echo "E3_CROSS_COMPILER_TARGET_ARCHS ="

echo "E3_EPICS_PATH:=${TARGET}"          > CONFIG_BASE.local
echo "EPICS_BASE_TAG:=tags/R${VERSION}" >> CONFIG_BASE.local
echo "E3_BASE_VERSION:=${VERSION}"      >> CONFIG_BASE.local
echo "E3_CROSS_COMPILER_TARGET_ARCHS =" >> CONFIG_BASE.local



## Require needs 3.0.1
echo ""
echo ">>> Creating RELEASE_DEV.local ... "
echo "EPICS_BASE:=${epics_base}"
echo "E3_REQUIRE_VERSION:=3.0.1"
echo "E3_SEQUENCER_NAME:=sequencer"     
echo "E3_SEQUENCER_VERSION:=2.2.6"


echo "EPICS_BASE:=${epics_base}"      > RELEASE_DEV.local
echo "E3_REQUIRE_VERSION:=3.0.1"     >> RELEASE_DEV.local
echo "E3_SEQUENCER_NAME:=sequencer"  >> RELEASE_DEV.local
echo "E3_SEQUENCER_VERSION:=2.2.6"   >> RELEASE_DEV.local



## Require 3.0.1 is needed
echo ""
echo ">>> Creating RELEASE.local ... "
echo "EPICS_BASE:=${epics_base}"
echo "E3_REQUIRE_VERSION:=3.0.1"
echo "E3_SEQUENCER_NAME:=sequencer"     
echo "E3_SEQUENCER_VERSION:=2.2.6" 

echo "EPICS_BASE:=${epics_base}"      > RELEASE.local
echo "E3_REQUIRE_VERSION:=3.0.1"     >> RELEASE.local
echo "E3_SEQUENCER_NAME:=sequencer"  >> RELEASE.local
echo "E3_SEQUENCER_VERSION:=2.2.6"   >> RELEASE.local


sed -i 's/#e3-seq/e3-seq/g'             configure/MODULES_COMMON
sed -i 's/e3-sequencer/#e3-sequencer/g' configure/MODULES_COMMON

#bash e3.bash base
#bash e3.bash devreq
#bash e3.bash -ctifealb mod
