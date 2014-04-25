#!/bin/bash
if [[ $3 == "" ]]; then
  echo "Usage: $0 INPUTFILE OUTPUTFILE SLICENAME"
else
  INPUTFILE=$1
  OUTPUTFILE=$2
  SLICENAME=$3
  
  for node in $( cat $INPUTFILE ); do 
    ssh -o ConnectTimeout=2 -o BatchMode=yes $SLICENAME@$node echo $node; 
  done | sort 2>/dev/null 1> $OUTPUTFILE
fi
