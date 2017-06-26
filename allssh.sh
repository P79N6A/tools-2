#!/bin/sh

#sh allssh -c "cmd" -u search -h mapd03.qss.zzbc2

CMD="ls"
#USER="liuzhuo"
USER=`whoami`
DES_DIR=""
#HOST_LIST="mapd03.qss.zzbc2 i615.se.zzbc2 mapd04.qss.zzbc2 i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc merger113.se.zzzc nlp36.se.zzzc nlp37.se.zzzc w-log8.safe.zzbc"
#HOST_LIST="mapd03.qss.zzbc2 i615.se.zzbc2 mapd04.qss.zzbc2 i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc nlp37.se.zzzc"
HOST_LIST="i992.se.zzzc merger5.mapse.zzzc merger110.se.zzzc"

test=0
while getopts tu:c:d:h: i;do
    case ${i} in
        u) USER="${OPTARG}"
        ;;
        c) CMD="${OPTARG}"
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
    echo "ssh ${USER}@${host} \"${CMD}\""
    if [ "${test}"x = "0"x ];then
        ssh ${USER}@${host} "${CMD}"
    fi
done
