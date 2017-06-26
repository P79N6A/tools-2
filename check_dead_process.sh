#!/bin/sh

PWD=`readlink -f $0`
PWD=`dirname "${PWD}"`
cd ${PWD}
source ../functions.sh

exec=0
while getopts e i;do
    case ${i} in
        e) exec=1
            ;;
        ?) exit
    esac
done

process_list="
updater_wap_bada.sh
dump_relation.sh
gen_id.php
depth_send_qbus.php
get_relation_from_redis.php
add_detail_qconf.php
delete_attr.php
add_brand.php
depth.php
updater-wap-movie.sh
patch.php
select_attr.php
indexer.php
add_attr.php
qbus-send.php
fold.php
add_detail.php
updater_wap_idx.sh
spiderCaller.py
"

ttl="6"

echo `date`" check_dead_process"
for process in ${process_list};do
    echo ${process}
    echo "days"
    ps -eo pid,etime,args |grep ${process} | awk '$2~/^.*-..:..:../{print $0}'
    echo "${ttl} hours"
    ps -eo pid,etime,args |grep ${process} | awk '$2~/^..:..:../{split($2,a,":");if(a[1]>='"${ttl}"'){print $0}}'
    if [ ${exec} = 1 ];then
        #超过一天
        ps -eo pid,etime,args |grep ${process} | awk '$2~/^.*-..:..:../{print $1}' | xargs -i kill -9 {}

        #超过ttl小时
        ps -eo pid,etime,args |grep bada | awk '$2~/^..:..:../{split($2,a,":");if(a[1]>='"${ttl}"'){print $1}}' | xargs -i kill -9 {}
    fi
done

#删除depth-updater-wap-bada.lock, depth-updater-wap-movie.lock
bada_lock_ttl=`expr 60 \* ${ttl}`
bada_lock=`find /home/s/var -maxdepth 1 -cmin +${bada_lock_ttl}  -name "*depth-updater-wap-bada.lock"`
movie_lock=`find /home/s/var -maxdepth 1 -cmin +60  -name "*depth-updater-wap-movie.lock"`
if [ ${exec} = 1 ];then
    if [ ${bada_lock}x != ""x ];then
        echo "rm -f ${bada_lock}"
        rm -f ${bada_lock}
        error "upater_wap_bada.sh run more than ${ttl} hours"
    fi

    if [ ${movie_lock}x != ""x ];then
        echo "rm -f ${movie_lock}"
        rm -f ${movie_lock}
        error "updater-wap-movie.sh run more than 1 hours"
    fi
else
    echo ${bada_lock}
    echo ${movie_lock}
fi
