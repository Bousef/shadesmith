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

def process_user_color_images(image_paths: list, output_dir: str = None):
    """Process up to 3 user color images for paint mixing analysis."""
    try:
        # Validate input
        if not image_paths or len(image_paths) == 0:
            return {"error": "No image paths provided"}
        
        if len(image_paths) > 3:
            return {"error": "Maximum 3 color images allowed for paint mixing"}
        
        # Set default output directory
        if output_dir is None:
            output_dir = "uploads"
        
        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)
        
        processed_images = []
        
        for i, input_path in enumerate(image_paths):
            try:
                # Validate input file exists
                if not os.path.exists(input_path):
                    processed_images.append({
                        "index": i + 1,
                        "input_file": input_path,
                        "success": False,
                        "error": "File does not exist"
                    })
                    continue
                
                # Generate output filename
                base_name = os.path.splitext(os.path.basename(input_path))[0]
                output_filename = f"user_color_{i+1}_{base_name}.png"
                output_path = os.path.join(output_dir, output_filename)
                
                # Convert and optimize for color analysis
                with Image.open(input_path) as img:
                    # Convert to RGB for consistent color analysis
                    rgb_img = img.convert('RGB')
                    
                    # Resize if too large (for faster processing)
                    if rgb_img.width > 1000 or rgb_img.height > 1000:
                        rgb_img.thumbnail((1000, 1000), Image.Resampling.LANCZOS)
                    
                    # Save as PNG
                    rgb_img.save(output_path, 'PNG')
                
                # Get image info
                file_size = os.path.getsize(output_path)
                
                processed_images.append({
                    "index": i + 1,
                    "input_file": input_path,
                    "output_file": output_path,
                    "output_filename": output_filename,
                    "width": rgb_img.width,
                    "height": rgb_img.height,
                    "file_size_bytes": file_size,
                    "success": True
                })
                
            except Exception as e:
                processed_images.append({
                    "index": i + 1,
                    "input_file": input_path,
                    "success": False,
                    "error": str(e)
                })
        
        successful_conversions = [img for img in processed_images if img.get("success")]
        
        return {
            "success": len(successful_conversions) > 0,
            "processed_images": processed_images,
            "successful_conversions": len(successful_conversions),
            "total_images": len(image_paths),
            "output_directory": output_dir,
            "message": f"Processed {len(successful_conversions)} out of {len(image_paths)} user color images"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to process user color images: {str(e)}"
        }

# Create the image converter agent
image_converter_agent = Agent(
    name="image_converter_agent",
    description="A specialized agent for image conversion, resizing, and analysis tasks. Handles up to 3 images for color analysis.",
    model="gemini-2.0-flash-exp",
    tools=[
        convert_image_to_png, 
        convert_image_to_jpeg, 
        resize_image, 
        get_image_info,
        convert_multiple_images_to_png,
        process_user_color_images
    ]
)
