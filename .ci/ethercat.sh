#!/bin/bash


git clone https://github.com/icshwi/etherlabmaster
cd etherlabmaster

make init
make patch
make build
make install

sudo tee /etc/ld.so.conf.d/ethercat.conf >/dev/null <<"EOF"
/opt/etherlab/lib 
EOF

cat /etc/ld.so.conf.d/ethercat.conf

sudo ldconfig

export LD_LIBRARY_PATH=/opt/etherlab/lib
