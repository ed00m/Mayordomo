#!/bin/sh 

STATUS=$(wc -l clientes.txt|cut -d" " -f1)

if [ ${STATUS} -gt 0 ];then

    while read ARCHIVO;do
        NOMBRE=$(echo ${ARCHIVO}|cut -d"|" -f1)
        APELLIDO=$(echo ${ARCHIVO}|cut -d"|" -f2)
        RUT=$(echo ${ARCHIVO}|cut -d"|" -f3)
        DIRECCION=$(echo ${ARCHIVO}|cut -d"|" -f4)
        OCUPACION=$(echo ${ARCHIVO}|cut -d"|" -f5)
        
        echo "NOMBRE:${NOMBRE} APELLIDO:${APELLIDO} RUT:${RUT} DIRECCION:${DIRECCION} OCUPACION:${OCUPACION}"
    
    done < clientes.txt
else
    echo "No existen clientes para procesar"
fi

exit 0
