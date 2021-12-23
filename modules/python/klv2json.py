#!/usr/bin/env python3

import klvdata
import sys
import json
import codecs

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
		filtereddata=[]
		posicaovalor=0
		for packet in klvdata.StreamParser(f):
			if type(packet) is not  klvdata.element.UnknownElement:
				metadata=packet.MetadataList()
					#print("Valor de K: " +str(k))
				for k, v in metadata.items():

					#Detecta a posição do valor do item - funcionalidade escrita para não ter dependência do tipo do equipamento ou configuração
					for j in range(0,len(v)):

						if ( v[j]=='Precision Time Stamp' or v[j]=='User Defined Time Stamp' or  v[j]=='' ):
							posicaovalor=0
						else:
							posicaovalor=j

					if k==2:
						break

				for k, v in metadata.items():
					metadata[k]=v[posicaovalor]
				data.append(metadata)
		
		for k in range(len(data)):
			numtags = len(data[k])
			if ((numtags>=12) and (2 in data[k]) ): #Processa apenas linhas que contém pelo menos 12 tags e apresenta tag de data
				if((k==0) and (13 in data[k]) and (14 in data[k]) ): # Caso primeira linha, verifica se existe a tag apenas na linha atual
					filtereddata.append(data[k])
				else:
					if((13 in data[k]) and (13 in data[k-1]) and (14 in data[k]) and (14 in data[k-1])): # verifica se as tags de lat e long existem na linha atual e anterior
						if(data[k][13]!=data[k-1][13] and data[k][14]!=data[k-1][14]):
							texto= bytes(data[k][1], "raw_unicode_escape")
							print(texto)
							filtereddata.append(data[k])


	json.dump(filtereddata,output)
	output.close()
