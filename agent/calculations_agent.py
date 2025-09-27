from google.adk.agents import Agent
import math
from itertools import permutations

def rgb_to_cmyk(r: int, g: int, b: int):
    """Convert RGB values to CMYK with adjustments for real-life paint mixing."""
    try:
        # Validate input values
        if not all(0 <= val <= 255 for val in [r, g, b]):
            return {"error": "RGB values must be between 0 and 255"}
        
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
            return {
                "success": True,
                "rgb": {"r": r, "g": g, "b": b},
                "cmyk": {"c": 0, "m": 0, "y": 0, "k": 100},
                "message": "Pure black color detected"
            }

        # Calculate C, M, Y
        c = (1 - r_prime - k) / (1 - k) if k < 1 else 0
        m = (1 - g_prime - k) / (1 - k) if k < 1 else 0
        y = (1 - b_prime - k) / (1 - k) if k < 1 else 0

        return {
            "success": True,
            "rgb": {"r": r, "g": g, "b": b},
            "cmyk": {
                "c": round(c * 100, 2),
                "m": round(m * 100, 2),
                "y": round(y * 100, 2),
                "k": round(k * 100, 2)
            },
            "message": f"Successfully converted RGB({r}, {g}, {b}) to CMYK"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to convert RGB to CMYK: {str(e)}"
        }

def calculate_color_mix_ratios(target_rgb: dict, user_colors: list):
    """Calculate the best ratios to mix user colors to achieve target RGB."""
    try:
        if not target_rgb or not user_colors or len(user_colors) > 3:
            return {"error": "Invalid input. Provide target_rgb and up to 3 user_colors."}
        
        target_r, target_g, target_b = target_rgb["r"], target_rgb["g"], target_rgb["b"]
        
        # Generate permutations of ratios
        ratios = [0.1 * i for i in range(11)]  # 0.0 to 1.0 in steps of 0.1
        permutations_of_ratios = [p for p in permutations(ratios, len(user_colors)) if abs(sum(p) - 1.0) < 0.01]
        
        closest_match = None
        min_distance = float("inf")
        
        # Find best ratio combination
        for ratio_set in permutations_of_ratios:
            mixed_r = sum(user_colors[i]["r"] * ratio_set[i] for i in range(len(user_colors)))
            mixed_g = sum(user_colors[i]["g"] * ratio_set[i] for i in range(len(user_colors)))
            mixed_b = sum(user_colors[i]["b"] * ratio_set[i] for i in range(len(user_colors)))
            
            # Calculate distance to target
            distance = math.sqrt((mixed_r - target_r) ** 2 + (mixed_g - target_g) ** 2 + (mixed_b - target_b) ** 2)
            
            if distance < min_distance:
                min_distance = distance
                closest_match = {
                    "ratios": ratio_set,
                    "mixed_rgb": {"r": int(mixed_r), "g": int(mixed_g), "b": int(mixed_b)},
                    "distance": distance
                }
        
        # Convert to CMYK
        target_cmyk = rgb_to_cmyk(target_r, target_g, target_b)
        mixed_cmyk = rgb_to_cmyk(closest_match["mixed_rgb"]["r"], closest_match["mixed_rgb"]["g"], closest_match["mixed_rgb"]["b"])
        
        return {
            "success": True,
            "target_rgb": target_rgb,
            "target_cmyk": target_cmyk["cmyk"],
            "closest_match": {
                "ratios": closest_match["ratios"],
                "mixed_rgb": closest_match["mixed_rgb"],
                "mixed_cmyk": mixed_cmyk["cmyk"],
                "distance": closest_match["distance"]
            },
            "message": "Successfully calculated color mixing ratios"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to calculate color mix ratios: {str(e)}"
        }

def calculate_shade_percentage(light_value: float, max_light: float = 100.0):
    """Calculate shade percentage based on light value."""
    try:
        if max_light <= 0:
            return {"error": "max_light must be greater than 0"}
        
        if light_value < 0 or light_value > max_light:
            return {"error": "Light value must be between 0 and max_light"}
        
        shade_percentage = ((max_light - light_value) / max_light) * 100
        return {
            "success": True,
            "light_value": light_value,
            "max_light": max_light,
            "shade_percentage": round(shade_percentage, 2),
            "interpretation": "High shade" if shade_percentage > 70 else "Medium shade" if shade_percentage > 30 else "Low shade",
            "message": f"Calculated shade percentage: {round(shade_percentage, 2)}%"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to calculate shade percentage: {str(e)}"
        }

