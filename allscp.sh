#!/bin/sh

#sh allscp -f "file1 file2" -d dir -u search -h mapd03.qss.zzbc2

FILE_LIST=".vimrc .bashrc"
USER=`whoami`
DES_DIR=""
#HOST_LIST="mapd03.qss.zzbc2 i615.se.zzbc2 mapd04.qss.zzbc2 i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc merger113.se.zzzc nlp36.se.zzzc nlp37.se.zzzc w-log8.safe.zzbc"
HOST_LIST="i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc mapd03.qss.zzbc2"
#HOST_LIST="i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc"

test=0
while getopts u:f:d:h:t i;do
    case ${i} in
        u) USER="${OPTARG}"
        ;;
        f) FILE_LIST="${OPTARG}"
        ;;
        d) DES_DIR="${OPTARG}"
        ;;
        h) HOST_LIST="${OPTARG}"
        ;;
        t) test=1
        ;;
        ?) echo "usage"
        exit 1
    esac
done
shift $(($OPTIND - 1))

for host in ${HOST_LIST};do
    for file in ${FILE_LIST};do
        PWD=`readlink -f ${file}`
        PWD=`dirname "${PWD}"`
        if [ "${DES_DIR}"x == ""x ];then
            DES_DIR=${PWD}
        fi
        echo "scp -qr ${file} ${USER}@${host}:${DES_DIR}"
        if [ "${test}"x = "0"x ];then
            scp -qr ${file} ${USER}@${host}:${DES_DIR}
        fi
    done
done
