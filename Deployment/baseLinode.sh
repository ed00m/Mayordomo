#!/bin/sh -x

sec=" fail2ban rkhunter chkrootkit psad sudo openvpn "
env=" git vim  zsh heirloom-mailx exim4 makepasswd "
router=" shorewall "

option=$1

if [ -z "${option}" ];
then
    option="all"
fi

if [ ${option} = "sec" ];
then    
    list=${sec}
    echo "Lists of Security"

elif [ ${option} = "env" ];
then
    list=${env}
    echo "Lists of Enviroment"

elif [ ${option} = "router" ];
then
    list=${router}
    echo "Lists of Routing"

elif [ ${option} = "all" ];
then
    list="${sec} ${env} ${router}"
    echo "Full Lists"

fi

if (aptitude install ${list} );then
    echo "Software Instalado con exito"
    exit 0
else
    echo "Problemas al instalar software"
    exit 1
fi
