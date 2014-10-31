#!/bin/sh -x
kcurrent=$(uname -r)
kcurrentVersion=$(echo ${kcurrent}|awk '{ print $1 }'|cut -d"-" -f1,2)

# Comparador

for KERNEL in $(dpkg -l|awk '/linux-image/ { print $2 }'|cut -d"-" -f3,4);do
    if [ "${KERNEL}" = "${kcurrentVersion}" ];then
        echo -e "\t [] Versiones del kernel iguales"
    else
        echo -e "\t [] Versiones del kernel no iguales"
        KERNELNUMBER=$(echo ${KERNEL}|)
        if [ "${KERNEL}" -lt "${kcurrentVersion}" ];then
            echo -e "\t [] es menor"
        fi
    fi

done
