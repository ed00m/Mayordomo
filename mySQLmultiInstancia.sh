#!/bin/sh -x

nombre=${1:?Nombre Instancia}
num=${2:?Numero Instancia}

puerto=3306
puertoNuevo=$(expr ${puerto} \* 2 + ${num})

####################################################
# DIRECTORIOS
###################################################

#DATA
mkdir /var/lib/${nombre}
chown -R mysql.mysql /var/lib/${nombre}

#LOGS
mkdir /var/log/${nombre}
chown -R mysql.mysql /var/log/${nombre}

#CONFIGURACION
if(cp -R /etc/mysql/ /etc/${nombre});then
    if (mv /etc/${nombre}/my.cnf /etc/${nombre}/${nombre}.cnf);then

        #MODIFICAMOS CONFIGURACION PARA LA NUEVA INSTANCIA
        sed -i "s/${puerto}/${puertoNuevo}/g" /etc/${nombre}/${nombre}.cnf
        sed -i 's/mysqld.sock/mysqld2.sock/g' /etc/${nombre}/${nombre}.cnf
        sed -i 's/mysqld.pid/mysqld2.pid/g' /etc/${nombre}/${nombre}.cnf
        sed -i 's/var\/lib\/mysql/var\/lib\/mysql2/g' /etc/${nombre}/${nombre}.cnf
        sed -i 's/var\/log\/mysql/var\/log\/mysql2/g' /etc/${nombre}/${nombre}.cnf
        sed -i 's/\/etc\/mysql\//\/etc\/mysql2\//g' /etc/${nombre}/${nombre}.cnf
        
        #INICIALIZAMOS LA NUEVA INSTANCIA
        mysql_install_db --user=mysql --datadir=/var/lib/${nombre}

        #INICIAMOS LA NUEVA INSTANCIA
        mysqld_safe --defaults-file=/etc/${nombre}/${nombre}.cnf &

        #CAMBIAMOS LA CLAVE DE ROOT
        nuevaClave=$(makepasswd -chars 24)
        /usr/bin/mysqladmin -S /var/run/mysqld/${nombre}.sock -u root password "${nuevaClave}"
        echo "Nueva clave:".${nuevaClave}
    fi
fi
