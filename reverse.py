#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import string
from itertools import ifilter,imap

def lines(f=sys.stdin):
    for line in ifilter(lambda x: x, imap(string.strip, f)):
        yield line.decode("utf-8")[::-1]

for line in lines(sys.stdin):
    print >> sys.stdout, line.encode("utf-8")
