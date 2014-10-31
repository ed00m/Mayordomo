#!/bin/sh -x
set -e
set -v

path=$(pwd)
Deployment=${path}/Deployment

sh ${Deployment}/baseLinode.sh env
sh ${Deployment}/zshInstall.sh
sh ${Deployment}/zshtheme.sh
cp ${Deployment}/vimrc ~/.vimrc

exit 0
