# Shadesmith Multi-Agent Pipeline API Documentation

## Overview

The Shadesmith API provides a comprehensive multi-agent system for color analysis, image processing, and paint mixing calculations. The system consists of four specialized agents that work together to process images and calculate optimal paint mixing ratios.

## Architecture

### Multi-Agent System
- **Image Converter Agent**: Converts images to PNG format and handles resizing
- **RGB Scanner Agent**: Extracts RGB values using Google Cloud Vision API
- **Calculations Agent**: Performs color calculations, conversions, and paint mixing ratios
- **Parent Agent**: Orchestrates the complete pipeline and returns comprehensive results

## Base URL
```
http://localhost:8080
```

## Authentication
No authentication required for local development.

---

## Endpoints

### 1. Pipeline Status
**GET** `/pipeline-status`

Check the status of all pipeline components and available endpoints.

#### Response
```json
{
  "success": true,
  "message": "All pipeline components are operational",
  "available_endpoints": [
    "/complete-paint-mixing",
    "/rgb-to-cmyk",
    "/scan-rgb-from-images",
    "/convert-multiple-images",
    "/rgbToRatio",
    "/convert-to-png",
    "/test-vision"
  ],
  "pipeline_components": {
    "image_converter_agent": {
      "status": "active",
      "tools": 6,
      "description": "Converts images to PNG format"
    },
    "rgb_scanner_agent": {
      "status": "active",
      "tools": 4,
      "description": "Extracts RGB values using Google Cloud Vision"
    },
    "calculations_agent": {
      "status": "active",
      "tools": 8,
      "description": "Performs color calculations and paint mixing"
    },
    "parent_agent": {
      "status": "active",
      "tools": 6,
      "description": "Orchestrates the complete pipeline"
    }
  }
}
```

---

### 2. Complete Paint Mixing Pipeline
**POST** `/complete-paint-mixing`

The main endpoint that orchestrates the complete multi-agent pipeline for paint mixing analysis.

#### Request
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `files`: Image files (up to 3 images) - required
  - `target_rgb`: Target color in JSON format - required

#### Example Request
```bash
curl -X POST http://localhost:8080/complete-paint-mixing \
  -F "files=@red_image.jpg" \
  -F "files=@white_image.jpg" \
  -F 'target_rgb={"r": 255, "g": 192, "b": 203}'
```

#### Response
```json
{
  "success": true,
  "agent_chain": [
    "image_converter_agent",
    "rgb_scanner_agent",
    "calculations_agent",
    "parent_agent"
  ],
  "pipeline_steps": [
    {
      "step": 1,
      "agent": "Image Converter Agent",
      "action": "Convert multiple images to PNG",
      "input": ["uploads/red_image.jpg", "uploads/white_image.jpg"],
      "output": [
        {
          "index": 1,
          "input_file": "uploads/red_image.jpg",
          "output_file": "uploads/color_1_red_image.png",
          "output_filename": "color_1_red_image.png",
          "success": true
        }
      ],
      "result": {
        "success": true,
        "message": "Successfully converted 2 out of 2 images",
        "total_converted": 2,
        "converted_files": [...],
        "errors": []
      }
    }
  ],
  "final_result": {
    "pipeline_summary": {
      "images_processed": 2,
      "user_colors_count": 2,
      "total_steps": 3,
      "conversion_skipped": false,
      "agents_used": [
        "image_converter_agent",
        "rgb_scanner_agent",
        "calculations_agent",
        "parent_agent"
      ]
    },
    "user_colors": [
      {
        "r": 255,
        "g": 0,
        "b": 0,
        "pixel_fraction": 1.0,
        "score": 1.0
      }
    ],
    "target_color": {
      "rgb": {"r": 255, "g": 192, "b": 203},
      "cmyk": {"c": 0.0, "m": 24.71, "y": 20.39, "k": 0.0}
    },
    "resulting_color": {
      "rgb": {"r": 254, "g": 204, "b": 204},
      "cmyk": {"c": 0.0, "m": 19.69, "y": 19.69, "k": 0.39}
    },
    "mixing_ratios": [0.2, 0.8],
    "accuracy": {
      "distance": 12.04,
      "level": "Good"
    },
    "paint_mixing_instructions": {
      "success": true,
      "summary": "Mix 2 colors in the specified ratios",
      "total_parts": 1.0,
      "instructions": [
        {
          "color": "Color 1 (RGB: 255, 0, 0)",
          "instruction": "Add 20.0% of Color 1 (RGB: 255, 0, 0)",
          "percentage": 20.0,
          "ratio": 0.2
        },
        {
          "color": "Color 2 (RGB: 255, 255, 255)",
          "instruction": "Add 80.0% of Color 2 (RGB: 255, 255, 255)",
          "percentage": 80.0,
          "ratio": 0.8
        }
      ]
    }
  }
}
```

