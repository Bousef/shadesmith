#!/usr/bin/env python3
"""
Test the complete multi-agent pipeline using actual API calls
"""

import requests
import json
import os
from typing import Dict, Any

# Base URL for the Flask app
BASE_URL = "http://localhost:8080"

def test_pipeline_status():
    """Test the pipeline status endpoint"""
    print("🔍 Testing Pipeline Status...")
    try:
        response = requests.get(f"{BASE_URL}/pipeline-status")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Pipeline Status: {data['message']}")
            print(f"   Success: {data['success']}")
            print(f"   Available endpoints: {len(data['available_endpoints'])}")
            return True
        else:
            print(f"❌ Pipeline Status failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Pipeline Status error: {e}")
        return False

def test_complete_paint_mixing_pipeline():
    """Test the complete paint mixing pipeline with multiple images"""
    print("\n🎨 Testing Complete Paint Mixing Pipeline...")
    
    # Check if test images exist
    test_images = ["purple_image.jpg", "test-image.png"]
    existing_images = []
    
    for image in test_images:
        if os.path.exists(image):
            existing_images.append(image)
        else:
            print(f"⚠️  Image not found: {image}")
    
    if not existing_images:
        print("❌ No test images found. Please ensure purple_image.jpg and test-image.png exist.")
        return False
    
    print(f"📸 Using images: {existing_images}")
    
    # Prepare the request
    files = []
    for image in existing_images:
        files.append(('files', (image, open(image, 'rb'), 'image/jpeg' if image.endswith('.jpg') else 'image/png')))
    
    # Target color for mixing
    target_rgb = {"r": 128, "g": 64, "b": 192}
    
    try:
        # Make the API call
        response = requests.post(
            f"{BASE_URL}/complete-paint-mixing",
            files=files,
            data={'target_rgb': json.dumps(target_rgb)}
        )
        
        # Close file handles
        for _, (_, file_handle, _) in files:
            file_handle.close()
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Complete Paint Mixing Pipeline successful!")
            
            # Display results
            print(f"\n📊 Pipeline Summary:")
            summary = data['final_result']['pipeline_summary']
            print(f"   Images processed: {summary['images_processed']}")
            print(f"   User colors: {summary['user_colors_count']}")
            print(f"   Agents used: {', '.join(summary['agents_used'])}")
            
            print(f"\n🎯 Target Color: RGB({target_rgb['r']}, {target_rgb['g']}, {target_rgb['b']})")
            
            result_color = data['final_result']['resulting_color']['rgb']
            print(f"🎨 Result Color: RGB({result_color['r']}, {result_color['g']}, {result_color['b']})")
            
            accuracy = data['final_result']['accuracy']
            print(f"📏 Accuracy: {accuracy['level']} (distance: {accuracy['distance']:.2f})")
            
            print(f"\n📋 Mixing Instructions:")
            instructions = data['final_result']['paint_mixing_instructions']['instructions']
            for i, instruction in enumerate(instructions, 1):
                print(f"   {i}. {instruction['instruction']}")
            
            print(f"\n🔄 Pipeline Steps:")
            for step in data['pipeline_steps']:
                print(f"   Step {step['step']}: {step['action']} ({step['agent']})")
                if step['result']['success']:
                    print(f"      ✅ {step['result']['message']}")
                else:
                    print(f"      ❌ Failed")
            
            return True
        else:
            print(f"❌ Complete Paint Mixing failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Complete Paint Mixing error: {e}")
        return False

def test_individual_endpoints():
    """Test individual endpoints"""
    print("\n🔧 Testing Individual Endpoints...")
    
    # Test RGB to CMYK conversion
    print("   Testing RGB to CMYK...")
    try:
        rgb_data = {"r": 128, "g": 64, "b": 192}
        response = requests.post(f"{BASE_URL}/rgb-to-cmyk", json=rgb_data)
        if response.status_code == 200:
            data = response.json()
            cmyk = data['cmyk']
            print(f"      ✅ RGB(128, 64, 192) → CMYK({cmyk['c']:.2f}, {cmyk['m']:.2f}, {cmyk['y']:.2f}, {cmyk['k']:.2f})")
        else:
            print(f"      ❌ RGB to CMYK failed: {response.status_code}")
    except Exception as e:
        print(f"      ❌ RGB to CMYK error: {e}")
    
    # Test paint mixing calculation
    print("   Testing Paint Mixing Calculation...")
    try:
        mixing_data = {
            "user_colors": [
                {"r": 83, "g": 27, "b": 136},
                {"r": 0, "g": 162, "b": 232}
            ],
            "target_rgb": {"r": 128, "g": 64, "b": 192}
        }
        response = requests.post(f"{BASE_URL}/rgbToRatio", json=mixing_data)
        if response.status_code == 200:
            data = response.json()
            if 'ratios' in data:
                ratios = data['ratios']
                print(f"      ✅ Mixing ratios: {[f'{r:.1%}' for r in ratios]}")
            else:
                print(f"      ✅ Paint mixing response: {data}")
        else:
            print(f"      ❌ Paint mixing failed: {response.status_code}")
    except Exception as e:
        print(f"      ❌ Paint mixing error: {e}")

def main():
    """Run all tests"""
    print("🚀 Starting Multi-Agent Pipeline API Tests")
    print("=" * 50)
    
    # Test pipeline status
    status_ok = test_pipeline_status()
    
    # Test individual endpoints
    test_individual_endpoints()
    
    # Test complete pipeline
    pipeline_ok = test_complete_paint_mixing_pipeline()
    
    print("\n" + "=" * 50)
    print("📋 Test Summary:")
    print(f"   Pipeline Status: {'✅ PASS' if status_ok else '❌ FAIL'}")
    print(f"   Complete Pipeline: {'✅ PASS' if pipeline_ok else '❌ FAIL'}")
    
    if status_ok and pipeline_ok:
        print("\n🎉 All tests passed! The multi-agent pipeline is working correctly.")
    else:
        print("\n⚠️  Some tests failed. Please check the output above.")

if __name__ == "__main__":
    main()
