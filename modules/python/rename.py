import os
import pandas as pd

df = pd.read_csv(r'E:\OneDrive\Documentos\GitHub\fmv\modules\python\de-para.csv',';')
# print(df)

for i,row in df.iterrows():
    # print(row['de'],row['para'])
    print(i)
    os.rename(row['de'],row['para'])