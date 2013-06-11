#!/bin/bash
set -e
#########################################
# MODO DE USO
#########################################
# OPCION DB:
#   CREA/CLONA BASE DE DATOS
#
# OPCION USER:
#   CREA USUARIO PARA BASE DE DATOS CON 
#   PERMISOS PREDETERMINADOS
#   ARG=>USUARIO
#
#########################################
# SCRIPT PARA COPIAR/CLONAR BASE DE DATOS
# VERSION 2
#########################################

DB_FUENTE=DATAWAREHOUSE
DB_DESTINO=NOMBRENUEVADB

DBSERVER=localhost
DB_USER=USERADMIN
DBPASSWORD=PASSUSERADMIN

CONECTOR="mysql -u${DB_USER} -p${DBPASSWORD}"
 
fCreateTable=""
fInsertData=""

#########################################
# FUNCIONES
#########################################

function databaseCopy(){
if (echo "exit"|${CONECTOR});then
    
    echo "* Conexion exitosa a "${DB_FUENTE}" en "${DBSERVER}
    echo "* Preparando para copiar en "${DB_DESTINO}
    echo "* +--------------------------------------------------+"

    sleep 1

    echo "* BORRANDO, SI EXISTE, ESQUEMA "${DB_DESTINO}
    
    if(!(echo "DROP DATABASE IF EXISTS "${DB_DESTINO}";"|${CONECTOR}));then
        echo "* BORRADO DE ESQUEMA "${DB_DESTINO}" A FALLADO"
        echo "* SALIENDO..."
        exit 1
    else
        echo "* CREANDO "${DB_DESTINO}
        sleep 1
        if (!(echo "CREATE DATABASE ${DB_DESTINO};"|${CONECTOR}));then
            echo "* CREACION DE ESQUEMA "${DB_DESTINO}" A FALLADO"
            echo "* SaLIENDO..."
            exit 1
        fi
    fi
    
    echo "* INICIANDO COPIA DE TABLAS"
    echo "* CAPTURANDO INFORMACION DESDE "${DB_FUENTE}
    sleep 1

    for TABLE in `echo "SHOW TABLES" | ${CONECTOR} ${DB_FUENTE} | tail -n +2`; do
        createTable=`echo "SHOW CREATE TABLE ${TABLE}"|${CONECTOR} -B -r ${DB_FUENTE}|tail -n +2|cut -f 2-`
        fCreateTable="${fCreateTable} ;\n ${createTable}"
        insertData="INSERT INTO ${DB_DESTINO}.${TABLE} SELECT * FROM ${DB_FUENTE}.${TABLE}"
        fInsertData="${fInsertData} ; ${insertData}"
    done
    
    echo "* GUARDANDO INFORMACION EN "${DB_DESTINO}
    sleep 1

    if (!(echo -e "${fCreateTable} ;\n ${fInsertData}"|${CONECTOR} ${DB_DESTINO}));then
        echo "* NO SE LOGRO GUARDAR LA INFORMACION EN EL ESQUEMA "${DB_DESTINO}
        echo "* SALIENDO..."
        exit 1
    fi

    echo "* COMPROBANDO ESTADO DE LAS NUEVAS TABLAS EN "${DB_DESTINO}
    echo "SHOW TABLE STATUS;"|${CONECTOR} ${DB_DESTINO}

else
    echo "* [ERROR FATAL] - CONEXION IMPOSIBLE"
    echo "* Saliendo..."
    echo ""
    exit 1
fi
}

function createUser(){

    echo ""
    echo "* +--------------------------------------------------+"
    echo "* GENERANDO CLAVE PARA USUARIO "${USUARIO}
    USER_CLAVE=`tr -dc a-zA-Z0-9 < /dev/urandom|head -c 16`

    echo "* CREANDO USUARIO EN "${DB_DESTINO}
    echo "GRANT SELECT,UPDATE,DELETE,INSERT ON "${DB_DESTINO}".* TO '"${USUARIO}"'@'"${HOST}"' IDENTIFIED BY '"${USER_CLAVE}"';" | ${CONECTOR} mysql
    echo "* USUARIO: "${USUARIO}
    echo "* CLAVE GENERADA: "${USER_CLAVE}
    echo "* ACTUALIZANDO PERMISOS"
    echo "FLUSH PRIVILEGES;"|${CONECTOR} mysql
    echo "* +--------------------------------------------------+"
    echo ""
    sleep 5
}

#########################################
# EJECUCION
#########################################

OPCION=${1:?DB,USER,FULL}

case ${OPCION} in
    DB|db)
        databaseCopy
    ;;    
    USER|user)
        USUARIO=${2:? INGRESA UN NOMBRE DE USUARIO}
        createUser
    ;;
    FULL|full)
        USUARIO=${2:? INGRESA UN NOMBRE DE USUARIO}
        databaseCopy
        createUser
    ;;
    *)

    echo "#########################################"
    echo "# MODO DE USO"
    echo "#########################################"
    echo "# OPCION DB:"
    echo "#   CREA/CLONA BASE DE DATOS"
    echo "#"
    echo "# OPCION USER:"
    echo "#   CREA USUARIO PARA BASE DE DATOS CON" 
    echo "#   PERMISOS PREDETERMINADOS"
    echo "#   ARG=>USUARIO"
    echo "#"
    echo ""
    echo "Ejemplos:"
    echo "* ./DatabaseCopy.sh full juanperez"
    echo "* ./DatabaseCopy.sh user juanperez"
    echo "* ./DatabaseCopy.sh db"
    ;;

esac

exit 0
