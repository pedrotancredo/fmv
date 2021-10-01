#!/usr/bin/env python3

import klvdata
import sys
import json

'''

This script receives as  command line parameter 
the name of the klvdata binary file and writes a JSON file.
 This script ignore Unknown Elements that prevent its functioning
'''

if __name__ == "__main__":
	args=sys.argv
	with open(args[1], 'rb') as f:
		output = open(args[2]+".json", "w")
		data=[]
		for packet in klvdata.StreamParser(f):
			if type(packet) is not  klvdata.element.UnknownElement:
				metadata=packet.MetadataList()
				data.append(metadata)
	
		json.dump(data,output)
	output.close()
