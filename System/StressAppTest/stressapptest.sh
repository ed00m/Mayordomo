#!/bin/sh -x

#############################################
# StressAppTest
############################################

SOURCE=stressapptest-1.0.6_autoconf.tar.gz
DIR=stressapptest-1.0.6_autoconf

tar zxvf ${SOURCE}
cd ${DIR}
./configure
make
sudo make install
