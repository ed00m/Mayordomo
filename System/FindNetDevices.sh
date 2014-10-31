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
echo "* INTERFAZ|IP|MAC"
echo "Primero mostrare un nombre de interfaz y su Mac por estar en la primera linea"

ifconfig -a|awk '/eth/ || /wlan/ || /tun/ || /bridg/ || /lo/ || /usb/ { print "* "$1" | "$5 }'
sleep 5
clear

echo "Ahora hare una busqueda usando tanto /proc como ifconfig"

DEVICES=$(ls -1 /proc/net/dev_snmp6)

for INTERFACES in ${DEVICES};do
    DEVNAME=${INTERFACES}
    DEVMAC=$(ifconfig ${INTERFACES} |awk '/HWaddr/ { print $5 }')
    DEVIP=$(ifconfig ${INTERFACES} | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

    echo ${DEVNAME}"|"${DEVIP}"|"${DEVMAC}
done

sleep 5
clear

echo "y ¿si usamos solo /proc?"
clear
echo "continuara"
exit 0
