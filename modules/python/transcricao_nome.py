#%%
import glob
import pandas as pd
import shutil

#%%

def find_nth(haystack, needle, n):
    start = haystack.find(needle)
    while start >= 0 and n > 1:
        start = haystack.find(needle, start+len(needle))
        n -= 1
    return start


#%%
InputPath  = r'E:/OneDrive/Documentos/Furnas/Dataset_2/TS_frames'
OutputPath  = r'E:/OneDrive/Documentos/Furnas/Dataset_2/TS_frames_ds'

#%%
Paths = glob.glob(InputPath + '/**/*.jpg', recursive=True)

for i,Path in enumerate(Paths):
    Paths[i] = Paths[i].replace('\\','/')
# %%

for i,OldPath in enumerate(Paths):

    # OldPath = r'Z:\TS_frames\2019\DRB\19-10-22\LTSMANIQ1_T0218_T0061.ts#620.88.jpg'
    NewPath = OldPath.replace("/","&")
    NewPath = OutputPath + "/" + NewPath[find_nth(OldPath,"/",6)+1::]
    shutil.copy(OldPath,NewPath)
    print(i+1,'/',len(Paths))
    # print(NewPath)


#%%


#%%


