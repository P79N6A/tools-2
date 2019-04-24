#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys

ret_set = set()
for line in sys.stdin:
    ret_set.add(line.rstrip("\n"))

for line in ret_set:
    print >> sys.stdout, line
