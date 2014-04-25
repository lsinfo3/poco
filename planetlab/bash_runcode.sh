#!/bin/bash 
if [[ $3 == "" ]]; then
  echo "Usage: $0 NODEFILE SLICENAME COMMAND"
else
  NODEFILE=$1
  SLICENAME=$2
  COMMAND=$3
  export PSSH_USER="$SLICENAME"
  export PSSH_OUTDIR="/tmp/runout"
  export PSSH_ERRDIR="/tmp/runerr"
  export PSSH_OPTIONS="ConnectTimeout 3"
  echo "Starting program $COMMAND on all nodes"
  parallel-ssh -h $NODEFILE "nohup $COMMAND > /dev/null &" > /dev/null
fi
