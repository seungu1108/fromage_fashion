# fine-tuning fromage with fashion data

<p align="center">
<img alt="FROMAGe chat animation" src="./demo.gif" width="40%">
</p>

This repository stores code for fine-tuning and model weighting of FROMAGe.

For pkl files, we excluded data from a specific company because it was used.

## Setup instructions

### Environment
Set up a new virtualenv, and install required libraries:
```
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

We modified some of the contents of the `requirement.txt` file.

Because I changed torch, torchvision, torchaudio to the latest version for sm_80 compatibility of gpu, and I saved the related files on google drive, so I added gdown.

Add the `fromage` library to PYTHONPATH:
```
export PYTHONPATH=$PYTHONPATH:/home/path/to/fromage/
```

### pikle file

The format was similar to the cc3m pkl file from the image, but the project needed url data for link connections, so we added item_url in the format of capture, image, and item_url.

This can be seen in `fromage/extract_img_embs.py`.

The file is excluded because it is data from a specific company.

The change point is that if the precision of img_emb is set to bfloat16, an error occurs, so I changed it to float32 of numpy and added item_url column.

The tsv file format is as follows.

```
caption image item_url
A picture of a cat  cat.png http://cat.jpg
Mountains  mountain.png http://mountain.jpg 
```

### Pretrained Checkpoints

We needed the model weight trained by FROMAGe for fine-tuning, so we overwritten the value of the prune model weight in the weight file trained once in `test_weight.py`.

You can change the location of the model file you trained once and the weighted file location of the prune model provided by fromage and run it.

## Training

### Generating Caption

We used LLAMA to generate caption data because we had image data but there was no caption data to match it.

`LLaMA-Adapter_2/llama_adapter_v2_multimodal7b/working/llama_test.py` proceeded through the corresponding script and used 7B here at [Link](https://github.com/shawwn/llama-dl/) for the weighted file.

It generated 12,957 captions and took about 11 hours.

### Preparing Dataset

To create the same shape as cc3m in the existing FROMAGe, we set it as the create_our_dataset function in the `test.py` file.

This is also data for a particular company, so we excluded the files.

### Training FROMAGe

After preparing Dataset as detailed above, you can start a new training job with the following command line flag:

```
python -u '/home/fromage/main.py' \
        --multiprocessing-distributed \ --epochs=21 \
        --resume='/home/fromage/fromage_model/test_model/ckpt.pth.tar' \
        --max-len=177 \ --world-size 1 \ --rank 0 \ --dataset=cc3m  \ --val-dataset=cc3m \
        --dataset_dir='/home/fromage/datasets' \
        --opt-version='facebook/opt-6.7b' \
        --visual-model='openai/clip-vit-large-patch14' \
        --image-dir='/home/fromage/datasets/images/'  \
        --log-base-dir='/home/fromage/runs/' \
        --exp_name='exp_00003' \ --learning-rate=0.00003 \
        --batch-size=6 \ --print-freq=100 \ --precision='bf16'
```

We did it in the A100 40GB environment of the google cloud platform,

The dataset used 12,957 pairs of images and captions.

It took approximately 30 minutes per epoch, and memory used 22GB of GPU and 38GB of CPU.

LLM Model : Facebook/opt-1.3b Model and Visual Model : Openai/clip-bit-large-patch14 Model are the largest available models in the V100 environment.

As a peculiarity of the V100 environment, the precision of fp16,bf16 was not available because it could operate only with fp32.

## Inference

For inference, there is an example in the file `test_inference.ipynb`.

It took memory used 17GB of GPU and 42GB of CPU.

The change point is to proceed by receiving input, some parameter values, and output methods have been changed.

## Demo

The demo is a chat app created with a flutter and has its contents in the `server.py` and `flutter_demo` folders,

and is an interaction between the input and output values entered in the inference.

Please refer to the link below for the folder and contents.

[Demo folder Link](https://github.com/seungu1108/fromage_fashion/tree/main/flutter_demo#flutter-for-demo)

## Reference
FROMAGe : [Paper](https://arxiv.org/abs/2301.13823) | [Project Webpage](https://jykoh.com/fromage) | [Demo](https://huggingface.co/spaces/jykoh/fromage)

recommend image and url data : https://www.brandi.co.kr

training data : https://www.tag-walk.com/en/

generate caption model : https://github.com/Alpha-VLLM/LLaMA2-Accessory

generate caption model weight : https://github.com/shawwn/llama-dl/

