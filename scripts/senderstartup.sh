#!/bin/bash

# Bqueue dicomserver & sender startup script
#  Only to be run at system startup !!
# 2021 Mauricio Asenjo
# version 0.2

. /etc/bashrc

bqueuedir=/cache/bqueue
queues="hl7_ian_queue cmove send2falp verify"
dicomdir=/cache/img

#start dicomserver
cd $dicomdir
command rm dicomserver.sh.pid
command rm dicomserver.sh.log
./dicomserver.sh start


cd $bqueuedir

# clean up logs & pidfiles 
command rm nohup.out
for q in $queues ; do 
	./bqreset.sh $q".conf" all
	command rm $q/$q.$(hostname -s).pid
done

# Start all queues
./bqcontrol.sh startall
