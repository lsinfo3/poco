#!/bin/bash
if [[ $3 == "" ]]; then
  echo "Usage: $0 PINGFILE SSHFILE OUTPUTFILE"
  echo "(Attention: Input files need to be sorted)"
else
  # Attention: Files $1 and $2 need to be sorted
  PINGFILE=$1
  SSHFILE=$2
  OUTPUTFILE=$3
  
  comm $PINGFILE $SSHFILE -3 -2 > $OUTPUTFILE
fi
