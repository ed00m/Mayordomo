#!/bin/sh

<<COMENTS
    white label : INFO
    orange label: WARNING or NOTICE
    red label   : ERROR DATA
    green label : EXECUTION   
COMENTS

archivo=data/usuarios_pract3.csv
#archivo=${1?:INGRESE ARCHIVO A PROCESAR}
IFS=";"
count=0
groups_list=$(mktemp -t "${0##*/}.XXXXXX") || exit $?

#/
# * Functions
#/

funct_print_dataMissing(){
    printf '\033[0;31m%s\033[0m\n' "  [] Informacion faltante para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol} ${permisos}"
}

funct_print_dataIncorrect(){
    printf '\033[0;31m%s\033[0m\n' "  [] Informacion incorrecta para Usuario: ${nombre} ${aPaterno} ${aMaterno} ${dpto} ${rol} ${permisos}"
}

funct_home(){
    
    HOME=$1
    
    if [ ! -d ${HOME} ];then
        printf '\033[0;33m%s\033[0m\n' "    [] ${HOME} no existe, se creara"
        printf '\033[0;32m%s\033[0m\n' "    [] mkdir -p ${HOME}"
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

funct_migrate(){
    
    usuario=$1
    
    if [ -d ${HOME}/${usuario} ] && [ -d ${group_path} ] &&
    [ $(ls -1a ${group_path} |grep -vE "^.$|^..$|.profile|.bash"|wc -l|cut -d " " -f1) -gt 0 ];
    then
        printf '\033[0;33m%s\033[0m\n' "    [] Migrate::Decision 1"
        printf '\033[0;32m%s\033[0m\n' "    [] mv ${group_path}/* ${HOME}/${usuario}/"
        printf '\033[0;32m%s\033[0m\n' "    [] rm -fr ${group_path}"
    elif [ -d ${HOME}/${usuario} ] && [ -d ${group_path} ] &&
    [ $(ls -1a ${group_path} |grep -vE "^.$|^..$|.profile|.bash"|wc -l|cut -d " " -f1) -eq 0 ];
    then
        printf '\033[0;33m%s\033[0m\n' "    [] Migrate::Decision 2"
        printf '\033[0;32m%s\033[0m\n' "    [] rm -fr ${group_path}"
    elif [ ! -d ${group_path} ];
    then
        printf '\033[0;33m%s\033[0m\n' "    [] Migrate::Decision 3"
        printf '\033[0;33m%s\033[0m\n' "    [] No hay datos que migrar para el usuario ${usuario}"
    elif [ ! -d ${HOME}/${usuario} ] && [ -d ${group_path} ];
    then
        printf '\033[0;33m%s\033[0m\n' "    [] Migrate::Decision 4"
        printf '\033[0;32m%s\033[0m\n' "    [] mkdir -p ${HOME}/${usuario}"
        printf '\033[0;32m%s\033[0m\n' "    [] mv ${group_path}/* ${HOME}/${usuario}/"
    fi
    
    printf '\033[0;33m%s\033[0m\n' "    [] sed -i -e \"s@${group_path}@${HOME}/${usuario}@g\" /etc/passwd"
}

funct_group(){ 
    
    VAR=$1
    TYPE=$2
    MATCH=0
    
    echo "  [] VAR: "${VAR}" [] Type: "${TYPE}
    
    if [ "${TYPE}" = "group" ];then
        target=/etc/group
        message="grupo"
        exec="groupadd ${GROUP}"
    
    elif [ "${TYPE}" = "user" ];then
        target=/etc/passwd
        message="usuario"
        exec="useradd \"${usuario}\" -p \"${clavecrypt}\" -m -d \"${HOME}/${usuario}\" -c \"${dpto} - ${rol}\" -g \"${GROUP}\""
    fi
            
    MATCH=$(grep ${VAR} ${target}|wc -l|cut -d" " -f1)
    
    if [ ${MATCH} -lt 1 ];
    then
        printf '\033[0;33m%s\033[0m\n' "    [] No se encontro coincidencia, nombre de ${message} \"${VAR}\" se creara"
        printf '\033[0;32m%s\033[0m\n' "    [] ${exec}"
    else
        printf '\033[0;33m%s\033[0m\n' "    [] Se encontraron (${MATCH}) coincidencia(s), nombre de ${message} \"${VAR}\" se filtrara"
        echo "    [] Aplicando Doble filtro a ${VAR}"        
        
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
                    printf '\033[0;33m%s\033[0m\n' "      [] El ${message} \"${VAR}\" es distinto que \"${group_field}\""
                    createGROUPTRUE=TRUE
                else
                    if [ "${TYPE}" = "user" ];then
                        echo "  [] MIGRATE"
                        printf '\033[0;33m%s\033[0m\n' "    [] Usuario ${usuario} se encuentra en ${group_path} y debe estar en ${HOME}/${usuario}"
                        funct_migrate ${usuario}
                    else
                        printf '\033[0;33m%s\033[0m\n' "    [] Iguales: \"${VAR}\" = \"${group_field}\", no se creara ${message}"
                        createGROUPFALSE=TRUE
                    fi
                fi
            done < ${groups_list}
            
            if [ "${createGROUPTRUE}" = "TRUE" ] && [ ! "${createGROUPFALSE}" = "TRUE" ];
            then 
                printf '\033[0;33m%s\033[0m\n' "    [] Se creara ${message}: ${VAR}"
                printf '\033[0;32m%s\033[0m\n' "    [] ${exec}"
            fi
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
        funct_print_dataMissing
    else
        if [ -z ${nombre##[0-9]*} ] || [ -z ${aPaterno##[0-9]*} ] || 
        [ -z ${aMaterno##[0-9]*} ] || [ -z ${dpto##[0-9]*} ] ||
        [ -z ${rol##[0-9]*} ] || [ -z ${permisos##[0-9]*} ] ||
        [ "${nombre}" = "nombre" ] || [ "${aPaterno}" = "aPaterno" ] ||
        [ "${aMaterno}" = "aMaterno" ] || [ "${dpto}" = "depto" ] || 
        [ "${rol}" = "rol" ] || [ "${rol}" = "permisos" ] ;
        then
            funct_print_dataIncorrect
        else
            nombre_=$(echo ${nombre} | tr '[:upper:]' '[:lower:]')
            aPaterno_=$(echo ${aPaterno} | tr '[:upper:]' '[:lower:]')
            aMaterno_=$(echo ${aMaterno} | tr '[:upper:]' '[:lower:]')
            dpto_=$(echo ${dpto} | tr '[:upper:]' '[:lower:]')
            rol_=$(echo ${rol} | tr '[:upper:]' '[:lower:]')
            
            u=$(echo ${nombre_}|cut -c 1)
            o=$(echo ${aMaterno_}|cut -c 1)
            usuario=${u}${aPaterno_}${o}
            
            clavecrypt=$(perl -e"  use Crypt::PasswdMD5; print unix_md5_crypt(${usuario});")
            
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

