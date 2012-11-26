#!/bin/bash
#########################################
# SCRIPT PARA COPIAR/CLONAR BASE DE DATOS
#########################################

# Opcional
#PREFIJO=${1:?Ingresa el prefijo de la BD}
DBPASSWORD=
DB_FUENTE=NOMBREBDACOPIAR
#DB_DESTINO=${PREFIJO}_NOMBRENUEVADB
DB_DESTINO=NOMBRENUEVADB
DBSERVER=localhost
#DB_USER=${PREFIJO}_NOMBREUSUARIO
DB_USER=NOMBREUSUARIO
HOST=HOST
 
fCreateTable=""
fInsertData=""
echo "-----------------------------------------+"
echo "Copiando "${DB_FUENTE}" a "${DB_DESTINO}
#DBCONN="-h ${DBSERVER} -u ${DBUSER} --password=${DBPASSWORD}"
DBCONN=""
echo "-----------------------------------------+"
echo "* Borrando "${DB_DESTINO}" si existe"
echo "DROP DATABASE IF EXISTS ${DB_DESTINO};" | mysql ${DBCONN}
echo "* Creando "${DB_DESTINO}
echo "CREATE DATABASE ${DB_DESTINO};" | mysql ${DBCONN}
#echo "USE ${DB_DESTINO}" | mysql ${DBCONN}
echo "* Capturando tablas"
for TABLE in `echo "SHOW TABLES" | mysql ${DBCONN} ${DB_FUENTE} | tail -n +2`; do
        createTable=`echo "SHOW CREATE TABLE ${TABLE}"|mysql -B -r ${DBCONN} ${DB_FUENTE}|tail -n +2|cut -f 2-`
        fCreateTable="${fCreateTable} ;\n ${createTable}"
        insertData="INSERT INTO ${DB_DESTINO}.${TABLE} SELECT * FROM ${DB_FUENTE}.${TABLE}"
        fInsertData="${fInsertData} ; ${insertData}"
done
echo "* Aplicando cambios"
echo -e "${fCreateTable} ;\n ${fInsertData}"  | mysql ${DBCONN} ${DB_DESTINO}
echo "* Comprobando estado de la nueva tabla"
echo "SHOW TABLE STATUS;" | mysql ${DBCONN} ${DB_DESTINO}
 
#############################
# BD :: USUARIO
#############################
echo "* Generando clave para usuario"
USER_CLAVE=`cat /dev/urandom | tr -cd "[:alnum:]" | head -c 16`
 
echo "------------------------------------------+"
echo "Creando usuario "${DB_USER}" en "${DB_DESTINO}
echo "------------------------------------------+"
 
echo "GRANT SELECT,UPDATE,DELETE,INSERT ON "${DB_DESTINO}".* TO '"${DB_USER}"'@'"${HOST}"' IDENTIFIED BY '"${USER_CLAVE}"';" | mysql ${DBCONN} mysql
echo "+ USUARIO GENERADO: "${DB_USER}
echo "+ CLAVE: "${USER_CLAVE}
