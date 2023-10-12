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

We modified some of the contents of the 'requirement.txt' file.
Because I changed torch, torchvision, torchaudio to the latest version for sm_80 compatibility of gpu, and I saved the related files on google drive, so I added gdown.

Add the `fromage` library to PYTHONPATH:
```
export PYTHONPATH=$PYTHONPATH:/home/path/to/fromage/
```

### pikle file

The format was similar to the cc3mpkl file from the image, but the project needed url data for link connections, so we added item_url in the format of capture, image, and item_url.
This can be seen in 'fromage/extract_img_embs.py'.
The file is excluded because it is data from a specific company.
The change point is that if the precision of img_emb is set to bfloat16, an error occurs, so I changed it to floor32 of lumpy and added item_url column.
The tsv file format is as follows.

```
caption image item_url
A picture of a cat  cat.png http://cat.jpg
Mountains  mountain.png http://mountain.jpg 
```

### Pretrained Checkpoints

We needed the model weight trained by FROMAGe for fine-tuning, so we overwritten the value of the prune model weight in the weight file trained once in test_weight.py.
You can change the location of the model file you trained once and the weighted file location of the prune model provided by fromage and run it.

## Training

### Generating Caption



### Preparing Dataset

To create the same shape as cc3m in the existing FROMAGe, we set it as the create_our_dataset function in the test.py file.
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
In the V100 environment, LLM model is a maximum model that can be used by Facebook/opt-1.3b model and Visual model is an openai/clip-bit-large-patch14 model.

## Inference

For inference, there is an example in the file test_inference.ipynb.
The change point is to proceed by receiving input, some parameter values, and output methods have been changed.

## Demo


## Reference
FROMAGe : [Paper](https://arxiv.org/abs/2301.13823) | [Project Webpage](https://jykoh.com/fromage) | [Demo](https://huggingface.co/spaces/jykoh/fromage)
recommend image and url data : https://www.brandi.co.kr
training data : https://www.tag-walk.com/en/


