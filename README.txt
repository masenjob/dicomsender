FALPSENDER script README
version 3

1- Detener todos los servicios y mover directorio /cache:

cd /cache/bqueue
./bqcontrol.sh stopall
cd /cache/img
kill $(ps ax | grep storescp | grep "FALPSENDER1:11112" | awk '{print $1}')
command rm dicomserver.sh.pid
command rm dicomserver.sh.log
rm -rf /cache.bak
mv /cache /cache.bak


2- Obtener dicomsender-main.zip , descomprimir en /

wget https://github.com/masenjob/dicomsender/archive/refs/heads/main.zip -O dicomsender.zip

unzip dicomsender.zip -d /
mv /dicomsender-main /cache


3- iniciar configurador:
cd /cache/config

bash config.sh <archivo de configuracion>

Ejemplo: para móvil 1:

./config.sh MOVIL1.conf


4- Iniciar servicios:

cd /cache/scripts
./startall.sh


----
notas

- para ejecutar monitor de colas:

cd /cache/bqueue
./monitor.sh

- para obtener una lista de estudios a revisar de los ultimos dos días, poniendolos en la cola de verificación:

cd /cache/scripts
./get_studies_by_date.sh

- para obtener una lista de estudios a revisar para cualquier otra fecha (ejemplo: 10 de octubre del 2021):

cd /cache/scripts
./get_studies_by_date.sh 20211010

- para obtener una lista de estudios a revisar para un rango de fechas (ejemplo: desde el 5 de octubre al 7 de octubre del 2021):

cd /cache/scripts
./get_studies_by_date.sh 20211005-20211007



