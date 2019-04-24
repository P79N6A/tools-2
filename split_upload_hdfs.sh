#!/bin/sh
# 可用于切分、多进程上传文件到hdfs上，节省时间

CUR_DIR=`readlink -f $0`
CUR_DIR=`dirname "${CUR_DIR}"`
cd ${CUR_DIR}
export PATH=${HOME}/bin:/usr/local/bin:/home/s/bin:${CUR_DIR}/env/bin:${PATH}
cooccur_num=10 # 并发数
tmp_dir="/da1/s/data/luoyangen/tmp/shuidi_split"
split_num=1000000 # 切分小文件的行数
input_file=""
hdfs_dir=""
while getopts "i:o:c:t:" i; do
    case ${i} in
        i) input_file="${OPTARG}" #需要上传的文件
        ;;
        o) hdfs_dir="${OPTARG}" #hdfs目标目录
        ;;
        c) cooccur_num=${OPTARG} #并发数
        ;;
        t) tmp_dir="${OPTARG}" #本地临时目录
        ;;
    esac
done
shift $(($OPTIND - 1))
echo -e "split ${input_file} -a 3 -dl ${split_num} ${tmp_dir}/part-"
split ${input_file} -a 3 -dl ${split_num} ${tmp_dir}/part-
tempfifo=$$.fifo
mkfifo $tempfifo
exec 1000<>$tempfifo
rm -rf $tempfifo
#echo ${cooccur_num}
for ((i=1; i<=$cooccur_num; i++))
do
        echo >&1000
done

for f in `cd ${tmp_dir} && ls`
do
    read -u1000
    {
        echo -e "hadoop fs -put ${tmp_dir}/$f ${hdfs_dir}/$f"
        hadoop fs -put ${tmp_dir}/$f ${hdfs_dir}/$f
        echo >&1000
    } &
done
wait
rm ${tmp_dir}/part-* -rf
