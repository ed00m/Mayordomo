#!/bin/sh -x

mariadb_list=/etc/apt/sources.list.d/mariadb.list

echo "[] Elija modo de instalacion, por [c]omando o [a]rchivo"
read mode

case ${mode} in
    c|C)
        apt-get install python-software-properties
        apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
        add-apt-repository 'deb http://mirrors.supportex.net/mariadb/repo/5.5/debian wheezy main'
    ;;
    a|A)
        echo "# MariaDB 5.5 repository list - created 2013-11-30 14:34 UTC" > ${mariadb_list}
        echo "# http://mariadb.org/mariadb/repositories/" >> ${mariadb_list}
        echo "deb http://mirrors.supportex.net/mariadb/repo/5.5/debian wheezy main" >> ${mariadb_list}
        echo "deb-src http://mirrors.supportex.net/mariadb/repo/5.5/debian wheezy main" >> ${mariadb_list}
    ;;
esac

apt-get update
apt-get install mariadb-server
