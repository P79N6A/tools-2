#!/bin/sh

#sh syncfile.sh -f "file1 file2" -d dir -u search -h mapd03.qss.zzbc2

FILE_LIST=".vim* .bashrc"
USER="liuzhuo"
DES_DIR=""
HOST_LIST="mapd03.qss.zzbc2 test1.mapse.zzzc i992.se.zzzc merger6.mapse.zzzc i615.se.zzbc2 mapd04.qss.zzbc2 w-log8.safe.zzbc"

while getopts u:f:d:h: i;do
    case ${i} in
        u) USER="${OPTARG}"
        ;;
        f) FILE_LIST="${OPTARG}"
        ;;
        d) DES_DIR="${OPTARG}"
        ;;
        h) HOST_LIST="${OPTARG}"
        ;;
        ?) echo "usage"
        exit 1
    esac
done

#if [ "${USER}" = "search" ];then
    #HOST_LIST="i928.se.zzzc"
#fi

for host in ${HOST_LIST};do
    for file in ${FILE_LIST};do
        PWD=`readlink -f ${file}`
        PWD=`dirname "${PWD}"`
        if [ "${DES_DIR}"x == ""x ];then
            DES_DIR=${PWD}
        fi
        echo "scp -r ${file} ${USER}@${host}:${DES_DIR}"
        scp -r ${file} ${USER}@${host}:${DES_DIR}
    done
done
