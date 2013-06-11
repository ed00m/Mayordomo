#!/bin/sh -x
set -e
echo "* INSTALACION/CONFIGURACION AMBIENTE ZSH+OH-MY-ZSH"
if (!(wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh));then
    echo "* No se pudo configurar el ambiente"
    exit 1
fi
chsh -s /bin/zsh
echo "* PARA APLICAR CAMBIOS INICIE SESION NUEVAMENTE"
sleep 4
exit 0

