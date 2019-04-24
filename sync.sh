#!/bin/sh
#此脚本只能在19机器运行！！！

PWD=`readlink -f $0`
PWD=`dirname "${PWD}"`
cd ${PWD}
export PATH=${HOME}/bin:${PWD}/env/bin:${PATH}:/usr/local/bin:/home/s/bin

dest_user="liuzhuo"
dest_host_list="mapd04.se.zzzc i928.se.zzzc.qihoo.net i992.se.zzzc.qihoo.net merger110.se.zzzc.qihoo.net"
dest_dir="/home/liuzhuo"
src_dir="${PWD}"
exclude_list=".exclude.list"
delete_flag="0"
ci_msg=""

while getopts "dm:" i; do
    case ${i} in
        d) delete_flag=1
        ;;
        m) ci_msg="${OPTARG}"
        ;;
        ?) echo "Usage"
        exit 1
    esac
done
shift $(($OPTIND - 1))

update_git() {
    msg="$1"
    echo "git ci -am \"${msg}\""
    git ci -am "${msg}"
}

if [ "${ci_msg}"x != ""x ];then
    update_git "$ci_msg"

    echo "git push -u origin master"
    git push -u origin master
fi

for dest_host in ${dest_host_list};do
    if [ "${dest_host}"x != ""x ];then
        cur_dest_dir=${dest_user}@${dest_host}:${dest_dir}
    fi
    echo -e "\n-----run rsync-----"
    echo "rsync -vtr --exclude-from=${exclude_list} ${src_dir} ${cur_dest_dir}"
    rsync -vtr --exclude-from=${exclude_list} ${src_dir} ${cur_dest_dir}

    echo -e "\n-----check delete-----"
    echo "rsync -vtr --delete --exclude-from=${exclude_list} ${src_dir} ${cur_dest_dir}"

    if [ "${delete_flag}"x == "1"x ];then
        rsync -vtr --delete --exclude-from=${exclude_list} ${src_dir} ${cur_dest_dir}
    else
        rsync -vtrn --delete --exclude-from=${exclude_list} ${src_dir} ${cur_dest_dir}
    fi
done
