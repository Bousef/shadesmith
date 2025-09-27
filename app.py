
from flask import Flask, request, jsonify
from agent.agent import get_project_info, calculate_shade_percentage
from agent.image_converter_agent import convert_image_to_png
from google.cloud import vision
import os
from werkzeug.utils import secure_filename
import uuid
import time

app = Flask(__name__)

# Configuration for file uploads
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'tiff', 'webp'}

# Create uploads directory if it doesn't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def cleanup_old_files():
    """Remove files older than 1 hour from uploads folder."""
    try:
        current_time = time.time()
        for filename in os.listdir(UPLOAD_FOLDER):
            file_path = os.path.join(UPLOAD_FOLDER, filename)
            if os.path.isfile(file_path):
                file_age = current_time - os.path.getmtime(file_path)
                if file_age > 3600:  # 1 hour in seconds
                    os.remove(file_path)
                    print(f"Cleaned up old file: {filename}")
    except Exception as e:
        print(f"Error during cleanup: {e}")

@app.route("/", methods=["GET"])
def home():
    return "Welcome to the Shadesmith Agent!"

@app.route("/project-info", methods=["GET"])
def project_info():
    return jsonify(get_project_info())

@app.route("/shade-percentage", methods=["POST"])
def shade_percentage():
    data = request.json
    print(f"Received data: {data}")  # Debug log
    light_value = data.get("light_value", 0)
    max_light = data.get("max_light", 100.0)
    return jsonify(calculate_shade_percentage(light_value, max_light))

@app.route('/test-vision', methods=['GET'])
def test_vision():
    try:
        # Set the service account key file path
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'keys/cloudvision.json'
        client = vision.ImageAnnotatorClient()

        with open("test-image.png", "rb") as image_file:
            content = image_file.read()

        image = vision.Image(content=content)
        response = client.label_detection(image=image)

        labels = [label.description for label in response.label_annotations]
        return jsonify(labels)
    except Exception as e:
        print(f"Error: {e}")  # Log the error
        return jsonify({"error": str(e)}), 500

@app.route('/convert-to-png', methods=['POST'])
def convert_to_png():
    """Convert an uploaded image file to PNG format."""
    # Debug: Print request info
    print(f"Content-Type: {request.content_type}")
    print(f"Files: {list(request.files.keys())}")
    
    # Check if file is uploaded
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400
    
    file = request.files['file']
    
    # Check if file is selected
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400
    
    # Check if file type is allowed
    if not allowed_file(file.filename):
        return jsonify({"error": f"File type not allowed. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"}), 400
    
    try:
        # Generate unique filename for input
        input_filename = secure_filename(file.filename)
        input_name, input_ext = os.path.splitext(input_filename)
        unique_input_filename = f"{input_name}_{uuid.uuid4().hex[:8]}{input_ext}"
        input_path = os.path.join(UPLOAD_FOLDER, unique_input_filename)
        
        # Save uploaded file
        file.save(input_path)
        
        # Generate output path
        output_filename = f"{input_name}_{uuid.uuid4().hex[:8]}.png"
        output_path = os.path.join(UPLOAD_FOLDER, output_filename)
        
        # Convert to PNG using agent function
        try:
            # Use the agent function directly
            result = convert_image_to_png(input_path, output_path)
            
            print(f"Conversion result: {result}")
            
            if result.get('success'):
                result['message'] = f"Successfully converted '{input_path}' to PNG format using agent function"
                result['agent_response'] = "Used agent function directly"
            else:
                result['agent_response'] = "Agent function returned error"
                
        except Exception as agent_error:
            result = {
                "success": False,
                "error": f"Agent function error: {str(agent_error)}"
            }
        
        # Clean up input file
        if os.path.exists(input_path):
            os.remove(input_path)
        
        if result.get('success'):
            # Return the converted file info
            return jsonify({
                "success": True,
                "message": "Image successfully converted to PNG",
                "output_filename": output_filename,
                "download_url": f"/download/{output_filename}"
            })
        else:
            return jsonify(result), 400
            
    except Exception as e:
        # Clean up input file if it exists
        if 'input_path' in locals() and os.path.exists(input_path):
            os.remove(input_path)
        return jsonify({"error": f"Conversion failed: {str(e)}"}), 500

@app.route('/download/<filename>', methods=['GET'])
def download_file(filename):
    """Download converted PNG file."""
    try:
        # Security check - ensure filename is safe
        if not filename or '..' in filename or '/' in filename:
            return jsonify({"error": "Invalid filename"}), 400
            
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        
        if os.path.exists(file_path):
            from flask import send_file
            return send_file(file_path, as_attachment=True, download_name=filename)
        else:
            # List available files for debugging
            available_files = [f for f in os.listdir(UPLOAD_FOLDER) if f.endswith('.png')]
            return jsonify({
                "error": f"File '{filename}' not found",
                "available_files": available_files,
                "hint": "Make sure you're using the exact filename returned from the conversion API"
            }), 404
    except Exception as e:
        return jsonify({"error": f"Download failed: {str(e)}"}), 500

@app.route('/list-files', methods=['GET'])
def list_files():
    """List all available converted PNG files."""
    try:
        files = []
        for filename in os.listdir(UPLOAD_FOLDER):
            if filename.endswith('.png'):
                file_path = os.path.join(UPLOAD_FOLDER, filename)
                file_size = os.path.getsize(file_path)
                file_mtime = os.path.getmtime(file_path)
                files.append({
                    "filename": filename,
                    "size_bytes": file_size,
                    "size_mb": round(file_size / (1024 * 1024), 2),
                    "created": time.ctime(file_mtime),
                    "download_url": f"/download/{filename}"
                })
        
        return jsonify({
            "success": True,
            "files": files,
            "count": len(files)
        })
    except Exception as e:
        return jsonify({"error": f"Failed to list files: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
