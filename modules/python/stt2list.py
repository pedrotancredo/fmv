import glob
import csv
import pandas as pd
import time

#%%
InputPath  = r'Z:/TS_transcricao'


my_path = InputPath
files = glob.glob(my_path + '/**/*.txt', recursive=True)


#%% Grava lista de arquivos em csv

input_list_path = 'fileslist.csv'

with open(input_list_path, 'w', newline='', encoding='utf-8') as stt_list:
    stt_write = csv.writer(stt_list, escapechar='?',quoting=csv.QUOTE_NONE)
    
    for line in files:
        stt_write.writerow([line])
#%% Cria dataframe com valores da lista

df = pd.read_csv(input_list_path, sep=';', encoding='utf-8', names = ['path'], header = None)

#transcricaolist = [0]*len(fileswav)

#%% Varre a lista de paths no dataframe incluíndo a coluna de transcrição

output_transcript = 'transcript.txt'

for i in range(len(df)-1):
#    if i < 22403:
        #continue
    filename = df.iloc[i]['path']
    my_file = open(filename, "r")

    content = my_file.read()
    print(str(i),'|',filename)    
    print(content)
    print('--------------------------------------------------------------------------------------------------------')

    line = [str(i),filename,content]
    with open(output_transcript, 'a', newline='', encoding='utf-8') as transcript_list:
        transcript_write = csv.writer(transcript_list, delimiter='|', escapechar='?',quoting=csv.QUOTE_NONE)
        transcript_write.writerow(line)
    
    time.sleep(0.5)
    #transcricaolistazure = [0]*len(files)


# my_file = open("sample.txt", "r")

# content = my_file.read()

# print(content)