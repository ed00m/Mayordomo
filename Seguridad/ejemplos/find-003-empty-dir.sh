#!/bin/sh -x
set -e

###########
#
# ESTE SCRIPT BUSCA DIRECTORIOS VACIOS EN EL SISTEMA
#
##########

USEREXEC=`whoami`

if [ ${USEREXEC} != "root" ];then
    echo "* EJECUTA ESTE SCRIPT COMO ROOT PARA OBTENER MAS RESULTADOS"
    exit 1
else
    find / -depth -type d -empty
fi
exit 0
