#!/bin/bash
if [[ $2 == "" ]]; then
  echo "Usage: $0 NODEFILE SLICENAME FILENAME"
else
  NODEFILE=$1
  SLICENAME=$2
  FILENAME=$3
  
  parallel-scp -O "ConnectTimeout 3" -h $NODEFILE -l $SLICENAME -e /tmp/scperr -o /tmp/scpout $FILENAME /home/$SLICENAME/.
fi
