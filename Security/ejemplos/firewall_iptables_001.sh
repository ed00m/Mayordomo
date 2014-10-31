#!/bin/sh

#############
#
# REGLAS FIREWALL PARA IMPLEMENTAR UN PROXY
# NAVEGACION WEB CON SQUID
# ACEPTA CONEXIONES ENTRANTES
#
#############
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

echo "iptables -F"
echo "iptables -X"
echo "iptables -Z"
echo "iptables -t nat -F"
echo "iptables -P INPUT ACCPET"
echo "iptables -P OUTPUT ACCEPT"
echo "iptables -P FORWARD ACCEPT"
echo "iptables -t nat     -P PREROUTING ACCEPT"
echo "iptables -t nat     -P POSTROUTING ACCEPT"
echo "iptables -A INPUT   -i lo -j ACCEPT"
echo "iptables -A INPUT   -s ${IPWAN} -i ${ETHERWAN} -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port  ${PORTWEB}   -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port  ${PORTWEBS}  -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port  ${PORTFTP_A} -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port  ${PORTFTP_P} -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port  ${PORTSSH}   -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port  ${PORTPOP}   -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port  ${PORTIMAP}  -j ACCEPT"
echo "iptables -A FORWARD -s ${IPWAN} -i ${ETHERWAN} -j DROP"
echo "iptables -t nat     -A PREROUTING -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port ${PORTWEB} -j REDIRECT -to-port ${PORTPROXY}"
echo "iptables -t nat     -A PREROUTING -s ${IPWAN} -i ${ETHERWAN} -p tcp --destination-port ${PORTWEBS} -j REDIRECT -to-port ${PORTPROXY}"
echo "iptables -t nat     -A POSTROUTING -s ${IPWAN} -o ${ETHERLAN} -j MASQUERADE"
echo "echo 1 > /proc/sys/net/ipv4/ip_forward"
echo "service iptables save"
echo "service iptables start"
