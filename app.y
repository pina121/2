import os
import io
from flask import Flask, request, render_template, send_file, jsonify
from PIL import Image
from rembg import remove
import uuid

app = Flask(__name__)

# Create uploads directory if it doesn't exist
UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/remove-bg', methods=['POST'])
def remove_background():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file:
        try:
            # Read the image
            input_image = Image.open(file.stream)
            
            # Process the image with rembg
            output_image = remove(input_image)
            
            # Save the processed image with a unique filename
            filename = f"{uuid.uuid4()}.png"
            output_path = os.path.join(UPLOAD_FOLDER, filename)
            output_image.save(output_path)
            
            return jsonify({'filename': filename}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500

@app.route('/download/<filename>')
def download_file(filename):
    try:
        return send_file(os.path.join(UPLOAD_FOLDER, filename), as_attachment=True)
    except Exception as e:
        return jsonify({'error': str(e)}), 404

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
