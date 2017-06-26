#!/bin/sh
#sh kill_process.sh -e -p 进程名称 [-i 进程号]
PWD=`readlink -f $0`
PWD=`dirname "${PWD}"`
cd ${PWD}

exec=0
process=""
pid=""

while getopts ep:i: i;do
    case ${i} in
        e) exec=1
            ;;
        p) process=${OPTARG}
            ;;
        i) pid=${OPTARG}
            ;;
        ?) exit
    esac
done

if [ ${process}x = ""x -a ${pid}x = ""x ];then
    process="updater_wap_bada"
fi
if [ ${pid}x = ""x ];then
    pid=`ps aux | grep ${process} | grep "grep" -v | head -1 | awk '{print $2}'`
fi

if [ ${exec} = 1 ];then
    pstree -aup ${pid} | awk -F"," '{print $2}' | cut -d" " -f1 | xargs kill -9
    if [ ${process}x = "updater_wap_bada"x ];then
        rm -f /home/s/var/depth-updater-wap-bada.lock
    fi
else
    echo ${process}
    echo ${pid}
    pstree -aup ${pid} | awk -F"," '{print $2}' | cut -d" " -f1
fi
