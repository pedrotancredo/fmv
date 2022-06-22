# %% [markdown]
#Carrega Módulos
#Author Pedro Tancredo

#%%
import subprocess
import re 
import os
import pandas as pd
import datetime
import glob

def get_length(filename):
    result = subprocess.run(["ffprobe",filename],stdout=subprocess.PIPE, text=True, stderr=subprocess.STDOUT)

    
    if re.search('(?s)Duration:\s*(.*?),.*?bitrate:\s*(.*?)\s*kb\/s\n',result.stdout) is None:
        return('Erro')
    else:
        rs = re.search('Duration: (.*?),.*?bitrate: (.*?) kb',result.stdout)
        return rs.group(1), rs.group(2)
                
#%%
#Calcula HASH
import hashlib
def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()
#%%
#Parâmetros
InputPath  = r'Y:/'
OutputPath = r'Z:/'

#%%
#Entrada
my_path = InputPath
filests = glob.glob(my_path + '/**/*.ts', recursive=True)

#%%
# durationts = [0]*len(filests)
# ratets = [0]*len(filests)
hashts = [0]*len(filests)
for i, file in enumerate(filests):
    if i < 0:
        continue
    print(str(i))
    print(file)
    # durationts[i], ratets[i] = get_length(file)
    # Rodou até o 440
    hashts[i] = md5(file)
    # print(durationts[i],'--',ratets[i])#,hashts[i])
    print(i,hashts[i])

#%%

ts = [sub.replace('Y://','') for sub in filests]
# indexwav = [sub for sub in wav]

dfts = pd.DataFrame(ts)
dfts['duration'] = durationts
dfts['bitrate'] = ratets

#%%

ts = [sub.replace('Y://','') for sub in filests]
# indexwav = [sub for sub in wav]

dfts = pd.DataFrame(ts)
dfts['hash_md5'] = hashts

data = dfts.to_json('./hash_fmv.json', orient='columns')
print(data)


#%%
data = dfts.to_json('./fmv2.json', orient='columns')
print(data)

#%%
newdf = pd.read_json('./hash_fmv.json')
#%%
#Saída
my_path = OutputPath
filesmp4 = glob.glob(my_path + '/**/*.mp4', recursive=True)
fileswav = glob.glob(my_path + '/**/*.wav', recursive=True)
filesjson = glob.glob(my_path + '/**/*.json', recursive=True)


#%%
duration = [0]*len(filesmp4)
for i, file in enumerate(filesmp4):
    print(str(i))
    print(file)
    duration[i], rate = get_length(file)
    print(duration[i],'--',rate)
#%%
durationwav = [0]*len(fileswav)
for i, file in enumerate(fileswav):
    print(str(i))
    print(file)
    durationwav[i], rate = get_length(file)
    print(durationwav[i],'--',rate)
#%%
# res = [sub.replace('4', '1') for sub in test_list]
mp4 = [sub.replace('.mp4','').replace('Z://TS_videos\\','') for sub in filesmp4]
# indexmp4 = [sub. for sub in mp4]

wav = [sub.replace('.wav','').replace('Z://TS_audios\\','') for sub in fileswav]
# indexwav = [sub for sub in wav]

dfmp4 = pd.DataFrame(mp4)
dfmp4['duration.mp4'] = duration

dfwav = pd.DataFrame(wav)
dfwav['duration.wav'] = durationwav
#%%
exportar = pd.merge(dfmp4,dfwav,how="inner",on=0,sort=True,
                  copy=True,indicator=False,validate=None,)
#%%
# exportar['duration.mp4'] =  pd.to_datetime(exportar['duration.mp4'], format='%H:%M:%S.%f')
# exportar['duration.wav'] =  pd.to_datetime(exportar['duration.wav'], format='%H:%M:%S.%f')

exportar['duration.mp4'] =  pd.to_timedelta(exportar['duration.mp4'])
exportar['duration.wav'] =  pd.to_timedelta(exportar['duration.wav'])

exportar['delta'] = abs((exportar['duration.mp4']-exportar['duration.wav']).dt.total_seconds())
# exportar['deltat'] = exportar['delta'].dt.total_seconds()
#%%
# print (exportar.dtypes)

# temp =  pd.to_timedelta(exportar['duration.mp4'])
# dates_input = exportar["duration.mp4"].values.astype('datetime64[D]')

totaltime = exportar['duration.mp4'].sum()

# print(str(totaltime))

print(str(int(totaltime.total_seconds()/3600)) + ' horas')
