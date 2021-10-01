#!/usr/bin/env python3

import klvdata
import sys
import pickle

'''

This script receives as  command line parameter 
the name of the klvdata binary file and
 writes a Pickle file preserving the python object for reuse.
 This script ignore Unknown Elements that prevent its functioning
'''

if __name__ == "__main__":
	args=sys.argv
	with open(args[1], 'rb') as f:
		output = open(args[2]+".pkl", "wb")
		for packet in klvdata.StreamParser(f):
			if type(packet) is not  klvdata.element.UnknownElement:
				metadata=packet.MetadataList()
				pickle.dump(metadata, output)
	output.close()