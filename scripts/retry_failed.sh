#!/bin/bash
# Move failed jobs to the cmove in queue

QUEUEPATH=/cache/bqueue

mv $QUEUEPATH/send2falp/failed/*.job $QUEUEPATH/verify/in
command rm $QUEUEPATH/send2falp/failed/*.log
mv $QUEUEPATH/verify/failed/*.job $QUEUEPATH/cmove/in
command rm $QUEUEPATH/verify/failed/*.log
