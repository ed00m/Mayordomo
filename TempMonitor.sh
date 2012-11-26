kernel=`uname -s -r -v` # -s, --kernel-name | -r, --kernel-release | -v, --kernel-version
maquina=`uname -n -m -o` # -n, --nodename | -m, --machine | -p, --processor | -o, --operating-system | -i, --hardware-platform
fecha=`date "+%Y%m%d"`
fecha_log=`date "+%Y%m%d%H%M%S"`
asunto="Monitor de temperatura "$maquina" - "$fecha_log
log="../log/temperatura_$fecha_log.log"
 
echo "VERSION 0.6                           " >  $log
echo "#-------------------------------------" >> $log
echo "# MONITOR DE TEMPERATURA              " >> $log
echo "#-------------------------------------" >> $log
echo "# Maquina   : "$maquina                 >> $log
echo "# Kernel    : "$kernel                  >> $log
echo "# Fecha     : "$fecha                   >> $log
echo "# Ejecucion : "$fecha_log               >> $log
echo ""
 
sensors >> $log
 
temperatura=`grep 90 $log | cut -d " " -f8| cut -d "." -f1`
 
echo " * La temperatura es de "$temperatura" °C" >> $log
 
if [ $temperatura -gt 64 ]; then
  if [ $temperatura -gt 80 ];then
    cat $log|mailx -s "[CRITICO] $asunto" -r remitente -c remitentecopia destinatario
    reboot
  fi
  if [[ $temperatura -gt 66 && $temperatura -lt 81 ]];then
    cat $log|mailx -s "[WARNING] $asunto" -r remitente -c remitentecopia destinatario
fi
exit 0