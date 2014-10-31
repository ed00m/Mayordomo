#!/bin/sh -x
set -e

###########
#
# ESTE SCRIPT BUSCA ARCHIVOS VACIOS EN EL SISTEMA
#
##########

USEREXEC=`whoami`

if [ ${USEREXEC} != "root" ];then
    echo "* EJECUTA ESTE SCRIPT COMO ROOT PARA OBTENER MAS RESULTADOS"
    exit 1
else
    find / -depth -type f -empty
fi
exit 0
