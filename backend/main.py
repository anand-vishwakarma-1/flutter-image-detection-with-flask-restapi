import os,sys
sys.path.append(os.path.dirname(sys.argv[0]))
from flask import Flask,jsonify

import upload as upload
import predict as predict
# import upload as upload

app = Flask(__name__)
app.secret_key = os.urandom(16)
app.register_blueprint(upload.mod)
app.register_blueprint(predict.mod)
@app.route('/')
def home():
    return jsonify({
        "status": "success",
    })

app.run(port=5000,debug=False)

# http://10.0.2.2:5000

# http://127.0.0.1:5000/upload