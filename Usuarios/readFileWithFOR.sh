#!/bin/sh -x
##################################
# MANIPULACION DE CAMPOS CON FOR #
##################################

DBFINAL=mayordomo.final
DBSTAGE=mayordomo.lista
DBCOMPA=mayordomo.compa

if [ ! -f ${DBCOMPA} ];then
    if (! touch ${DBCOMPA});then
        echo "ERROR:No pude crear el archivo de ${DBCOMPA}"
        exit 1
    fi
fi

if [ ! -f ${DBFINAL} ];then
    if (! touch ${DBFINAL});then
        echo "ERROR:No se puede crear archivo ${DBFINAL}"
        exit 1
    fi
fi

if (ls -1 FTP > ${DBSTAGE});then
    echo "Directorio con permisos de lectura"
else
    echo "ERROR:Directorio sin permisos de lectura"
    exit 1
fi

diff ${DBSTAGE} ${DBFINAL}|grep '<'|cut -d" " -f2 > ${DBCOMPA}

STATUS=$(wc -l ${DBSTAGE}|cut -d" " -f1)

if [ ${STATUS} -gt 0 ];then

    for ARCHIVO in $(cat ${DBCOMPA});do
        PASO0=$(echo ${ARCHIVO})
        echo ${PASO0}
        PASO1=$(echo ${PASO0}|awk '{ print "=>"$1 }')
        echo ${PASO1}
    done
else
    echo "No procesó porque no hay archivos nuevos"
fi

exit 0
