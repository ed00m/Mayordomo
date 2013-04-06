#!/bin/sh
for USUARIO in $(awk -F: '{ if ($3 >= '500' && $3 < '600' ) print $1 }' /etc/passwd);do
    if [ -d /home/${USUARIO} ];then
         mv /home/${USUARIO} /home/usuarios/${USUARIO}
    else
        echo "El home usuario ${USUARIO} ya fue migrado"
    fi
    sed -i -e "s@/home/${USUARIO}@/home/usuarios/${USUARIO}@g" /etc/passwd
done
