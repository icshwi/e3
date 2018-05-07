#!/bin/bash

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

. ${SC_TOP}/.cfgs/.e3_functions.cfg



aa=$1

E3_MODULE_LOCATION=${E3_SITEMODS_PATH}
#E3_MODULE_LOCATION=${EPICS_BASE}


pushd ${aa}



echo "Original Dependency Generator"
cat *.d | sed 's/ /\n/g'  | sed -n "s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*%\1 \2%p;s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([^/]*\)/.*%\1 \2%p" | sort -u


#cat *.d | sed 's/ /\n/g'
echo ""
echo "Working version 1"

cat *.d 2>/dev/null | sed 's/ /\n/g' | sed -n "s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([^/]*\)/.*%\1 \2%p" | sort -u 
#cat *.d 2>/dev/null | sed 's/ /\n/g' | sed -n "s%${E3_MODULE_LOCATION}/ *\([^/]*\) / \([0-9]*\.[0-9]*\)\.[0-9]* / .*%\1 \2%p" | sort -u
#                        /testing/base-3.15.5/require/3.0.0/siteMods/ asyn       / 4.33.0 /include/asynOctet.h
echo ""
echo "Working version 2"
cat *.d 2>/dev/null | sed 's/ /\n/g' | sed -n "s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([0-9]*\.[0-9]*\.[0-9]*\)/.*%\1 \2%p" | sort -u


echo ""
echo "Working version 3"
cat *.d | sed 's/ /\n/g'  | sed -n "s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*%\1 \2%p;s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([^/]*\)/.*%\1 \2%p" | grep -v "include" | sort -u


echo ""
echo "Working version 4"
sed 's/ /\n/g' *.d | sed -n "s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*%\1 \2%p;s%${E3_MODULE_LOCATION}/*\([^/]*\)/\([^/]*\)/.*%\1 \2%p" | grep -v "include" | sort -u


# cat *.d 


popd


# sed -n 's%${EPICS_MODULES}/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*%\1 \2%p;s%$(EPICS_MODULES)/*\([^/]*\)/\([^/]*\)/.*%\1 \2%p'

#cat *.d | sed 's/ /\n/g'  | sed -n 's%${EPICS_MODULES}/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*%\1 \2%p;s%${EPICS_MODULES}/*\([^/]*\)/\([^/]*\)/.*%\1 \2%p'| sort -u

#cat *.d | sed 's/ /\n/g'  | sed -n 's%/epics/base-3.15.5/require/3.0.1/siteMods/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*/p'
#sed -nE 's/${EPICS_MODULES}/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*%\1 \2%p'

# cat *.d | sed 's/ /\n/g'
# cat *.d | tr " " "\n"


#sed -nE 's/^NAME="([^"]+)".*/\1/p'
