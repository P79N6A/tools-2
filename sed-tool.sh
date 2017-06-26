#!/bin/sh

Usage() {
    echo "usage: $0 -a|-d [-f file] [input] [input] ..."
    exit 1;
}

RunSed() {
    if [ "${METHOD}"x = "add"x ]; then
        sed -i "\$a${1}" ${2}
        #sed "\$a${1}" ${2}
        #echo "sed '\$a${1}' ${2}"
    else
        sed -i "/${1}/d" ${2}
        #sed "/${1}/d" ${2}
        #echo "sed '/${1}/d' ${2}"
    fi
}

while getopts :adhf: i;do
    case ${i} in
        a) METHOD="add"
        ;;
        d) METHOD="del"
        ;;
        f) FILE="${OPTARG}"
        ;;
        h)
        Usage $0
        ;;
    esac
done

if [ "${METHOD}"x = ""x ]; then
    Usage $0
fi

shift $(($OPTIND - 1))

if [ "${FILE}"x = ""x ]; then
    RunSed ${1} ${2}
else
    cat ${FILE} | while read line
    do
        RunSed $line ${1}
    done
fi