def calculate_color_distance(rgb1: dict, rgb2: dict):
    """Calculate the Euclidean distance between two RGB colors."""
    try:
        if not all(key in rgb1 for key in ["r", "g", "b"]):
            return {"error": "rgb1 must contain r, g, b values"}
        if not all(key in rgb2 for key in ["r", "g", "b"]):
            return {"error": "rgb2 must contain r, g, b values"}
        
        distance = math.sqrt(
            (rgb1["r"] - rgb2["r"]) ** 2 + 
            (rgb1["g"] - rgb2["g"]) ** 2 + 
            (rgb1["b"] - rgb2["b"]) ** 2
        )
        
        return {
            "success": True,
            "rgb1": rgb1,
            "rgb2": rgb2,
            "distance": round(distance, 2),
            "normalized_distance": round(distance / 441.67, 4),  # Normalized to 0-1 scale
            "message": f"Color distance: {round(distance, 2)}"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to calculate color distance: {str(e)}"
        }

def calculate_color_brightness(rgb: dict):
    """Calculate the brightness of an RGB color."""
    try:
        if not all(key in rgb for key in ["r", "g", "b"]):
            return {"error": "RGB must contain r, g, b values"}
        
        # Using the standard luminance formula
        brightness = 0.299 * rgb["r"] + 0.587 * rgb["g"] + 0.114 * rgb["b"]
        
        return {
            "success": True,
            "rgb": rgb,
            "brightness": round(brightness, 2),
            "brightness_percentage": round((brightness / 255) * 100, 2),
            "interpretation": "Very bright" if brightness > 200 else "Bright" if brightness > 150 else "Medium" if brightness > 100 else "Dark" if brightness > 50 else "Very dark",
            "message": f"Color brightness: {round(brightness, 2)}"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to calculate color brightness: {str(e)}"
        }

def process_rgb_scanner_results(rgb_scanner_results: dict, target_rgb: dict):
    """Process RGB Scanner Agent results and calculate paint mixing ratios for target color."""
    try:
        # Validate inputs
        if not rgb_scanner_results or not isinstance(rgb_scanner_results, dict):
            return {"error": "Invalid RGB scanner results provided"}
        
        if not target_rgb or not isinstance(target_rgb, dict):
            return {"error": "Invalid target RGB provided"}
        
        if not all(key in target_rgb for key in ["r", "g", "b"]):
            return {"error": "Target RGB must contain r, g, b values"}
        
        # Extract user colors from RGB scanner results
        user_colors = []
        
        # Handle different result formats from RGB Scanner Agent
        if "primary_rgb_values" in rgb_scanner_results:
            # From extract_primary_rgb_values
            for rgb_info in rgb_scanner_results["primary_rgb_values"]:
                if rgb_info.get("rgb"):
                    user_colors.append(rgb_info["rgb"])
        
        elif "scanned_results" in rgb_scanner_results:
            # From scan_rgb_from_multiple_images
            for result in rgb_scanner_results["scanned_results"]:
                if result.get("success") and result.get("primary_rgb"):
                    user_colors.append(result["primary_rgb"])
        
        elif "primary_rgb" in rgb_scanner_results:
            # Single image result
            if rgb_scanner_results.get("success"):
                user_colors.append(rgb_scanner_results["primary_rgb"])
        
        else:
            return {"error": "No valid RGB values found in scanner results"}
        
        if not user_colors:
            return {"error": "No user colors extracted from scanner results"}
        
        if len(user_colors) > 3:
            return {"error": "Maximum 3 user colors allowed for paint mixing"}
        
        # Calculate color mixing ratios
        mix_result = calculate_color_mix_ratios(target_rgb, user_colors)
        
        if not mix_result.get("success"):
            return mix_result
        
        # Convert target and mixed colors to CMYK
        target_cmyk = rgb_to_cmyk(target_rgb["r"], target_rgb["g"], target_rgb["b"])
        mixed_cmyk = rgb_to_cmyk(
            mix_result["closest_match"]["mixed_rgb"]["r"],
            mix_result["closest_match"]["mixed_rgb"]["g"],
            mix_result["closest_match"]["mixed_rgb"]["b"]
        )
        
        return {
            "success": True,
            "target_rgb": target_rgb,
            "target_cmyk": target_cmyk["cmyk"],
            "user_colors": user_colors,
            "user_colors_count": len(user_colors),
            "closest_match": {
                "ratios": mix_result["closest_match"]["ratios"],
                "mixed_rgb": mix_result["closest_match"]["mixed_rgb"],
                "mixed_cmyk": mixed_cmyk["cmyk"],
                "distance": mix_result["closest_match"]["distance"]
            },
            "paint_mixing_instructions": generate_paint_mixing_instructions(
                user_colors, 
                mix_result["closest_match"]["ratios"]
            ),
            "message": f"Successfully calculated paint mixing ratios for target color using {len(user_colors)} user colors"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to process RGB scanner results: {str(e)}"
        }

