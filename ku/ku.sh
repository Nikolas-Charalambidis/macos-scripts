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
#     2023-08-01 : Nikolas CHARALAMBIDIS : Script creation
#     2023-08-03 : Nikolas CHARALAMBIDIS : Namespaces support
#     2023-08-05 : Nikolas CHARALAMBIDIS : ku spin
#
#===================================================================================================
#  END_OF_HEADER
#===================================================================================================

COMMAND=$1

LOGS_DIR=~/Logs/kubectl
LOG_LINES_NUMBER=1000

info() { echo "$(tput setaf 6)INFO: $(tput sgr0)$*" >&2; }
error() { echo "$(tput setaf 1)ERROR: $(tput sgr0)$*" >&2; exit 2; }
warning() { echo "$(tput setaf 3)WARNING: $(tput sgr0)$*" >&2; }

require_input() {  if [[ -z $OPTARG ]]; then error "The argument -$OPT must have an input"; fi; }
require_number() { if ! [[ $OPTARG =~ ^[0-9]+$ ]] ; then error "The argument -$OPT must be a number: $OPTARG"; fi; }

#===================================================================================================
#  FUNCTIONS
#===================================================================================================

argument_pod() {
        POD=$2
        if [[ -z $POD ]]; then
                echo "Missing pod name"
                echo
                help $1
        elif [[ $POD == '-h' || $POD == '-H' || $POD == '--help' ]]; then
                help $1
        fi
}

find_pod() {
        # PROCESS
        COMMAND_NAMESPACE=`[[ -z "${NAMESPACE}" ]] || echo " -n ${NAMESPACE}"`

        echo -n "$(tput setaf 4)==>$(tput sgr0) kubectl get pods$COMMAND_NAMESPACE | grep -m 1 $POD | awk '{print \$1}'"$'\r'; 
        KUBERNETES_POD=`kubectl get pods$COMMAND_NAMESPACE | grep -m 1 $POD | awk '{print $1}'`

        if [[ -z $KUBERNETES_POD ]]; then
                echo "$(tput setaf 1)==>$(tput sgr0) kubectl get pods$COMMAND_NAMESPACE | grep -m 1 $POD | awk '{print \$1}'";
                error "No pod name matches $(tput bold)$POD$(tput sgr0) in the `[[ -z "${NAMESPACE}" ]] && echo "current" || echo "$(tput bold)${NAMESPACE}$(tput sgr0)"` namespace"
        else
                echo "$(tput setaf 34)==>$(tput sgr0) kubectl get pods$COMMAND_NAMESPACE | grep -m 1 $POD | awk '{print \$1}'";
                info "Found $(tput bold)$KUBERNETES_POD$(tput sgr0) in the `[[ -z "${NAMESPACE}" ]] && echo "current" || echo "$(tput bold)${NAMESPACE}$(tput sgr0)"` namespace"
        fi
}

#===================================================================================================
#  HELP DEFINITION
#===================================================================================================

