#!/bin/sh 
set -e
#########################################
# SCRIPT PARA ENCONTRAR LAS DIRECCIONES
# MAC DE LOS DISPOSITICOS ACTIVOS
# VERSION 2
#########################################

#########################################
# EJECUCION
#########################################
echo "* INTERFAZ | MAC"
ifconfig|awk '/eth/ || /wlan/  { print "* "$1" | "$5 }'

exit 0
