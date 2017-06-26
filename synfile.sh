#!/bin/sh

#sh syncfile.sh -f "file1 file2" -d dir -u search -h mapd03.qss.zzbc2

FILE_LIST=".vimrc .bashrc"
#USER="liuzhuo"
USER=`whoami`
DES_DIR=""
#HOST_LIST="mapd03.qss.zzbc2 i615.se.zzbc2 mapd04.qss.zzbc2 i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc merger113.se.zzzc nlp36.se.zzzc nlp37.se.zzzc w-log8.safe.zzbc"
#HOST_LIST="mapd03.qss.zzbc2 i615.se.zzbc2 mapd04.qss.zzbc2 i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc nlp37.se.zzzc"
HOST_LIST="i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc qp3.se.zzzc"

test=0
while getopts tu:f:d:h: i;do
    case ${i} in
        u) USER="${OPTARG}"
        ;;
        f) FILE_LIST="${OPTARG}"
        ;;
        d) DES_DIR="${OPTARG}"
        ;;
        t) test=1
        ;;
        h) HOST_LIST="${OPTARG}"
        ;;
        ?) echo "usage"
        exit 1
    esac
done

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