---

### 3. RGB to CMYK Conversion
**POST** `/rgb-to-cmyk`

Convert RGB color values to CMYK format.

#### Request
```json
{
  "r": 255,
  "g": 192,
  "b": 203
}
```

#### Response
```json
{
  "success": true,
  "rgb": {"r": 255, "g": 192, "b": 203},
  "cmyk": {"c": 0.0, "m": 24.71, "y": 20.39, "k": 0.0}
}
```

---

### 4. Paint Mixing Calculation
**POST** `/rgbToRatio`

Calculate optimal paint mixing ratios for a target color.

#### Request
```json
{
  "user_colors": [
    {"r": 255, "g": 0, "b": 0},
    {"r": 255, "g": 255, "b": 255}
  ],
  "target_rgb": {"r": 255, "g": 192, "b": 203}
}
```

#### Response
```json
{
  "success": true,
  "message": "Successfully calculated color mixing ratios",
  "target_rgb": {"r": 255, "g": 192, "b": 203},
  "target_cmyk": {"c": 0.0, "m": 24.71, "y": 20.39, "k": 0.0},
  "user_colors": [
    {"r": 255, "g": 0, "b": 0, "pixel_fraction": 1.0, "score": 1.0},
    {"r": 255, "g": 255, "b": 255, "pixel_fraction": 1.0, "score": 1.0}
  ],
  "user_colors_count": 2,
  "closest_match": {
    "ratios": [0.2, 0.8],
    "mixed_rgb": {"r": 254, "g": 204, "b": 204},
    "mixed_cmyk": {"c": 0.0, "m": 19.69, "y": 19.69, "k": 0.39},
    "distance": 12.04
  }
}
```

---

### 5. Multiple Image Conversion
**POST** `/convert-multiple-images`

Convert multiple images to PNG format for color analysis.

#### Request
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `files`: Image files (up to 3 images) - required

#### Example Request
```bash
curl -X POST http://localhost:8080/convert-multiple-images \
  -F "files=@image1.jpg" \
  -F "files=@image2.png"
```

#### Response
```json
{
  "success": true,
  "message": "Successfully converted 2 out of 2 images",
  "total_converted": 2,
  "converted_files": [
    {
      "index": 1,
      "input_file": "uploads/image1.jpg",
      "output_file": "uploads/color_1_image1.png",
      "output_filename": "color_1_image1.png",
      "success": true
    }
  ],
  "errors": []
}
```

---

### 6. RGB Scanning from Images
**POST** `/scan-rgb-from-images`

Extract RGB values from multiple images using Google Cloud Vision API.

#### Request
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `files`: Image files (up to 3 images) - required

#### Example Request
```bash
curl -X POST http://localhost:8080/scan-rgb-from-images \
  -F "files=@image1.jpg" \
  -F "files=@image2.png"
```

#### Response
```json
{
  "success": true,
  "message": "Successfully scanned RGB values from 2 out of 2 images",
  "total_scanned": 2,
  "scanned_results": [
    {
      "index": 1,
      "image_path": "uploads/color_1_image1.png",
      "success": true,
      "color_count": 1,
      "primary_rgb": {
        "r": 255,
        "g": 0,
        "b": 0,
        "pixel_fraction": 1.0,
        "score": 1.0
      },
      "all_colors": [
        {
          "r": 255,
          "g": 0,
          "b": 0,
          "pixel_fraction": 1.0,
          "score": 1.0
        }
      ]
    }
  ],
  "errors": []
}
```

---

### 7. Single Image Conversion
**POST** `/convert-to-png`

Convert a single image to PNG format.

#### Request
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `file`: Single image file - required

#### Example Request
```bash
curl -X POST http://localhost:8080/convert-to-png \
  -F "file=@image.jpg"
```

#### Response
```json
{
  "success": true,
  "message": "Image converted successfully",
  "input_file": "uploads/image.jpg",
  "output_file": "uploads/converted_image.png",
  "output_filename": "converted_image.png"
}
```

