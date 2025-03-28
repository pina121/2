from flask import Flask, request, render_template, send_file
from rembg import remove
from PIL import Image
import io
import os

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['RESULT_FOLDER'] = 'results'

# Create folders if they don't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['RESULT_FOLDER'], exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/remove-bg', methods=['POST'])
def remove_background():
    if 'image' not in request.files:
        return 'No image uploaded', 400
    
    file = request.files['image']
    if file.filename == '':
        return 'No image selected', 400
    
    # Read the image
    input_image = Image.open(file.stream)
    
    # Remove the background
    output_image = remove(input_image)
    
    # Save the result to a BytesIO object
    img_byte_arr = io.BytesIO()
    output_image.save(img_byte_arr, format='PNG')
    img_byte_arr.seek(0)
    
    # Save the processed image
    result_path = os.path.join(app.config['RESULT_FOLDER'], f"result_{file.filename.split('.')[0]}.png")
    output_image.save(result_path)
    
    # Return the processed image
    return send_file(img_byte_arr, mimetype='image/png', as_attachment=True, 
                    download_name=f"bg_removed_{file.filename.split('.')[0]}.png")

if __name__ == '__main__':
    app.run(debug=True)
