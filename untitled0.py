import subprocess
import re 
# import os

def get_length(filename):
    result = subprocess.run(["ffprobe",filename],stdout=subprocess.PIPE, text=True, stderr=subprocess.STDOUT)

    
    if re.search('Duration: (.*?),.*?bitrate: (.*?) kb',result.stdout) is None:
        return('Erro')
    else:
        rs = re.search('Duration: (.*?),.*?bitrate: (.*?) kb',result.stdout)
        return rs.group(1), rs.group(2)
                

# print(get_length(filename))



# from pathlib import Path
# result = list(Path(".").rglob("*.[tT][xX][tT]"))

#%%
import glob
my_path = r'Y:/'
files = glob.glob(my_path + '/**/*.mp4', recursive=True)


#%%
duration = [0]*len(files)
for i, file in enumerate(files):
    print(str(i))
    print(file)
    duration[i], rate = get_length(file)
    print(duration[i],'--',rate)
#%%