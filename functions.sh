#!/bin/sh
#

# 用途：发送短信/邮件报警
# 示例：
#     send_alert "whitelist_test"  "subject of alert"  'content of alert'

send_alert(){
    alert_id="$1"
    alert_subject="$2"
    alert_content="$3"

    _subject=`printf "$alert_subject" | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'`
    _msg=`printf "$alert_content" | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'`

    for times in 1 2 3
    do
        if   which curl >/dev/null;then
            curl -s --connect-timeout 5 -f -d "subject=${_subject}&content=${_msg}"  \
            "http://alarms.ops.qihoo.net:8360/intfs/alarm_intf?group_name=$alert_id"
            [ $? -eq 0 ] && break
        elif which wget >/dev/null;then
            wget -q -O - --timeout=5 -q --post-data "subject=${_subject}&content=${_msg}"  \
            "http://alarms.ops.qihoo.net:8360/intfs/alarm_intf?group_name=$alert_id"
            [ $? -eq 0 ] && break
        elif which fetch >/dev/null;then
            fetch -q -T5 -1 -o- "http://alarms.ops.qihoo.net:8360/intfs/alarm_intf?group_name=$alert_id&subject=${_subject}&content=${_msg}"
            [ $? -eq 0 ] && break
        fi
    done
}


# 用途：根据主机名获取idc名字
get_idc_name(){
    _idc=`hostname | grep -Po '\w+\.qihoo\.net' | awk -F. '{print $1}'`
    if [[ x != x${_idc} ]];then
        echo ${_idc}
    else
        echo "None"
    fi
}

error() {
    send_alert "g_so_map_poi" "$1" "$2"
    #send_alert "g_so_map_dev" "$1" "$2"
    exit 1
}

