#!/bin/bash
# Move failed jobs to the cmove in queue
# 2021 Mauricio Asenjo
# version 1

QUEUEPATH=/cache/bqueue

mv $QUEUEPATH/send2falp/failed/*.job $QUEUEPATH/send2falp/out
command rm $QUEUEPATH/send2falp/failed/*.log
mv $QUEUEPATH/verify/failed/*.job $QUEUEPATH/cmove/in
command rm $QUEUEPATH/verify/failed/*.log
