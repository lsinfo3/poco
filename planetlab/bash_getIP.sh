#!/bin/bash
if [[ $2 == "" ]]; then
  echo "Usage: $0 INPUTFILE OUTPUTFILE"
else
  INPUTFILE=$1
  OUTPUTFILE=$2
  for node in $( cat $INPUTFILE ); do 
    echo $node";"$(ping $node -c1 -W1 | grep "PING " | tr '()' ' ' | awk '{print $2";"$3}' )  
  done 2>/dev/null | tee $OUTPUTFILE
fi
