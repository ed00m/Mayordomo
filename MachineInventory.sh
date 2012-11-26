#!/bin/sh
##########################################
# SCRIPT BASE PARA INVENTARIO DE EQUIPOS
# VERSION 1
##########################################

kernel=`uname -s -r -v` # -s, --kernel-name | -r, --kernel-release | -v, --kernel-version
maquina=`uname -n -m -o` # -n, --nodename | -m, --machine | -p, --processor | -o, --operating-system | -i, --hardware-platform
fecha=`date "+%Y%m%d"`
ipserver=`sudo ifconfig|awk '/eth/ { print $0 }'|awk '/[0-2][0-5][0-5].[0-2][0-5][0-5].[0-2][0-5][0-5]./ { print $2 }'|cut -d ":" -f2`
memoria=`free -m|awk '/total/ || /Mem/ || /Swap/ { print $1"\t"$2 }'|sed -e "s@total@\ttotal@" -e "s@used@@" -e "s@Mem@\tMem@" -e "s@Swap@\tSwap@"`
cpuinfo=`cat /proc/cpuinfo |grep -iE  "processor|cpu cores|cpu Mhz|cache size"|sort -u|sed -e "s@  @\n@g" -e "s@processor@\tprocessor@g" -e "s@cpu@\tcpu@g" -e "s@cache@\n\tcache@g" -e "s@model@\tmodel@g"`

##########################################
# IMPRIME INFO
##########################################

echo "* nombre: "${maquina}
echo "* kernel-version: "${kernel}
echo "* fecha: "${fecha}
echo "* IP: "${ipserver}
echo "* Memoria: ${memoria}"
echo "* CPU info: ${cpuinfo}"

exit 0
