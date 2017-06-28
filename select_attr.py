#!/usr/bin/python
# -*- coding: utf-8 -*-
#test merge

import sys
reload(sys)
sys.setdefaultencoding("utf-8")

try:
    import ujson as json
except Exception,e:
    import json
#import json

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
    if isinstance(ret, int) or isinstance(ret, float):
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

output_orig = False
output_json = False
list_type = False
field_num = 0
select_fields = []

try:
    opts, args = getopt.getopt(sys.argv[1:], "kljf:s:")
except getopt.GetoptError, err:
    # print help information and exit:
    print str(err) # will print something like "option -a not recognized"
    print "usage"
    sys.exit(2)
for o, a in opts:
    if o in ["-h"]:
        usage()
        sys.exit(1)
    if o in ["-k"]:
        output_orig = True
    if o in ["-l"]:
        list_type = True
    if o in ["-f"]:
        field_num = int(a)
    if o in ["-j"]:
        output_json = True
    if o in ["-s"]:
        select_fields = a.split(",")

try:
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        data = line.split("\t")
        obj = None
        if len(data) > field_num:
            obj = json.loads(data[field_num])
        if isinstance(obj, dict):
            ret = get_fields(obj)
            if output_json:
                ret = json.dumps(dict(ret), ensure_ascii=False)
            else:
                ret = "\t".join(ret).encode("utf-8")
            print >> sys.stdout, ret
        elif list_type and isinstance(obj, list):
            for item in obj:
                ret = get_fields(item)
                print >> sys.stdout, "\t".join(ret).encode("utf-8")
        else:
            print >> sys.stderr, line
except Exception,e:
    pass
