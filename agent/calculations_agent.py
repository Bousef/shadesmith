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
    """Calculate the best ratios to mix user colors to achieve target RGB using subtractive color theory."""
    try:
        if not target_rgb or not user_colors or len(user_colors) > 3:
            return {"error": "Invalid input. Provide target_rgb and up to 3 user_colors."}
        
        target_r, target_g, target_b = target_rgb["r"], target_rgb["g"], target_rgb["b"]
        
        # Generate permutations of ratios
        ratios = [0.1 * i for i in range(11)]  # 0.0 to 1.0 in steps of 0.1
        permutations_of_ratios = [p for p in permutations(ratios, len(user_colors)) if abs(sum(p) - 1.0) < 0.01]
        
        closest_match = None
        min_distance = float("inf")
        
        # Find best ratio combination using subtractive mixing
        for ratio_set in permutations_of_ratios:
            # Convert RGB to CMYK for subtractive mixing
            mixed_cmyk = subtractive_color_mix(user_colors, ratio_set)
            # Convert back to RGB for comparison
            mixed_rgb = cmyk_to_rgb(mixed_cmyk)
            
            # Calculate distance to target
            distance = math.sqrt((mixed_rgb["r"] - target_r) ** 2 + (mixed_rgb["g"] - target_g) ** 2 + (mixed_rgb["b"] - target_b) ** 2)
            
            if distance < min_distance:
                min_distance = distance
                closest_match = {
                    "ratios": ratio_set,
                    "mixed_rgb": mixed_rgb,
                    "mixed_cmyk": mixed_cmyk,
                    "distance": distance
                }
        
        # Convert target to CMYK
        target_cmyk = rgb_to_cmyk(target_r, target_g, target_b)
        
        return {
            "success": True,
            "target_rgb": target_rgb,
            "target_cmyk": target_cmyk["cmyk"],
            "closest_match": {
                "ratios": closest_match["ratios"],
                "mixed_rgb": closest_match["mixed_rgb"],
                "mixed_cmyk": closest_match["mixed_cmyk"],
                "distance": closest_match["distance"]
            },
            "message": "Successfully calculated color mixing ratios using subtractive color theory"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to calculate color mix ratios: {str(e)}"
        }

def subtractive_color_mix(user_colors: list, ratios: list):
    """Mix colors using subtractive color theory (like real paint mixing)."""
    try:
        # For paint mixing, we need to think about what each color absorbs/reflects
        # White reflects all light, so it dilutes other colors
        # Blue absorbs red and green (reflects blue)
        # Yellow absorbs blue (reflects red and green)
        # When mixed: Blue + Yellow should create green (both absorb blue, yellow reflects green)
        
        # Convert to a more paint-realistic model
        # Use complementary colors: Red-Cyan, Green-Magenta, Blue-Yellow
        
        # Calculate weighted average of RGB values with paint mixing logic
        mixed_r = 0
        mixed_g = 0 
        mixed_b = 0
        
        for i, color in enumerate(user_colors):
            weight = ratios[i]
            mixed_r += color["r"] * weight
            mixed_g += color["g"] * weight
            mixed_b += color["b"] * weight
        
        # Apply paint mixing logic:
        # - White dilutes (makes colors lighter)
        # - Complementary colors neutralize each other
        # - Blue + Yellow = Green (yellow reflects green, blue doesn't interfere with green)
        
        # Apply real paint mixing rules
        # Blue + Yellow = Green (subtractive mixing)
        # Blue absorbs red and green, reflects blue
        # Yellow absorbs blue, reflects red and green
        # When mixed: both absorb blue, yellow reflects green = GREEN
        
        # Find blue and yellow in the mix
        blue_amount = 0
        yellow_amount = 0
        
        for i, color in enumerate(user_colors):
            if color["r"] == 0 and color["g"] == 0 and color["b"] == 255:  # Pure blue
                blue_amount = ratios[i]
            elif color["r"] == 255 and color["g"] == 255 and color["b"] == 0:  # Pure yellow
                yellow_amount = ratios[i]
        
        # If we have both blue and yellow, apply subtractive mixing
        if blue_amount > 0 and yellow_amount > 0:
            # Blue + Yellow = Green in subtractive mixing
            green_strength = min(blue_amount, yellow_amount) * 2  # Both contribute to green
            mixed_g = min(255, mixed_g + green_strength * 255)
            # Reduce blue component (blue gets absorbed)
            mixed_b = mixed_b * (1 - green_strength * 0.5)
            # Reduce red component (yellow absorbs some red)
            mixed_r = mixed_r * (1 - green_strength * 0.3)
        
        # Convert back to CMYK for consistency
        cmyk_result = rgb_to_cmyk(int(mixed_r), int(mixed_g), int(mixed_b))
        return cmyk_result["cmyk"]
    
    except Exception as e:
        return {"c": 0, "m": 0, "y": 0, "k": 0}

def cmyk_to_rgb(cmyk: dict):
    """Convert CMYK to RGB."""
    try:
        c = cmyk["c"] / 100.0
        m = cmyk["m"] / 100.0
        y = cmyk["y"] / 100.0
        k = cmyk["k"] / 100.0
        
        r = int(255 * (1 - c) * (1 - k))
        g = int(255 * (1 - m) * (1 - k))
        b = int(255 * (1 - y) * (1 - k))
        
        return {
            "r": max(0, min(255, r)),
            "g": max(0, min(255, g)),
            "b": max(0, min(255, b))
        }
    
    except Exception as e:
        return {"r": 0, "g": 0, "b": 0}

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
            "message": f"Successfully calculated paint mixing ratios for target color using {len(user_colors)} user colors"
        }
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to process RGB scanner results: {str(e)}"
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
        process_rgb_scanner_results
    ]
)