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


# STT da Azure, configuração
speech_key = "aa9591cfde1e418d99490bacb4786abd"
region=service_region = "brazilsouth"
language = "pt-BR"
profanity = speechsdk.ProfanityOption.Raw

def from_file(audiofile):
    """Transcreve um trecho de audio em texto a partir de um arquivo, ideal para arquivos pequenos"""

    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
    speech_config.speech_recognition_language=language
    speech_config.set_profanity(profanity)  
    audio_input = speechsdk.AudioConfig(filename=audiofile)
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_input)

    result = speech_recognizer.recognize_once_async().get()
    return result.text

def speech_recognize_continuous_from_file(audiofile):
    """Transcreve um trecho de audio de forma contínua a partir de um arquivo"""

    # Parâmetros de configuração
    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
    speech_config.speech_recognition_language=language  
    speech_config.set_profanity(profanity)
    audio_config = speechsdk.audio.AudioConfig(filename=audiofile)
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_config)

    # Definição das funções que são chamadas durante o disparo dos eventos
    def stop(evt):
        """Evento que encerra o reconhecimento de voz"""
        speech_recognizer.stop_continuous_recognition()
        nonlocal done
        done = True
  
    def handle_final_result(evt):
        nonlocal result
        result.append(evt.result.text)

    # Chamada dos eventos
    speech_recognizer.recognized.connect(handle_final_result)
    speech_recognizer.session_stopped.connect(stop)
    speech_recognizer.canceled.connect(stop)

    # Início do reconhecimento    
    result = []
    done = False

    speech_recognizer.start_continuous_recognition()
    while not done:
        time.sleep(0.5)

    # Converte lista de frases em string única
    all_results = ' '.join([str(item) for item in result])

    return all_results
#%% Roda um pra teste

single = r'Z:\TS_trechos\2019\DRB\19-10-02\LTGUPMIC_T0274_T0295_P1.ts\LTGUPMIC_T0274_T0295_P1#38.28#81.59.wav'
out = speech_recognize_continuous_from_file(single)
print(out)

#%% Gera lista de arquivos
my_path = r'Z:\TS_trechos'
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
transcricaolistazure = [0]*len(fileswav)
#%% azure


for i, file in enumerate(fileswav):
    #if i < 4390:
        #continue
    print(str(i),'|',file)
    transcricaolistazure[i] = from_file(file)
    print(transcricaolistazure[i])
    print('--------------------------------------------------------------------------------------------------------')
    

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