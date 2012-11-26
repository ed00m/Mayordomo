#!/bin/sh
(
rkhunter --versioncheck
rkhunter --update
rkhunter --cronjob --report-warnings-only
) | mailx -s "$(date +"%Y%m%d") :: rkhunter :: $(uname -n)" -r remitente@dominio.tld destinatario@dominio.tld