# %% Módulos

"""
Itera no INPUT_PATH procurando por arquivos do tipo FILE_EXTENSION e retorna
informações sobre eles que ficam salvas em OUPUT_PATH
"""
import subprocess
import re
import glob
import hashlib
import pandas as pd

# import datetime

# %% Funções Extras

def get_length(filename):
    """
    Utilizando o ffprobre e recebendo como entrada o caminho de um arquivo de mídia
    retorna os valores de duração e bitrate.
    """

    result = subprocess.run(["ffprobe",filename],
                            stdout=subprocess.PIPE,
                            text=True,
                            stderr=subprocess.STDOUT,
                            check=True)

    pattern = r'(?s)Duration:\s*(.*?),.*?bitrate:\s*(.*?)\s*kb\/s\n'
    if re.search(pattern,result.stdout) is None:
        return 'Erro'
    else:
        result = re.search('Duration: (.*?),.*?bitrate: (.*?) kb',result.stdout)
        return result.group(1), result.group(2)

def md5(fname):
    """
    Utilizando o módulo nativo hashlib, retrona a string hash md5 a partir do caminho
    de um arquivo.

    fonte: https://stackoverflow.com/questions/3431825/generating-an-md5-checksum-of-a-file
    """

    hash_md5 = hashlib.md5()
    with open(fname, "rb") as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()
# %% Parâmetros de Entrada
INPUT_PATH  = r'Y:/' # Unidade onde está mapeado o fileshare
OUTPUT_PATH = r'./fmvaa.json' # Caminho para arquivo de saída .json
FILE_EXTENSION = '.ts'
# %%

# Lista de arquivos de extensão file_extension que serão iterados para extrair as informações,
# esta celula pode demorar a rodar por isso está separada

input_list = glob.glob(INPUT_PATH + '/**/*' + FILE_EXTENSION, recursive=True)

# %%

# Listas de mesmo tamanho da input_list que receberão os valores de duração e bitrate,

duration_list = [0]*len(input_list)
bitrate_list = [0]*len(input_list)
# hash_list = [0]*len(input_list) # não vamos gerar o md5 dos arquivos, muito lento

for i, item in enumerate(input_list):

    duration_list[i], bitrate_list[i] = get_length(item)
    # hash_list[i] = md5(file) # não vamos gerar o md5 dos arquivos, muito lento
    print(i,'/',len(input_list))

# %%

# Carrega tudo em um df

sub_path_list = [item.replace(INPUT_PATH,'') for item in input_list]

df = pd.DataFrame(sub_path_list)
df['duration'] = duration_list
df['bitrate'] = bitrate_list
# df['hash_md5'] = hash_list # não vamos gerar o md5 dos arquivos, muito lento

#%% Salva tudo em json

df.to_json(OUTPUT_PATH, orient='columns')
