from google.adk.agents import Agent
from .image_converter_agent import image_converter_agent
from .rgb_scanner_agent import rgb_scanner_agent
from .calculations_agent import calculations_agent
import os

def process_image_pipeline(image_path: str, skip_conversion: bool = False):
    """
    Sequential pipeline: Image Converter → RGB Scanner → Calculations → Parent
    Image Converter Agent sends images to RGB Scanner Agent,
    RGB Scanner Agent sends RGB values to Calculations Agent,
    Calculations Agent returns results to parent to return to user
    """
    try:
        pipeline_results = {
            "success": True,
            "pipeline_steps": [],
            "final_result": None,
            "agent_chain": []
        }
        
        current_image_path = image_path
        
        # Step 1: Image Converter Agent
        if not skip_conversion:
            print(f"🔄 Step 1: Image Converter Agent processing {image_path}")
            conversion_result = image_converter_agent.tools[0](image_path)
            
            if not conversion_result.get("success"):
                return {
                    "success": False,
                    "error": f"Image Converter Agent failed: {conversion_result.get('error')}",
                    "failed_step": "image_conversion"
                }
            
            current_image_path = conversion_result["output_file"]
            pipeline_results["pipeline_steps"].append({
                "step": 1,
                "agent": "Image Converter Agent",
                "action": "Convert to PNG",
                "input": image_path,
                "output": current_image_path,
                "result": conversion_result
            })
            pipeline_results["agent_chain"].append("image_converter_agent")
        
        # Step 2: RGB Scanner Agent (receives image from Image Converter)
        print(f"🔄 Step 2: RGB Scanner Agent processing {current_image_path}")
        rgb_result = rgb_scanner_agent.tools[0](current_image_path)
        
        if not rgb_result.get("success"):
            return {
                "success": False,
                "error": f"RGB Scanner Agent failed: {rgb_result.get('error')}",
                "failed_step": "rgb_scanning",
                "pipeline_steps": pipeline_results["pipeline_steps"]
            }
        
        pipeline_results["pipeline_steps"].append({
            "step": 2,
            "agent": "RGB Scanner Agent",
            "action": "Extract RGB values",
            "input": current_image_path,
            "output": rgb_result["primary_rgb"],
            "result": rgb_result
        })
        pipeline_results["agent_chain"].append("rgb_scanner_agent")
        
        # Step 3: Calculations Agent (receives RGB from RGB Scanner)
        primary_rgb = rgb_result["primary_rgb"]
        print(f"🔄 Step 3: Calculations Agent processing RGB({primary_rgb['r']}, {primary_rgb['g']}, {primary_rgb['b']})")
        
        cmyk_result = calculations_agent.tools[0](
            primary_rgb["r"], 
            primary_rgb["g"], 
            primary_rgb["b"]
        )
        
        if not cmyk_result.get("success"):
            return {
                "success": False,
                "error": f"Calculations Agent failed: {cmyk_result.get('error')}",
                "failed_step": "rgb_to_cmyk_conversion",
                "pipeline_steps": pipeline_results["pipeline_steps"]
            }
        
        pipeline_results["pipeline_steps"].append({
            "step": 3,
            "agent": "Calculations Agent",
            "action": "Convert RGB to CMYK",
            "input": primary_rgb,
            "output": cmyk_result["cmyk"],
            "result": cmyk_result
        })
        pipeline_results["agent_chain"].append("calculations_agent")
        
        # Step 4: Parent Agent (receives results from Calculations Agent)
        print(f"✅ Step 4: Parent Agent compiling final results")
        pipeline_results["final_result"] = {
            "original_image": image_path,
            "processed_image": current_image_path,
            "rgb_values": primary_rgb,
            "cmyk_values": cmyk_result["cmyk"],
            "pipeline_summary": {
                "total_steps": len(pipeline_results["pipeline_steps"]),
                "agents_used": pipeline_results["agent_chain"],
                "conversion_skipped": skip_conversion
            }
        }
        pipeline_results["agent_chain"].append("parent_agent")
        
        return pipeline_results
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Pipeline failed: {str(e)}",
            "pipeline_steps": pipeline_results.get("pipeline_steps", [])
        }

