#!/bin/sh


###################################################
## SCRIPT de IPTABLES ##
## Pello Xabier Altadill Izura ##
## I+D+I+I en tiempo record ##
## Investigacion, Desarrollo, ##
## Innovacion e IMPLANTACION ##
## ##
## Este script es de ejemplo ##
## y no es el mejor ejemplo, ##
## pero funciona en RedHat 7.2 ##
## y es muy pedagogico ##
###################################################

## Notas para usuarios de IPCHAINS:
# ipchains e iptables son modulos del kernel que
# NO pueden convivir juntos
# DENY ahora es DROP
# Los LOG se guardan de otra forma


echo -n Aplicando Reglas de Firewall...

## Instalando modulos
modprobe ip_tables
modprobe ip_nat_ftp
modprobe ip_conntrack_ftp

## Variables
EXTIF="eth0" # La que va al router
INTIF="eth1" # La que va a la LAN

## Primeras reglas
/sbin/iptables -P INPUT ACCEPT # INPUT se acepta por defecto MAL HECHO
/sbin/iptables -F INPUT
/sbin/iptables -P OUTPUT ACCEPT # OUTPUT se acepta por defecto, weno..
/sbin/iptables -F OUTPUT
/sbin/iptables -P FORWARD ACCEPT # FORWARD se acepta por defecto buf
/sbin/iptables -F FORWARD
/sbin/iptables -t nat -F


## se deniega 80 y se guarda log (ejemplo)
/sbin/iptables -A INPUT -i $INTIF -s 0.0.0.0/0 -p TCP --dport www -j LOG --log-prefix "IPTablesFW> "
/sbin/iptables -A INPUT -i $INTIF -s 0.0.0.0/0 -p TCP --dport www -j DROP

## Acceso al 3128 (proxy squid) desde LAN
/sbin/iptables -A INPUT -i $INTIF -s 192.168.1.0/24 -p TCP --dport 3128 -j ACCEPT
# El resto se tira
/sbin/iptables -A INPUT -i $INTIF -s 0.0.0.0/0 -p TCP --dport 3128 -j DROP


## Acceso al 143 desde LAN
/sbin/iptables -A INPUT -i $INTIF -s 192.168.1.0/24 -p TCP --dport 143 -j ACCEPT

## Acceso al ssh desde la LAN
/sbin/iptables -A INPUT -i $EXTIF -s 213.195.64.0/24 -p TCP --dport 22 -j ACCEPT

## Acceso al ssh un rango externo
/sbin/iptables -A INPUT -i $EXTIF -s 213.195.64.0/24 -p TCP --dport 22 -j ACCEPT
# el resto se tira
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -p TCP --dport 22 -j DROP

## Acceso al puerto 25
/sbin/iptables -A INPUT -i $EXTIF -s 213.191.89.0/24 -p TCP --dport 25 -j ACCEPT
/sbin/iptables -A INPUT -i $INTIF -s 192.168.1.0/24 -p TCP --dport 25 -j ACCEPT
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -p TCP --dport 25 -j DROP

## FORWARD
# Que me haga log de todo el forward
/sbin/iptables -A FORWARD -j LOG

## He aqui el forward para la LAN, una regla mágica
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
# Ese peazo de bit que hay que habilitar
echo 1 > /proc/sys/net/ipv4/ip_forward


Ejemplo de firewall más completo

Este ejemplo es algo más serio, ya que la regla de input por defecto es DROP. Esta política de reglas es la
más segura, ya que por defecto se denegará TODO, y poco a poco se van habilitando las entradas precisas.

#!/bin/sh

## SCRIPT de IPTABLES
## Pello Xabier Altadill Izura

echo -n Aplicando Reglas de Firewall...

## Paramos el ipchains y quitamos el modulo
/etc/rc.d/init.d/firewall stop
rmmod ipchains

## Instalando modulos
modprobe ip_tables
modprobe ip_nat_ftp
modprobe ip_conntrack_ftp


## Variables
IPTABLES=iptables
EXTIF="eth1"
INTIF="eth0"

