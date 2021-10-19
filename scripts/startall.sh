#!/bin/bash
# Starts all queues and services
# Mauricio Asenjo
# version 0.2

cd /cache/img
./dicomserver.sh start

cd /cache/bqueue
./bqcontrol.sh startall


