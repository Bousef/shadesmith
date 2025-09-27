from google.adk.agents import Agent
from google.cloud import vision
import os

def scan_rgb_from_image(image_path: str):
    """Scan RGB values from an image using Google Cloud Vision API."""
    try:
        # Validate input file exists
        if not os.path.exists(image_path):
            return {"error": f"Image file '{image_path}' does not exist"}
        
        # Initialize the Vision API client
        client = vision.ImageAnnotatorClient()
        
        # Read the image file
        with open(image_path, 'rb') as image_file:
            content = image_file.read()
        
        # Perform image properties detection using Vision API
        image = vision.Image(content=content)
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
        
        # Get the most dominant color
        primary_color = dominant_colors[0] if dominant_colors else None
        
        return {
            "success": True,
            "image_path": image_path,
            "primary_rgb": primary_color,
            "all_colors": dominant_colors,
            "color_count": len(dominant_colors),
            "message": f"Successfully scanned RGB values from '{image_path}'"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to scan RGB values: {str(e)}"
        }

def scan_rgb_from_multiple_images(image_paths: list):
    """Scan RGB values from multiple images using Google Cloud Vision API."""
    try:
        # Validate input
        if not image_paths or len(image_paths) == 0:
            return {"error": "No image paths provided"}
        
        if len(image_paths) > 3:
            return {"error": "Maximum 3 images allowed for RGB scanning"}
        
        # Initialize the Vision API client
        client = vision.ImageAnnotatorClient()
        
        scanned_results = []
        errors = []
        
        for i, image_path in enumerate(image_paths):
            try:
                # Validate input file exists
                if not os.path.exists(image_path):
                    errors.append(f"Image file '{image_path}' does not exist")
                    continue
                
                # Read the image file
                with open(image_path, 'rb') as image_file:
                    content = image_file.read()
                
                # Perform image properties detection using Vision API
                image = vision.Image(content=content)
                response = client.image_properties(image=image)
                
                # Extract dominant colors
                colors = response.image_properties_annotation.dominant_colors.colors
                dominant_colors = []
                
                for color in colors:
                    rgb = {
                        "r": int(color.color.red),
                        "g": int(color.color.green),
                        "b": int(color.color.blue),
                        "score": color.score,
                        "pixel_fraction": color.pixel_fraction
                    }
                    dominant_colors.append(rgb)
                
                # Get the most dominant color
                primary_color = dominant_colors[0] if dominant_colors else None
                
                scanned_results.append({
                    "index": i + 1,
                    "image_path": image_path,
                    "primary_rgb": primary_color,
                    "all_colors": dominant_colors,
                    "color_count": len(dominant_colors),
                    "success": True
                })
                
            except Exception as e:
                errors.append(f"Failed to scan '{image_path}': {str(e)}")
        
        return {
            "success": len(scanned_results) > 0,
            "scanned_results": scanned_results,
            "total_scanned": len(scanned_results),
            "errors": errors,
            "message": f"Successfully scanned RGB values from {len(scanned_results)} out of {len(image_paths)} images"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to scan RGB values from multiple images: {str(e)}"
        }

def scan_rgb_from_converter_results(converter_results: dict):
    """Scan RGB values from Image Converter Agent results."""
    try:
        # Validate input
        if not converter_results or not isinstance(converter_results, dict):
            return {"error": "Invalid converter results provided"}
        
        # Extract image paths from converter results
        image_paths = []
        
        # Handle different result formats from Image Converter Agent
        if "converted_files" in converter_results:
            # From convert_multiple_images_to_png
            for file_info in converter_results["converted_files"]:
                if file_info.get("success") and "output_file" in file_info:
                    image_paths.append(file_info["output_file"])
        
        elif "processed_images" in converter_results:
            # From process_user_color_images
            for img_info in converter_results["processed_images"]:
                if img_info.get("success") and "output_file" in img_info:
                    image_paths.append(img_info["output_file"])
        
        elif "output_file" in converter_results:
            # Single image result
            if converter_results.get("success"):
                image_paths.append(converter_results["output_file"])
        
        else:
            return {"error": "No valid image paths found in converter results"}
        
        if not image_paths:
            return {"error": "No successfully converted images found to scan"}
        
        # Scan RGB values from the extracted image paths
        return scan_rgb_from_multiple_images(image_paths)
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to scan RGB from converter results: {str(e)}"
        }

def extract_primary_rgb_values(scanned_results: dict):
    """Extract primary RGB values from scanned results for paint mixing."""
    try:
        # Validate input
        if not scanned_results or not isinstance(scanned_results, dict):
            return {"error": "Invalid scanned results provided"}
        
        primary_rgb_values = []
        
        # Handle different result formats
        if "scanned_results" in scanned_results:
            # From scan_rgb_from_multiple_images
            for result in scanned_results["scanned_results"]:
                if result.get("success") and result.get("primary_rgb"):
                    primary_rgb_values.append({
                        "index": result["index"],
                        "image_path": result["image_path"],
                        "rgb": result["primary_rgb"]
                    })
        
        elif "primary_rgb" in scanned_results:
            # Single image result
            if scanned_results.get("success"):
                primary_rgb_values.append({
                    "index": 1,
                    "image_path": scanned_results["image_path"],
                    "rgb": scanned_results["primary_rgb"]
                })
        
        else:
            return {"error": "No valid RGB values found in scanned results"}
        
        return {
            "success": len(primary_rgb_values) > 0,
            "primary_rgb_values": primary_rgb_values,
            "count": len(primary_rgb_values),
            "message": f"Extracted {len(primary_rgb_values)} primary RGB values"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to extract primary RGB values: {str(e)}"
        }

# Create the RGB scanner agent
rgb_scanner_agent = Agent(
    name="rgb_scanner_agent",
    description="Specialized agent for scanning RGB values from images using Google Cloud Vision. Can process multiple images and extract RGB values from Image Converter Agent results.",
    model="gemini-2.0-flash-exp",
    tools=[
        scan_rgb_from_image,
        scan_rgb_from_multiple_images,
        scan_rgb_from_converter_results,
        extract_primary_rgb_values
    ]
)