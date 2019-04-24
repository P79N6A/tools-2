#!/usr/bin/python
# -*- coding: utf-8 -*-
# 实现了sort |uniq -c的功能，输出两列：出现次数、数据
# 输出按照出现次数倒序排列
# 可以用作去重、求两个文件的交集、并集、差集

import sys
reload(sys)
sys.setdefaultencoding("utf-8")

key_dict = {}
for line in sys.stdin:
    line = line.strip()
    key = line
    count = 1
    if not line:
        continue
    try:
        items = line.split("\t")
        if len(items) == 2:
            key = items[0]
            count = int(items[1])
    except Exception,e:
        print >> sys.stderr, Exception,":",e, line
    key_dict[key] = key_dict.setdefault(key, 0) + count

reverse_dict = {}
for k in key_dict:
    v = key_dict[k]
    reverse_dict.setdefault(v,[]).append(k)

num_lst = sorted(reverse_dict.keys(), reverse=True)
for num in num_lst:
    for v in reverse_dict[num]:
        print "\t".join([str(num), v])

