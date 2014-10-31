#!/bin/sh

####################################
# ESTE SCRIPT BUSCA UN PROCESO EN EJECUCION
# BAJO CONDICIONES DEFINIDAS
####################################

#SERVICIO=${1:?INGRESE SERVICIO}

#echo "* Buscando servicio"
#ps aux |awk '/${SERVICIO}/{ if ($4 > 1) print $0 }'

echo "* Buscando FS llenos (>85) y vacios(<10)"
df -h |awk '{ if ($5 > 85 || $5 < 10) print $0 }'


