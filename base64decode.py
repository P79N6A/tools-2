#!/usr/bin/env python
# -*- coding: utf-8 -*-

import base64
import sys
import json

def encode_string(line):
    line = base64.encodestring(line)
    return line

def decode_string(line):
    js = json.loads(line)
    url = base64.decodestring(js['url'].strip())
    return url

for line in sys.stdin:
    line = line.strip()
    if sys.argv[1] == '-d':
        line = decode_string(line)
    if sys.argv[1] == '-e':
        line = encode_string(line)
    print line
