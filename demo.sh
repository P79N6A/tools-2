#!/bin/sh

PWD=`readlink -f ${0}`
PWD=`dirname ${PWD}`
cd ${PWD}

while getopts "af:" i; do
    case ${i} in
        a) echo "-a"
        ;;
        f) arg="${OPTARG}" #get the value
        echo $arg
        ;;
        ?) echo "Usage"
        exit 1
    esac
done
