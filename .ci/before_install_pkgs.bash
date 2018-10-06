#!/bin/bash

sudo apt-get -qq update
sudo apt-get install -y linux-headers-$(uname -r) 
sudo apt-get install -y build-essential realpath ipmitool libtool automake tclx  tree screen re2c darcs
sudo apt-get install -y libreadline-dev libxt-dev x11proto-print-dev libxmu-headers libxmu-dev libxpm-dev libxmuu-dev libxmuu1 libpcre++-dev libsnmp-dev python-dev libnetcdf-dev libhdf5-dev libpng-dev libbz2-dev libxml2-dev libusb-dev libusb-1.0-0-dev libudev-dev libraw1394-dev libboost-dev libboost-regex-dev libboost-filesystem-dev 
