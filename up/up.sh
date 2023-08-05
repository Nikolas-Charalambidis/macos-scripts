#!/bin/bash

lookUp() {
  DIR=${PWD%/*}
    NEW=".."
    while [[ -n $DIR ]]; do
        if [[ ${DIR##*/} == $1* ]]; then
            cd "$NEW"
            return 0
        fi
        DIR=${DIR%/*}
        NEW+="/.."
    done
    echo up: $1: No directory found >&2
    return 1
}

# Argument is a flag (-h, --help)
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: 
    up [--help] [ number | directory ]

Examples:

# Navigates up to the parent directory (if it exists)
[foo@bar company/projects/tools/1.1.0/bong/bin/jenkins]$ up
[foo@bar company/projects/tools/1.1.0/bong/bin]$

# Navigates up 3 directories (unless the root directory is reached)
[foo@bar company/projects/tools/1.1.0/bong/bin/jenkins]$ up 4
[foo@bar company/projects/tools]$

# Navigates up to the fist matched directory by name (starts with)
[foo@bar company/projects/tools/1.1.0/bong/bin/jenkins]$ up b
[foo@bar company/projects/tools/1.1.0/bong/bin]$

[foo@bar company/projects/tools/1.1.0/bong/bin/jenkins]$ up p
[foo@bar company/projects]$

[foo@bar company/projects/tools/1.1.0/bong/bin/jenkins]$ up -f 1
[foo@bar company/projects/tools/1.1.0]$

Flags:
    -h, --help                      Help.

Global flags:
    -d, --directory, -f, --folder   Enforces look-up by name. This is useful in the case the looked-up directory name in hierarchy starts with or is a sole a digit. 
"
    return 0;
fi

# No arguments given
if [[ -z $1 ]]; then
    cd ..

# Argument is a number
elif [[ $1 =~ ^[0-9]+$ ]]; then
    for (( i=0; i<$1; i++ )); do
        if [[ $PWD == '/' ]]; then
            # Root reached
            return 0;
        fi
        cd ..
    done

# Argument is a flag (-d, --directory, -f, --folder)
elif [[ $1 == "-d" ]] || [[ $1 == "--directory" ]] || [[ $1 == "-f" ]] || [[ $1 == "--folder" ]]; then
    if [[ -z $2 ]]; then
        echo up: $1: No directory given >&2
        return 1
    else
        lookUp $2
    fi
# Argument is a string
else
    lookUp $1
fi
