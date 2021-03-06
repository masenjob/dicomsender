#!/bin/bash

# installsender.sh
# sender installation script
# 2021 Mauricio Asenjo
# version 0.4

dicomsenderDir="/cache"

echo "DicommSender install script"
echo ""

if [ -d $dicomsenderDir ] ; then
	echo "dicomsender dir $dicomsenderDir found"
	if [ -d $dicomsenderDir/bqueue ] ; then
		echo "Bqueue dir found"
		echo "Stopping queues"	
		cd $dicomsenderDir/bqueue
		./bqcontrol.sh stopall
		echo "Stopping Dicomserver"
	fi
	cd /cache/img
	./dicomserver.sh stop
	dmpid=$(ps ax | grep storescp | grep "FALPSENDER1:11112" | awk '{print $1}')
	if [ ! -z "$dmpid" ] ; then
			kill $dmpid
	fi
	echo "Backing up $dicomsenderDir"
	cd /
	rm -rf /$dicomsenderDir".bak"
	mv /$dicomsenderDir /$dicomsenderDir".bak"
fi
cd /
if [ -f dicomserver.zip ]; then
	echo "dicomserver.zip from previous installation found. Removing it"
	command rm dicomserver.zip
fi
wget https://github.com/masenjob/dicomsender/archive/refs/heads/main.zip -O dicomsender.zip
unzip dicomsender.zip -d /
mv /dicomsender-main /cache
echo "Done"