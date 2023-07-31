#!/bin/bash

# Define 'help' function
help()
{
   echo ""
   echo "Usage: $0 -p myPodName -l 1000 -s"
   echo -e "\t-p MADNATORY: String that Kubernetes pod must contain, for example the pod 'yo-momma-66c4f54568-4fq7k' is found by 'yo-momma'."
   echo -e "\t-l OPTIONAL:  Number of lines if specified, otherwise the full pod logs are downloaded."
   echo -e "\t-s OPTIONAL:  Flag whether the downloaded file should NOT be opened after the script execution, otherwise it is opened by default."
   echo ""
   echo "Created by Nikolas Charalambidis, see: https://github.com/Nikolas-Charalambidis/macos-scripts"
   echo ""
   exit 1
}

# Parse parameters
while getopts "p:l:s" opt
do
   case "$opt" in
   	  p ) p="$OPTARG" ;;
      l ) l="$OPTARG" ;;
      s ) s='true' ;;
      ? ) help ;; # Call 'help' in case parameter is non-existent
   esac
done

# Validation
if [[ -z "$p" ]] ; then
   echo "Some or all of the parameters are empty";
   help
fi

regex='^[0-9]+$'
if ! [[ $l =~ $regex ]] ; then
   echo "The argument -l must be a number";
   help
fi

# Process
POD=`kubectl get pods | grep -m 1 $p | awk '{print $1}'`

NOW=`echo $(date +%Y%m%d_%H%M%S)`
DIR=~/Logs/kubectl
FILE=$DIR/$POD.$NOW.log

touch $FILE
if [[ -z $l ]]; then
	echo "Extracting all log lines from $POD ..."
    kubectl logs $POD > $FILE
else
	echo "Extracting last $l log lines from $POD ..."
    kubectl --tail=$l logs $POD > $FILE
fi

echo $FILE

if [[ $s != 'true' ]]; then
	echo "Opening..."
	open $FILE
fi 

exit 0
