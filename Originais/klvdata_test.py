#!/usr/bin/env python
import sys, klvdata;
import pprint

for packet in klvdata.StreamParser(sys.stdin.buffer.read()): 
				packet.structure()

