#!/bin/sh -x

mariadb_list=/etc/apt/sources.list.d/mariadb.list
sources_list=/etc/apt/sources.list

clear () {
    sed -i -e "/mariadb/d" ${sources_list}
    if [ -f ${mariadb_list} ];then
        rm -f ${mariadb_list}
    fi
}

echo "[] Elija modo de instalacion, por [c]omando o [a]rchivo"
read mode

mientras="entrar"

while [ "${mientras}" = "entrar" ];do

    case ${mode} in
        c|C)
            clear
            apt-get install python-software-properties
            apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
            add-apt-repository 'deb http://mirrors.supportex.net/mariadb/repo/5.5/debian wheezy main'
            mientras="salir"
        ;;
        a|A)
            clear
            echo "# MariaDB 5.5 repository list - created 2013-11-30 14:34 UTC" > ${mariadb_list}
            echo "# http://mariadb.org/mariadb/repositories/" >> ${mariadb_list}
            echo "deb http://mirrors.supportex.net/mariadb/repo/5.5/debian wheezy main" >> ${mariadb_list}
            echo "deb-src http://mirrors.supportex.net/mariadb/repo/5.5/debian wheezy main" >> ${mariadb_list}
            mientras="salir"
        ;;
        *)
            echo "[] Opcion incorrecta, [c]omando o [a]rchivo"
        ;;
    esac
done

if [ "${mientras}" = "salir" ];then
    apt-get update
    apt-get install mariadb-server
else
    echo "[] Error no se actualizara"
fi