def process_manual_rgb_pipeline(r: int, g: int, b: int):
    """
    Direct pipeline: RGB values → Calculations Agent → Parent
    Skips Image Converter and RGB Scanner agents
    """
    try:
        pipeline_results = {
            "success": True,
            "pipeline_steps": [],
            "final_result": None,
            "agent_chain": []
        }
        
        # Step 1: Calculations Agent (receives manual RGB input)
        print(f"🔄 Step 1: Calculations Agent processing manual RGB({r}, {g}, {b})")
        cmyk_result = calculations_agent.tools[0](r, g, b)
        
        if not cmyk_result.get("success"):
            return {
                "success": False,
                "error": f"Calculations Agent failed: {cmyk_result.get('error')}",
                "failed_step": "rgb_to_cmyk_conversion"
            }
        
        pipeline_results["pipeline_steps"].append({
            "step": 1,
            "agent": "Calculations Agent",
            "action": "Convert RGB to CMYK",
            "input": {"r": r, "g": g, "b": b},
            "output": cmyk_result["cmyk"],
            "result": cmyk_result
        })
        pipeline_results["agent_chain"].append("calculations_agent")
        
        # Step 2: Parent Agent (receives results from Calculations Agent)
        print(f"✅ Step 2: Parent Agent compiling final results")
        pipeline_results["final_result"] = {
            "input_rgb": {"r": r, "g": g, "b": b},
            "output_cmyk": cmyk_result["cmyk"],
            "pipeline_summary": {
                "total_steps": 1,
                "agents_used": ["calculations_agent", "parent_agent"],
                "input_type": "manual_rgb"
            }
        }
        pipeline_results["agent_chain"].append("parent_agent")
        
        return pipeline_results
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Manual RGB pipeline failed: {str(e)}"
        }

def calculate_paint_mix_pipeline(target_rgb: dict, user_colors: list):
    """
    Paint mixing pipeline: Target RGB + User Colors → Calculations Agent → Parent
    """
    try:
        pipeline_results = {
            "success": True,
            "pipeline_steps": [],
            "final_result": None,
            "agent_chain": []
        }
        
        # Step 1: Calculations Agent (receives target RGB and user colors)
        print(f"🔄 Step 1: Calculations Agent calculating paint mix ratios")
        mix_result = calculations_agent.tools[1](target_rgb, user_colors)
        
        if not mix_result.get("success"):
            return {
                "success": False,
                "error": f"Calculations Agent failed: {mix_result.get('error')}",
                "failed_step": "paint_mix_calculation"
            }
        
        pipeline_results["pipeline_steps"].append({
            "step": 1,
            "agent": "Calculations Agent",
            "action": "Calculate paint mix ratios",
            "input": {"target_rgb": target_rgb, "user_colors": user_colors},
            "output": mix_result["closest_match"],
            "result": mix_result
        })
        pipeline_results["agent_chain"].append("calculations_agent")
        
        # Step 2: Parent Agent (receives results from Calculations Agent)
        print(f"✅ Step 2: Parent Agent compiling final results")
        pipeline_results["final_result"] = {
            "target_color": target_rgb,
            "mixing_ratios": mix_result["closest_match"]["ratios"],
            "resulting_color": mix_result["closest_match"]["mixed_rgb"],
            "cmyk_values": mix_result["closest_match"]["mixed_cmyk"],
            "accuracy": mix_result["closest_match"]["distance"],
            "pipeline_summary": {
                "total_steps": 1,
                "agents_used": ["calculations_agent", "parent_agent"],
                "input_type": "paint_mixing"
            }
        }
        pipeline_results["agent_chain"].append("parent_agent")
        
        return pipeline_results
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Paint mix pipeline failed: {str(e)}"
        }

