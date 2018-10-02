#!/bin/bash


TARGET_PATH=$1
SESSION_NAME=$2
STARTUP=$3

# https://superuser.com/questions/235760/ld-library-path-unset-by-screen
# LD_LIBRARY_PATH unset within screen

sudo chgrp root $(which screen)
chmod 777 /var/run/screen


cat > ${TARGET_PATH}/.screenrc <<EOF

logfile ${TARGET_PATH}/output.log
logfile flush 1
log on
logtstamp after 1
logtstamp on
EOF


screen -c ${TARGET_PATH}/.screenrc -dm -L -S ${SESSION_NAME} /bin/bash -c "iocsh.bash ${STARTUP}"

sleep 2

cat ${TARGET_PATH}/output.log

killall screen

exit
