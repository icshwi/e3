#!/bin/bash


git clone https://github.com/icshwi/etherlabmaster
cd etherlabmaster
make init
make patch
make build
make install

exit

