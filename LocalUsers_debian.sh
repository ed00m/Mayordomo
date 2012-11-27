kernel=`uname -s -r -v`   # -s, --kernel-name | -r, --kernel-release | -v, --kernel-version
maquina=`uname -n -m -o`  # -n, --nodename | -m, --machine | -p, --processor | -o, --operating-system | -    i, --hardware-platform
fecha=`date "+%Y%m%d"`
fecha_log=`date "+%Y%m%d%H%M%S"`
asunto="Levantamiento de usuarios en "$maquina" - "$fecha_log
log="../log/levantamiento_usuarios_$fecha_log.log"
data="../data/usuarios_$fecha.txt"
correotmp="../tmp/correos.tmp"
echo "VERSION 1.1                           " > $log
echo "#-------------------------------------" >> $log
echo "# LEVANTAMIENTO DE USUARIOS           " >> $log
echo "#-------------------------------------" >> $log
echo "# Maquina   : "$maquina                 >> $log
echo "# Kernel    : "$kernel                  >> $log
echo "# Fecha     : "$fecha                   >> $log
echo "# Ejecucion : "$fecha_log               >> $log
echo " "                                      >> $log
echo " * Limpieza de registros SSH"           >> $log
rm -f $data.activarSSH                        >> $log
echo " * Limpieza de registros SSH, Listo"    >> $log
if [ -f $data ]; then
while read datos; do
usuario=`echo $datos|cut -d "|" -f1`
mail=`echo $datos|cut -d "|" -f2`
claves=`makepasswd --char 16 --crypt`
clave=`echo $claves|cut -d " " -f1`
clavecifrada=`echo $claves|cut -d " " -f2`
echo "Estimado," > $correotmp
echo "La cuenta [$usuario] se ha creado, para guardar archivos necesitas un cliente SFTP (Secure FTP) como Filezilla (http://filezilla-project.org)." >> $correotmp
echo " " >> $correotmp 
echo "En tu espacio encontraras 2 directorios:" >> $correotmp
echo "bkp para guardar información confidencial (No publica) y public_html (www.tubencinera.cl/~$usuario) para los archivos que quieras publicar, desde un texto plano hasta una pagina web." >> $correotmp
echo " " >> $correotmp
echo "Por favor respeta los derechos de publicación de otras personas." >> $correotmp
echo " " >> $correotmp
echo "Los datos de acceso son:" >> $correotmp
echo "» servidor: tubencinera.cl" >> $correotmp
echo "» usuario : $usuario" >> $correotmp
echo "» clave   : $clave" >> $correotmp
echo "» Tipo    : SFTP" >> $correotmp
echo "» Storage : 500MB" >> $correotmp
echo " " >> $correotmp 
echo "En 24 horas el acceso quedara habilitado." >> $correotmp
echo "Este correo fue generado automaticamente. No responder" >> $correotmp

#sudo adduser $usuario --disabled-password --gecos $usuario
useradd $usuario -m -p $clavecifrada -d /home/$usuario >> $log
usermod -d /home/$usuario $usuario >> $log
addgroup $usuario ftpseguro >> $log
addgroup $usuario accesossh >> $log
quotatool -u $usuario -bq 500M -l '500 Mb' /home >> $log
mkdir -p /home/$usuario/public_html >> $log
mkdir -p /home/$usuario/bkp >> $log
chown root:root /home/$usuario >> $log
chown $usuario:$usuario /home/$usuario/bkp >> $log
chown $usuario:$usuario /home/$usuario/public_html >> $log
ln -s /usr/lib/cgi-bin /home/$usuario/public_html/cgi-bin >> $log
cp -f /var/www/robots.txt /home/$usuario/public_html/ >> $log
#sudo useradd $usuario -p $clavecifrada
cat $correotmp|mailx -s "Cuenta [$usuario] creada en tubencinera.cl" -r servidores@sinaltec.cl $mail
echo "$usuario|$clave|$mail" >> $data.activarSSH
done < $data >> $log

cat $log|mailx -s "$asunto" -r servidores@sinaltec.cl -c ed00m@guffy.unxrd servidores@sinaltec.cl
gzip -9 $log
gzip -9 $data
rm -f $correotmp
exit 0
else
 echo "* El archivo base para hoy no existe->"$data >> $log
 asunto="[BASE NO EXISTE] Levantamiento de usuarios en "$maquina" - "$fecha_log
 cuerpo="* El archivo base para hoy no existe->$data"
 echo $cuerpo|mailx -s "$asunto" -r servidores@sinaltec.cl -c ed00m@guffy.unxrd servidores@sinaltec.cl
 exit 1
fi