## En este caso,
## la tarjeta eth1 es la que va al ROUTER y la eth0 la de la LAN

## Primeras reglas
/sbin/iptables -P INPUT DROP
/sbin/iptables -F INPUT
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -F OUTPUT
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -F FORWARD
/sbin/iptables -t nat -F

### En principio, si las reglas INPUT por defecto hacen DROP, no haria falta
### meter mas reglas, pero si temporalmente se pasa a ACCEPT no esta de mas.

## Todo lo que viene de cierta IP se deja pasar (administradores remotos…)
/sbin/iptables -A INPUT -i $EXTIF -s 203.175.34.0/24 -d 0.0.0.0/0 -j ACCEPT

## El localhost se deja
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -j ACCEPT

## Aceptar al exterior al 80 y al 443

# Permitir salida al 80
/sbin/iptables -A INPUT -i $EXTIF -p tcp --sport 80 -j ACCEPT
/sbin/iptables -A OUTPUT -o $EXTIF -p tcp --dport 80 -j ACCEPT
# Permitir salida al 443
/sbin/iptables -A INPUT -i $EXTIF -p tcp --sport 443 -j ACCEPT
/sbin/iptables -A OUTPUT -o $EXTIF -p tcp --dport 443 -j ACCEPT

## SALIDA SMTP - Para que el servidor se pueda conectar a otros MTA
# Permitir salida SMTP
/sbin/iptables -A INPUT -i $EXTIF -p tcp --sport 25 -j ACCEPT
/sbin/iptables -A OUTPUT -o $EXTIF -p tcp --dport 25 -j ACCEPT

## SALIDA FTP - Para que el servidor se pueda conectar a FTPs
/sbin/iptables -A INPUT -i $EXTIF -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT
/sbin/iptables -A OUTPUT -o $EXTIF -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
# ftp activo
/sbin/iptables -A INPUT -i $EXTIF -p tcp --sport 20 -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A OUTPUT -o $EXTIF -p tcp --dport 20 -m state --state ESTABLISHED -j ACCEPT
# ftp pasivo
/sbin/iptables -A INPUT -i $EXTIF -p tcp --sport 1024:65535 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
/sbin/iptables -A OUTPUT -o $EXTIF -p tcp --sport 1024:65535 --dport 1024:65535 -m state --state ESTABLISHED,RELATED -j ACCEPT


## El acceso al 19720 desde fuera, DENEGADO
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -d 0.0.0.0/0 -p tcp --dport 19720 -j DROP

## El acceso al 19720 desde dentro, ACEPTADO
/sbin/iptables -A INPUT -i $INTIF -s 192.168.9.0/24 -p tcp --dport 19720 -j ACCEPT

## El acceso al 19721 desde fuera, DENEGADO
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -d 0.0.0.0/0 -p tcp --dport 19721 -j DROP

## El acceso al SSH desde fuera, DENEGADO
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -d 0.0.0.0/0 -p tcp --dport 1972 -j DROP

## El acceso al SMTP desde dentro, permitido.
/sbin/iptables -A INPUT -i $INTIF -p tcp --dport 25 -j ACCEPT
## El acceso al SMTP desde fuera, DENEGADO
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -d 0.0.0.0/0 -p tcp --dport 25 -j DROP


## Acceso al 80 desde el interior ACCEPTADO PARA DOS IPs
/sbin/iptables -A INPUT -i $INTIF -s 192.168.9.11/32 -p tcp --dport 80 -j ACCEPT
/sbin/iptables -A INPUT -i $INTIF -s 192.168.9.54/32 -p tcp --dport 80 -j ACCEPT
## Acceso al 80 desde el interior DENEGADO PARA EL RESTO
#/sbin/iptables -A INPUT -i $INTIF -s 192.168.9.0/24 -p tcp --dport 80 -j DROP


## Acceso al PROXY
/sbin/iptables -A INPUT -i $INTIF -s 192.168.9.0/24 -p tcp --dport 8082 -j ACCEPT
/sbin/iptables -A INPUT -i $INTIF -s 192.168.10.0/24 -p tcp --dport 8082 -j ACCEPT
/sbin/iptables -A INPUT -s 127.0.0.0/8 -p tcp --dport 8082 -j ACCEPT

