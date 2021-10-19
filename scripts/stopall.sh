#!/bin/bash
# Stops all queues and services
# Mauricio Asenjo
# version 0.2

cd /cache/bqueue
./bqcontrol.sh stopall

cd /cache/img
./dicomserver.sh stop

