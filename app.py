from flask import Flask, render_template, request, send_file
from rembg import remove
from PIL import Image
import io

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        # Check if an image file was uploaded
        if "file" not in request.files:
            return "No file part", 400
        file = request.files["file"]
        if file.filename == "":
            return "No selected file", 400
        
        try:
            # Open the uploaded image
            input_image = Image.open(file.stream)
            
            # Remove the background
            output_image = remove(input_image)
            
            # Save the output image to a bytes buffer
            img_io = io.BytesIO()
            output_image.save(img_io, format="PNG")
            img_io.seek(0)
            
            # Return the processed image as a downloadable file
            return send_file(
                img_io,
                mimetype="image/png",
                as_attachment=True,
                download_name="output.png"
            )
        except Exception as e:
            return f"Error processing image: {str(e)}", 500
    
    # Render the upload form for GET requests
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True)
