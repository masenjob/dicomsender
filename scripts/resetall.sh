#!/bin/bash
# Reset and stop all queues and services
# Mauricio Asenjo
# version 0.2

cd /cache/bqueue
./bqcontrol.sh stopall
# clean up logs & pidfiles
command rm nohup.out
for q in $queues ; do
        ./bqreset.sh $q".conf" all
        command rm $q/$q.$(hostname -s).pid
done

cd /cache/img
./dicomserver.sh stop
command rm dicomserver.sh.log
command rm -rf /cache/img/incoming/*
