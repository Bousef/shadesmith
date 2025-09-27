#!/usr/bin/env python3
"""
Test script for Flask app integration with the multi-agent pipeline
"""

import requests
import json
import os
import time
from pathlib import Path

# Flask app URL (adjust if running on different port)
BASE_URL = "http://localhost:8080"

def test_health_check():
    """Test if Flask app is running"""
    print("🧪 Testing Flask app health check...")
    
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"✅ Health check: {response.status_code}")
        print(f"   Response: {response.text}")
        return response.status_code == 200
    except requests.exceptions.ConnectionError:
        print("❌ Flask app is not running. Start it with: python app.py")
        return False
    except Exception as e:
        print(f"❌ Health check failed: {str(e)}")
        return False

def test_project_info_endpoint():
    """Test project info endpoint"""
    print("\n🧪 Testing project info endpoint...")
    
    try:
        response = requests.get(f"{BASE_URL}/project-info")
        print(f"✅ Project info: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Project: {data.get('project_name', 'N/A')}")
            print(f"   Description: {data.get('description', 'N/A')}")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Project info test failed: {str(e)}")
        return False

def test_shade_percentage_endpoint():
    """Test shade percentage calculation endpoint"""
    print("\n🧪 Testing shade percentage endpoint...")
    
    try:
        test_data = {
            "light_value": 75,
            "max_light": 100
        }
        
        response = requests.post(
            f"{BASE_URL}/shade-percentage",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"✅ Shade percentage: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Light value: {data.get('light_value', 'N/A')}")
            print(f"   Shade percentage: {data.get('shade_percentage', 'N/A')}%")
            print(f"   Interpretation: {data.get('interpretation', 'N/A')}")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Shade percentage test failed: {str(e)}")
        return False

def test_image_conversion_endpoint():
    """Test image conversion endpoint"""
    print("\n🧪 Testing image conversion endpoint...")
    
    # Find a test image
    test_images = ["purple_image.jpg", "test-image.png"]
    test_image = None
    
    for img in test_images:
        if os.path.exists(img):
            test_image = img
            break
    
    if not test_image:
        print("❌ No test image found for conversion test")
        return False
    
    try:
        with open(test_image, 'rb') as f:
            files = {'file': (test_image, f, 'image/jpeg')}
            response = requests.post(f"{BASE_URL}/convert-to-png", files=files)
        
        print(f"✅ Image conversion: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Success: {data.get('success', False)}")
            print(f"   Output filename: {data.get('output_filename', 'N/A')}")
            print(f"   Download URL: {data.get('download_url', 'N/A')}")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Image conversion test failed: {str(e)}")
        return False

def test_rgb_to_ratio_endpoint():
    """Test RGB to ratio calculation endpoint"""
    print("\n🧪 Testing RGB to ratio endpoint...")
    
    try:
        test_data = {
            "target_rgb": {"r": 128, "g": 64, "b": 192},
            "user_colors": [
                {"r": 255, "g": 0, "b": 0},    # Red
                {"r": 0, "g": 255, "b": 0}     # Green
            ]
        }
        
        response = requests.post(
            f"{BASE_URL}/rgbToRatio",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"✅ RGB to ratio: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Success: {data.get('success', False)}")
            if data.get('success'):
                closest_match = data.get('closest_match', {})
                print(f"   Mixing ratios: {closest_match.get('ratios', 'N/A')}")
                print(f"   Distance: {closest_match.get('distance', 'N/A')}")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ RGB to ratio test failed: {str(e)}")
        return False

def test_rgb_to_cmyk_endpoint():
    """Test RGB to CMYK conversion endpoint"""
    print("\n🧪 Testing RGB to CMYK endpoint...")
    
    try:
        test_data = {
            "r": 128,
            "g": 64,
            "b": 192
        }
        
        response = requests.post(
            f"{BASE_URL}/rgb-to-cmyk",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"✅ RGB to CMYK: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Success: {data.get('success', False)}")
            if data.get('success'):
                cmyk = data.get('cmyk', {})
                print(f"   CMYK: C={cmyk.get('c', 'N/A')}, M={cmyk.get('m', 'N/A')}, Y={cmyk.get('y', 'N/A')}, K={cmyk.get('k', 'N/A')}")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ RGB to CMYK test failed: {str(e)}")
        return False

def test_pipeline_status_endpoint():
    """Test pipeline status endpoint"""
    print("\n🧪 Testing pipeline status endpoint...")
    
    try:
        response = requests.get(f"{BASE_URL}/pipeline-status")
        print(f"✅ Pipeline status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Success: {data.get('success', False)}")
            if data.get('success'):
                components = data.get('pipeline_components', {})
                print(f"   Active components: {len(components)}")
                endpoints = data.get('available_endpoints', [])
                print(f"   Available endpoints: {len(endpoints)}")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Pipeline status test failed: {str(e)}")
        return False

def test_convert_multiple_images_endpoint():
    """Test convert multiple images endpoint"""
    print("\n🧪 Testing convert multiple images endpoint...")
    
    # Find test images
    test_images = ["purple_image.jpg", "test-image.png"]
    existing_images = [img for img in test_images if os.path.exists(img)]
    
    if not existing_images:
        print("❌ No test images found for multiple image conversion test")
        return False
    
    try:
        files = []
        for img in existing_images[:2]:  # Test with up to 2 images
            files.append(('files', (img, open(img, 'rb'), 'image/jpeg')))
        
        response = requests.post(f"{BASE_URL}/convert-multiple-images", files=files)
        
        # Close files
        for _, (_, file_obj, _) in files:
            file_obj.close()
        
        print(f"✅ Convert multiple images: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Success: {data.get('success', False)}")
            if data.get('success'):
                print(f"   Converted: {data.get('total_converted', 0)} images")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Convert multiple images test failed: {str(e)}")
        return False

def test_list_files_endpoint():
    """Test list files endpoint"""
    print("\n🧪 Testing list files endpoint...")
    
    try:
        response = requests.get(f"{BASE_URL}/list-files")
        print(f"✅ List files: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Success: {data.get('success', False)}")
            print(f"   File count: {data.get('count', 0)}")
            return True
        else:
            print(f"   Error: {response.text}")
            return False
    except Exception as e:
        print(f"❌ List files test failed: {str(e)}")
        return False

def main():
    """Run all Flask integration tests"""
    print("🚀 Starting Flask Integration Tests")
    print("=" * 60)
    
    tests = [
        ("Health Check", test_health_check),
        ("Project Info", test_project_info_endpoint),
        ("Shade Percentage", test_shade_percentage_endpoint),
        ("Image Conversion", test_image_conversion_endpoint),
        ("RGB to Ratio", test_rgb_to_ratio_endpoint),
        ("RGB to CMYK", test_rgb_to_cmyk_endpoint),
        ("Pipeline Status", test_pipeline_status_endpoint),
        ("Convert Multiple Images", test_convert_multiple_images_endpoint),
        ("List Files", test_list_files_endpoint)
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
    print("📊 Flask Integration Test Results:")
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
        print("🎉 All Flask integration tests passed!")
    else:
        print("⚠️  Some tests failed. Make sure the Flask app is running.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