# Desde el exterior denegado
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -p tcp --dport 8082 -j DROP

## Acceso a POP3 e IMAP desde el EXTERIOR, DENEGADO
/sbin/iptables -A INPUT -i $INTIF -s 192.168.9.0/24 -p tcp --dport 110 -j ACCEPT
/sbin/iptables -A INPUT -i $INTIF -s 192.168.9.0/24 -p tcp --dport 143 -j ACCEPT
/sbin/iptables -A INPUT -i $INTIF -s 192.168.10.0/24 -p tcp --dport 110 -j ACCEPT
/sbin/iptables -A INPUT -i $INTIF -s 192.168.10.0/24 -p tcp --dport 143 -j ACCEPT


## Acceso a POP3 e IMAP desde el EXTERIOR, DENEGADO
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -p tcp --dport 110 -j DROP
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -p tcp --dport 143 -j DROP
## Acceso al 8082 desde fuera, DENEGADO
/sbin/iptables -A INPUT -i $EXTIF -s 0.0.0.0/0 -p tcp --dport 8082 -j DROP


## FORWARD
# Que me haga log de todo el forward
#/sbin/iptables -A FORWARD -j LOG

# He aqui el forward

## Norma general
##iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

iptables -t nat -A POSTROUTING -o eth1 -s 192.168.9.11/32 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -s 192.168.9.16 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -s 192.168.9.54/32 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -s 192.168.9.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -s 192.168.10.0/24 -j MASQUERADE

# Habilitar el forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward


5. Reglas de protección

Tranquilos , aquí no vamos a hablar de la última maza de cartas Magic que me he comprado, ni de formulas
para salir airosos jugando a La Llamada de Cthulhu, entre otras cosas porque no juego a esas cosas raras.

En esta breve sección listamos algunas reglas para proteger nuestro equipo y por extensión la red, de ciertos ataques muy habituales en las redes como el smurf y otras formas de inundación y DoS.
¿Es recomendable usar todas estas normas? Según como administremos el nivel de paranoia.
Nota: hay que dar valores concretos a las variables $

# Deshabilitar broadcast
/bin/echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Deshabilitar el ping… quizá discutible.
/bin/echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all
 
# Deshabilitar la redirección del ping
/bin/echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects

# Registrar los accesos extraños, paquetes falseados, etc..
/bin/echo "1" > /proc/sys/net/ipv4/conf/all/log_martians

# Anti-flooding o inundación de tramas SYN.
iptables -N syn-flood
iptables -A INPUT -i $IFACE -p tcp --syn -j syn-flood
iptables -A syn-flood -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A syn-flood -j DROP
 
# Guardar los accesos con paquetes fragmentados, recurso utilizado para tirar
# servidores y otras maldades (bug en Apache por ejemplo)
iptables -A INPUT -i $IFACE -f -j LOG --log-prefix "Fragmento! "
iptables -A INPUT -i $IFACE -f -j DROP
 
# Anti-spoofing (falseo de ip origen)
iptables -A INPUT  -i $IFACE -s $IPADDR -j DROP
iptables -A INPUT  -i $IFACE -s $CLASS_A -j DROP
iptables -A INPUT  -i $IFACE -s $CLASS_B -j DROP
iptables -A INPUT  -i $IFACE -s $CLASS_C -j DROP
iptables -A INPUT -i $IFACE -s $CLASS_D_MULTICAST -j DROP
iptables -A INPUT -i $IFACE -s $CLASS_E_RESERVED_NET -j DROP
iptables -A INPUT  -i $IFACE -d $LOOPBACK -j DROP
iptables -A INPUT -i $IFACE -d $BROADCAST -j DROP
(bien explicado en el script de linuxguruz)

# Proxy Transparent: peticiones al puerto 80 redirigir al SQUID(3128)
iptables -t nat -A PREROUTING -p tcp -s 0.0.0.0/0 --dport 80 -j REDIRECT --to 3128
