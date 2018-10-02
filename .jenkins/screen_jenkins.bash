#!/bin/bash

SESSIONNAME=$1
STARTUP=$2

# https://superuser.com/questions/235760/ld-library-path-unset-by-screen
# LD_LIBRARY_PATH unset within screen

sudo chgrp root $(which screen)
sudo chmod 777 /var/run/screen


cat > ${HOME}/.screenrc <<EOF

logfile ${HOME}/output.log
logfile flush 1
log on
logtstamp after 1
logtstamp on
EOF


screen -dm -L -S ${SESSIONNAME} /bin/bash -c "iocsh.bash ${STARTUP}"

sleep 2

cat ${HOME}/output.log

killall screen

exit
