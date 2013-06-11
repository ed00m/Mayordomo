#!/bin/sh -x
set -e
#########################################
# SCRIPT PARA RKHUNTER
# LO ACTUALIZA Y REPORTA SOLO WARNINGS
# VERSION 2
#########################################
REMITENTE=remitente@dominio.tld
DESTINATARIOS=destinatario@dominio.tld,destinatario2@dominio.tld,destinatario3@dominio.tld

ASUNTO=$(date +"%Y%m%d")" :: rkhunter :: "$(uname -n)

#########################################
# EJECUCION
#########################################
(
rkhunter --versioncheck
rkhunter --update
rkhunter --cronjob --report-warnings-only
) | mailx -s "${ASUNTO}" -r ${REMITENTE} ${DESTINATARIOS}

exit 0