def process_complete_paint_mixing_pipeline(image_paths: list, target_rgb: dict, skip_conversion: bool = False):
    """
    Complete pipeline: Image Converter → RGB Scanner → Calculations → Parent
    Processes multiple images and calculates paint mixing ratios for target color
    """
    try:
        pipeline_results = {
            "success": True,
            "pipeline_steps": [],
            "final_result": None,
            "agent_chain": []
        }
        
        # Step 1: Image Converter Agent (process multiple images)
        if not skip_conversion:
            print(f"🔄 Step 1: Image Converter Agent processing {len(image_paths)} images")
            conversion_result = image_converter_agent.tools[4](image_paths)  # convert_multiple_images_to_png
            
            if not conversion_result.get("success"):
                return {
                    "success": False,
                    "error": f"Image Converter Agent failed: {conversion_result.get('error')}",
                    "failed_step": "image_conversion"
                }
            
            pipeline_results["pipeline_steps"].append({
                "step": 1,
                "agent": "Image Converter Agent",
                "action": "Convert multiple images to PNG",
                "input": image_paths,
                "output": conversion_result["converted_files"],
                "result": conversion_result
            })
            pipeline_results["agent_chain"].append("image_converter_agent")
        else:
            # If skipping conversion, use image_paths directly
            conversion_result = {"converted_files": [{"output_file": path} for path in image_paths]}
        
        # Step 2: RGB Scanner Agent (scan RGB from converted images)
        print(f"🔄 Step 2: RGB Scanner Agent scanning RGB values")
        rgb_result = rgb_scanner_agent.tools[2](conversion_result)  # scan_rgb_from_converter_results
        
        if not rgb_result.get("success"):
            return {
                "success": False,
                "error": f"RGB Scanner Agent failed: {rgb_result.get('error')}",
                "failed_step": "rgb_scanning",
                "pipeline_steps": pipeline_results["pipeline_steps"]
            }
        
        pipeline_results["pipeline_steps"].append({
            "step": 2,
            "agent": "RGB Scanner Agent",
            "action": "Extract RGB values from images",
            "input": conversion_result,
            "output": rgb_result["scanned_results"],
            "result": rgb_result
        })
        pipeline_results["agent_chain"].append("rgb_scanner_agent")
        
        # Step 3: Calculations Agent (process RGB results + target color)
        print(f"🔄 Step 3: Calculations Agent calculating paint mixing ratios")
        calculations_result = calculations_agent.tools[5](rgb_result, target_rgb)  # process_rgb_scanner_results
        
        if not calculations_result.get("success"):
            return {
                "success": False,
                "error": f"Calculations Agent failed: {calculations_result.get('error')}",
                "failed_step": "paint_mixing_calculation",
                "pipeline_steps": pipeline_results["pipeline_steps"]
            }
        
        pipeline_results["pipeline_steps"].append({
            "step": 3,
            "agent": "Calculations Agent",
            "action": "Calculate paint mixing ratios",
            "input": {"rgb_scanner_results": rgb_result, "target_rgb": target_rgb},
            "output": calculations_result["closest_match"],
            "result": calculations_result
        })
        pipeline_results["agent_chain"].append("calculations_agent")
        
        # Step 4: Parent Agent (compile final results for user)
        print(f"✅ Step 4: Parent Agent compiling final results for user")
        pipeline_results["final_result"] = {
            "target_color": {
                "rgb": target_rgb,
                "cmyk": calculations_result["target_cmyk"]
            },
            "user_colors": calculations_result["user_colors"],
            "paint_mixing_instructions": calculations_result["paint_mixing_instructions"],
            "mixing_ratios": calculations_result["closest_match"]["ratios"],
            "resulting_color": {
                "rgb": calculations_result["closest_match"]["mixed_rgb"],
                "cmyk": calculations_result["closest_match"]["mixed_cmyk"]
            },
            "accuracy": {
                "distance": calculations_result["closest_match"]["distance"],
                "level": "Excellent" if calculations_result["closest_match"]["distance"] < 10 else "Good" if calculations_result["closest_match"]["distance"] < 30 else "Fair"
            },
            "pipeline_summary": {
                "total_steps": len(pipeline_results["pipeline_steps"]),
                "agents_used": pipeline_results["agent_chain"],
                "images_processed": len(image_paths),
                "conversion_skipped": skip_conversion,
                "user_colors_count": calculations_result["user_colors_count"]
            }
        }
        pipeline_results["agent_chain"].append("parent_agent")
        
        return pipeline_results
    
    except Exception as e:
        return {
            "success": False,
            "error": f"Complete paint mixing pipeline failed: {str(e)}",
            "pipeline_steps": pipeline_results.get("pipeline_steps", [])
        }

