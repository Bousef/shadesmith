from google.adk.agents import Agent
from PIL import Image
import os

def convert_image_to_png(input_path: str, output_path: str = None):
    """Convert an image file to PNG format."""
    try:
        # Validate input file exists
        if not os.path.exists(input_path):
            return {"error": f"Input file '{input_path}' does not exist"}
        
        # Generate output path if not provided
        if output_path is None:
            base_name = os.path.splitext(input_path)[0]
            output_path = f"{base_name}.png"
        
        # Open and convert the image
        with Image.open(input_path) as img:
            # Convert to RGB if necessary (for formats like RGBA, P, etc.)
            if img.mode in ('RGBA', 'LA', 'P'):
                # Keep transparency for RGBA and LA modes
                img.save(output_path, 'PNG')
            else:
                # Convert to RGB for other modes
                rgb_img = img.convert('RGB')
                rgb_img.save(output_path, 'PNG')
        
        return {
            "success": True,
            "input_file": input_path,
            "output_file": output_path,
            "message": f"Successfully converted '{input_path}' to PNG format"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to convert image: {str(e)}"
        }




def convert_multiple_images_to_png(image_paths: list, output_dir: str = None):
    """Convert up to 3 images to PNG format for color analysis."""
    try:
        # Validate input
        if not image_paths or len(image_paths) == 0:
            return {"error": "No image paths provided"}
        
        if len(image_paths) > 3:
            return {"error": "Maximum 3 images allowed for color analysis"}
        
        # Set default output directory
        if output_dir is None:
            output_dir = "uploads"
        
        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)
        
        converted_files = []
        errors = []
        
        for i, input_path in enumerate(image_paths):
            try:
                # Validate input file exists
                if not os.path.exists(input_path):
                    errors.append(f"File '{input_path}' does not exist")
                    continue
                
                # Generate output filename
                base_name = os.path.splitext(os.path.basename(input_path))[0]
                output_filename = f"color_{i+1}_{base_name}.png"
                output_path = os.path.join(output_dir, output_filename)
                
                # Convert to PNG
                with Image.open(input_path) as img:
                    # Convert to RGB if necessary
                    if img.mode in ('RGBA', 'LA', 'P'):
                        img.save(output_path, 'PNG')
                    else:
                        rgb_img = img.convert('RGB')
                        rgb_img.save(output_path, 'PNG')
                
                converted_files.append({
                    "index": i + 1,
                    "input_file": input_path,
                    "output_file": output_path,
                    "output_filename": output_filename,
                    "success": True
                })
                
            except Exception as e:
                errors.append(f"Failed to convert '{input_path}': {str(e)}")
        
        return {
            "success": len(converted_files) > 0,
            "converted_files": converted_files,
            "total_converted": len(converted_files),
            "errors": errors,
            "message": f"Successfully converted {len(converted_files)} out of {len(image_paths)} images"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to convert multiple images: {str(e)}"
        }


# Create the image converter agent
image_converter_agent = Agent(
    name="image_converter_agent",
    description="A specialized agent for image conversion, resizing, and analysis tasks. Handles up to 3 images for color analysis.",
    model="gemini-2.0-flash-exp",
    tools=[
        convert_image_to_png, 
        convert_multiple_images_to_png
    ]
)