def generate_paint_mixing_instructions(user_colors: list, ratios: list):
    """Generate human-readable paint mixing instructions."""
    try:
        if not user_colors or not ratios or len(user_colors) != len(ratios):
            return {"error": "Invalid input for mixing instructions"}
        
        instructions = []
        total_parts = sum(ratios)
        
        for i, (color, ratio) in enumerate(zip(user_colors, ratios)):
            if ratio > 0:
                percentage = (ratio / total_parts) * 100
                color_name = f"Color {i+1} (RGB: {color['r']}, {color['g']}, {color['b']})"
                instructions.append({
                    "color": color_name,
                    "ratio": round(ratio, 3),
                    "percentage": round(percentage, 1),
                    "instruction": f"Add {round(percentage, 1)}% of {color_name}"
                })
        
        return {
            "success": True,
            "instructions": instructions,
            "total_parts": round(total_parts, 3),
            "summary": f"Mix {len(instructions)} colors in the specified ratios"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to generate mixing instructions: {str(e)}"
        }

def calculate_paint_mixing_accuracy(target_rgb: dict, mixed_rgb: dict):
    """Calculate the accuracy of paint mixing compared to target color."""
    try:
        # Validate inputs
        if not all(key in target_rgb for key in ["r", "g", "b"]):
            return {"error": "Target RGB must contain r, g, b values"}
        
        if not all(key in mixed_rgb for key in ["r", "g", "b"]):
            return {"error": "Mixed RGB must contain r, g, b values"}
        
        # Calculate color distance
        distance = math.sqrt(
            (target_rgb["r"] - mixed_rgb["r"]) ** 2 + 
            (target_rgb["g"] - mixed_rgb["g"]) ** 2 + 
            (target_rgb["b"] - mixed_rgb["b"]) ** 2
        )
        
        # Calculate accuracy percentage (0-100%)
        max_distance = 441.67  # Maximum possible distance in RGB space
        accuracy = max(0, 100 - (distance / max_distance) * 100)
        
        # Determine accuracy level
        if accuracy >= 95:
            accuracy_level = "Excellent"
        elif accuracy >= 85:
            accuracy_level = "Very Good"
        elif accuracy >= 75:
            accuracy_level = "Good"
        elif accuracy >= 65:
            accuracy_level = "Fair"
        else:
            accuracy_level = "Poor"
        
        return {
            "success": True,
            "target_rgb": target_rgb,
            "mixed_rgb": mixed_rgb,
            "distance": round(distance, 2),
            "accuracy_percentage": round(accuracy, 2),
            "accuracy_level": accuracy_level,
            "message": f"Paint mixing accuracy: {round(accuracy, 2)}% ({accuracy_level})"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to calculate paint mixing accuracy: {str(e)}"
        }

# Create the calculations agent
calculations_agent = Agent(
    name="calculations_agent",
    description="Specialized agent for color calculations, conversions, and mathematical operations. Processes RGB Scanner Agent results and calculates paint mixing ratios for target colors.",
    model="gemini-2.0-flash-exp",
    tools=[
        rgb_to_cmyk, 
        calculate_color_mix_ratios, 
        calculate_shade_percentage,
        calculate_color_distance,
        calculate_color_brightness,
        process_rgb_scanner_results,
        generate_paint_mixing_instructions,
        calculate_paint_mixing_accuracy
    ]
)