#!/bin/sh

archivo=data/usuarios_pract3.csv
#archivo=${1?:INGRESE ARCHIVO A PROCESAR}
IFS=";"
count=0

while read nombre aPaterno aMaterno dpto rol permisos
do
    count=$((count+1))
    echo "[] Usuario: "${count}
    
    if [ -z ${nombre} ] || [ -z ${aPaterno} ] || [ -z ${aMaterno} ] ||
    [ -z ${dpto} ] || [ -z ${rol} ] || [ -z ${permisos} ] ;
    then
        printf '\033[0;31m%s\033[0m\n' "  [] Informacion faltante para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol} ${permisos}"
    else
        if [ -z ${nombre##[0-9]*} ] || [ -z ${aPaterno##[0-9]*} ] || 
        [ -z ${aMaterno##[0-9]*} ] || [ -z ${dpto##[0-9]*} ] ||
        [ -z ${rol##[0-9]*} ] || [ -z ${permisos##[0-9]*} ] ||
        [ "${nombre}" = "nombre" ] || [ "${aPaterno}" = "aPaterno" ] ||
        [ "${aMaterno}" = "aMaterno" ] || [ "${dpto}" = "depto" ] || 
        [ "${rol}" = "rol" ] || [ "${rol}" = "permisos" ] ;
        then
            printf '\033[0;31m%s\033[0m\n' "  [] Informacion incorrecta para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol} ${permisos}"
        else
            u=$(echo ${nombre}|cut -c 1)
            o=$(echo ${aMaterno}|cut -c 1)
            usuario=${u}${aPaterno}${o}

            clavecrypt=$(perl -e"  use Crypt::PasswdMD5; print unix_md5_crypt(${usuario});")
            
            dpto_=$(echo ${dpto} | tr '[:upper:]' '[:lower:]')
            rol_=$(echo ${rol} | tr '[:upper:]' '[:lower:]')
            
            case ${dpto_} in
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
                printf '\033[0;33m%s\033[0m\n' "  [] No se encontro coincidencia en el nombre del grupo, se creara"
                printf '\033[0;32m%s\033[0m\n' "  [] groupadd ${GROUP}"
            else
                printf '\033[0;33m%s\033[0m\n' "  [] Se encontro coincidencia en el nombre del grupo, se filtrara"
                printf '\033[0;32m%s\033[0m\n' "  [] Doble filtro ${GROUP}"
                
                groups_list=$(mktemp -t "${0##*/}.XXXXXX") || exit $?
                
                if (grep ${GROUP} /etc/group > ${groups_list});
                then
                    while read GROUP_LINEA;do
                        
                        group_field=$(echo ${GROUP_LINEA}|cut -d":" -f1)
                        
                        if [ ! "${GROUP}" = "${group_field}" ];then
                            printf '\033[0;33m%s\033[0m\n' "  [] Distintos: \"${GROUP}\" = \"${group_field}\", se creara grupo"
                            printf '\033[0;32m%s\033[0m\n' "  [] groupadd ${GROUP}"
                        else
                            printf '\033[0;33m%s\033[0m\n' "  [] Iguales: \"${GROUP}\" = \"${group_field}\", no se creara grupo"
                        fi
                    done < ${groups_list}
                else
                    exit $?
                fi
            fi
            
            if [ ! -d ${HOME} ];then
                printf '\033[0;33m%s\033[0m\n' "  [] ${HOME} no existe, se creara"
                echo "  [] mkdir -p ${HOME}"
            fi

            echo "  [] useradd \"${usuario}\" -p \"${clavecrypt}\" -m -d \"${HOME}/${usuario}\" -c \"${dpto} - ${rol}\" -g \"${GROUP}\""
        fi
    fi
    
    
done < ${archivo}

