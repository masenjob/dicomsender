#!/bin/bash
# Dicom receiver
# starts a Dicom Server on the specified port
# and stores received studies on the $dest_dir
#
# requires dcm4che 5
#
# 2021 Mauricio Asenjo
# version 2

# Get the script directory
dir=$(dirname ${BASH_SOURCE[0]})

# Config file (relative to script location)
config=$dir"/"$(basename $0)".conf"

if [ -f $config ]
then
        source $config
else
        echo "ERROR: Config file "$config" not found."
        echo "Make sure the config file exists and has this format:"
        echo "AET=<AET of the dicomserver>"
        echo "port=<port of the dicom server>"
        echo "recv_dir=<absolute path of the destination directory>"
        echo "dir_format=<format of the directories where the study is stored"
        echo "#example: dir_format='{00080050}/{0020000D}/{0020000E}/{00080018}.dcm'"
        exit 1
fi

# Check if we got a parameter
if [ -z $1 ]; then
	echo "usage:  $0 start | stop | status"
	exit 0
fi

action=$1

 # Start storescp
start_dicomserver ()
{
	#reset logfile
	echo "" > $logfile
	echo "STARTING $0"
	nohup storescp -b $AET:$port --directory $recv_dir --filepath $dir_format >> $logfile & PID=$!
	local status=$?
	echo $PID > $pidfile
	echo "$0 STARTED"
	return $status
}

#stop the storescp pid in $pidfile
stop_dicomserver ()
{
if [ -f $pidfile ]; then
	local PID=$(cat $pidfile)
	if [ "$(ps ax | grep storescp | grep $AET":"$port | awk '{print $1}')"  -eq "$PID" ] ; then
		kill $PID
		local status=$?
		if [ $status = 0 ] ; then
			echo "$0 STOPPED"
			rm $pidfile
		else
			echo "0 cannot be stopped. Consider running kill -9 $PID and remove $pidfile"
		fi
	else
		# pidfile found, but no process running
		echo "No process found. Consider removing $pidfile" 
		local status=2
	fi
else
	# no pid found , stopped
	echo "$0 NOT RUNNING"
	local status=0
fi
return $status
}

status_dicomserver ()
{
	if [ -f $pidfile ]; then
		if [ "$(ps ax | grep storescp | grep $AET":"$port | awk '{print $1}')"  -eq "$(cat $pidfile)" ] ; then
			# pidfile found and match a storescp process
			echo "RUNNING"
		else
			# pidfile found, but no process runing
			echo "NOT_RUNNING"
		fi
	else
		echo "STOPPED"
	fi
}

logfile=$dir"/"$(basename $0)".log"
pidfile=$dir"/"$(basename $0)".pid"


case $action in
	
	status)
		echo "service status: $(status_dicomserver) "
		;;
		
	start)
		echo "Starting $0 :"
		start_dicomserver
		;;
		
	stop)
		echo "Stopping $0 :"
		stop_dicomserver
		;;
		
	*)
		echo $action": unknown option"
		exit 1
		;;
esac
