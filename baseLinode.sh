#!/bin/sh -x

if (aptitude install git vim fail2ban rkhunter chkrootkit zsh psad sudo shorewall makepasswd openvpn heirloom-mailx exim4);then
    echo "Software Instalado con exito"
else
    echo "Problemas al instalar software"
    exit 1
fi
