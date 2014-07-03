#/bin/sh -x # Modo depuracion
set -e # Se cae en caso de error
set -v # Modo verbose en ejecucion

OBJECT=multi_data.txt
#rm -f ${OBJECT} 

for i in $(seq 175000)
do
	NAME=$(tr -dc A-Za-z0-9 < /dev/urandom|head -c 10) # Generara texto como: qwerty1234QWERTY
	LASTNAME=$(tr -dc A-Za-z0-9 < /dev/urandom|head -c 10) # Genarara texto como: qwerty1234QWERTY
	FOLIO=$(tr -dc 0-9 < /dev/urandom|head -c 10) # Generara texto como: 0123456789
	echo ${NAME}"|"${LASTNAME}"|"${FOLIO}"|"${i} >> ${OBJECT} # Guarda cadenas de texto en el mismo archivo
done
exit 0
