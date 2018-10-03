#!/bin/bash

mkdir -p ${HOME}/.ssh
echo -e "Host *\n StrictHostKeyChecking no" > ${HOME}/.ssh/config
echo -e "machine bitbucket.org\n  login jeonghanlee\n  password $CI_USER_PASSWORD" > ${HOME}/.netrc

bash .ci/ethercat.sh  > /dev/null 2>&1 
#  source .ci/ethercat_libpath.sh
