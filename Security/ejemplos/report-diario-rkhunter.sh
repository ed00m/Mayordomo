#!/bin/sh

#######################
#
# ESTE SCRIPT EJECUTA RKHUNTER,
# ACTUALIZA LA BASE DE DEFINICIONES
# Y NOS ENVIA EL REPORTE DE WARNINGS
#
########################

DESTINATARIOS="destinatario@dominio.tld,destinatario2@dominio.tld"
REMITENTE="remitente@dominio.tld"

(
    rkhunter --versioncheck
    rkhunter --update
    rkhunter --cronjob --report-warnings-only
) | mailx -s "$(date +"%Y%m%d") :: rkhunter :: $(uname -n)" -r ${REMITENTE} ${DESTINATARIOS}
