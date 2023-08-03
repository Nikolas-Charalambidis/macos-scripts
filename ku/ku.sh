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
#     2023/08/03 : Nikolas CHARALAMBIDIS : Namespaces support and integer Regex fix
#
#===================================================================================================
#  END_OF_HEADER
#===================================================================================================

COMMAND=$1

LOGS_DIR=~/Logs/kubectl
LOG_LINES_NUMBER=1000

die() { echo "$*" >&2; exit 2; }
require_number() { if ! [[ $OPTARG =~ ^-?[0-9]+$ ]] ; then die "The argument -$OPT must be a number: $OPTARG"; fi; }

argument_pod() {
        echo "1: $1"
        echo "2: $2"
        POD=$1
        if [[ -z $POD ]]; then
                echo "Missing pod name"
                echo
                help $2
        elif [[ $POD == '-h' || $POD == '-H' || $POD == '--help' ]]; then
                help $2
        fi
}

find_pod() {
                # PROCESS
        echo "Looking for the pod matching the '$POD' string..."
        echo " kubectl get pods `[[ -z "${NAMESPACE}" ]] || echo "-n ${NAMESPACE}"` | grep -m 1 $POD | awk '{print $1}'"

        if [[ -z "${NAMESPACE}" ]]; then
                KUBERNETES_POD=`kubectl get pods | grep -m 1 $POD | awk '{print $1}'`
        else
                KUBERNETES_POD=`kubectl get pods -n $NAMESPACE | grep -m 1 $POD | awk '{print $1}'`
        fi

        if [[ -z $KUBERNETES_POD ]]; then
                die "No pod name matches '$POD'"
        else
                echo "Matched pod with the name $KUBERNETES_POD" 
        fi
}

help() {
        if [[ $1 == 'logs' ]]; then
                echo "Fetches the logs for a pod, writes into a file in the default directory $LOGS_DIR, and opens the file. If not specified, the number of fetched lines is 1000 by default due to possibly huge size of the logs.
Usage:
  ku logs <pod> [-l LINES] [-a] [-s]

Options:
  -f     OPTIONAL FLAG          Specify that the full logs should be fetched. 
  -l     OPTIONAL NUMBER        Specify a given number of logs lines should be fetched. The default value is $LOG_LINES_NUMBER.
  -n     OPTIONAL STRING        Specify a given namespace, otherwise the currently selected is used by default. 
  -s     OPTIONAL FLAG          Specify that the file with the fetched logs content will not be opened after logs fetching and writing.

Examples:

  Assuming the following output:
    [user@server ~]$ kubectl get pods
    NAME                             READY   STATUS    RESTARTS      AGE
    yo-momma-0                       1/1     Running   0             24m
    yo-momma-1                       1/1     Running   0             43m
    yo-daddy                         1/1     Running   0             38m

  # Fetches the default $LOG_LINES_NUMBER logs lines from 'yo-momma-0' into a file in the default directory, and opens the log file
  ku logs momma

  # Fetches the default $LOG_LINES_NUMBER logs lines from 'yo-momma-0' into a file in the default directory without opening the log file
  ku logs momma -s

  # Fetches 250 logs lines from 'yo-momma-0' into a file in the default directory, and opens the log file
  ku logs momma -l 250

  # Fetches the full logs from 'yo-momma-0' into a file in the default directory, and opens the log file
  ku logs momma -f
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

        argument_pod $2 'logs'

        # Define variables
        FULL='false'
        SILENT='false'

        # Skip first two parameters
        OPTIND=3

        # Parse arguments
        while getopts "l:n:fhs" OPT; do
                case "$OPT" in
                        h)      help ;;
                        f)      FULL='true' ;;
                        l)      require_number; LOG_LINES_NUMBER=$OPTARG ;;
                        n)      NAMESPACE=$OPTARG ;;
                        s)      SILENT='true' ;;
                        \?)     die "Illegal option -$OPTARG" ;;
                esac
        done

        # Move 'getopts' on to the next argument.
        shift $((OPTIND-1))  

        find_pod

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
                echo " kubectl logs $KUBERNETES_POD `[[ -z "${NAMESPACE}" ]] || echo "-n ${NAMESPACE}"` > $LOG_FILE"
                echo "This might take a while..."
                if [[ -z "${NAMESPACE}" ]]; then
                        kubectl logs $KUBERNETES_POD > $LOG_FILE
                else
                        kubectl logs $KUBERNETES_POD -n $NAMESPACE> $LOG_FILE
                fi
        else
                echo "Extracting last $LOG_LINES_NUMBER logs lines from $KUBERNETES_POD using the command..."
                echo " kubectl --tail=$LOG_LINES_NUMBER logs $KUBERNETES_POD `[[ -z "${NAMESPACE}" ]] || echo "-n ${NAMESPACE}"` > $LOG_FILE"
                if [[ -z "${NAMESPACE}" ]]; then
                        kubectl --tail=$LOG_LINES_NUMBER logs $KUBERNETES_POD > $LOG_FILE
                    else
                        kubectl --tail=$LOG_LINES_NUMBER logs $KUBERNETES_POD -n $NAMESPACE> $LOG_FILE
                fi
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
