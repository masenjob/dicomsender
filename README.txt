FALPSENDER SCRIPT README

INSTRUCCIONES DE INSTALACION

1- Descargar y ejecutar script de instalación:

cd /
wget https://github.com/masenjob/dicomsender/raw/main/config/installsender.sh -O installsender.sh
bash installsender.sh


2- iniciar configurador:

cd /cache/config
bash config.sh <archivo de configuracion>

Ejemplo: para móvil 1:
bash config.sh MOVIL1.conf


3- Iniciar servicios y poblar colas con estudios de ultimos 2 dias:

/cache/scripts/startall.sh
/cache/scripts/get_studies_by_date.sh


----
notas

- para ejecutar monitor de colas:

cd /cache/bqueue
./monitor.sh

- para obtener una lista de estudios a revisar de los ultimos dos días, poniendolos en la cola de verificación:

/cache/scripts/get_studies_by_date.sh

- para obtener una lista de estudios a revisar para cualquier otra fecha (ejemplo: 10 de octubre del 2021):

cd /cache/scripts
./get_studies_by_date.sh 20211010

- para obtener una lista de estudios a revisar para un rango de fechas (ejemplo: desde el 5 de octubre al 7 de octubre del 2021):

cd /cache/scripts
./get_studies_by_date.sh 20211005-20211007



