
from flask import Flask, request, jsonify
from agent.parent_agent import get_project_info
from agent.calculations_agent import calculations_agent
from agent.image_converter_agent import convert_image_to_png, image_converter_agent
from agent.parent_agent import parent_agent
from agent.rgb_scanner_agent import rgb_scanner_agent
from google.cloud import vision
import os
from werkzeug.utils import secure_filename
import uuid
import time
from itertools import permutations
import math

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
    # Use the calculations agent for shade percentage
    result = calculations_agent.tools[2](light_value, max_light)  # calculate_shade_percentage
    return jsonify(result)

@app.route('/test-vision', methods=['POST'])
def test_vision():
    try:
        # Get the uploaded image file
        file = request.files['file']
        image_content = file.read()

        # Initialize the Vision API client
        client = vision.ImageAnnotatorClient()

        # Perform image properties detection using Vision API
        image = vision.Image(content=image_content)
        response = client.image_properties(image=image)

        # Extract dominant colors
        colors = response.image_properties_annotation.dominant_colors.colors
        dominant_colors = []
        for color in colors:
            rgb = {
                "r": int(color.color.red),
                "g": int(color.color.green),
                "b": int(color.color.blue),
                "score": color.score,  # Confidence score
                "pixel_fraction": color.pixel_fraction  # Fraction of image pixels with this color
            }
            dominant_colors.append(rgb)

        # Return dominant colors
        return jsonify({"dominant_colors": dominant_colors})
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

def rgb_to_cmyk(r, g, b):
    """Convert RGB to CMYK with adjustments for real-life paint mixing."""
    # Normalize RGB values
    r_prime = r / 255.0
    g_prime = g / 255.0
    b_prime = b / 255.0

    # Calculate K (Black)
    k = 1 - max(r_prime, g_prime, b_prime)

    # Avoid introducing black for vibrant colors
    if k > 0.5 and (r > 100 or g > 100 or b > 100):  # Adjust threshold for bright colors
        k = 0

    if k == 1:
        return {"c": 0, "m": 0, "y": 0, "k": 100}

    # Calculate C, M, Y
    c = (1 - r_prime - k) / (1 - k) if k < 1 else 0
    m = (1 - g_prime - k) / (1 - k) if k < 1 else 0
    y = (1 - b_prime - k) / (1 - k) if k < 1 else 0

    return {"c": round(c * 100), "m": round(m * 100), "y": round(y * 100), "k": round(k * 100)}


