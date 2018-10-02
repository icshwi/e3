#!/bin/bash


git clone https://github.com/icshwi/etherlabmaster
cd etherlabmaster
make init
make patch
make build
make install

sudo tee /etc/ld.so.conf.d/e3_ethercat.conf >/dev/null <<"EOF"
/opt/etherlab/lib 
EOF

sudo ldconfig 
exit

