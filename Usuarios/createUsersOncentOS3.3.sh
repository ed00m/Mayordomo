#!/bin/sh

archivo=data/usuarios_pract3.csv
#archivo=${1?:INGRESE ARCHIVO A PROCESAR}
IFS=";"
count=0
groups_list=$(mktemp -t "${0##*/}.XXXXXX") || exit $?

#/
# * Functions
#/

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

funct_group(){ 
    
    VAR=$1
    TYPE=$2
    
    echo "  [] GrupoArgs: "${VAR}" [] Type: "${TYPE}
    
    if [ "${TYPE}" = "group" ];then
        target=/etc/group
        message="grupo"
        exec="groupadd ${GROUP}"
    
    elif [ "${TYPE}" = "user" ];then
        target=/etc/passwd
        message="usuario"
        exec="useradd \"${usuario}\" -p \"${clavecrypt}\" -m -d \"${HOME}/${usuario}\" -c \"${dpto} - ${rol}\" -g \"${GROUP}\""
    fi
            
    if (! grep ${VAR} ${target} > /dev/null);then
        printf '\033[0;33m%s\033[0m\n' "  [] No se encontro coincidencia en el nombre del ${message}, \"${VAR}\" se creara"
        printf '\033[0;32m%s\033[0m\n' "  [] ${exec}"
    else
        printf '\033[0;33m%s\033[0m\n' "  [] Se encontro coincidencia en el nombre del ${message}, se filtrara"
        printf '\033[0;32m%s\033[0m\n' "  [] Doble filtro ${VAR}"
                
        if (grep ${VAR} ${target} > ${groups_list});
        then
            while read GROUP_LINEA;do
                if [ "${TYPE}" = "group" ];then
                    group_field=$(echo ${GROUP_LINEA}|cut -d":" -f1)
                elif [ "${TYPE}" = "user" ];then
                    group_field=$(echo ${GROUP_LINEA}|cut -d":" -f1)
                    group_path=$(echo ${GROUP_LINEA}|cut -d":" -f6)
                fi
            
                if [ ! "${VAR}" = "${group_field}" ];then
                    printf '\033[0;33m%s\033[0m\n' "  [] Distintos: \"${VAR}\" = \"${group_field}\", se creara ${message}"
                    printf '\033[0;32m%s\033[0m\n' "  [] ${exec}"
                else
                    if [ "${TYPE}" = "user" ];then
                        # Aca migro
                        echo " [] Migrare"
                        echo " [] Usuario se encuentra en ${group_path} y debe estar en ${HOME}/${usuario}"
                    else
                        printf '\033[0;33m%s\033[0m\n' "  [] Iguales: \"${VAR}\" = \"${group_field}\", no se creara ${message}"
                    fi
                fi
            done < ${groups_list}
        else
            exit $?
        fi
    fi
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
            
            # Si no existe grupo lo crea
            funct_group ${GROUP} group
            funct_group ${MASTERGROUP} group
            # Si no existe home lo crea
            funct_home ${HOME}
            # Si usuario no existe lo crea
            funct_group ${usuario} user
            # Imprime y/o ejecuta la creacion de nuevos usuarios
            #funct_useradd ${usuario} ${clavecrypt} ${HOME} ${usuario} ${dpto} ${rol} ${GROUP}
        fi
    fi
    
    
done < ${archivo}

