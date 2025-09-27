#!/usr/bin/env python3
"""
Test the pipeline to create pink from red and white
"""

import requests
import json
import os
from PIL import Image, ImageDraw

def create_test_colors():
    """Create red and white test images"""
    print("🎨 Creating red and white test images...")
    
    # Create red image
    red_img = Image.new('RGB', (100, 100), color=(255, 0, 0))  # Pure red
    red_img.save('pexels-photo-4723038.jpeg', 'JPEG')
    print("   ✅ Created pexels-photo-4723038.jpeg (RGB: 255, 0, 0)")
    
    # Create white image
    white_img = Image.new('RGB', (100, 100), color=(255, 255, 255))  # Pure white
    white_img.save('solid-white-background-au1ygbma6jyibvyf.jpg', 'JPEG')
    print("   ✅ Created solid-white-background-au1ygbma6jyibvyf.jpg (RGB: 255, 255, 255)")
    
    return ['pexels-photo-4723038.jpeg', 'solid-white-background-au1ygbma6jyibvyf.jpg']

def test_pink_mixing():
    """Test creating pink from red and white"""
    print("\n🌸 Testing Pink Creation from Red and White...")
    
    # Create test images
    test_images = create_test_colors()
    
    # Target pink color (light pink)
    target_pink = {"r": 255, "g": 192, "b": 203}  # Light pink RGB
    
    print(f"🎯 Target Pink: RGB({target_pink['r']}, {target_pink['g']}, {target_pink['b']})")
    
    # Prepare the request
    files = []
    for image in test_images:
        files.append(('files', (image, open(image, 'rb'), 'image/jpeg')))
    
    try:
        # Make the API call
        response = requests.post(
            "http://localhost:8080/complete-paint-mixing",
            files=files,
            data={'target_rgb': json.dumps(target_pink)}
        )
        
        # Close file handles
        for _, (_, file_handle, _) in files:
            file_handle.close()
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Pink mixing pipeline successful!")
            
            # Display results
            print(f"\n📊 Pipeline Summary:")
            summary = data['final_result']['pipeline_summary']
            print(f"   Images processed: {summary['images_processed']}")
            print(f"   User colors: {summary['user_colors_count']}")
            
            print(f"\n🎨 Input Colors:")
            user_colors = data['final_result']['user_colors']
            for i, color in enumerate(user_colors, 1):
                print(f"   Color {i}: RGB({color['r']}, {color['g']}, {color['b']})")
            
            result_color = data['final_result']['resulting_color']['rgb']
            print(f"\n🎯 Target Pink: RGB({target_pink['r']}, {target_pink['g']}, {target_pink['b']})")
            print(f"🎨 Result Color: RGB({result_color['r']}, {result_color['g']}, {result_color['b']})")
            
            accuracy = data['final_result']['accuracy']
            print(f"📏 Accuracy: {accuracy['level']} (distance: {accuracy['distance']:.2f})")
            
            print(f"\n📋 Mixing Instructions:")
            instructions = data['final_result']['paint_mixing_instructions']['instructions']
            for i, instruction in enumerate(instructions, 1):
                print(f"   {i}. {instruction['instruction']}")
            
            # Show the mixing ratios
            ratios = data['final_result']['mixing_ratios']
            print(f"\n🔢 Mixing Ratios:")
            print(f"   Red: {ratios[0]:.1%}")
            print(f"   White: {ratios[1]:.1%}")
            
            return True
        else:
            print(f"❌ Pink mixing failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Pink mixing error: {e}")
        return False

def test_different_pink_shades():
    """Test different shades of pink"""
    print("\n🌈 Testing Different Pink Shades...")
    
    pink_shades = [
        {"name": "Light Pink", "rgb": {"r": 255, "g": 192, "b": 203}},
        {"name": "Hot Pink", "rgb": {"r": 255, "g": 20, "b": 147}},
        {"name": "Deep Pink", "rgb": {"r": 255, "g": 0, "b": 127}},
        {"name": "Pale Pink", "rgb": {"r": 250, "g": 218, "b": 221}}
    ]
    
    for shade in pink_shades:
        print(f"\n🎨 Testing {shade['name']}: RGB({shade['rgb']['r']}, {shade['rgb']['g']}, {shade['rgb']['b']})")
        
        # Use the same red and white images
        files = [
            ('files', ('pexels-photo-4723038.jpeg', open('pexels-photo-4723038.jpeg', 'rb'), 'image/jpeg')),
            ('files', ('solid-white-background-au1ygbma6jyibvyf.jpg', open('solid-white-background-au1ygbma6jyibvyf.jpg', 'rb'), 'image/jpeg'))
        ]
        
        try:
            response = requests.post(
                "http://localhost:8080/complete-paint-mixing",
                files=files,
                data={'target_rgb': json.dumps(shade['rgb'])}
            )
            
            # Close file handles
            for _, (_, file_handle, _) in files:
                file_handle.close()
            
            if response.status_code == 200:
                data = response.json()
                ratios = data['final_result']['mixing_ratios']
                accuracy = data['final_result']['accuracy']
                result = data['final_result']['resulting_color']['rgb']
                
                print(f"   Result: RGB({result['r']}, {result['g']}, {result['b']})")
                print(f"   Ratios: Red {ratios[0]:.1%}, White {ratios[1]:.1%}")
                print(f"   Accuracy: {accuracy['level']} (distance: {accuracy['distance']:.2f})")
            else:
                print(f"   ❌ Failed: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error: {e}")

def cleanup():
    """Clean up test files"""
    print("\n🧹 Cleaning up test files...")
    test_files = ['pexels-photo-4723038.jpeg', 'solid-white-background-au1ygbma6jyibvyf.jpg']
    for file in test_files:
        if os.path.exists(file):
            os.remove(file)
            print(f"   ✅ Removed {file}")

def main():
    """Run pink mixing tests"""
    print("🌸 Starting Pink Mixing Tests")
    print("=" * 50)
    
    try:
        # Test basic pink mixing
        success = test_pink_mixing()
        
        if success:
            # Test different pink shades
            test_different_pink_shades()
        
        print("\n" + "=" * 50)
        if success:
            print("🎉 Pink mixing tests completed successfully!")
            print("💡 Tip: For lighter pink, use more white. For deeper pink, use more red.")
        else:
            print("⚠️  Pink mixing tests failed.")
            
    finally:
        cleanup()

if __name__ == "__main__":
    main()
