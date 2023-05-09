import cv2
import numpy as np
import paddlehub as hub
import os

# set PATH=C:\mylibs;%PATH%

os.chdir('./work')
print(os.getcwd())
os.environ["CUDA_VISIBLE_DEVICES"] = "0"

human_seg = hub.Module(name='humanseg_server')
cap_video = cv2.VideoCapture('man/h2.mp4')
fps = cap_video.get(cv2.CAP_PROP_FPS)
save_path = 'man/h2_88.mp4'
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
        # bg_im = np.zeros((height, width, 4), dtype=np.uint8)  # 创建一个四通道图像，第四个通道为 alpha 通道
        # bg_im[:, :, 3] = 0  # 将 alpha 通道设置为全 0，表示完全透明

        bg_im = np.ones_like(img_matting) * 0
        # bg_im[:, :, 1] = 255       # get green canva
        bg_im[:, :, 1] = 88       # get green canva
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