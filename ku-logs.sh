#!/bin/bash

POD=`kubectl get pods | grep -m 1 $1 | awk '{print $1}'`

NOW=`echo $(date +%Y%m%d_%H%M%S)`
DIR="/Users/nikolas/Logs/kubectl"
FILE=$DIR/$POD.$NOW.log

if [[ -z $2 ]]; then
	echo "Extracting all log lines from $POD..."
    kubectl logs $POD > $FILE
else
	echo "Extracting last $2 log lines from $POD..."
    kubectl --tail=$2 logs $POD > $FILE
fi

echo $FILE
exit 0;
