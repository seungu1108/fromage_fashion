# fine-tuning fromage with fashion data

<p align="center">
<img alt="FROMAGe chat animation" src="./demo.gif" width="40%">
</p>

This repository stores code for fine-tuning and model weighting of FROMAGe.

For pkl files, we excluded data from a specific company because it was used.

## Team
[Kim Seol A](https://github.com/kxxseola) | [Nam Hee jung](https://github.com/eveningwalk) | [Baek Min Hong](None)

This project was carried out with the above personnel.

## Papers
[Papers selected for KSC 2023](https://github.com/seungu1108/fromage_fashion/blob/main/paper/fromage_fashion.pdf)

## Preparing
### pikle file

The format was similar to the cc3m pkl file from the image, but the project needed url data for link connections, so we added item_url in the format of capture, image, and item_url.

This can be seen in `fromage/extract_img_embs.py`.

The file is excluded because it is data from a specific company.

The change point is that if the precision of img_emb is set to bfloat16, an error occurs, so I changed it to float32 of numpy and added item_url column.

The tsv file format is as follows.

| caption | image | item_url |
|---------|---------|---------|
| A picture of a cat  | cat.png  | http://cat.jpg  |
| Mountains  | mountain.png  | http://mountain.jpg  |

### Pretrained Checkpoints

We needed the model weight trained by FROMAGe for fine-tuning, so we overwritten the value of the prune model weight in the weight file trained once in `test_weight.py`.

You can change the location of the model file you trained once and the weighted file location of the prune model provided by fromage and run it.

### Generating Caption

We used LLAMA to generate caption data because we had image data but there was no caption data to match it.

`LLaMA-Adapter_2/llama_adapter_v2_multimodal7b/working/llama_test.py` proceeded through the corresponding script and used 7B here at [Model Weight Link](https://github.com/shawwn/llama-dl/) for the weighted file.

It generated 12,957 captions and took about 11 hours.

Please refer to the link below for the folder and contents.

[llama_adapter_v2_multimodal7b folder Link](https://github.com/seungu1108/fromage_fashion/tree/main/LLaMA-Adapter_2/llama_adapter_v2_multimodal7b)

### Preparing Dataset

To create the same shape as cc3m in the existing FROMAGe, we set it as the `create_our_dataset` function in the `test.py` file.

This is also data for a particular company, so we excluded the files.

## Training

You can run the `running` function in the `test.py` file for training.

We did it in the A100 40GB environment of the google cloud platform,

The dataset used 12,957 pairs of images and captions.

It took approximately 30 minutes per epoch, and memory used 22GB of GPU and 38GB of CPU.

LLM Model : Facebook/opt-1.3b Model and Visual Model : Openai/clip-bit-large-patch14 Model are the largest available models in the V100 environment.

As a peculiarity of the V100 environment, the precision of fp16,bf16 was not available because it could operate only with fp32.

## Inference

For inference, there is an example in the file `test_inference.ipynb`.

It took memory used 17GB of GPU and 42GB of CPU.

The change point is to proceed by receiving input, some parameter values, and output methods have been changed.

### example
<img width="909" alt="image" src="https://github.com/seungu1108/fromage_fashion/assets/29696196/755daadb-3998-4b76-addf-8cb18cf51727">

## Demo

The demo is a chat app created with a flutter and has its contents in the `server.py` and `flutter_demo` folders,

and is an interaction between the input and output values entered in the inference.

Please refer to the link below for the folder and contents.

[Demo folder Link](https://github.com/seungu1108/fromage_fashion/tree/main/flutter_demo#flutter-for-demo)

## To-do
- [x] Use LLAMA to generate caption data
- [x] Create a pikle file for project data
- [x] Change prune model weight to full model weight for fine-tuning
- [x] Fine-tuning learning of the FROMAGe model
- [x] Create Demo app using Flutter
- [ ] V100 also uses fp16 to make it lighter for larger models
- [ ] Lightweight treatment using LLM models with Lora

## Reference
FROMAGe : [Paper](https://arxiv.org/abs/2301.13823) | [Project Webpage](https://jykoh.com/fromage) | [Demo](https://huggingface.co/spaces/jykoh/fromage)

recommend image and url data : https://www.brandi.co.kr

training data : https://www.tag-walk.com/en/

generate caption model : https://github.com/Alpha-VLLM/LLaMA2-Accessory

generate caption model weight : https://github.com/shawwn/llama-dl/

## Acknowledge
This project was created with the support of [AIffel](https://www.aiffel.io/?utm_source=modulabs&utm_medium=on_banner_all&utm_campaign=kdt_23_06&utm_content=m_bran_main-bn_everyone).
