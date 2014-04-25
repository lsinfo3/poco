#!/bin/bash
if [[ $3 == "" ]]; then
  echo "Usage: $0 INPUTFILE OUTPUTFILE SLICENAME"
else
  INPUTFILE=$1
  OUTPUTFILE=$2
  SLICENAME=$3
  
  ./bash_runcode.sh $INPUTFILE $SLICENAME "echo Hallo"
  
  sleep 10
  wc -l /tmp/runerr/* | awk '$1<1' | cut -d"/" -f4 > $OUTPUTFILE
fi
