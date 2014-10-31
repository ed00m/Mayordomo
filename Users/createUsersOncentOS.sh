#!/bin/sh
archivo=data/usuarios.csv
#archivo=${1?:INGRESE ARCHIVO A PROCESAR}

IFS=";"
HOME=/home/usuarios

while read nombre aPaterno aMaterno
do
    
    u=$(echo ${nombre}|cut -c 1)
    o=$(echo ${aMaterno}|cut -c 1)
    usuario=${u}${aPaterno}${o}

    clavecrypt=$(perl -e"  use Crypt::PasswdMD5; print unix_md5_crypt(${usuario});")

    echo "useradd \"${usuario}\" -p \"${clavecrypt}\" -m -d \"${HOME}/${usuario}\" -sincrypt \"${usuario}"
    
done < ${archivo}

