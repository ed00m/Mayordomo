#!/bin/sh

archivo=${1?:INGRESE ARCHIVO A PROCESAR}
IFS=";"

while read nombre aPaterno aMaterno dpto rol
do
    if [ -z ${nombre} ] || [ -z ${aPaterno} ] || [ -z ${aMaterno} ] || [ -z ${dpto} ] || [ -z ${rol} ];
    then
        printf '\033[0;31m%s\033[0m\n' "[] Informacion faltante para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol}"
    else
        if [ -z ${nombre##[0-9]*} ] || [ -z ${aPaterno##[0-9]*} ] || [ -z ${aMaterno##[0-9]*} ] || [ -z ${dpto##[0-9]*} ] || [ -z ${rol##[0-9]*} ] ||
        [ "${nombre}" = "nombre" ] || [ "${aPaterno}" = "aPaterno" ] || [ "${aMaterno}" = "aMaterno" ] ||
        [ "${dpto}" = "depto" ] || [ "${rol}" = "rol" ];
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
            
            if (! grep ${GROUP} /etc/group > /dev/null);then
                printf '\033[0;33m%s\033[0m\n' "[] No se encontro coincidencia"
                printf '\033[0;32m%s\033[0m\n' "[] groupadd ${GROUP}"
            else
                printf '\033[0;33m%s\033[0m\n' "[] Se encontro coincidencia"
                printf '\033[0;32m%s\033[0m\n' "[] Doble filtro ${GROUP}"
                
                groups_list=$(mktemp -t "${0##*/}.XXXXXX") || exit $?
                
                grep ${GROUP} /etc/group > ${groups_list}
                
                for GROUP_LINEA in $(cat ${groups_list});do
                    
                    group_field=$(echo ${GROUP_LINEA}|cut -d":" -f1)
                    
                    if [ ! "${GROUP}" = "${group_field}" ];then
                        printf '\033[0;33m%s\033[0m\n' "[] Distintos: \"${GROUP}\" = \"${group_field}\""
                        printf '\033[0;32m%s\033[0m\n' "[] groupadd ${GROUP}"
                    else
                        printf '\033[0;33m%s\033[0m\n' "\"[] Iguales ${GROUP}\" = \"${group_field}\""
                    fi
                done
            fi
            
            if [ ! -d ${HOME} ];then
                echo "[] ${HOME} no existe, se creara"
                echo "[] mkdir -p ${HOME}"
            fi

            echo "[] useradd \"${usuario}\" -p \"${clavecrypt}\" -m -d \"${HOME}/${usuario}\" -c \"${dpto} - ${rol}\" -g \"${GROUP}\""
        fi
    fi
    
    
done < ${archivo}

