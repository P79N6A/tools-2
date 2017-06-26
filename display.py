#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import string
from itertools import ifilter,imap
from collections import OrderedDict
#import ujson as json
import json

def lines(f):
    for line in ifilter(lambda x: len(x)>0, imap(string.strip, f)):
        data = json.loads(line, object_hook=OrderedDict)
        #data = json.loads(line, object_pairs_hook=OrderedDict)
        #data = json.loads(line)
        yield data

for data in lines(sys.stdin):
    #print json.dumps(data)
    #print json.dumps(data, ensure_ascii=False).encode("utf-8")
    print json.dumps(data, ensure_ascii=False, indent=4)
