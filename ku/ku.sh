#!/bin/bash

#===================================================================================================
#  HEADER
#===================================================================================================
#  IMPLEMENTATION
#     version         ku 0.0.1
#     author          Nikolas CHARALAMBIDIS
#     license         GNU GPLv3
#     link            https://github.com/Nikolas-Charalambidis/macos-scripts/ku
# 
#===================================================================================================
#  HISTORY
#     2023/08/01 : Nikolas CHARALAMBIDIS : Script creation
#
#===================================================================================================
#  END_OF_HEADER
#===================================================================================================

COMMAND=${1}

LOGS_DIR=~/Logs/kubectl
LOG_LINES_NUMBER=1000

die() { echo "$*" >&2; exit 2; }
needs_arg() { echo "HERE $OPTARG=$OPT"; if [[ -z "$OPTARG" ]]; then die "No arg for --$OPT option"; fi; }

requires_number() {
        regex='^[0-9]+$'
        if ! [[ $OPTARG =~ $regex ]] ; then
           die "The argument -$OPT must be a number";
        fi
}

help() {
        if [[ $1 == 'logs' ]]; then
                echo "Fetches the logs for a pod, writes into a file in the default directory $LOGS_DIR, and opens the file. If not specified, the number of fetched lines is 1000 by default due to possibly huge size of the logs.
Usage:
  ku logs <pod> [-l LINES] [-a] [-s]

Options:
  -f     OPTIONAL FLAG          Specify that the full logs should be fetched. 
  -l     OPTIONAL NUMBER        A certain number of logs lines should be fetched. The default value is $LOG_LINES_NUMBER.
  -s     OPTIONAL FLAG          Specify that the file with the fetched logs content will not be opened after logs fetching and writing.

Examples:
  # Fetches the default $LOG_LINES_NUMBER logs lines from a first pod matching 'foo' into a file in the default directory, and opens the log file
  ku logs foo

  # Fetches the default $LOG_LINES_NUMBER logs lines from a first pod matching 'foo' into a file in the default directory without opening the log file
  ku logs foo -s

  # Fetches 250 logs lines from a first pod matching 'foo' into a file in the default directory, and opens the log file
  ku logs foo -l 250

  # Fetches the full logs from a first pod matching 'foo' into a file in the default directory, and opens the log file
  ku logs foo -f
"
        elif [[ $1 == 'spin' ]]; then
                echo "Not yet implemented."
        else 
                echo "ku is a small utility for common kubectl commands.

  Find more at https://github.com/Nikolas-Charalambidis/macos-scripts/ku

Basic Commands:
  logs          Fetches logs from a first pod matching the input name.
  spin          Deletes a first pod matching the input name which makes Kubernetes to deploy a new one up to the defined scale.

Usage:
  Use \"ku <command> --help\" for more information about a given command.
"
        fi

        exit 0
}

#===================================================================================================
#  HELP
#===================================================================================================

if [[ -z $COMMAND || $COMMAND == '-h' || $COMMAND == '-H' || $COMMAND == '--help' ]]; then
        help a
#===================================================================================================
#  LOGS
#===================================================================================================

elif [[ $COMMAND == 'logs' ]]; then

        # Parse and validate $POD
        POD=${2}
        if [[ -z $POD ]]; then
                echo "Missing pod name"
                echo
                help logs
        elif [[ $POD == '-h' || $POD == '-H' || $POD == '--help' ]]; then
                help logs
        fi

        # Define variables
        FULL='false'
        SILENT='false'

        # Skip first two parameters
        OPTIND=3

        # Parse arguments
        while getopts "l:fhs" OPT; do
                case "$OPT" in
                        l)      requires_number; LOG_LINES_NUMBER=$OPTARG ;;
                        f)      FULL='true' ;;
                        s)      SILENT='true' ;;
                        h)      help ;;
                        \?)     die "Illegal option -$OPTARG" ;;
                esac
        done

        # Move 'getopts' on to the next argument.
        shift $((OPTIND-1))  

        # PROCESS
        echo "Looking for the pod matching the '$POD' string..."
        echo " kubectl get pods | grep -m 1 $POD | awk '{print $1}'"
        KUBERNETES_POD=`kubectl get pods | grep -m 1 $POD | awk '{print $1}'`
        if [[ -z $KUBERNETES_POD ]]; then
                die "No pod name matches $POD"
        else
                echo "Matched pod with the name $KUBERNETES_POD" 
        fi

        # Create a directory (if it does not exists) and a file
        NOW=`echo $(date +%Y%m%d_%H%M%S)`
        LOG_FILE=$LOGS_DIR/$KUBERNETES_POD.$NOW.log
        mkdir -p $LOGS_DIR
        touch $LOG_FILE
        echo "File..."
        echo " $LOG_FILE"

        # Fetching logs
        if [[ $FULL == 'true' ]]; then
                echo "Extracting the full logs from $KUBERNETES_POD using the command..."
                echo " kubectl logs $KUBERNETES_POD > $LOG_FILE"
                echo "This might take a while..."
                kubectl logs $KUBERNETES_POD > $LOG_FILE
        else
                echo "Extracting last $LOG_LINES_NUMBER logs lines from $KUBERNETES_POD using the command..."
                echo " kubectl --tail=$LOG_LINES_NUMBER logs $KUBERNETES_POD > $LOG_FILE"
                kubectl --tail=$LOG_LINES_NUMBER logs $KUBERNETES_POD > $LOG_FILE
        fi

        # Silent 
        if [[ $SILENT == 'true' ]]; then
                echo "Finished"
        else
                echo "Finished, opening..."
                open $LOG_FILE
        fi 

        exit 0
        
#===================================================================================================
#  SPIN
#===================================================================================================
        
elif [[ $COMMAND == 'spin' ]]; then
        help spin
        
#===================================================================================================
#  DEFAULT
#===================================================================================================
else 
        die "Illegal command $COMMAND"
fi
