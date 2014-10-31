# VARIABLES
#############
ambiente="prod o testing/QA o desarrollo"
host=`uname -n`
destinatarios=destinatario@dominio.tld
remitente=remitente@${host}.${ambiente}.dominio.tld
proceso="Proceso"
# Palabras claves separar por pipe |
procesos="Nombre del proceso que vamos a monitorear"
filtros="grep|nombredelscript|y otras|palabras|claves"
echo "* Buscando proceso ${proceso}"
estado=0
while [ "$estado" -eq 0 ]; do
    if(!(ps aux |grep -iE "${procesos}"|grep -vE "${filtros}" 2> /dev/null));then
        mensajecorreo="* Proceso ${proceso} no se esta ejecutando :: "$(date +"%Y%m%d_%H%M%S")
        asunto="[ERROR] - ${proceso} no se ejecuta en ${host}"
        echo ${mensajecorreo}|mailx -s "${asunto}" -r ${remitente} ${destinatarios}
        echo "* Se recuperara servicio ${proceso}"
        #################################################################
        # Opciones avanzadas/personalizadas para reinicio de servicios
        #################################################################
        Por ejemplo
        /etc/init.d/PROCESO ACCION
        return=$?
        if [ "$return" -eq 0 ];then
            echo "* Proceso fue reiniciado"
            if(ps aux |grep -iE "${procesos}"|grep -vE "${filtros}" 2> /dev/null);then
                mensajecorreo="* Proceso ${Proceso} ya se esta ejecutando :: "$(date +"%Y%m%d_%H%M%S")
                asunto="[SERVICE RECOVERY] - ${proceso} se ha reiniciado en  ${host}"
                echo ${mensajecorreo}|mailx -s "${asunto}" -r ${remitente} ${destinatarios}  
            fi
        fi
    fi  
    sleep "tiempo en segundos"
done