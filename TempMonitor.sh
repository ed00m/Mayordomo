#!/bin/sh
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
destinatarios=destinatario1@dominio.tld

tempCritica=80
tempWarning=70


#########################################
# EJECUCION
#########################################

echo "#-------------------------------------" >> ${log}
echo "# MONITOR DE TEMPERATURA              " >> ${log}
echo "#-------------------------------------" >> ${log}
echo "# Maquina   : "${maquina}               >> ${log}
echo "# Kernel    : "${kernel}                >> ${log}
echo "# Fecha     : "${$fecha}                 >> ${log}
echo ""
 
obtieneTemp=`sensors`
 
temperatura=`echo ${obtieneTemp}|grep +|cut -d "+" -f2|cut -d " " -f1`
tempInt=`echo ${temperatura}|cut -d "." -f1`
tempDec=`echo ${temperatura}|cut -d "." -f2`

if [ ${tempDec} -gt 5 ]; then
    temperatura=`expr ${tempInt} + 1`
else
    temperatura=${tempInt}
fi

echo " * La temperatura es de "$temperatura" °C" >> ${log}
 
if [ ${temperatura} -gt ${tempWarning} ]; then
    if [ ${temperatura} -gt ${tempCritica} ];then
        echo "* La temperatura es critica" >> ${log}
        cat ${log}|mailx -s "[CRITICO] $asunto" -r ${remitente} ${destinatarios}
        reboot
    fi
    if [[ ${temperatura} -gt ${tempWarning} && ${temperatura} -lt ${tempCritica} ]];then
        echo "* Advertencia de temperatura " >> ${log}
        cat $log|mailx -s "[WARNING] $asunto" -r ${remitente} ${destinatarios} 
    fi
else
    echo "* La temperatura esta dentro de lo normal" >> ${log}
fi

exit 0
