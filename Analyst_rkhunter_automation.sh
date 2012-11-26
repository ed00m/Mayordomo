kernel=`uname -s -r -v`		# -s, --kernel-name | -r, --kernel-release | -v, --kernel-version
maquina=`uname -n -m -o`	# -n, --nodename | -m, --machine | -p, --processor | -o, --operating-system | -i, --hardware-platform
fecha=`date "+%Y%m%d"`
fecha_log=`date "+%Y%m%d%H%M%S"`
asunto="Actualizacion de RKHUNTER "$maquina" - "$fecha_log
log="../log/actualizacion_rkhunter_$fecha_log.log"

echo "VERSION 0.6                           " > $log
echo "#-------------------------------------" >> $log
echo "# ACTUALIZACION DE RKHUNTER           " >> $log
echo "#-------------------------------------" >> $log
echo "# Maquina   : "$maquina                 >> $log
echo "# Kernel    : "$kernel                  >> $log
echo "# Fecha     : "$fecha                   >> $log
echo "# Ejecucion : "$fecha_log               >> $log
echo ""

rkhunter --update >> $log 
echo " * Actualizacion de RKHUNTER terminado" >> $log
#cat $log|mailx -s "$asunto" -r servidores@sinaltec.cl -c pablo@guffy.unxrd servidores@sinaltec.cl
echo " * Actualizacion de RKHUNTER terminado"|mailx -s "$asunto" -r servidores@sinaltec.cl -c ed00m@guffy.unxrd servidores@sinaltec.cl
gzip -9 $log
exit 0