help() {
        if [[ $1 == 'logs' ]]; then
                echo "Fetches logs from a first pod matching the input name, writes into a file in the default directory $LOGS_DIR, and opens the file. If not specified, the number of fetched lines is 1000 by default due to possibly huge size of the logs.
Usage:
  ku logs <pod> [-f] [-l LINES] [-n NAMESPACE] [-s] [

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

  # Fetches the default $LOG_LINES_NUMBER logs lines from 'yo-momma-0' in the 'family' namespace into a file in the default directory, and opens the log file
  ku logs momma -n family

  # Fetches 250 logs lines from 'yo-momma-0' in the 'family' namespace into a file in the default directory without opening the log file
  ku logs momma -n family -sl 250

Disclaimer:
  Though a basic validation exists, the author(s) take(s) no responsibility for incorrect usage or unwanted outcomes.
"
        elif [[ $1 == 'spin' ]]; then
                echo "Deletes a first pod matching the input name which makes Kubernetes to deploy a new one up to the defined scale.

Usage:
  ku spin <pod> [-n NAMESPACE]

Options:
  -n     OPTIONAL STRING        Specify a given namespace, otherwise the currently selected is used by default.

Examples:

  Assuming the following output:
    [user@server ~]$ kubectl get pods
    NAME                             READY   STATUS    RESTARTS      AGE
    yo-momma-0                       1/1     Running   0             24m
    yo-momma-1                       1/1     Running   0             43m
    yo-daddy                         1/1     Running   0             38m

  # Deletes a pod 'yo-momma-0'
  ku spin momma

  # Deletes a pod 'yo-momma-0' in the 'family' namespace
  ku spin momma -n family


Disclaimer:
  Though a basic validation exists, the author(s) take(s) no responsibility for incorrect usage or unwanted outcomes.
"
        else 
                echo "ku is a small utility for common kubectl commands.

  Find more at https://github.com/Nikolas-Charalambidis/macos-scripts/ku

Basic Commands:
  logs          Fetches logs from a first pod matching the input name.
  spin          Deletes a first pod matching the input name which makes Kubernetes to deploy a new one up to the defined scale.

Usage:
  Use \"ku <command> --help\" for more information about a given command.

Disclaimer:
  Though a basic validation exists, the author(s) take(s) no responsibility for incorrect usage or unwanted outcomes.
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

        argument_pod 'logs' $2 

        # Define variables
        FULL='false'
        SILENT='false'

        # Skip first two commands and validate no more command is used
        OPTIND=3
        if ! [[ -z $3 ]] && ! [[ $3 =~ ^-[^-]+$ ]] ; then error "There is not expected any further command after $(tput bold)ku $1 $2 $(tput sgr0)"; fi;

        # Parse arguments
        while getopts "l:n:fhs" OPT; do
                case "$OPT" in
                        h)      help 'logs' ;;
                        f)      FULL='true' ;;
                        l)      require_number ; LOG_LINES_NUMBER=$OPTARG ;;
                        n)      require_input ; NAMESPACE=$OPTARG ;;
                        s)      SILENT='true' ;;
                        \?)     error "Wrong option choice or usage. Try 'ku logs --help'" ;;
                esac
        done

        # Move 'getopts' on to the next argument.
        shift $((OPTIND-1))  

        find_pod

        # Create a directory (if it does not exists) and a file
        NOW=`echo $(date +%Y%m%d_%H%M%S)`
        LOG_NAME=$KUBERNETES_POD.$NOW.log
        LOG_FILE=$LOGS_DIR/$LOG_NAME
        mkdir -p $LOGS_DIR
        touch $LOG_FILE
        info "Created a file $(tput bold)$LOG_FILE$(tput sgr0) to write the fetched logs down"
        
        COMMAND_TAIL=`[[ $FULL == 'true' ]] || echo " --tail=$LOG_LINES_NUMBER"`

        # Fetching logs
        echo -n "$(tput setaf 4)==>$(tput sgr0) kubectl logs $KUBERNETES_POD$COMMAND_TAIL$COMMAND_NAMESPACE > $LOG_FILE"$'\r';
        if kubectl logs $KUBERNETES_POD$COMMAND_TAIL$COMMAND_NAMESPACE > $LOG_FILE; then
            echo "$(tput setaf 34)==>$(tput sgr0) kubectl logs $KUBERNETES_POD$COMMAND_TAIL$COMMAND_NAMESPACE > $LOG_FILE"
        else
            echo "$(tput setaf 1)==>$(tput sgr0) kubectl logs $KUBERNETES_POD$COMMAND_TAIL$COMMAND_NAMESPACE > $LOG_FILE"
        fi

        # Silent 
        if [[ $SILENT == 'true' ]]; then
                info "Finished"
        else
                info "Finished. Opening the file..."
                open $LOG_FILE
        fi

        exit 0
        
#===================================================================================================
#  SPIN
#===================================================================================================
        
elif [[ $COMMAND == 'spin' ]]; then

        argument_pod 'spin' $2

        # Skip first two commands and validate no more command is used
        OPTIND=3
        if ! [[ -z $3 ]] && ! [[ $3 =~ ^-[^-]+$ ]] ; then error "There is not expected any further command after $(tput bold)ku $1 $2 $(tput sgr0)"; fi;

        # Parse arguments
        while getopts "n:h" OPT; do
                case "$OPT" in
                        h)      help 'spin' ;;
                        n)      require_input ; NAMESPACE=$OPTARG ;;
                        \?)     error "Wrong option choice or usage. Try 'ku spin --help'" ;;
                esac
        done

        # Move 'getopts' on to the next argument.
        shift $((OPTIND-1))  

        find_pod

        echo -n "$(tput setaf 4)==>$(tput sgr0) kubectl delete $KUBERNETES_POD$COMMAND_NAMESPACE"$'\r';
        if kubectl delete $KUBERNETES_POD$COMMAND_NAMESPACE; then
                echo "$(tput setaf 34)==>$(tput sgr0) kubectl delete $KUBERNETES_POD$COMMAND_NAMESPACE"
        else
                echo "$(tput setaf 1)==>$(tput sgr0) kubectl delete $KUBERNETES_POD$COMMAND_NAMESPACE"
        fi

        exit 0
        
#===================================================================================================
#  DEFAULT
#===================================================================================================
else 
        error "Illegal command $COMMAND"

        exit 0
fi