---

### 8. Shade Percentage Calculation
**POST** `/shade-percentage`

Calculate the shade percentage of a color.

#### Request
```json
{
  "rgb": {"r": 128, "g": 64, "b": 192}
}
```

#### Response
```json
{
  "success": true,
  "rgb": {"r": 128, "g": 64, "b": 192},
  "shade_percentage": 50.0,
  "brightness": 128.0
}
```

---

## Usage Examples

### Python Example
```python
import requests
import json

# Test complete paint mixing pipeline
def test_paint_mixing():
    files = [
        ('files', ('red.jpg', open('red.jpg', 'rb'), 'image/jpeg')),
        ('files', ('white.jpg', open('white.jpg', 'rb'), 'image/jpeg'))
    ]
    
    target_rgb = {"r": 255, "g": 192, "b": 203}  # Light pink
    
    response = requests.post(
        'http://localhost:8080/complete-paint-mixing',
        files=files,
        data={'target_rgb': json.dumps(target_rgb)}
    )
    
    # Close file handles
    for _, (_, file_handle, _) in files:
        file_handle.close()
    
    if response.status_code == 200:
        data = response.json()
        print(f"Mixing ratios: {data['final_result']['mixing_ratios']}")
        print(f"Accuracy: {data['final_result']['accuracy']['level']}")
        return data
    else:
        print(f"Error: {response.status_code}")
        return None

# Test RGB to CMYK conversion
def test_rgb_to_cmyk():
    rgb_data = {"r": 255, "g": 192, "b": 203}
    
    response = requests.post(
        'http://localhost:8080/rgb-to-cmyk',
        json=rgb_data
    )
    
    if response.status_code == 200:
        data = response.json()
        print(f"CMYK: {data['cmyk']}")
        return data
    else:
        print(f"Error: {response.status_code}")
        return None
```

### JavaScript Example
```javascript
// Test complete paint mixing pipeline
async function testPaintMixing() {
    const formData = new FormData();
    formData.append('files', redImageFile);
    formData.append('files', whiteImageFile);
    formData.append('target_rgb', JSON.stringify({r: 255, g: 192, b: 203}));
    
    try {
        const response = await fetch('http://localhost:8080/complete-paint-mixing', {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const data = await response.json();
            console.log('Mixing ratios:', data.final_result.mixing_ratios);
            console.log('Accuracy:', data.final_result.accuracy.level);
            return data;
        } else {
            console.error('Error:', response.status);
            return null;
        }
    } catch (error) {
        console.error('Error:', error);
        return null;
    }
}

// Test RGB to CMYK conversion
async function testRgbToCmyk() {
    const rgbData = {r: 255, g: 192, b: 203};
    
    try {
        const response = await fetch('http://localhost:8080/rgb-to-cmyk', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(rgbData)
        });
        
        if (response.ok) {
            const data = await response.json();
            console.log('CMYK:', data.cmyk);
            return data;
        } else {
            console.error('Error:', response.status);
            return null;
        }
    } catch (error) {
        console.error('Error:', error);
        return null;
    }
}
```

---

## Error Handling

### Common Error Responses
```json
{
  "error": "No files provided",
  "status": 400
}
```

```json
{
  "error": "Invalid target_rgb format",
  "status": 400
}
```

```json
{
  "error": "Image processing failed",
  "status": 500
}
```

### HTTP Status Codes
- **200**: Success
- **400**: Bad Request (invalid parameters)
- **500**: Internal Server Error (processing failed)

---

## Rate Limits
No rate limits currently implemented for local development.

---

## Dependencies
- **Google Cloud Vision API**: Required for RGB extraction
- **PIL (Pillow)**: Required for image processing
- **Flask**: Web framework
- **Google ADK**: Agent framework

---

## Setup Instructions

1. **Install dependencies**:
   ```bash
   pip install flask pillow google-cloud-vision google-adk
   ```

2. **Set up Google Cloud Vision API**:
   - Enable the Vision API in your Google Cloud project
   - Set up authentication credentials

3. **Run the Flask application**:
   ```bash
   python app.py
   ```

4. **Test the API**:
   ```bash
   curl http://localhost:8080/pipeline-status
   ```

---

## Support
For issues or questions, please check the pipeline status endpoint first to ensure all components are operational.
