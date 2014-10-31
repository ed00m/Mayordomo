#!/bin/sh

####################################
#
# REGLAS FIREWALL PARA IMPLEMENTAR
# CON LISTAS BLANCAS,LISTAS NEGRAS
#
####################################
ETHERWAN="eth0"
ETHERLAN="eth1"
IPWAN="192.0.0.0/24"
IPLAN="192.0.1.0/24"
PORTWEB=80
PORTWEBS=8080
PORTFTP_A=20
PORTFTP_P=21
PORTSSH=22
PORTPOP=110
PORTIMAP=147
PORTPROXY=3128
####################################
# RUNLEVELS
# chkconfig: 345 30 99
# description: Start and stop on Firewall service
# SEGMENTOS DE RED BAJO TLD O PAIS (GEOIP)
#
####################################
#WHITELIST=/usr/local/etc/firewall/whitelist.txt
WHITELIST=whitelist.txt
#BLACKLIST=/usr/local/etc/firewall/blacklist.txt
BLACKLIST=blacklist.txt
####################################
# PUERTOS QUE SE USARAN
####################################
ALLOWED=${PORTWEB}" "${PORTWEBS}" "${PORTSSH}" "${PORTFTP_A}" "${PORTFTP_P}
####################################
# RUTA DE IPTABLES EN SO
####################################
IPTABLES=/sbin/iptables
####################################
# RETORNO A SISTEMA
####################################
RETVAL=0
####################################
# PARA INICIAR FIREWALL
####################################
start() {
  echo "* * * * * * * * * * * * * * * * * * * *"
  echo "* Configurando reglas de Firewall..."
  echo "* Permitiendo localhost..."
  echo "* * * * * * * * * * * * * * * * * * * *"
  #Allow localhost.
  echo "\t ${IPTABLES} -A INPUT -t filter -s 127.0.0.1 -j ACCEPT"
  #
  ## Whitelist
  #
  for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
    echo "* Aceptando  $x..."
    echo "\t ${IPTABLES} -A INPUT -t filter -s $x -j ACCEPT"
  done
  #
  ## Blacklist
  #
  for x in `grep -v ^# $BLACKLIST | awk '{print $1}'`; do
    echo "* Denegando $x..."
    echo "\t $IPTABLES -A INPUT -t filter -s $x -j DROP"
  done
  #
  ## Permitted Ports
  #
  for port in $ALLOWED; do
    echo "Aceptando Puertos TCP $port..."
    echo "\t ${IPTABLES} -A INPUT -t filter -p tcp --dport $port -j ACCEPT"
  done
  for port in $ALLOWED; do
    echo "Aceptando Puertos UDP $port..."
    echo "\t ${IPTABLES} -A INPUT -t filter -p udp --dport $port -j ACCEPT"
  done
  echo "\t ${IPTABLES} -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"
  echo "\t ${IPTABLES} -A INPUT -p udp -j DROP"
  echo "\t ${IPTABLES} -A INPUT -p tcp --syn -j DROP"
  RETVAL=0
}
####################################
# PARAR FIREWALL
####################################
stop() {
  echo "* Elimando reglas de iptables..."
  echo "\t ${IPTABLES} -F"
  echo "\t ${IPTABLES} -X"
  echo "\t ${IPTABLES} -Z"
  RETVAL=0
}

####################################
# 
####################################
case $1 in
    start|restart)
        stop
        start
    ;;
    stop)
        stop
    ;;
    status)
        echo "${IPTABLES} -L"
        echo "${IPTABLES} -t nat -L"
        RETVAL=0
    ;;
    *)
        echo "Usage: firewall {start|stop|restart|status}"
    RETVAL=1
esac
exit $RETVAL
