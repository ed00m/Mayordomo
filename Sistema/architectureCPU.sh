####################################################################################################
#
# IMPLEMENTACION DE
# http://gnulinuxporqueno.cl/2013/05/17/como-saber-que-arquitectura-soporta-mi-cpu/
#
# grep -q "^flags.*\blm\b" /proc/cpuinfo && echo "CPU de 64 bits (soporta x86_64)" || echo "CPU de 32 bits (no soporta x86_64)"
#
####################################################################################################

if (grep -q "^flags.*\blm\b" /proc/cpuinfo);then
    echo "CPU de 64 bits (soporta x86_64)"
else
    echo "CPU de 32 bits (no soporta x86_64)"
fi
