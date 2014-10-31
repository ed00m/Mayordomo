#!/bin/sh

###########
#
# ESTE SCRIPT BUSCA INTERFACES DE RED ETHERNET EN EL SISTEMA Y
# LES CAMBIA EL MAC ADDRESS
#
##########

USEREXEC=`whoami`

if [ ${USEREXEC} != "root" ];then
    echo "* EJECUTA ESTE SCRIPT COMO ROOT PARA OBTENER MAS RESULTADOS"
        exit 1
else
    ifconfig|awk '/eth/ { print $1 }' > devices
    echo "* Buscando interfaces ethernet"
    echo "* Reasignando MAC ADDRESS"
    
    for i in `cat devices`;
    do
        VARR=""
        
        for j in $(seq 6);
        do
            VARR=${VARR}":"$(tr -dc a-d0-5 < /dev/urandom|head -c 2)
        done

        MAC=$(echo ${VARR} |sed -e "s/^://") 
        echo "ifconfig "${i}" hw ether "${MAC}
    done
fi
exit 0
