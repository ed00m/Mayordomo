#!/bin/sh -x

hostname=$1
ip=$2
gateway=$3
netmask=$4
vcpus=$5
dist=$6

xen-create-image --hostname ${hostname} \
                 --ip ${ip} \
                 --gateway ${gateway} \
                 --netmask ${netmask} \
                 --vcpus ${vcpus} \
                 --dist ${dist} \
                 --dir /var
