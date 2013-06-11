#!/bin/sh
archivo=${1?:INGRESE ARCHIVO A PROCESAR}

IFS=";"

while read nombres1 nombres2 apellidos1 apellidos2 carrera jornada ingreso comuna clave
do
    clavecrypt=$(perl -e"  use Crypt::PasswdMD5; print unix_md5_crypt(${clave});")
        usuario=$(echo ${nombres1}|cut -c 1)
            user=${usuario}${apellidos1}

                echo "useradd "${user}" -p "${clavecrypt}" -m -d /home/"${user}" -c "${carrera}" -sincrypt "${clave}
                    useradd ${user} -p "${clavecrypt}" -m -d /home/${user} -c ${carrera}
                    done < ${archivo} > cargar2.log
