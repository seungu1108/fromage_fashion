import cv2
import llama
import torch
from PIL import Image
import os

import pandas as pd
import requests
from io import BytesIO
import numpy as np
import time

from torchvision import transforms


device = "cuda" if torch.cuda.is_available() else "cpu"
print(device)

llama_dir = '/home/modalyeon/aiffelthon/llama/LLaMA-Adapter_2/llama_adapter_v2_multimodal7b/llama_df'

start_time = time.time()

# choose from BIAS-7B, LORA-BIAS-7B
model, preprocess = llama.load("LORA-BIAS-7B", llama_dir, device)
model.eval()

#prompt = llama.format_prompt("can you explain the object facts on the materials and colors of the clothes?")
prompt = llama.format_prompt("summerize the object facts on the materials and colors of the clothes into one sentence")
captions = []
file_path = "/home/modalyeon/aiffelthon/llama/LLaMA-Adapter/llama_adapter_v2_multimodal7b/working/tagwalk.tsv"

df_12975 = pd.read_csv(file_path, sep='\t')
df_train = df_12975.iloc[:10000]
df_val = df_12975.iloc[10000:]


df = df_train.copy()  
#df = df_val.copy()
print("shape : ", df.shape)

i = 0

for url in df['image']:
    time.sleep(1)

    i += 1
    print('Count', i, ':', url)
    response = requests.get(url)
    image = Image.open(BytesIO(response.content)).convert("RGB")
    img_array = np.array(image)
    img = Image.fromarray(img_array)
    img = preprocess(img).unsqueeze(0).to(device)


    result = model.generate(img, [prompt], max_gen_len = 26)[0]
    captions.append(result)
            
    print(result)
    print("Length : ", len(result))
    print('\n\n')

df.to_csv('tagwalk_train.tsv', sep='\t', index=False)   #hjnam 


end_time = time.time()
elapsed_time = end_time - start_time
print()
print(f'The processing took {elapsed_time/60/60} hours.')