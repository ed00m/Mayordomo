####################################################################################################
#
# IMPLEMENTACION DE
# http://gnulinuxporqueno.cl/2013/06/10/como-saber-que-arquitectura-es-mi-so/
#
# uname -a|grep -E "i386|i486|i586|i686" && echo "Sistema de 32 bits" || echo "Sistema de 64 bits"
#
####################################################################################################

if (! uname -a|grep -E "i386|i486|i586|i686" > /dev/null);then
    echo "Sistema de 64 bits"
else
    echo "Sistema de 32 bits"
fi