@app.route('/rgbToRatio', methods=['POST'])
def rgbToRatio():
    """Calculate paint mixing ratios using the Calculations Agent."""
    try:
        # Get input data
        data = request.json
        target_rgb = data.get("target_rgb")  # Example: { "r": 255, "g": 255, "b": 0 }
        user_colors = data.get("user_colors")  # Example: [ { "r": 255, "g": 0, "b": 0 }, { "r": 0, "g": 255, "b": 0 } ]

        if not target_rgb or not user_colors or len(user_colors) > 3:
            return jsonify({"error": "Invalid input. Provide target_rgb and up to 3 user_colors."}), 400

        # Use the Calculations Agent for paint mixing
        result = calculations_agent.tools[1](target_rgb, user_colors)  # calculate_color_mix_ratios
        
        if result.get('success'):
            return jsonify(result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        print(f"Error: {e}")  # Log the error
        return jsonify({"error": str(e)}), 500

@app.route('/complete-paint-mixing', methods=['POST'])
def complete_paint_mixing():
    """Complete paint mixing pipeline: Image Converter → RGB Scanner → Calculations → Results."""
    try:
        # Check if files are uploaded
        if 'files' not in request.files:
            return jsonify({"error": "No files uploaded"}), 400
        
        files = request.files.getlist('files')
        if not files or files[0].filename == '':
            return jsonify({"error": "No files selected"}), 400
        
        # Get target RGB from form data
        target_rgb_str = request.form.get('target_rgb')
        if not target_rgb_str:
            return jsonify({"error": "target_rgb is required"}), 400
        
        try:
            import json
            target_rgb = json.loads(target_rgb_str)
        except json.JSONDecodeError:
            return jsonify({"error": "Invalid target_rgb format. Use JSON: {\"r\": 128, \"g\": 64, \"b\": 192}"}), 400
        
        # Validate target RGB
        if not all(key in target_rgb for key in ["r", "g", "b"]):
            return jsonify({"error": "target_rgb must contain r, g, b values"}), 400
        
        # Save uploaded files
        image_paths = []
        for file in files:
            if file and allowed_file(file.filename):
                # Generate unique filename
                input_filename = secure_filename(file.filename)
                input_name, input_ext = os.path.splitext(input_filename)
                unique_filename = f"{input_name}_{uuid.uuid4().hex[:8]}{input_ext}"
                file_path = os.path.join(UPLOAD_FOLDER, unique_filename)
                
                file.save(file_path)
                image_paths.append(file_path)
        
        if not image_paths:
            return jsonify({"error": "No valid image files uploaded"}), 400
        
        # Use the complete paint mixing pipeline
        result = parent_agent.tools[3](image_paths, target_rgb)  # process_complete_paint_mixing_pipeline
        
        # Clean up uploaded files
        for path in image_paths:
            if os.path.exists(path):
                os.remove(path)
        
        if result.get('success'):
            return jsonify(result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        # Clean up files on error
        if 'image_paths' in locals():
            for path in image_paths:
                if os.path.exists(path):
                    os.remove(path)
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

def suggest_additional_colors(target_rgb, user_colors):
    """Suggest additional colors needed to achieve the target color."""
    suggestions = []
    
    # Analyze what's missing
    target_r, target_g, target_b = target_rgb["r"], target_rgb["g"], target_rgb["b"]
    
    # Get current color ranges
    min_r = min(color["r"] for color in user_colors)
    max_r = max(color["r"] for color in user_colors)
    min_g = min(color["g"] for color in user_colors)
    max_g = max(color["g"] for color in user_colors)
    min_b = min(color["b"] for color in user_colors)
    max_b = max(color["b"] for color in user_colors)
    
    # Check what's missing
    if target_r < min_r:
        suggestions.append({
            "color": "red",
            "rgb": {"r": 0, "g": 0, "b": 0},
            "reason": f"Need lower red values (target: {target_r}, available: {min_r}-{max_r})"
        })
    if target_r > max_r:
        suggestions.append({
            "color": "red",
            "rgb": {"r": 255, "g": 0, "b": 0},
            "reason": f"Need higher red values (target: {target_r}, available: {min_r}-{max_r})"
        })
    
    if target_g < min_g:
        suggestions.append({
            "color": "green", 
            "rgb": {"r": 0, "g": 0, "b": 0},
            "reason": f"Need lower green values (target: {target_g}, available: {min_g}-{max_g})"
        })
    if target_g > max_g:
        suggestions.append({
            "color": "green",
            "rgb": {"r": 0, "g": 255, "b": 0},
            "reason": f"Need higher green values (target: {target_g}, available: {min_g}-{max_g})"
        })
        
    if target_b < min_b:
        suggestions.append({
            "color": "blue",
            "rgb": {"r": 0, "g": 0, "b": 0},
            "reason": f"Need lower blue values (target: {target_b}, available: {min_b}-{max_b})"
        })
    if target_b > max_b:
        suggestions.append({
            "color": "blue",
            "rgb": {"r": 0, "g": 0, "b": 255},
            "reason": f"Need higher blue values (target: {target_b}, available: {min_b}-{max_b})"
        })
    
    return suggestions

@app.route('/rgb-paint-mixing', methods=['POST'])
def rgb_paint_mixing():
    """Direct RGB paint mixing pipeline: RGB values → Calculations → Results (no images needed)."""
    try:
        # Get JSON data from request
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        # Extract user colors and target RGB
        user_colors = data.get("user_colors")  # List of RGB objects
        target_rgb = data.get("target_rgb")  # Target color RGB object
        
        # Validate input
        if not target_rgb or not user_colors or len(user_colors) > 3:
            return jsonify({"error": "Invalid input. Provide target_rgb and up to 3 user_colors."}), 400
        
        # Validate target RGB structure
        if not all(key in target_rgb for key in ["r", "g", "b"]):
            return jsonify({"error": "target_rgb must contain r, g, b values"}), 400
        
        # Validate user colors structure
        for i, color in enumerate(user_colors):
            if not all(key in color for key in ["r", "g", "b"]):
                return jsonify({"error": f"user_colors[{i}] must contain r, g, b values"}), 400
        
        # Use the Calculations Agent directly for RGB mixing
        result = calculations_agent.tools[1](target_rgb, user_colors)  # calculate_color_mix_ratios
        
        if result.get('success'):
            # Check if the result is close enough to be practical
            distance = result["closest_match"]["distance"]
            accuracy_threshold = 50  # Adjustable threshold
            
            # Add color suggestions if accuracy is poor
            color_suggestions = []
            if distance > accuracy_threshold:
                color_suggestions = suggest_additional_colors(target_rgb, user_colors)
            
            # Add additional metadata for consistency with complete pipeline
            enhanced_result = {
                "success": True,
                "message": "Successfully calculated RGB paint mixing ratios",
                "target_rgb": result["target_rgb"],
                "target_cmyk": result["target_cmyk"],
                "user_colors": user_colors,
                "user_colors_count": len(user_colors),
                "closest_match": result["closest_match"],
                "pipeline_type": "rgb_direct",
                "accuracy_analysis": {
                    "distance": distance,
                    "is_achievable": distance <= accuracy_threshold,
                    "accuracy_level": "Excellent" if distance <= 10 else "Good" if distance <= 30 else "Fair" if distance <= 50 else "Poor"
                },
                "color_suggestions": color_suggestions,
                "processing_steps": [
                    {
                        "step": 1,
                        "agent": "calculations_agent",
                        "action": "calculate_color_mix_ratios",
                        "input": {"target_rgb": target_rgb, "user_colors": user_colors}
                    }
                ]
            }
            return jsonify(enhanced_result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        print(f"Error: {e}")  # Log the error
        return jsonify({"error": str(e)}), 500

@app.route('/rgb-to-cmyk', methods=['POST'])
def rgb_to_cmyk_endpoint():
    """Convert RGB to CMYK using the Calculations Agent."""
    try:
        data = request.json
        r = data.get("r")
        g = data.get("g")
        b = data.get("b")
        
        if r is None or g is None or b is None:
            return jsonify({"error": "r, g, b values are required"}), 400
        
        # Use the Calculations Agent
        result = calculations_agent.tools[0](r, g, b)  # rgb_to_cmyk
        
        if result.get('success'):
            return jsonify(result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/scan-rgb-from-images', methods=['POST'])
def scan_rgb_from_images():
    """Scan RGB values from multiple images using the RGB Scanner Agent."""
    try:
        # Check if files are uploaded
        if 'files' not in request.files:
            return jsonify({"error": "No files uploaded"}), 400
        
        files = request.files.getlist('files')
        if not files or files[0].filename == '':
            return jsonify({"error": "No files selected"}), 400
        
        # Save uploaded files
        image_paths = []
        for file in files:
            if file and allowed_file(file.filename):
                # Generate unique filename
                input_filename = secure_filename(file.filename)
                input_name, input_ext = os.path.splitext(input_filename)
                unique_filename = f"{input_name}_{uuid.uuid4().hex[:8]}{input_ext}"
                file_path = os.path.join(UPLOAD_FOLDER, unique_filename)
                
                file.save(file_path)
                image_paths.append(file_path)
        
        if not image_paths:
            return jsonify({"error": "No valid image files uploaded"}), 400
        
        # Use the RGB Scanner Agent
        result = rgb_scanner_agent.tools[1](image_paths)  # scan_rgb_from_multiple_images
        
        # Clean up uploaded files
        for path in image_paths:
            if os.path.exists(path):
                os.remove(path)
        
        if result.get('success'):
            return jsonify(result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        # Clean up files on error
        if 'image_paths' in locals():
            for path in image_paths:
                if os.path.exists(path):
                    os.remove(path)
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/convert-multiple-images', methods=['POST'])
def convert_multiple_images():
    """Convert multiple images to PNG using the Image Converter Agent."""
    try:
        # Check if files are uploaded
        if 'files' not in request.files:
            return jsonify({"error": "No files uploaded"}), 400
        
        files = request.files.getlist('files')
        if not files or files[0].filename == '':
            return jsonify({"error": "No files selected"}), 400
        
        # Save uploaded files
        image_paths = []
        for file in files:
            if file and allowed_file(file.filename):
                # Generate unique filename
                input_filename = secure_filename(file.filename)
                input_name, input_ext = os.path.splitext(input_filename)
                unique_filename = f"{input_name}_{uuid.uuid4().hex[:8]}{input_ext}"
                file_path = os.path.join(UPLOAD_FOLDER, unique_filename)
                
                file.save(file_path)
                image_paths.append(file_path)
        
        if not image_paths:
            return jsonify({"error": "No valid image files uploaded"}), 400
        
        # Use the Image Converter Agent
        result = image_converter_agent.tools[4](image_paths)  # convert_multiple_images_to_png
        
        # Clean up uploaded files
        for path in image_paths:
            if os.path.exists(path):
                os.remove(path)
        
        if result.get('success'):
            return jsonify(result)
        else:
            return jsonify(result), 400
            
    except Exception as e:
        # Clean up files on error
        if 'image_paths' in locals():
            for path in image_paths:
                if os.path.exists(path):
                    os.remove(path)
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/pipeline-status', methods=['GET'])
def pipeline_status():
    """Get the status of all pipeline components."""
    try:
        status = {
            "success": True,
            "pipeline_components": {
                "image_converter_agent": {
                    "status": "active",
                    "tools": len(image_converter_agent.tools),
                    "description": "Converts images to PNG format"
                },
                "rgb_scanner_agent": {
                    "status": "active", 
                    "tools": len(rgb_scanner_agent.tools),
                    "description": "Extracts RGB values using Google Cloud Vision"
                },
                "calculations_agent": {
                    "status": "active",
                    "tools": len(calculations_agent.tools),
                    "description": "Performs color calculations and paint mixing"
                },
                "parent_agent": {
                    "status": "active",
                    "tools": len(parent_agent.tools),
                    "description": "Orchestrates the complete pipeline"
                }
            },
            "available_endpoints": [
                "/complete-paint-mixing",
                "/rgb-paint-mixing",
                "/rgb-to-cmyk", 
                "/scan-rgb-from-images",
                "/convert-multiple-images",
                "/rgbToRatio",
                "/convert-to-png",
                "/test-vision"
            ],
            "message": "All pipeline components are operational"
        }
        
        return jsonify(status)
        
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
