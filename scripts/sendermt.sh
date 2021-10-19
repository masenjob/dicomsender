#!/bin/bash
# Bqueue maintenance script
. /etc/bashrc

DICOMSERVERLOG=/cache/img/dicomserver.sh.log
QUEUEPATH=/cache/bqueue

# resetear log dicomserver :
echo "" > $DICOMSERVERLOG

cd $QUEUEPATH

#reset hl7_ian_queue
./bqreset.sh hl7_ian_queue logs

#reset cmove logs
./bqreset.sh cmove logs

#reset send2falp logs
./bqreset.sh send2falp logs

# Delete out dir in all queues
command rm $QUEUEPATH/hl7_ian_queue/finished/*
command rm $QUEUEPATH/hl7_ian_queue/out/*
#command rm $QUEUEPATH/cmove/out*
command rm $QUEUEPATH/send2falp/out/*