def process_rgb_scanner_to_calculations_pipeline(rgb_scanner_results: dict, target_rgb: dict):
    """
    Direct pipeline: RGB Scanner Results + Target RGB → Calculations Agent → Parent
    Skips Image Converter Agent
    """
    try:
        pipeline_results = {
            "success": True,
            "pipeline_steps": [],
            "final_result": None,
            "agent_chain": []
        }
        
        # Step 1: Calculations Agent (process RGB scanner results + target color)
        print(f"🔄 Step 1: Calculations Agent processing RGB scanner results with target color")
        calculations_result = calculations_agent.tools[5](rgb_scanner_results, target_rgb)  # process_rgb_scanner_results
        
        if not calculations_result.get("success"):
            return {
                "success": False,
                "error": f"Calculations Agent failed: {calculations_result.get('error')}",
                "failed_step": "paint_mixing_calculation"
            }
        
        pipeline_results["pipeline_steps"].append({
            "step": 1,
            "agent": "Calculations Agent",
            "action": "Calculate paint mixing ratios from RGB scanner results",
            "input": {"rgb_scanner_results": rgb_scanner_results, "target_rgb": target_rgb},
            "output": calculations_result["closest_match"],
            "result": calculations_result
        })
        pipeline_results["agent_chain"].append("calculations_agent")
        
        # Step 2: Parent Agent (compile final results for user)
        print(f"✅ Step 2: Parent Agent compiling final results for user")
        pipeline_results["final_result"] = {
            "target_color": {
                "rgb": target_rgb,
                "cmyk": calculations_result["target_cmyk"]
            },
            "user_colors": calculations_result["user_colors"],
            "paint_mixing_instructions": calculations_result["paint_mixing_instructions"],
            "mixing_ratios": calculations_result["closest_match"]["ratios"],
            "resulting_color": {
                "rgb": calculations_result["closest_match"]["mixed_rgb"],
                "cmyk": calculations_result["closest_match"]["mixed_cmyk"]
            },
            "accuracy": {
                "distance": calculations_result["closest_match"]["distance"],
                "level": "Excellent" if calculations_result["closest_match"]["distance"] < 10 else "Good" if calculations_result["closest_match"]["distance"] < 30 else "Fair"
            },
            "pipeline_summary": {
                "total_steps": 1,
                "agents_used": ["calculations_agent", "parent_agent"],
                "input_type": "rgb_scanner_results",
                "user_colors_count": calculations_result["user_colors_count"]
            }
        }
        pipeline_results["agent_chain"].append("parent_agent")
        
        return pipeline_results
    
    except Exception as e:
        return {
            "success": False,
            "error": f"RGB scanner to calculations pipeline failed: {str(e)}"
        }

def get_project_info():
    """Get information about the Shadesmith project."""
    return {
        "project_name": "Shadesmith",
        "description": "A Flutter application project with sequential multi-agent color processing pipeline",
        "framework": "Flutter",
        "platforms": ["Android", "iOS", "Web", "macOS", "Windows", "Linux"],
        "pipeline_flows": [
            "Complete Pipeline: Image Converter → RGB Scanner → Calculations → Parent",
            "Direct Pipeline: RGB Scanner Results → Calculations → Parent",
            "Manual Pipeline: Target RGB + User Colors → Calculations → Parent"
        ],
        "agents": [
            "Image Converter Agent (converts up to 3 images to PNG)",
            "RGB Scanner Agent (extracts RGB using Google Cloud Vision)", 
            "Calculations Agent (RGB to CMYK, paint mixing, accuracy calculations)",
            "Parent Coordinator Agent (orchestrates pipelines and returns results to users)"
        ],
        "capabilities": [
            "Process multiple user color images",
            "Extract RGB values from images",
            "Calculate optimal paint mixing ratios",
            "Generate step-by-step mixing instructions",
            "Provide accuracy assessments",
            "Convert between RGB and CMYK color spaces"
        ]
    }

# Create the parent coordinator agent
parent_agent = Agent(
    name="shadesmith_parent_agent",
    description="Main coordinator agent that orchestrates multi-agent pipelines and returns comprehensive results to users. Supports complete paint mixing workflows with image processing, RGB extraction, and color calculations.",
    model="gemini-2.0-flash-exp",
    tools=[
        process_image_pipeline, 
        process_manual_rgb_pipeline, 
        calculate_paint_mix_pipeline,
        process_complete_paint_mixing_pipeline,
        process_rgb_scanner_to_calculations_pipeline,
        get_project_info
    ]
)