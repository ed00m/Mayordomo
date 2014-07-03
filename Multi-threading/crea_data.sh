#/bin/sh -x
set -e
set -v
OBJECT=data.txt
rm -f ${OBJECT} 
for i in $(seq 1000000)
do
	NAME=$(tr -dc A-Za-z0-9 < /dev/urandom|head -c 10)
	LASTNAME=$(tr -dc A-Za-z0-9 < /dev/urandom|head -c 10)
	FOLIO=$(tr -dc 0-9 < /dev/urandom|head -c 10)   
	echo ${NAME}"|"${LASTNAME}"|"${FOLIO}"|"${i} >> ${OBJECT}
done
exit 0
