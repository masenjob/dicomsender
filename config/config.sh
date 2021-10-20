#!/bin/bash

# config.sh
# sender configuration script
# 2021 Mauricio Asenjo
# version 0.11

# Check if we got a parameter
if [ -z $1 ]; then
        echo "usage:  $0 <config_file>"
        exit 0
fi

config_file=$1

if [ ! -f $config_file ]
then
    echo "ERROR: File: "$config_file" not found, exiting"
	echo "config file must have the following parameters:"
	echo "EI_MOVIL_AET=#AET de EI movil"
	echo "EI_MOVIL_HOST=#Ip de EI movil"
	echo "EI_CENTRAL_AET=#AET de pipeline en EI Central"
    exit 2
fi

source ./$config_file

dicomsenderDir=/cache
templates=$dicomsenderDir/templates
bqueueDir=$dicomsenderDir/bqueue
bqueueWorkersDir=$bqueueDir/workers
scriptsDir=$dicomsenderDir/scripts
dicomserverDir=$dicomsenderDir/img

installConfig ()
{
	local config=$1 # config file name
	local destDir=$2 # Full path of the destination directory
	local templateFile=$templates/$config.template
	local sourceFile=$templates/$config

	sed "s/###_EI_MOVIL_AET_###/$EI_MOVIL_AET/g" $templateFile > $sourceFile
	sed -i "s/###_EI_MOVIL_HOST_###/$EI_MOVIL_HOST/g" $sourceFile
	sed -i "s/###_EI_CENTRAL_AET_###/$EI_CENTRAL_AET/g" $sourceFile

	cp $sourceFile $destDir/
}

if [ -d $bqueueDir ]; then
	echo "Found $bqueueDir. Will not download and install a new one"
else
	echo "Downloading a new bqueue distribution"
	wget https://github.com/masenjob/bqueue/archive/refs/heads/main.zip -O bqueue-main.zip
	echo "Installing a new bqueue distribution"
	unzip bqueue-main.zip -d /cache
	mv /cache/bqueue-main $bqueueDir
fi

echo "configuring permissions"

find $dicomsenderDir -name "*.sh" -exec chmod +x {} \;

echo "installing cmove-to-dicomqueue.sh configuration"
installConfig cmove-to-dicomqueue.sh.conf $bqueueWorkersDir

echo "installing dicomsender2-to-falp.sh.conf configuration"
installConfig dicomsender2-to-falp.sh.conf $bqueueWorkersDir

echo "installing dicom_verify_series.sh.conf configuration"
installConfig dicom_verify_series.sh.conf $bqueueWorkersDir

echo "installing get_studies_by_date.sh.conf configuration"
installConfig get_studies_by_date.sh.conf $scriptsDir

echo " Copying config files"

cp $templates/send2falp.conf $bqueueDir
cp $templates/cmove.conf $bqueueDir
cp $templates/hl7_ian_queue.conf $bqueueDir
cp $templates/verify.conf $bqueueDir
cp $templates/dicomserver.sh.conf $dicomserverDir
cp $templates/parsehl7.sh.conf $bqueueWorkersDir

echo " Copying scripts"
cp $bqueueDir/utils/dicomserver.sh $dicomserverDir
cp $bqueueDir/utils/get_studies_by_date.sh $scriptsDir

echo " Creating symlinks "
cd $bqueueWorkersDir
ln -s dicomsender2.sh dicomsender2-to-falp.sh
ln -s cmove.sh cmove-to-dicomqueue.sh
cd $dicomsenderDir
ln -s scripts/senderstartup.sh senderstartup.sh

echo " Initializing queues"

cd $bqueueDir
./bqcontrol.sh startall
./bqcontrol.sh stopall

echo " Setting queue permissions"
chgrp -R smbgroup $bqueueDir
chmod -R ug+rw $bqueueDir

echo " Installing new crontab"
crontab -r # clear existing crontab file
cp $dicomsenderDir/scripts/dicomsender.cron /etc/cron.d

echo "Done"

