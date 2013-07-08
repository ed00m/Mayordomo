#!/bin/sh

newGroup=SYSADMIN

for USUARIO in $(awk -F: '{ if ($3 >= '500' && $3 < '600' ) print $1 }' /etc/passwd);do
    
    gpasswd −a user ${USUARIO} ${newGroup}
    
    grep -En "${USUARIO}|${newGroup}" /etc/passwd

done
