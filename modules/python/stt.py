#%% Importa bibliotecas
import requests
import json
import glob
import azure.cognitiveservices.speech as speechsdk
import csv
import pandas as pd
import time
#%% Define funções
def speech_to_text(wavfile_path):
    dados_arquivo = {'file': open(wavfile_path, 'rb')} 
    resultado = requests.post(url='https://sttdemo.cybervox.ai/api',  files=dados_arquivo)
    resultado.encoding = 'utf-8'
    print(resultado)
    transcricao_json = json.loads(resultado.text)
    transcricao = transcricao_json['texto']            
    return transcricao

def from_file(audiofile):
    speech_config = speechsdk.SpeechConfig(subscription="77a786d869364dfeb521c65d2db1b770", region="brazilsouth")
    speech_config.speech_recognition_language="pt-BR"
    speech_config.set_profanity(speechsdk.ProfanityOption.Raw)
    #ProfanityOption(value)
    #speechConfig.setProfanity(SpeechSDK.ProfanityOption.Raw);
    audio_input = speechsdk.AudioConfig(filename=audiofile)
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_input)


    result = speech_recognizer.recognize_once_async().get()
    #print(result.text)
    return result.text

#%% Gera lista de arquivos
my_path = r'Z:\TS_STT'
fileswav = glob.glob(my_path + '/**/*.wav', recursive=True)

#%% Grava lista de arquivos em csv

input_list_path = 'STT/stt_list2021.csv'

with open(input_list_path, 'w', newline='', encoding='utf-8') as stt_list:
    stt_write = csv.writer(stt_list, escapechar='?',quoting=csv.QUOTE_NONE)
    
    for line in fileswav:
        stt_write.writerow([line])
#%% Cria dataframe com valores da lista

df_path = pd.read_csv(input_list_path, sep=';', encoding='utf-8', names = ['path'], header = None)

#transcricaolist = [0]*len(fileswav)
#%% Roda um pra teste

single = r'Z:\TS_STT\2019\DRB\19-10-02\LTGUPMIC_T0274_T0295_P3.ts\LTGUPMIC_T0274_T0295_P3#133.956#152.997.wav'
print(from_file(single))


#%% Varre a lista de paths no dataframe incluíndo a coluna de transcrição

output_transcript = 'STT/transcript.txt'

for i in range(len(df_path)-1):
    if i < 22403:
        continue
    filename = df_path.iloc[i]['path']
    transcript = from_file(filename)
    print(str(i),'|',filename)
    #transcricaolistazure[i] = from_file(filename)
    print(transcript)
    print('--------------------------------------------------------------------------------------------------------')
    line = [str(i),filename,transcript]
    with open(output_transcript, 'a', newline='', encoding='utf-8') as transcript_list:
        transcript_write = csv.writer(transcript_list, delimiter='|', escapechar='?',quoting=csv.QUOTE_NONE)
        transcript_write.writerow(line)
    
    time.sleep(0.5)
#transcricaolistazure = [0]*len(fileswav)
#%% azure


for i, file in enumerate(fileswav):
    #if i < 4390:
        #continue
    print(str(i),'|',file)
    transcricaolistazure[i] = from_file(file)
    print(transcricaolistazure[i])
    print('--------------------------------------------------------------------------------------------------------')
    


#%% escreve em arquivo

with open('data/censo', 'r') as f_in:
    with open('output/g00.csv', 'w', newline='', encoding='utf-8') as out00, \
         open('output/g10.csv', 'w', newline='', encoding='utf-8') as out10, \
         open('output/g20.csv', 'w', newline='', encoding='utf-8') as out20, \
         open('output/g30.csv', 'w', newline='', encoding='utf-8') as out30, \
         open('output/g40.csv', 'w', newline='', encoding='utf-8') as out40, \
         open('output/g50.csv', 'w', newline='', encoding='utf-8') as out50, \
         open('output/g60.csv', 'w', newline='', encoding='utf-8') as out60:
             
        w00 = csv.writer(out00, escapechar='?',quoting=csv.QUOTE_NONE)
        w10 = csv.writer(out10, escapechar='?',quoting=csv.QUOTE_NONE)
        w20 = csv.writer(out20, escapechar='?',quoting=csv.QUOTE_NONE)
        w30 = csv.writer(out30, escapechar='?',quoting=csv.QUOTE_NONE)
        w40 = csv.writer(out40, escapechar='?',quoting=csv.QUOTE_NONE)
        w50 = csv.writer(out50, escapechar='?',quoting=csv.QUOTE_NONE)
        w60 = csv.writer(out60, escapechar='?',quoting=csv.QUOTE_NONE)

        for line in f_in:
            line = line.strip('\n')
            #row = []
            
            group = line.split('|')[0]

            if   group == '00':
                w00.writerow([line])
            elif group == '10':
                w10.writerow([line])
            elif group == '20':
#%%
for i, file in enumerate(fileswav):
    if i < 4390:
        continue
    print(str(i),'|',file)
    transcricaolist[i] = speech_to_text(file)
    print(transcricaolist[i])
    print('--------------------------------------------------------------------------------------------------------')
#%%
durationwav = [0]*len(fileswav)
for i, file in enumerate(fileswav):
    print(str(i))
    print(file)
    durationwav[i], rate = get_length(file)
    print(durationwav[i],'--',rate)
    
#%%
durationts = [0]*len(filests)
for i, file in enumerate(filests):
    print(str(i),' | ',file)
    #print(file)
    #if i<441:
        #continue
    #else:
    durationts[i], rate = get_length(file)
    print(durationts[i],'--',rate)
#%%
# res = [sub.replace('4', '1') for sub in test_list]
mp4 = [sub.replace('.mp4','').replace('Z://TS_videos\\','') for sub in filesmp4]
# indexmp4 = [sub. for sub in mp4]

wav = [sub.replace('.wav','').replace('Z://TS_audios\\','') for sub in fileswav]
# indexwav = [sub for sub in wav]

#%%
ts = [sub.replace('Y://','') for sub in filests]
#%%
dfmp4 = pd.DataFrame(mp4)
dfmp4['duration.mp4'] = duration

dfwav = pd.DataFrame(wav)
dfwav['duration.wav'] = durationwav
#%%
dfts = pd.DataFrame(ts)
dfts['duration.ts'] = durationts