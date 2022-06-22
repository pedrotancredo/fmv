# %% Módulos

"""
Itera no INPUT_PATH procurando por arquivos do tipo FILE_EXTENSION e verifica a situação deles
1. Verifica se no nome do arquivo possui algum ' '
2. Verifica se o arquivo contém todos os 5 streams
"""
import subprocess
import re
import glob
import hashlib
# from numpy import append
import pandas as pd

# %% Funções Extras
def get_stream_info(filename):
    """
    Utilizando o ffprobe e recebendo como entra o caminho de um arquivo de mídia
    retorna uma lista contendo informações de cada stream do arquivo
    """

    result = subprocess.run(["ffprobe",filename],
                            stdout=subprocess.PIPE,
                            text=True,
                            stderr=subprocess.STDOUT,
                            check=True)

    output = result.stdout.split('\n')
    result = []

    pattern = r'Stream\s+#\d+:\d+\[.*?\]:\s+(\w*):\s+(\w*)\s+(.*?)$'
    for line in output:

        if re.search(pattern,line) is None:
            continue

        else:
            matches = re.search(pattern, line)
            result.append((matches.group(1), matches.group(2), matches.group(3)))

    return result

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
# INPUT_PATH  = r'F:/FMV_TEMP/up' # Unidade onde está mapeado o fileshare
# INPUT_PATH  = r'I:/DRP' # Unidade onde está mapeado o fileshare
INPUT_PATH = r'C:\Users\pedro\OneDrive\Documentos\GitHub\fmv\test\input'
# INPUT_PATH  = r'Y:' # Unidade onde está mapeado o fileshare
# OUTPUT_PATH = r'./verify.json' # Caminho para arquivo de saída .json
OUTPUT_PATH = r'C:\Users\pedro\OneDrive\Documentos\GitHub\fmv\test\output' # Caminho para arquivo de saída .json
FILE_EXTENSION = '.ts'

# %%

# Lista de arquivos de extensão file_extension que serão iterados para extrair as informações,
# esta celula pode demorar a rodar por isso está separada

input_list = glob.glob(INPUT_PATH + '/**/*' + FILE_EXTENSION, recursive=True)

# %%

# Listas de mesmo tamanho da input_list que receberão os valores de duração e bitrate,
# input_list = input_list[28::]
info = [0]*len(input_list)

for i, item in enumerate(input_list):

    info[i] = get_stream_info(item)
    # hash_list[i] = md5(file) # não vamos gerar o md5 dos arquivos, muito lento
    print(i+1,'/',len(input_list))

# info = info[:][:][0]

# %%

# Carrega tudo em um df
# ffprobe -show_streams -print_format json input.mov
# sub_path_list = [item.replace(INPUT_PATH,'') for item in input_list]

# df = pd.DataFrame(sub_path_list)
df = pd.DataFrame(input_list)
# df['duration'] = duration_list
df['info'] = info
# df['bitrate'] = bitrate_list
# df['hash_md5'] = hash_list # não vamos gerar o md5 dos arquivos, muito lento

#%% Salva tudo em json

df.to_json(OUTPUT_PATH, orient='columns')

# %%
