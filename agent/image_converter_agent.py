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

def convert_image_to_jpeg(input_path: str, output_path: str = None, quality: int = 95):
    """Convert an image file to JPEG format."""
    try:
        # Validate input file exists
        if not os.path.exists(input_path):
            return {"error": f"Input file '{input_path}' does not exist"}
        
        # Generate output path if not provided
        if output_path is None:
            base_name = os.path.splitext(input_path)[0]
            output_path = f"{base_name}.jpg"
        
        # Open and convert the image
        with Image.open(input_path) as img:
            # Convert to RGB (JPEG doesn't support transparency)
            rgb_img = img.convert('RGB')
            rgb_img.save(output_path, 'JPEG', quality=quality)
        
        return {
            "success": True,
            "input_file": input_path,
            "output_file": output_path,
            "quality": quality,
            "message": f"Successfully converted '{input_path}' to JPEG format"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to convert image: {str(e)}"
        }

def resize_image(input_path: str, output_path: str = None, width: int = None, height: int = None, maintain_aspect_ratio: bool = True):
    """Resize an image while optionally maintaining aspect ratio."""
    try:
        # Validate input file exists
        if not os.path.exists(input_path):
            return {"error": f"Input file '{input_path}' does not exist"}
        
        # Validate dimensions
        if width is None and height is None:
            return {"error": "Either width or height must be specified"}
        
        # Generate output path if not provided
        if output_path is None:
            base_name = os.path.splitext(input_path)[0]
            ext = os.path.splitext(input_path)[1]
            output_path = f"{base_name}_resized{ext}"
        
        # Open and resize the image
        with Image.open(input_path) as img:
            if maintain_aspect_ratio:
                img.thumbnail((width or img.width, height or img.height), Image.Resampling.LANCZOS)
                resized_img = img
            else:
                resized_img = img.resize((width or img.width, height or img.height), Image.Resampling.LANCZOS)
            
            resized_img.save(output_path)
        
        return {
            "success": True,
            "input_file": input_path,
            "output_file": output_path,
            "original_size": f"{img.width}x{img.height}",
            "new_size": f"{resized_img.width}x{resized_img.height}",
            "message": f"Successfully resized '{input_path}'"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to resize image: {str(e)}"
        }

def get_image_info(input_path: str):
    """Get detailed information about an image file."""
    try:
        # Validate input file exists
        if not os.path.exists(input_path):
            return {"error": f"Input file '{input_path}' does not exist"}
        
        # Get image information
        with Image.open(input_path) as img:
            file_size = os.path.getsize(input_path)
            
            return {
                "success": True,
                "file_path": input_path,
                "file_size_bytes": file_size,
                "file_size_mb": round(file_size / (1024 * 1024), 2),
                "format": img.format,
                "mode": img.mode,
                "size": f"{img.width}x{img.height}",
                "width": img.width,
                "height": img.height,
                "has_transparency": img.mode in ('RGBA', 'LA', 'P'),
                "message": f"Image information retrieved for '{input_path}'"
            }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to get image info: {str(e)}"
        }

# Create the image converter agent
image_converter_agent = Agent(
    name="image_converter_agent",
    description="A specialized agent for image conversion, resizing, and analysis tasks",
    model="gemini-2.0-flash-exp",
    tools=[convert_image_to_png, convert_image_to_jpeg, resize_image, get_image_info]
)
