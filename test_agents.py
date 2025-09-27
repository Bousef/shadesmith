#!/usr/bin/env python3
"""
Test script for the Shadesmith multi-agent pipeline
Tests each agent individually and the complete pipeline
"""

import os
import sys
import json
from pathlib import Path

# Add the agent directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'agent'))

from agent.image_converter_agent import image_converter_agent
from agent.rgb_scanner_agent import rgb_scanner_agent
from agent.calculations_agent import calculations_agent
from agent.parent_agent import parent_agent

def test_image_converter_agent():
    """Test the Image Converter Agent"""
    print("🧪 Testing Image Converter Agent...")
    
    # Test with existing images
    test_images = [
        "purple_image.jpg",
        "test-image.png"
    ]
    
    # Filter to only existing files
    existing_images = [img for img in test_images if os.path.exists(img)]
    
    if not existing_images:
        print("❌ No test images found. Please add some test images to the project root.")
        return False
    
    print(f"📁 Testing with images: {existing_images}")
    
    # Test single image conversion
    result = image_converter_agent.tools[0](existing_images[0])  # convert_image_to_png
    print(f"✅ Single image conversion: {result.get('success', False)}")
    if result.get('success'):
        print(f"   Output: {result.get('output_file')}")
    
    # Test multiple image conversion
    if len(existing_images) > 1:
        result = image_converter_agent.tools[4](existing_images)  # convert_multiple_images_to_png
        print(f"✅ Multiple image conversion: {result.get('success', False)}")
        if result.get('success'):
            print(f"   Converted {result.get('total_converted')} images")
    
    return True

def test_rgb_scanner_agent():
    """Test the RGB Scanner Agent"""
    print("\n🧪 Testing RGB Scanner Agent...")
    
    # Test with existing PNG images
    test_images = [
        "latest_converted.png",
        "test_download.png",
        "output.png"
    ]
    
    existing_images = [img for img in test_images if os.path.exists(img)]
    
    if not existing_images:
        print("❌ No test PNG images found.")
        return False
    
    print(f"📁 Testing with images: {existing_images}")
    
    # Test single image RGB scanning
    result = rgb_scanner_agent.tools[0](existing_images[0])  # scan_rgb_from_image
    print(f"✅ Single image RGB scan: {result.get('success', False)}")
    if result.get('success'):
        primary_rgb = result.get('primary_rgb')
        print(f"   Primary RGB: R={primary_rgb['r']}, G={primary_rgb['g']}, B={primary_rgb['b']}")
    
    # Test multiple image RGB scanning
    if len(existing_images) > 1:
        result = rgb_scanner_agent.tools[1](existing_images)  # scan_rgb_from_multiple_images
        print(f"✅ Multiple image RGB scan: {result.get('success', False)}")
        if result.get('success'):
            print(f"   Scanned {result.get('total_scanned')} images")
    
    return True

def test_calculations_agent():
    """Test the Calculations Agent"""
    print("\n🧪 Testing Calculations Agent...")
    
    # Test RGB to CMYK conversion
    test_rgb = {"r": 128, "g": 64, "b": 192}
    result = calculations_agent.tools[0](test_rgb["r"], test_rgb["g"], test_rgb["b"])  # rgb_to_cmyk
    print(f"✅ RGB to CMYK conversion: {result.get('success', False)}")
    if result.get('success'):
        cmyk = result.get('cmyk')
        print(f"   CMYK: C={cmyk['c']}, M={cmyk['m']}, Y={cmyk['y']}, K={cmyk['k']}")
    
    # Test color mixing calculation
    target_rgb = {"r": 128, "g": 64, "b": 192}
    user_colors = [
        {"r": 255, "g": 0, "b": 0},    # Red
        {"r": 0, "g": 255, "b": 0},    # Green
        {"r": 0, "g": 0, "b": 255}     # Blue
    ]
    
    result = calculations_agent.tools[1](target_rgb, user_colors)  # calculate_color_mix_ratios
    print(f"✅ Color mixing calculation: {result.get('success', False)}")
    if result.get('success'):
        closest_match = result.get('closest_match')
        print(f"   Mixing ratios: {closest_match['ratios']}")
        print(f"   Resulting RGB: R={closest_match['mixed_rgb']['r']}, G={closest_match['mixed_rgb']['g']}, B={closest_match['mixed_rgb']['b']}")
        print(f"   Distance: {closest_match['distance']}")
    
    return True

