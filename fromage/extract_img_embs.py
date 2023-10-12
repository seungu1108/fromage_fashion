"""Extract image embeddings for a list of image urls.

Example usage:
    python extract_img_embs.py
"""
import torch
import gdown
import pandas as pd
from PIL import Image
import os
import requests
from io import BytesIO
import pickle as pkl
from tqdm import tqdm
import numpy as np
new_directory_path = '/home/modalyeon/aiffelthon/fromage'
os.chdir(new_directory_path)

from fromage import models, utils

def get_item_urls_66809():
    file_path = '/home/modalyeon/aiffelthon/fromage/datasets/brandi.tsv'
    if not os.path.exists(file_path):
        url = 'https://drive.google.com/uc?id=19sa5uOHu0SKzs4kcb22emEJgPibaNT4I'
        gdown.download(url, file_path, quiet=False)

    meta_data = pd.read_csv(file_path, sep='\t')
    random_sample = meta_data.iloc[:66809]
    return random_sample

def get_item_urls_66810():
    file_path = '/home/modalyeon/aiffelthon/fromage/datasets/brandi.tsv'
    if not os.path.exists(file_path):
        url = 'https://drive.google.com/uc?id=19sa5uOHu0SKzs4kcb22emEJgPibaNT4I'
        gdown.download(url, file_path, quiet=False)

    meta_data = pd.read_csv(file_path, sep='\t')
    random_sample = meta_data[66809:]
    return random_sample


def extract_embeddings_for_urls(image_urls, emb_output_path: str, device: str = "cuda"):
    # Load model checkpoint.

    model = models.load_fromage("/home/modalyeon/aiffelthon/fromage/fromage_model/")
    model.eval()

    visual_encoder = "openai/clip-vit-large-patch14"
    feature_extractor = utils.get_feature_extractor_for_model(
        visual_encoder, train=False
    )

    output_data = {"paths": [], "embeddings": [], "item_url":[]}
    with torch.no_grad():
        for mdata in tqdm(image_urls.itertuples(index=False), total=len(image_urls)):
            try:
                img = Image.open(BytesIO(requests.get(mdata.image).content))
                img_tensor = utils.get_pixel_values_for_model(feature_extractor, img)
                img_tensor = img_tensor[None, ...].to('cuda:0').bfloat16() # TypeError: Got unsupported ScalarType BFloat16 > 기존 모델 가중치가 bf16이라 변경할 수 없음
                img_emb = model.model.get_visual_embs(img_tensor, mode="retrieval")
                img_emb = img_emb[0, 0, :].cpu().float()
                img_emb = img_emb.detach().numpy()
                output_data["paths"].append(mdata.image)
                output_data["embeddings"].append(img_emb)
                output_data["item_url"].append(mdata.item_url)
            except:
                print('-----')
                print(mdata.image)
                print(mdata.item_url)

    with open(emb_output_path, "wb") as f:
        pkl.dump(output_data, f)


# 저장 경로 확인
# extract_embeddings_for_urls(image_urls=get_item_urls_63981(),emb_output_path="/home/modalyeon/aiffelthon/fromage/merge_pkl/brandi_66809.pkl")
# extract_embeddings_for_urls(image_urls=get_item_urls_69637(),emb_output_path="/home/modalyeon/aiffelthon/fromage/merge_pkl/brandi_66810.pkl")


'''
생성 후 테스트 
# 파일을 바이너리 모드로 열고 데이터 로드
with open("/home/modalyeon/aiffelthon/fromage/merge_pkl/cc3m_basic.pkl", 'rb') as file:
    loaded_data = pkl.load(file)

for k in enumerate(loaded_data.keys()):
    print(f'{k} {type(k)}')

type(loaded_data['embeddings'][0]) # len 256
type(loaded_data['embeddings'][0][0])


# 첫 번째 pkl 파일 불러오기
with open('/home/modalyeon/aiffelthon/fromage/merge_pkl/brandi_63981.pkl', 'rb') as f:
    data1 = pkl.load(f)

all_values = list(data1.values())
len(all_values[0])

# 두 번째 pkl 파일 불러오기
with open('/home/modalyeon/aiffelthon/fromage/merge_pkl/brandi_69637.pkl', 'rb') as f:
    data2 = pkl.load(f)

all_values = list(data2.values())
len(all_values[0])
        
# 데이터 합치기
combined_data = data1.copy()

for key, value in data2.items():
    if key in combined_data:
        combined_data[key].extend(value)
    else:
        combined_data[key] = value

all_values = list(combined_data.values())
len(all_values[0])

# 합쳐진 데이터를 새로운 pkl 파일로 저장
with open('/home/modalyeon/aiffelthon/fromage/merge_pkl/new_brandi.pkl', 'wb') as f:
    pkl.dump(data1, f)
'''