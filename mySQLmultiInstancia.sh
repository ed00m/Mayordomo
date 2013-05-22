#!/bin/sh -x

nombre=${1:?Nombre Instancia}
num=${2:?Numero Instancia}

puerto=3306
puertoNuevo=$(expr ${puerto} \* 2 + ${num})

####################################################
# DIRECTORIOS
###################################################

#DATA
mkdir /var/lib/mysql-${nombre}
chown -R mysql.mysql /var/lib/mysql-${nombre}

#LOGS
mkdir /var/log/mysql-${nombre}
chown -R mysql.mysql /var/log/mysql-${nombre}

#CONFIGURACION
if(cp -R /etc/mysql/ /etc/mysql-${nombre});then
    if (mv /etc/${nombre}/my.cnf /etc/mysql-${nombre}/${nombre}.cnf);then

        #MODIFICAMOS CONFIGURACION PARA LA NUEVA INSTANCIA
        sed -i "s/${puerto}/${puertoNuevo}/g"                /etc/mysql-${nombre}/${nombre}.cnf
        sed -i "s/mysqld.sock/${nombre}.sock/g"              /etc/mysql-${nombre}/${nombre}.cnf
        sed -i "s/mysqld.pid/${nombre}.pid/g"                /etc/mysql-${nombre}/${nombre}.cnf
        sed -i "s@/var/lib/mysql@/var/lib/mysql-${nombre}@g" /etc/mysql-${nombre}/${nombre}.cnf
        sed -i "s@/var/log/mysql@/var/log/mysql-${nombre}@g" /etc/mysql-${nombre}/${nombre}.cnf
        sed -i "s@/etc/mysql/@/etc/mysql-${nombre}/@g"       /etc/mysql-${nombre}/${nombre}.cnf
        
        #INICIALIZAMOS LA NUEVA INSTANCIA
        mysql_install_db --user=mysql --datadir=/var/lib/mysql-${nombre}

        #INICIAMOS LA NUEVA INSTANCIA
        mysqld_safe --defaults-file=/etc/mysql-${nombre}/${nombre}.cnf &

        #CAMBIAMOS LA CLAVE DE ROOT
        nuevaClave=$(makepasswd -chars 24)
        /usr/bin/mysqladmin -S /var/run/mysqld/${nombre}.sock -u root password "${nuevaClave}"
        echo "Nueva clave: ${nuevaClave}"
    fi
fi

exit 0
