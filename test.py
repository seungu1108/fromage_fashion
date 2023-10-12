import subprocess
from collections import OrderedDict
from multiprocessing import Pool

from transformers import logging

# command = "pip install -r /home/modalyeon/aiffelthon/fromage/requirements.txt"
# subprocess.run(command, shell=True)

logging.set_verbosity_error()
import copy
import csv
import gc
import json
import multiprocessing
import os
from io import BytesIO

import gdown
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import requests
import torch
from PIL import Image
from tqdm import tqdm

from fromage import models, utils


def create_our_dataset():
    file_path = '/home/modalyeon/aiffelthon/fromage/datasets/tagwalk.tsv'
    if not os.path.exists(file_path):
        url = 'https://drive.google.com/uc?id=1N3qONOcUF3wRzx6tqGCF3nHIvB83oRx6'
        gdown.download(url, file_path, quiet=False)

    train_tsv_data = [['caption','image']]
    val_tsv_data = [['caption','image']]

    meta_data = pd.read_csv(file_path, sep='\t')
    print(meta_data.head())

    train_data = meta_data[:400] 
    val_data = meta_data[400:500] 

    for typ in ('training','validation'):
        # 만들고자 하는 폴더 경로
        folder_path = f"/home/modalyeon/aiffelthon/fromage/datasets/images/cc3m/{typ}"

        # 해당 경로에 폴더가 없다면 폴더 생성
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
            print(f"{folder_path} 폴더가 생성되었습니다.")
        else:
            print(f"{folder_path} 폴더는 이미 존재합니다.")

        if typ == 'training':
            for d in tqdm(train_data.itertuples(index=False), total=len(train_data)):
                url = d.image
                file_path = f"{os.path.join(folder_path,url.split('/')[-1])}"
                try:
                    if not os.path.exists(file_path):
                        response = requests.get(url)
                        img_data = BytesIO(response.content)
                        image = Image.open(img_data)
                        image.save(file_path)
                except:
                    print(url, file_path)
                    continue
                train_tsv_data.append([d.caption,file_path])

        else:
            for d in tqdm(val_data.itertuples(index=False), total=len(val_data)):
                url = d.image
                file_path = f"{os.path.join(folder_path,url.split('/')[-1])}"
                try:
                    if not os.path.exists(file_path):
                        response = requests.get(url)
                        img_data = BytesIO(response.content)
                        image = Image.open(img_data)
                        image.save(file_path)
                except:
                    print(url,file_path)
                    continue
                val_tsv_data.append([d.caption,file_path])
    
    tsv = ['/home/modalyeon/aiffelthon/fromage/datasets/cc3m_train.tsv',
        '/home/modalyeon/aiffelthon/fromage/datasets/cc3m_val.tsv']

    tsv_data = [train_tsv_data, val_tsv_data]

    for i,t in tqdm(enumerate(tsv),total=len(tsv)):
        with open(t, mode='w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file, delimiter='\t')
            writer.writerows(tsv_data[i])


def running():
    #running    
    
    command = """python -u '/home/modalyeon/aiffelthon/fromage/main.py' \
        --multiprocessing-distributed \
        --epochs=21 \
        --resume='/home/modalyeon/aiffelthon/fromage/fromage_model/test_model/ckpt.pth.tar' \
        --max-len=177 \
        --world-size 1 \
        --rank 0 \
        --dataset=cc3m  \
        --val-dataset=cc3m \
        --dataset_dir='/home/modalyeon/aiffelthon/fromage/datasets' \
        --opt-version='facebook/opt-6.7b' \
        --visual-model='openai/clip-vit-large-patch14' \
        --exp_name='exp_00003' \
        --image-dir='/home/modalyeon/aiffelthon/fromage/datasets/images/'  \
        --log-base-dir='/home/modalyeon/aiffelthon/fromage/runs/' \
        --learning-rate=0.00003 \
        --batch-size=6 \
        --print-freq=100 \
        --precision='bf16'"""

    result = subprocess.run(command, shell=True) #반응 없을때는 cli 환경에서 실행하면됨


def cc3m_embedding_download():
    #cc3m embedding file download
    url = 'https://drive.google.com/u/0/uc?id=1ZalyAVoIycy-CYVtOrVjuYvrDwji0DFR'
    output = '/home/modalyeon/aiffelthon/fromage/fromage_model/cc3m_embeddings.pkl'  # 결과 나온 모델 폴더 지정
    gdown.download(url, output, quiet=False)


#prune model
def prune_model(fromage_exp):
    ckpt_path = f'/home/modalyeon/aiffelthon/fromage/runs/{fromage_exp}/ckpt_best.pth.tar' # ckpt_best.pth.tar가 없을 경우 ckpt.pth.tar
    pruned_output_path = f'/home/modalyeon/aiffelthon/fromage/runs/{fromage_exp}/pretrained_ckpt.pth.tar'
    model_args_path = f'/home/modalyeon/aiffelthon/fromage/runs/{fromage_exp}/model_args.json'

    with open(model_args_path, 'r') as f:
        model_kwargs = json.load(f)
        ret_token_idx = model_kwargs['retrieval_token_idx']

    with open(ckpt_path, 'rb') as f:
        checkpoint = torch.load(f)

    stripped_state_dict = {
        k.replace('module.', ''): v for k, v in checkpoint['state_dict'].items() if 
        ('.lm' not in k and '.visual_model' not in k)
    }
    stripped_state_dict = OrderedDict(sorted(stripped_state_dict.items()))

    del checkpoint['epoch']
    print('Best score:', checkpoint['best_score'])
    del checkpoint['optimizer']
    del checkpoint['scheduler']
    for k, v in stripped_state_dict.items():
        stripped_state_dict[k] = v.detach().clone()


    # Prune the pretrained token embeddings and keep just [RET].
    ret_embedding = stripped_state_dict['model.input_embeddings.weight'][ret_token_idx:ret_token_idx+1, :].detach().clone()
    stripped_state_dict['ret_input_embeddings.weight'] = ret_embedding

    with open(pruned_output_path, 'wb') as f:
        torch.save({'state_dict': stripped_state_dict}, f)


# inference setting
def display_interleaved_outputs(model_outputs, one_img_per_ret=True):
    for output in model_outputs:
        if type(output) == str:
            print(f'output : {output}')
        elif type(output) == list:
            if one_img_per_ret:
                plt.figure(figsize=(3, 3))
                plt.imshow(np.array(output[0]))
            else:
                fig, ax = plt.subplots(1, len(output), figsize=(3 * len(output), 3))
                for i, image in enumerate(output):
                    image = np.array(image)
                    ax[i].imshow(image)
                    ax[i].set_title(f'Image #{i+1}')
            plt.show()
        elif type(output) == Image.Image:
            plt.figure(figsize=(3, 3))
            plt.imshow(np.array(output))
            plt.show()

    
# create_our_dataset()
# running()
# cc3m_embedding_download()
# prune_model('fromage_exp')
