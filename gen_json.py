#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
将\t分割的字段生成json
echo -e "a\tb\tc" | python tools/gen_json.py -f cat,datasource,id

Created on 2015.01.01
@author: liuzhuo@360.cn
"""



import sys
reload(sys)
sys.setdefaultencoding("utf-8")

try:
    import ujson as json
except Exception,e:
    import json

import getopt

import string
from itertools import ifilter,imap

def select(path, obj):
    ret = obj
    for field in path:
        if not isinstance(ret, dict) or field not in ret:
            ret = ""
            break
        ret = ret.get(field)
    if isinstance(ret, dict) or isinstance(ret, list):
        ret = json.dumps(ret, ensure_ascii=False)
    if isinstance(ret, int):
        ret = str(ret)
    if not ret:
        ret = ""
    return ret

def get_fields(obj):
    ret = []
    for field in select_fields:
        item = select(field.split("."), obj)
        if output_json:
            ret.append((field,item))
        else:
            ret.append(item)
    if output_orig:
        ret.append(line)
    return ret

field_num = 0
fields = []
user = ""

try:
    opts, args = getopt.getopt(sys.argv[1:], "u:f:")
except getopt.GetoptError, err:
    # print help information and exit:
    print str(err) # will print something like "option -a not recognized"
    print "usage"
    sys.exit(2)
for o, a in opts:
    if o in ["-h"]:
        usage()
        sys.exit(1)
    if o in ["-u"]:
        user = a
    if o in ["-f"]:
        fields = a.split(",")
        field_num = len(fields)

int_fields = "main_cat_new".split()
float_fields = "prob".split()

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    data = line.split("\t")
    obj = None
    if len(data) != field_num:
        print >> sys.stderr, "data format error"
        print >> sys.stderr, line
    ret = {}
    for data_item, field_item in zip(data, fields):
        if field_item in int_fields:
            data_item = int(data_item)
        if field_item in float_fields:
            data_item = float(data_item)
        ret[field_item] = data_item
    if user:
        ret["user"] = user
    print >> sys.stdout, json.dumps(ret, ensure_ascii=False)
