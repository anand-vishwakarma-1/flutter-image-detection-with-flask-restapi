from flask import Flask,Blueprint,request,Response,jsonify,send_file

from models import *
from utils.datasets import *
from utils.utils import *

import json

import time

device = torch_utils.select_device(device = '0' if torch.cuda.is_available() else 'cpu')
model = Darknet(os.path.join(os.path.dirname(sys.argv[0]),'yolov3_tiny/yolov3-tiny.cfg'), (608, 352))
model.load_state_dict(torch.load(os.path.join(os.path.dirname(sys.argv[0]),'yolov3_tiny/yolov3-tiny.pt'), map_location=device)['model'])
model.to(device).eval()

names = load_classes(os.path.join(os.path.dirname(sys.argv[0]),'yolov3_tiny/coco.names'))
colors = [[random.randint(0, 255) for _ in range(3)] for _ in range(len(names))]

mod = Blueprint('predict',__name__)
@mod.route('/predict',methods=['post'])
def predict():
    imageName = json.loads(request.data)['imageName']
    if imageName != "":
        im0 = cv2.imread(os.path.join(os.path.dirname(sys.argv[0]),'uploaded_images',imageName))
        img = letterbox(im0, new_shape=(608, 352))[0]
        img = img[:, :, ::-1].transpose(2, 0, 1)  # BGR to RGB, to 3x416x416
        img = np.ascontiguousarray(img)
        img = torch.from_numpy(img).to(device)
        img = img.float()
        img /= 255.0
        if img.ndimension() == 3:
            img = img.unsqueeze(0)
        pred = model(img)[0]
        pred = non_max_suppression(pred, 0.3, 0.6,multi_label=False)
        pred_list = []
        x = 0
        det = pred[0]
        gn = torch.tensor(im0.shape)[[1, 0, 1, 0]]  #  normalization gain whwh
        if det is not None and len(det):
            # Rescale boxes from imgsz to im0 size
            det[:, :4] = scale_coords(img.shape[2:], det[:, :4], im0.shape).round()

            # # Print results
            for c in det[:, -1].unique():
                n = (det[:, -1] == c).sum()  # detections per class
                x += int(n)
                pred_list.append({"className": names[int(c)],"count": int(n),"scores": det[det[:, -1] == c,-2].tolist()})

            # Write results
            for *xyxy, conf, cls in det:
                label = '%s %.2f' % (names[int(cls)], conf)
                plot_one_box(xyxy, im0, label=label, color=colors[int(cls)])
        cv2.imwrite(os.path.join(os.path.dirname(sys.argv[0]),'uploaded_images',imageName.split('.')[0]+'_predicted.jpg'),im0)
        return jsonify({"predictions": pred_list, "count": x,"status": "success"})
    else:
        return jsonify({"status": "failed"})


@mod.route('/download',methods = ['POST'])
def download():
    imageName = json.loads(request.data)['imageName']
    if imageName != "":
        return send_file(os.path.join(os.path.dirname(sys.argv[0]),'uploaded_images',imageName.split('.')[0]+'_predicted.jpg'),attachment_filename=imageName.split('.')[0]+'_predicted.jpg')
    else:
        return jsonify({"status": "failed"})