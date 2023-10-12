from flask import Flask, request, jsonify
import numpy as np
import copy
import torch
from transformers import logging
logging.set_verbosity_error()
import sys
from io import BytesIO
import base64

from PIL import Image
import matplotlib.pyplot as plt

from fromage import models
from fromage import utils

app = Flask(__name__)

# BASE_WIDTH = 512
# MODEL_DIR = './fromage_model/fromage_vis4'

model_dir = '/home/modalyeon/aiffelthon/fromage/runs/fromage_exp' # epoch 20모델 
model = models.load_fromage(model_dir)

ret_scale_factor = 1  # Increase this hyperparameter to upweight the probability of FROMAGe returning an image.

input_context = []
all_outputs = []

@app.route('/', methods=['POST'])
def process_message():
    try:
        inp = request.json.get('text')    
        if model is not None:
            text = ''
            while True:
                if inp == 'q':
                    break
                # Add Q+A prefixes for prompting. This is helpful for generating dialogue.
                text += f'Q: {inp}\nA:'
                model_prompt = input_context + [text]
                # 이미지 url로 입력 받아오기 시도
                # if 'url' in inp:
                #     try: #https://img1.shopcider.com/product/1648005693000-bPswiA.jpg
                #         input_context = [utils.get_image_from_url(inp.split('url')[-1])]
                #     except:
                #         print(f'{inp.split("url")[-1]} is not image url')
                if 'recommend' in inp:
                    model_outputs = model.generate_for_images_and_texts(
                        model_prompt, num_words=32, ret_scale_factor=ret_scale_factor*2, max_num_rets=2)
                else:
                    model_outputs = model.generate_for_images_and_texts(
                        model_prompt, num_words=32, ret_scale_factor=ret_scale_factor, max_num_rets=2)

                lens = len(model_outputs)
                if lens == 1:
                    text += ' '.join([model_outputs[0]]) + '\n'
                    return jsonify({'response_text': model_outputs[0]})

                else:
                    response_data = {
                        'response_text': '',  # 빈 응답 
                        'response_image': [],  # 빈 이미지 리스트
                        'response_link': []  # 빈 링크 리스트
                    }
                    for i in range(lens):
                        if i % 3 == 0:
                            if model_outputs[i][0] == ' [RET]' or ' ':
                                if i == 0:
                                    text += ' '.join(['okay I show you']) + '\n'
                            else:
                                response_data['response_text'] = (model_outputs[i][0])
                        elif i % 3 == 1:
                            # response_data['response_text'] = ''
                            # response_data['response_text'] = model_outputs[0][:-6]
                            # 이미지를 열고 Base64로 인코딩
                            # image = Image.open('example.jpg')  # 이미지 파일 열기
                            # response_data['response_text'].append(model_outputs[0][:-6])
                            image = model_outputs[i][0]
                            image_byte_array = BytesIO()
                            image.save(image_byte_array, format='JPEG')  # 이미지를 바이트 배열로 저장
                            image_base64 = base64.b64encode(image_byte_array.getvalue()).decode('utf-8')  # Base64로 인코딩
                            response_data['response_image'].append(image_base64)
                            response_data['response_link'].append(model_outputs[i+1][0])

                    return jsonify(response_data)  # 응답 데이터 반환

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)




