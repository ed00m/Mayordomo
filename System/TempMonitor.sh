#!/bin/sh -x 
set -e

#########################################
# SCRIPT PARA MONITOREO DE TEMPERATURA
# USA LM-SENSORS (SENSORS)
# VERSION 2
########################################

# Opciones para kernel => -s, --kernel-name | -r, --kernel-release | -v, --kernel-version
kernel=`uname -s -r -v`

# Opciones para maquina => -n, --nodename | -m, --machine | -p, --processor | -o, --operating-system | -i, --hardware-platform
maquina=`uname -n -m -o`

fecha=`date "+%Y%m%d_%H%M%S"`
log="/tmp/$$_${fecha}.log"

asunto="Monitor de temperatura "${maquina}" - "${fecha}

remitente=remitente@dominio.tld
destinatarios=destinatarios@dominio.tld

tempCritica=80
tempWarning=70

ACCION=${1:?Ingrese accion}

#########################################
# EJECUCION
#########################################
 
temperatura=`sensors|awk '/temp/ { print $2 }'`
tempInt=`echo ${temperatura}|cut -d"." -f1|tr -dc 0-9`
tempDec=`echo ${temperatura}|cut -d"." -f2|tr -dc 0-9`

if [ ${tempDec} -gt 5 ]; then
    temperatura=`expr ${tempInt} + 1`
else
    temperatura=${tempInt}
fi

case ${ACCION} in

    '--full')
        
        echo "#-------------------------------------" >> ${log}
        echo "# MONITOR DE TEMPERATURA              " >> ${log}
        echo "#-------------------------------------" >> ${log}
        echo "# Maquina   : "${maquina}               >> ${log}
        echo "# Kernel    : "${kernel}                >> ${log}
        echo "# Fecha     : "${fecha}                >> ${log}
        echo ""

        echo "[x] La temperatura es de "$temperatura" °C" >> ${log}

        if [ ${temperatura} -gt ${tempWarning} ]; then
            
            if [ ${temperatura} -gt ${tempCritica} ];then
                echo "[x] La temperatura es critica" >> ${log}
                cat ${log}|mailx -s "[CRITICO] $asunto" -r ${remitente} ${destinatarios}
                reboot
            fi

            if [[ ${temperatura} -gt ${tempWarning} && ${temperatura} -lt ${tempCritica} ]];then
                echo "[x] Advertencia de temperatura" >> ${log}
                cat $log|mailx -s "[WARNING] $asunto" -r ${remitente} ${destinatarios} 
            fi

        else
            echo "[x] La temperatura (${temperatura}) esta dentro de lo normal" >> ${log}
        fi
    ;;

    '--info')

        echo "#-------------------------------------"
        echo "# MONITOR DE TEMPERATURA              "
        echo "#-------------------------------------"
        echo "# Maquina   : "${maquina}              
        echo "# Kernel    : "${kernel}               
        echo "# Fecha     : "${fecha}               
        echo ""

        echo " * La temperatura es de "$temperatura" °C"

    ;;

    *|'--help'|'--h'|'-h')
        echo "[x] Acciones permitidas"
        echo "--full: Captura informacion y envia reporte por correo"
        echo "--info: Muestra informacion en pantalla"
    ;;

esac

exit 0
