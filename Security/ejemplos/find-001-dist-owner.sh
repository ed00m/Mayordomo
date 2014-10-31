#!/bin/sh -x
set -e

USER=${1:?INGRESA NOMBRE DEL USUARIO}

###########
#
# ESTE SCRIPT BUSCA LOS ARCHIVOS CON OWNER DISTINTO AL USUARIO QUE SE INGRESO
#
##########

USEREXEC=`whoami`

if [ ${USEREXEC} != "root" ];then
    echo "* EJECUTA ESTE SCRIPT COMO ROOT PARA OBTENER MAS RESULTADOS"
    exit 1
else
    find / ! -user ${USER} -exec ls -ltrh {} \;
fi
exit 0