def test_parent_agent_pipeline():
    """Test the complete Parent Agent pipeline"""
    print("\n🧪 Testing Parent Agent Pipeline...")
    
    # Test manual RGB pipeline
    test_rgb = {"r": 128, "g": 64, "b": 192}
    result = parent_agent.tools[1](test_rgb["r"], test_rgb["g"], test_rgb["b"])  # process_manual_rgb_pipeline
    print(f"✅ Manual RGB pipeline: {result.get('success', False)}")
    if result.get('success'):
        final_result = result.get('final_result')
        print(f"   Input RGB: R={final_result['input_rgb']['r']}, G={final_result['input_rgb']['g']}, B={final_result['input_rgb']['b']}")
        print(f"   Output CMYK: C={final_result['output_cmyk']['c']}, M={final_result['output_cmyk']['m']}, Y={final_result['output_cmyk']['y']}, K={final_result['output_cmyk']['k']}")
    
    # Test paint mixing pipeline
    target_rgb = {"r": 128, "g": 64, "b": 192}
    user_colors = [
        {"r": 255, "g": 0, "b": 0},    # Red
        {"r": 0, "g": 255, "b": 0}     # Green
    ]
    
    result = parent_agent.tools[2](target_rgb, user_colors)  # calculate_paint_mix_pipeline
    print(f"✅ Paint mixing pipeline: {result.get('success', False)}")
    if result.get('success'):
        final_result = result.get('final_result')
        print(f"   Target color: R={final_result['target_color']['r']}, G={final_result['target_color']['g']}, B={final_result['target_color']['b']}")
        print(f"   Mixing ratios: {final_result['mixing_ratios']}")
        print(f"   Resulting color: R={final_result['resulting_color']['r']}, G={final_result['resulting_color']['g']}, B={final_result['resulting_color']['b']}")
        print(f"   Accuracy distance: {final_result['accuracy']}")
    
    return True

def test_complete_pipeline():
    """Test the complete pipeline with real images"""
    print("\n🧪 Testing Complete Pipeline...")
    
    # Find existing images
    test_images = [
        "purple_image.jpg",
        "test-image.png"
    ]
    
    existing_images = [img for img in test_images if os.path.exists(img)]
    
    if not existing_images:
        print("❌ No test images found for complete pipeline test.")
        return False
    
    # Test with first available image
    target_rgb = {"r": 128, "g": 64, "b": 192}  # Purple target
    
    print(f"📁 Testing complete pipeline with: {existing_images[0]}")
    print(f"🎯 Target color: R={target_rgb['r']}, G={target_rgb['g']}, B={target_rgb['b']}")
    
    result = parent_agent.tools[3]([existing_images[0]], target_rgb)  # process_complete_paint_mixing_pipeline
    
    print(f"✅ Complete pipeline: {result.get('success', False)}")
    if result.get('success'):
        final_result = result.get('final_result')
        print(f"   Pipeline steps: {final_result['pipeline_summary']['total_steps']}")
        print(f"   Agents used: {final_result['pipeline_summary']['agents_used']}")
        print(f"   User colors count: {final_result['pipeline_summary']['user_colors_count']}")
        
        if 'paint_mixing_instructions' in final_result:
            instructions = final_result['paint_mixing_instructions']
            print(f"   Mixing instructions: {instructions.get('summary', 'N/A')}")
        
        if 'accuracy' in final_result:
            accuracy = final_result['accuracy']
            print(f"   Accuracy: {accuracy.get('level', 'N/A')} (distance: {accuracy.get('distance', 'N/A')})")
    else:
        print(f"   Error: {result.get('error')}")
    
    return result.get('success', False)

def test_project_info():
    """Test project info function"""
    print("\n🧪 Testing Project Info...")
    
    result = parent_agent.tools[5]()  # get_project_info
    print(f"✅ Project info: {result.get('project_name', 'N/A')}")
    print(f"   Description: {result.get('description', 'N/A')}")
    print(f"   Agents: {len(result.get('agents', []))}")
    print(f"   Capabilities: {len(result.get('capabilities', []))}")
    
    return True

def main():
    """Run all tests"""
    print("🚀 Starting Shadesmith Multi-Agent Pipeline Tests")
    print("=" * 60)
    
    tests = [
        ("Image Converter Agent", test_image_converter_agent),
        ("RGB Scanner Agent", test_rgb_scanner_agent),
        ("Calculations Agent", test_calculations_agent),
        ("Parent Agent Pipeline", test_parent_agent_pipeline),
        ("Complete Pipeline", test_complete_pipeline),
        ("Project Info", test_project_info)
    ]
    
    results = {}
    
    for test_name, test_func in tests:
        try:
            results[test_name] = test_func()
        except Exception as e:
            print(f"❌ {test_name} failed with error: {str(e)}")
            results[test_name] = False
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 Test Results Summary:")
    print("=" * 60)
    
    passed = 0
    total = len(results)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1
    
    print(f"\n🎯 Overall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! The multi-agent pipeline is working correctly.")
    else:
        print("⚠️  Some tests failed. Check the output above for details.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
