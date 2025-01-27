# app.py (Flask Backend)
from flask import Flask, request, jsonify, redirect
from flask_cors import CORS
from werkzeug.utils import secure_filename
import os
import base64
from io import BytesIO
from PIL import Image
import time
import ana
import json
import os

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

result = 'Hello World' # Initialize a global variable to store the result

def save_image_from_base64(base64_data, filename):
    image_data = base64.b64decode(base64_data)
    image = Image.open(BytesIO(image_data))
    image.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

@app.route('/', methods=['GET', 'POST'])
def home():
    return redirect("/upload-image")
@app.route('/upload-image', methods=['GET', 'POST'])
def upload_image():
    global result  # Use the global variable to track the result

    if request.method == 'GET':
        return jsonify({"result": result})

    if 'image' not in request.json:
        return jsonify({"error": "No image provided"}), 400

    image_data = request.json['image']
    filename = "image_" + str(int(time.time())) + ".png"

    try:
        save_image_from_base64(image_data, filename)
        print(filename)
        # Update the result after processing the image
        path=f'./uploads/{filename}'
        result = ana.analyze_emotion_from_image(path)
        #os.remove(path)
        print(json.dump(result, indent=4))
        os.remove(path)
        return jsonify({"message": "Image uploaded successfully!", "filename": filename, "result": result}), 200
    except Exception as e:  # Reset result on failure
        print(result,type(result))
        result=json.dumps(result)
        print(result,type(result))
        return jsonify({"error": f"Failed to save image: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(debug=True)
