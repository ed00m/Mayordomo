#!/bin/sh

archivo=${1?:INGRESE ARCHIVO A PROCESAR}
IFS=";"

while read nombre aPaterno aMaterno dpto rol
do
    if [ -z ${nombre} ] || [ -z ${aPaterno} ] || [ -z ${aMaterno} ] || [ -z ${dpto} ] || [ -z ${rol} ];
    then
        printf '\033[0;31m%s\033[0m\n' "[] Informacion faltante para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol}"
    else
        if [ -z ${nombre##[0-9]*} ] || [ -z ${aPaterno##[0-9]*} ] || [ -z ${aMaterno##[0-9]*} ] || [ -z ${dpto##[0-9]*} ] || [ -z ${rol##[0-9]*} ];
        then
            printf '\033[0;31m%s\033[0m\n' "[] Informacion incorrecta para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol}"
        else
            u=$(echo ${nombre}|cut -c 1)
            o=$(echo ${aMaterno}|cut -c 1)
            usuario=${u}${aPaterno}${o}

            clavecrypt=$(perl -e"  use Crypt::PasswdMD5; print unix_md5_crypt(${usuario});")
            
            dpto_=$(echo ${dpto} | tr '[:upper:]' '[:lower:]')
            rol_=$(echo ${rol} | tr '[:upper:]' '[:lower:]')
            
            case ${dpto} in
                "informatica")
                    if [ "${rol_}" = "sysadmin" ];then
                        HOME=/home/sysadmin
                        GROUP=${rol_}
                    fi
                    if [ "${rol_}" = "analista" ];then
                        HOME=/home/analista
                        GROUP=${rol_}
                    fi
                    if [ "${rol_}" = "arquitecto" ];then
                        HOME=/home/arquitecto
                        GROUP=${rol_}
                    fi
                ;;
                *)
                    HOME=/home/usuarios
                    GROUP=${dpto_}
                ;;
            esac
            
            if (! grep ${GROUP} /etc/group);then
                echo "[] groupadd ${GROUP}"
            fi

            echo "[] useradd \"${usuario}\" -p \"${clavecrypt}\" -m -d \"${HOME}/${usuario}\" -c \"${dpto} - ${rol}\" -g \"${GROUP}\""
        fi
    fi
    
    
done < ${archivo}

