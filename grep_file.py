#!/usr/bin/python
# -*- coding: utf-8 -*-
# 使用python实现grep -f，适用于找出某一列在目标文件中出现的所有行,时间复杂度O(M+N)
# 参数: -k 源文件的第几列,从1开始计数
        #-d 源文件每行的分割字符/字符串, 默认"\t"
        #-f key的文件
# 使用方法： cat source.data | python file_grep -f key.data -k 2 -d "	"
import sys
reload(sys)
sys.setdefaultencoding("utf-8")
import getopt
try:
    import ujson as json
except Exception,e:
    import json

try:
    opts, args = getopt.getopt(sys.argv[1:], "k:f:d:jv", ["key=", "file=", "delimiter=", "json", "invert-match"])
except getopt.GetoptError:
    print """-k key, which column to search;
           -f file, source file name
           -d char, source line split character / or key field name
           -j whether json file
           -v include or exclude
           """
    sys.exit()
    # print help information and exit:
targ_key = ""
src_file = ""
split_ch = "\t"
json_file = False
invert_match = False
for o, a in opts:
    if o in ("-k", "--key"):
        targ_key = a
    if o in ("-f", "--file"):
        src_file = a
    if o in ("-d", "--delimiter"):
        split_ch = a
    if o in ("-j", "--json"):
        json_file = True
    if o in ("-v", "--invert-match"):
        invert_match = True
if not src_file:
    print "need to specify condition file"
    sys.exit()

#if not specify target key, this program become to find the total line
cond_set = set()
with open(src_file, 'r') as f:
    for line in f:
        cond_set.add(line.strip())

if json_file:
    for line in sys.stdin:
        line = line.strip()
        obj = json.loads(line)
        if "." in targ_key:
            a = obj
            for _key in targ_key.split("."):
                a = a.get(_key,"")
        else:
            a = obj.get(targ_key, "")
        if not a:
            print >> sys.stderr, "no selected key: ", line
            continue
        if ( a in cond_set ) != invert_match:
            print line
else:
    if targ_key:
        index = int(targ_key) - 1
        for line in sys.stdin:
            line = line.strip()
            fields = line.split(split_ch)
            if index >= len(fields):
                print "[key index exceeds]: %s" %(line)
                sys.exit()
            if ( fields[index] in cond_set ) != invert_match:
                print line
    else:
        for line in sys.stdin:
            line = line.strip()
            for cod in cond_set:
                if ( cod in line ) != invert_match:
                    print line
                    break
