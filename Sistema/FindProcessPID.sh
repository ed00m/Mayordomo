#!/bin/sh
set -e
#########################################
# SCRIPT PARA BUSCAR PROCESOS SEGUN
# CONDICIONES
#########################################

OPTION=$1
VALOR=$2
#########################################
# OPCIONES DE PS
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
#########################################

case $OPTION in
    -c|-cpu|-CPU)

        execAWK="awk '{ if ("'$3 > '${VALOR}') print $2 }'"'"
        execPS="ps aux"
        echo "${execPS}|${execAWK}" | sh

    ;;
    -m|-mem|-MEM)

        execAWK="awk '{ if ("'$4 > '${VALOR}') print $2 }'"'"
        execPS="ps aux"
        echo "${execPS}|${execAWK}" | sh

    ;;
    -u|-user|-USER)

        execAWK="awk '{ if ("'$1 > '${VALOR}') print $2 }'"'"
        execPS="ps aux"
        echo "${execPS}|${execAWK}" | sh

    ;;
    *)
    echo "* Modo de uso"
    echo $0" -u root"
    echo $0" -c 80"
    echo $0" -m 400"
    ;;

esac

#echo "* Resultado"
#echo -e ${EXEC}
exit 0
