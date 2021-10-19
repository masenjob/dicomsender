FALPSENDER script README
version 1

1- Tomar nota de:
AETitle de EI Camion
ip ei camion
AETitle de pipeline Falp

2- copiar cache<version>.tar.gz en /root ,
en linux: 

cd /cache/bqueue
./bqcontrol.sh stopall
cd /cache/img
kill $(ps ax | grep storescp | grep "FALPSENDER1:11112" | awk '{print $1}')
command rm dicomserver.sh.pid
command rm dicomserver.sh.log
mv /cache /cache.bak
tar xvfz /root/cache<version>.tar.gz

3- Generar en el directorio /cache, archivo de texto dee nombre "MOVIL(n).conf" donde (n) es el numero de móvil, con los siguientes parámetros:

EI_MOVIL_AET=AETitle de EI Camion
EI_MOVIL_HOST=ip ei camion
EI_CENTRAL_AET=AETitle de pipeline Falp

Ejemplo: para MOVIL1 , generamos /cache/MOVIL1.conf con lo siguiente:

EI_MOVIL_AET=TTXMNQYWL
EI_MOVIL_HOST=192.168.50.154
EI_CENTRAL_AET=MOVIL1


4- ejecutamos ( en /cache )

./config.sh <archivo de configuracion>

Ejemplo: para móvil 1:

./config.sh MOVIL1.conf

5- revisar que crontab contenga la linea:

*/5 * * * * /cache/scripts/retry_failed.sh > /var/log/dicomserver_retry.log

6- reiniciar :
reboot


----
notas

- para ejecutar monitord de colas:

cd /cache/bqueue
./monitor.sh

- para obtener una lista de estudios a revisar de los ultimos dos días, poniendolos en la cola de verificación:

cd /cache/scripts
./get_studies_by_date.sh

- para obtener una lista de estudios a revisar para cualquier otra fecha (ejemplo: 10 de octubre del 2021):

cd /cache/scripts
./get_studies_by_date.sh 20211010

- para obtener unalista de estudios a revisar para un rango de fechas (ejemplo: desde el 5 de octubre al 7 de octubre del 2021):

cd /cache/scripts
./get_studies_by_date.sh 20211005-20211007



