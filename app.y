import os
from io import BytesIO
from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
from rembg import remove
from werkzeug.utils import secure_filename

# Initialize Flask app
app = Flask(__name__)

# Configure CORS to allow requests from GitHub Pages
CORS(app, resources={
    r"/remove-bg": {
        "origins": [
            "https://yourusername.github.io",  # Your GitHub Pages URL
            "http://localhost:8000"            # For local testing
        ],
        "methods": ["POST"],
        "allow_headers": ["Content-Type"]
    }
})

# Configuration
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024  # 10MB limit

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/remove-bg', methods=['POST'])
def remove_background():
    # Check if file exists in request
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400
    
    file = request.files['file']
    
    # Validate file
    if file.filename == '':
        return jsonify({'error': 'Empty filename'}), 400
    if not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type'}), 400
    
    try:
        # Process image
        input_image = file.read()
        output_image = remove(input_image)
        
        # Return the processed image
        return send_file(
            BytesIO(output_image),
            mimetype='image/png',
            as_attachment=True,
            download_name='no-bg.png'
        )
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/')
def home():
    return jsonify({'status': 'Server is running'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
