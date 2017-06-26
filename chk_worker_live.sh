#!/usr/bin/env bash
# Workaround with pid files and auto restart procs
#*/5 * * * * lockf -t 0 /home/s/var/proc/chk_worker_live.lock /home/s/bin/chk_worker_live.sh >> /home/search/ditu/data_depth/logs/chk.log 2>&1

export PATH="/bin:/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin"
export LANG=C
export LC_ALL=C

#export LOGGER="/home/search/bin/qlogger.php"

export PIDDIR=''
export LOG='/home/s/logs/chk_worker_live.log'
export MAX_RETRY=6
export MAX_TIME_GAP=300
export NOALERT=0

# Parse opts
while getopts ":Ap:" Option
do
    case $Option in
        A)
            NOALERT=1
            ;;
        p)
            opt_piddir="$OPTARG"
            ;;
        *)
            echo "Argument fault, exit."
            echo "Usage:"
            echo "$0 -p /home/s/var/proc,/home/search/var/proc -A"
            echo "-A : not send alerts"
            echo "-p : dir of pid file, comma seperated"
            exit 255
            ;;
    esac
done
shift $(($OPTIND - 1))

PIDDIR=$(echo ${opt_piddir} | sed 's/,/ /g')
if [[ "x" == "x${PIDDIR}" ]];then
    PIDDIR="/home/s/var/proc/"
fi

gettime(){
    date '+%Y-%m-%d %H:%M:%S'
}

gethostn(){
    hostname|sed 's,\.qihoo\.net,,g'
}

send_msg(){
    alert_id="$1"
    alert_subject="$2"
    alert_content="$3"

    _subject=`printf "$alert_subject" | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'`
    _msg=`printf "$alert_content" | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'`

    for times in 1 2 3
    do
        if   which curl >/dev/null;then
            curl --connect-timeout 5 -d "subject=${_subject}&content=${_msg}"  \
                "http://alarms.ops.qihoo.net:8360/intfs/alarm_intf?group_name=$alert_id"
            [ $? -eq 0 ] && break
        elif which wget >/dev/null;then
            wget -O - --timeout=5 -q --post-data "subject=${_subject}&content=${_msg}"  \
                "http://alarms.ops.qihoo.net:8360/intfs/alarm_intf?group_name=$alert_id"
            [ $? -eq 0 ] && break
        elif which fetch >/dev/null;then
            fetch -q -T5 -1 -o- "http://alarms.ops.qihoo.net:8360/intfs/alarm_intf?group_name=$alert_id&subject=${_subject}&content=${_msg}"
            [ $? -eq 0 ] && break
        fi
    done

}

sent_alert(){
    hostname=`hostname|sed 's,\.qihoo\.net,,g;s,\.360so\.net,,g'`
    post_mod="${service_name}"
    case $1 in
        #1):just a restart warnning, 2):restart Failure
            1)
            post_sub="${hostname}:${service_name} restarted"
            post_msg="${hostname}:${service_name} restarted at [`gettime`]."
            ;;
        2)
            post_sub="${hostname}:${service_name} restart fail"
            post_msg="${hostname}:${service_name} restart failed, tried $c times"
            ;;
    esac

    if [[ ${NOALERT} -eq 0 ]];then
        #send_msg "${post_mod}_mon_whitelist" "$post_sub" "$post_msg"
        send_msg "g_so_map_poi" "$post_sub" "$post_msg"
    fi

    #$LOGGER alarm.procs_checking INFO "$post_msg" &

}


###############################################################################
# Main
###############################################################################

pidfiles=''
for dir in ${PIDDIR}
do
    #pidfiles="${pidfiles} `find -L ${dir} -iname 'mongo-data*[0-9].pid'`  "
    pidfiles="${pidfiles} `find -L ${dir} -iname '*[0-9].pid' | fgrep logsrv -v`  "
done

if [ -z "${pidfiles}" ] ;then
    printf "`gettime`\tNo .pid file found, abort.\n" >>${LOG}
    exit 0
fi


for pidf in ${pidfiles}
do
    c=0
    pidf_basename="${pidf##*/}"

    pidf_basename=${pidf_basename%.pid}
    service_pid=${pidf_basename##*.}
    service_name=${pidf_basename%.*}
    export service_name service_pid


    if [ "x" = "x$service_name" ]||[ "x" = "x$service_pid" ];then
        logmesg="name:[$service_name], pid:[$service_pid] missing... ?"
        send_msg "generic_mon_whitelist" "`gethostn` $logmesg "
        printf "`gettime`\t${logmesg}\n">>${LOG}
        continue
    fi

    kill -0  "${service_pid}"
    proc_stat=$?


    todo=0
    if [ $proc_stat -ne 0 ] ; then
        todo=1
    fi


    ## Typical condition : process down
    if [ $todo -eq 1 ]
    then
        printf "`gettime`\tprocess Not exsit, name:${service_name}, pid:${service_pid}\n"

        printf "`gettime`\tprocess Not exsit, name:${service_name}, pid:${service_pid}\n" >> ${LOG}

        rslvcmd="`cat ${pidf}`"
        stat=1

        # try to relaunch the process,up to ${MAX_RETRY} times
        while [ ${stat} -ne 0  ]
        do
            eval ${rslvcmd}
            if [ $? -eq 0 ];then
                stat=0
                break
            else
                stat=1
                c=`expr $c + 1`
                printf "`gettime`\tprocess restart failed,for the ${c} time, name:${service_name}\n" >>${LOG}
                if [ $c -ge ${MAX_RETRY} ];then
                    printf "`gettime`\tprocess restart failure for ${c} times,aborting, name:${service_name}\n" >>${LOG}
                    sent_alert 2
                    break
                fi
                continue
            fi
            sleep 1;
        done

        if [ $stat -eq 0 ];then
            sent_alert 1
            printf "`gettime`\tprocess restart successful, name:${service_name}\n" >>${LOG}
            rm -f ${pidf}
            if [ ! -f ${pidf} ];then
                printf "`gettime`\tremoved pid file,filename:${pidf}\n" >>${LOG}
            else
                printf "`gettime`\tcan't remove pid file,filename:${pidf}\n" >>${LOG}
            fi
        fi

        ## Another condition: Process alive
    else
        msg="`gettime` alive, name:${service_name}, pid:${service_pid}"
        printf "$msg\n" >>${LOG}
        #$LOGGER alarm.procs_checking INFO "$msg" &
    fi

    unset c
done

printf "\n">>${LOG}

#END
