#!/bin/bash

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"


E3_PATH="$1"
BASE="$2"
REQUIRE="$3"
C=$(tr -cd 0-9 </dev/urandom | head -c 8)

SESSION="${BASE}-${REQUIRE}-${C}"

#source ${E3_PATH}/base-${BASE}/require/${REQUIRE}/bin/setE3Env.bash

sudo chgrp root $(which screen)
sudo chmod 777 /var/run/screen

cat > ${E3_PATH}/.screenrc <<EOF

logfile ${E3_PATH}/output.log
logfile flush 1
log on
logtstamp after 1
logtstamp on
EOF


screen -c ${E3_PATH}/.screenrc -dm -L -S ${SESSION} /bin/bash -c "${E3_PATH}/base-${BASE}/require/${REQUIRE}/bin/iocsh.bash ${SC_TOP}/../.cmd"

sleep 30

cat ${E3_PATH}/output.log

sleep 30

screen -X -S ${SESSION} quit

