#!/bin/bash
if [[ $2 == "" ]]; then
  echo "Usage: $0 INPUTFILE OUTPUTFILE"
else
  INPUTFILE=$1
  OUTPUTFILE=$2
  for node in $( cat $INPUTFILE ); do 
    (ping $node -c1 -W 1 2>&1 > /dev/null ) && echo $node 
  done | sort 2>/dev/null 1> $OUTPUTFILE
fi
