import os,sys

from flask import Flask,Blueprint,request,Response,jsonify

mod = Blueprint('upload',__name__)
@mod.route('/upload',methods=['post'])
def upload():
    if 'image' not in request.files:
        return jsonify({"status": "failed","message":"Something went wrong",})
    image = request.files['image']
    if image.filename == '':
        return jsonify({"status": "failed","message":"file name not found ...",})
    else:
        image_path = os.path.join(os.path.dirname(sys.argv[0]),"uploaded_images",image.filename)
        try:
            image.save(image_path)
            return jsonify({"status": "success","message":"image recevied",})
        except:
            return jsonify({"status": "failed","message":"Something went wrong",})