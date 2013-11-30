#!/bin/sh

if (aptitude install php5-mysql php5-cli);then
    echo "[] Dependencias de PHP instaladas con exito"
else
    echo "[] Error al instalar Dependencias de PHP"
fi
