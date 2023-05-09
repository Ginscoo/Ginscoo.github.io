## 0.1. 准备
### 0.1.1. 安环境
    * `windows11`
    * `python3.10`
    * `RTX4090`
### 0.1.2. 帮助文档
    * github [https://github.com/PaddlePaddle/Paddle](https://github.com/PaddlePaddle/Paddle)
    * 模型中心 [https://www.paddlepaddle.org.cn/en/models](https://www.paddlepaddle.org.cn/en/models)
    * GPU版本选择 [https://www.paddlepaddle.org.cn/install/quick?docurl=/documentation/docs/zh/install/pip/windows-pip.html](https://www.paddlepaddle.org.cn/install/quick?docurl=/documentation/docs/zh/install/pip/windows-pip.html)
## 0.2. 安装
### 0.2.1. 安装`paddlepaddle`
```Shell
# 分为CPU与GPU版本，允许的话建议使用GPU加速
# CPU
pip install paddlepaddle
# GPU 参考 https://www.paddlepaddle.org.cn/install/quick?docurl=/documentation/docs/zh/install/pip/windows-pip.html
# 实际需要考虑具体显卡型号和版本
# 如安装11.7 
# pip install paddlepaddle-gpu==2.4.2.post117 -f https://www.paddlepaddle.org.cn/whl/windows/mkl/avx/stable.html
pip install paddlepaddle-gpu
```
### 0.2.2. 安装`paddlehub`
```Shell
# 模型管理中心
pip install paddlehub 
```
### 0.2.3. 安装GPU相关库
* 安装GPU相关库
    * 相关版本安装可参考 - [https://www.paddlepaddle.org.cn/install/quick?docurl=/documentation/docs/zh/install/pip/windows-pip.html](https://www.paddlepaddle.org.cn/install/quick?docurl=/documentation/docs/zh/install/pip/windows-pip.html)
    * 安装CUDA
        * 可能需要登录
        * 下载地址 - [https://developer.nvidia.cn/cuda-downloads?target_os=Windows&target_arch=x86_64](https://developer.nvidia.cn/cuda-downloads?target_os=Windows&target_arch=x86_64)
        * 历史版本下载 - [https://developer.nvidia.cn/cuda-toolkit-archive](https://developer.nvidia.cn/cuda-toolkit-archive)
        * 这里选择11.7
        * 安装完重启下
        * 安装位置一般在 `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.7`
    * 下载cuDNN
        * [https://developer.nvidia.com/rdp/cudnn-archive](https://developer.nvidia.com/rdp/cudnn-archive)
        * 解压一般包含如下几个文件
            * `bin`
            * `include`
            * `lib`
        * 直接复制到`CUDA`目录下`C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.7`,存在的直接覆盖即可
    * 下载 `Zlib`
        * 部分场景需要解压缩，需要安装` Installing Zlib`
        * 缺少报错`Could not locate zlibwapi.dll. Please make sure it is in your library path`
        * 参考文档 - [https://www.liaojinhua.com/python/3820.html](https://www.liaojinhua.com/python/3820.html)
        * 下载地址 - [https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#install-zlib-windows](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#install-zlib-windows)
        * 下载完成后解压将`zlibwapi.dll`复制到`C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.7\bin`即可
* 检查GPU配置情况
```python
import paddlepaddle.utils.run_check()
paddle.utils.run_check()
```
如果出现如下表示成功
```Console
Running verify PaddlePaddle program ... 
W0509 14:46:12.973776 32952 gpu_resources.cc:61] Please NOTE: device: 0, GPU Compute Capability: 8.9, Driver API Version: 12.1, Runtime API Version: 11.7
W0509 14:46:12.984279 32952 gpu_resources.cc:91] device: 0, cuDNN Version: 8.4.
PaddlePaddle works well on 1 GPU.
PaddlePaddle works well on 1 GPUs.
PaddlePaddle is installed successfully! Let's start deep learning with PaddlePaddle now.
```
出现下边或者其他表示有问题，需要自行检查版本或查看提示
```Console
# 可以尝试重启下
Running verify PaddlePaddle program ... 
W0509 14:46:12.973776 32952 gpu_resources.cc:61] Please NOTE: device: 0, GPU Compute Capability: 8.9, Driver API Version: 12.1, Runtime API Version: 11.7
W0509 14:46:12.984279 32952 gpu_resources.cc:91] device: 0, cuDNN Version: 8.4.
```

### 0.2.4. 安装`humanseg_server`及人像检测示例
```shell
# 人像识别服务
hub intsall humanseg_server
```
* `humanseg_server`示例,人像检测
    * 将`work/demo.mp4`非人体部分转化为绿色，并输出到`work/demo_out.mp4`

```python

import cv2
import numpy as np
import paddlehub as hub
import os

os.chdir('./work')
print(os.getcwd())
os.environ["CUDA_VISIBLE_DEVICES"] = "0"

human_seg = hub.Module(name='humanseg_server')
cap_video = cv2.VideoCapture('demo.mp4')
fps = cap_video.get(cv2.CAP_PROP_FPS)
save_path = 'demo_out.mp4'
width = int(cap_video.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap_video.get(cv2.CAP_PROP_FRAME_HEIGHT))
# cap_out = cv2.VideoWriter(save_path, cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'), fps, (width, height))
cap_out = cv2.VideoWriter(save_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))
prev_gray = None
prev_cfd = None

frame_toltal = cap_video.get(7)    # get all frame num
frame_index = 0                    # current frame index

while cap_video.isOpened():
    ret, frame_org = cap_video.read()
    if ret:
        [img_matting, prev_gray, prev_cfd] = human_seg.video_stream_segment(frame_org=frame_org, frame_id=cap_video.get(1), prev_gray=prev_gray, prev_cfd=prev_cfd, use_gpu=True)
        img_matting = np.repeat(img_matting[:, :, np.newaxis], 3, axis=2)
        bg_im = np.ones_like(img_matting) * 0
        bg_im[:, :, 1] = 255       # get green canva
        comb = (img_matting * frame_org + (1 - img_matting) * bg_im).astype(np.uint8)
        cap_out.write(comb)

        # show current information
        frame_index += 1
        print("Current Progress: {}/{}".format(frame_index, int(frame_toltal)))
    else:
        break

    # cv2.imshow('frame', comb)
    # if cv2.waitKey(1) & 0xFF == ord('q'):
    #     break

cap_video.release()
cap_out.release()

```