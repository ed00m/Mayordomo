#!/bin/sh
ACCION=${1:? ingrese accion}

case ${ACCION} in

    '--ejecutar')

        OPCION=${2:? ingrese opcion}

            case ${OPCION} in

            1)
                MiHome=$(pwd)
                echo "[x] Mi home es "${MiHome}
            ;;
            2)
                MiHome2=`pwd`
                echo "[x] Mi home2 es "${MiHome2}
            ;;
            3)
                MiHome3=$HOME
                echo "[x] Mi home3 es "${MiHome3}
            ;;
        *)
            echo "La opcion=>${OPCION} no es valida, consulte la Ayuda --help"
        ;;
            esac
    ;;
    '--help')
            echo "[x] ACCIONES: help o ejecutar"
            echo "[x] Opciones para ejecutar:"
            echo "     [x] 1: ejecucion como variable"
            echo "     [x] 2: ejecucion con comillas diagonales"
            echo "     [x] 3: obtener de ambiente"
    ;;
    *)
        echo "La accion=>${ACCION} no es valida, consulte la Ayuda --help"
    ;;
esac
echo "... FIN ..."
