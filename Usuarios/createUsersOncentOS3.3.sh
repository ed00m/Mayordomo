#!/bin/sh

archivo=data/usuarios_pract3.csv
#archivo=${1?:INGRESE ARCHIVO A PROCESAR}
IFS=";"
count=0
groups_list=$(mktemp -t "${0##*/}.XXXXXX") || exit $?

#/
# * Functions
#/

funct_group(){ 
    
    GROUP=$1
    
    echo "  [] GrupoArgs: "${GROUP} 
            
    if (! grep ${GROUP} /etc/group > /dev/null);then
        printf '\033[0;33m%s\033[0m\n' "  [] No se encontro coincidencia en el nombre del grupo, \"${GROUP}\" se creara"
        printf '\033[0;32m%s\033[0m\n' "  [] groupadd ${GROUP}"
    else
        printf '\033[0;33m%s\033[0m\n' "  [] Se encontro coincidencia en el nombre del grupo, se filtrara"
        printf '\033[0;32m%s\033[0m\n' "  [] Doble filtro ${GROUP}"
                
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
}

funct_print_faltante(){
    printf '\033[0;31m%s\033[0m\n' "  [] Informacion faltante para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol} ${permisos}"
}

funct_print_incorrecta(){
    printf '\033[0;31m%s\033[0m\n' "  [] Informacion incorrecta para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol} ${permisos}"
}

funct_home(){
    
    HOME=$1
    
    if [ ! -d ${HOME} ];then
        printf '\033[0;33m%s\033[0m\n' "  [] ${HOME} no existe, se creara"
        echo "  [] mkdir -p ${HOME}"
    fi
}

funct_useradd(){
    
    usuario=$1
    clavecrypt=$2
    HOME=$3
    dpto=$4
    rol=$5
    GROUP=$6 
    
    echo "  [] useradd \"${usuario}\" -p \"${clavecrypt}\" -m -d \"${HOME}/${usuario}\" -c \"${dpto} - ${rol}\" -g \"${GROUP}\""
}

while read nombre aPaterno aMaterno dpto rol permisos
do
    count=$((count+1))
    echo "[] Usuario: "${count}
    
    if [ -z ${nombre} ] || [ -z ${aPaterno} ] || [ -z ${aMaterno} ] ||
    [ -z ${dpto} ] || [ -z ${rol} ] || [ -z ${permisos} ] ;
    then
        funct_print_faltante
    else
        if [ -z ${nombre##[0-9]*} ] || [ -z ${aPaterno##[0-9]*} ] || 
        [ -z ${aMaterno##[0-9]*} ] || [ -z ${dpto##[0-9]*} ] ||
        [ -z ${rol##[0-9]*} ] || [ -z ${permisos##[0-9]*} ] ||
        [ "${nombre}" = "nombre" ] || [ "${aPaterno}" = "aPaterno" ] ||
        [ "${aMaterno}" = "aMaterno" ] || [ "${dpto}" = "depto" ] || 
        [ "${rol}" = "rol" ] || [ "${rol}" = "permisos" ] ;
        then
            funct_print_incorrecta
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
                        MASTERGROUP=${dpto_}
                    fi
                    if [ "${rol_}" = "analista" ];then
                        HOME=/home/analista
                        GROUP=${rol_}
                        MASTERGROUP=${dpto_}
                    fi
                    if [ "${rol_}" = "arquitecto" ];then
                        HOME=/home/arquitecto
                        GROUP=${rol_}
                        MASTERGROUP=${dpto_}
                    fi
                ;;
                *)
                    HOME=/home/usuarios
                    GROUP=${dpto_}
                    MASTERGROUP="usuarios"
                ;;
            esac
            
            funct_group ${GROUP}
            funct_group ${MASTERGROUP}
            funct_home ${HOME}
            funct_useradd ${usuario} ${clavecrypt} ${HOME} ${usuario} ${dpto} ${rol} ${GROUP}
        fi
    fi
    
    
done < ${archivo}

