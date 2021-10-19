#!/bin/bash
#
# get_studies_by_date.sh
# get a list of studies for the specified period
# in source pcas specified in configuration
# and generate job files for each one
#
# 2021 Mauricio Asenjo
# version 0.8

# Get the script directory
dir=$(dirname ${BASH_SOURCE[0]})

# Config file (relative to script location)
config=$dir"/"$(basename $0)".conf"

# Log file (relative to script location)
logfile=$dir"/"$(basename $0)".log"

# defaults
source_ssl="FALSE"
timeout="10m"
jobfilename="ACC"
study_id="SUID"
unique=0
tmpdir="/tmp"

if [ -f $config ]
then
        source $config
else
	echo "config file not found"
	echo "Make sure there is a $config file and has this contents:"
	echo "#source pacs options"
	echo "source_aet=<AET> # Source pacs AETITLE"
	echo "source_host=<hostname_or_ip> # Source pacs hostname or ip address"
	echo "source_port=<port> # source pacs dicom port"
	echo "# Optional source ssl options"
	echo "#source_ssl=<TRUE|FALSE>"
	echo "#source_trustore=/root/certs/falpKeystore.pkcs12"
	echo "#source_trustpass=4gf42w1n"
	echo "calling_ae=<AET> # AET for query"
	echo "timeout=<10m> # timeout in minutes"
	echo "study_id=<ACC|SUID> # Study query parameter is AccessionNumber ACC or StudyUID SUID. Default is SUID"
	echo "jobfilename=<ACC|SUID> # job filename is AccessionNumber ACC or StudyUID SUID. Default is ACC"
	echo "jobdir=<dir> # Directory to store job files "
	echo "unique=<0|1> # Whether filenames should have a unique suffix. Default is 0"
	echo "tmpdir=<dir> # dir to store temp files. Default is /tmp "
	exit 1
fi

xsl="get_studies_by_date.xsl"

if [ ! -f $xsl ] ; then
	echo "ERROR : $xsl not found"
	echo "Make sure there is a $xsl file in current dir and has this contents:"
	echo "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">
  <xsl:output method=\"text\"/>

  <xsl:template match=\"/NativeDicomModel\">
    <xsl:text>\"</xsl:text>
    <xsl:apply-templates select=\"DicomAttribute[@tag='0020000D']\"/>
    <xsl:text>\",\"</xsl:text>
    <xsl:apply-templates select=\"DicomAttribute[@tag='00080050']\"/>
    <xsl:text>\"
</xsl:text>
  </xsl:template>

  <xsl:template match=\"DicomAttribute\">
    <xsl:apply-templates select=\"Value\"/>
  </xsl:template>

</xsl:stylesheet>"
	exit 2
fi

if [ -z $1 ]
then
        echo "Date query not specified. Will query for studies since yesterday"
        dateQuery=$(date --date=yesterday +%Y%m%d)"-"
else
        dateQuery=$1
fi

#Get study list
studyList="studies"

#Generated study list will have a "1" appended to the name

genStudyList=$studyList"1"

# Create a new file

if (truncate -s 0 $tmpdir/$genStudyList) ; then
	echo "Generating new study list"
else
	echo "ERROR: file $tmpdir/$genStudyList cannot be created, aborting"
	exit 1
fi

sourcePacsConnString=$source_aet@$source_host:$source_port

echo "Querying studies for $dateQuery" ...
findscu -b $calling_ae -c $sourcePacsConnString -m StudyDate=$dateQuery -r AccessionNumber -r StudyInstanceUID -r StudyDate -x $xsl --out-cat --out-dir $tmpdir --out-file $studyList > $logfile

# remove double quotes from studylist file
sed -i 's/"//g' "$tmpdir/$genStudyList"

studyCount=$(cat "$tmpdir/$genStudyList" | wc -l)

echo "Generating  $studyCount job files .."

while read -r line
do
	studyUID=$(echo $line | awk -F "," '{ print $1 }')
	acc=$(echo $line | awk -F "," '{ print $2 }')
	# Create job file:
	if [ "$unique" -eq 0 ]; then
		suffix=""
	else
		suffix="_"$(date +%Y%m%d%H%M%s)
	fi
	if [ "$jobfilename" = "ACC" ]; then
		jobfile=$acc$suffix".job"
	else
		jobfile=$studyUID$suffix".job"
	fi
	
	#Replace spaces from the filename
	jobfile=$(echo "$jobfile" | sed 's/ /_/g')
	
	if [ "$study_id" = "SUID" ]; then
		contents="$studyUID"
	else
		contents="$acc"
	fi
	
	echo "$contents" > "$jobdir/$jobfile"
done < "$tmpdir/$genStudyList"
echo "Done"
