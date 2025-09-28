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

---

## Database Endpoints

### 1. Create User Profile
**POST** `/create-user-profile`

Create a new user profile (stores only UID).

#### Request
```json
{
  "user_id": "user_123"
}
```

#### Response
```json
{
  "success": true,
  "message": "User profile created/updated successfully",
  "user_id": "user_123",
  "user_data": {
    "uid": "user_123",
    "createdAt": "2024-01-01T00:00:00Z",
    "lastActive": "2024-01-01T00:00:00Z"
  }
}
```

---

### 2. Save Color to Inventory
**POST** `/save-color`

Save a color to user's inventory.

#### Request
```json
{
  "user_id": "user_123",
  "color_data": {
    "name": "Ocean Blue",
    "rgb": {"r": 0, "g": 119, "b": 190},
    "hex": "#0077BE",
    "cmyk": {"c": 100, "m": 37, "y": 0, "k": 25},
    "source": "manual",
    "tags": ["blue", "ocean"]
  }
}
```

#### Response
```json
{
  "success": true,
  "message": "Color 'Ocean Blue' saved successfully",
  "color_id": "color_uuid_123",
  "color_data": {
    "id": "color_uuid_123",
    "name": "Ocean Blue",
    "type": "color",
    "rgb": {"r": 0, "g": 119, "b": 190},
    "hex": "#0077BE",
    "cmyk": {"c": 100, "m": 37, "y": 0, "k": 25},
    "addedAt": "2024-01-01T00:00:00Z",
    "source": "manual",
    "tags": ["blue", "ocean"]
  }
}
```

---

### 3. Get User Inventory
**GET** `/get-inventory/<user_id>`

Get all colors from user's inventory.

#### Parameters
- `limit` (optional): Maximum number of colors to return (default: 50)

#### Response
```json
{
  "success": true,
  "message": "Retrieved 2 colors from inventory",
  "user_id": "user_123",
  "colors": [
    {
      "id": "color_uuid_123",
      "name": "Ocean Blue",
      "type": "color",
      "rgb": {"r": 0, "g": 119, "b": 190},
      "hex": "#0077BE",
      "addedAt": "2024-01-01T00:00:00Z"
    }
  ],
  "total_colors": 2
}
```

---

### 4. Save Mixing Result
**POST** `/save-mixing-result`

Save a paint mixing result to user's history.

#### Request
```json
{
  "user_id": "user_123",
  "mixing_data": {
    "user_colors": [
      {"r": 0, "g": 119, "b": 190},
      {"r": 255, "g": 140, "b": 0}
    ],
    "target_rgb": {"r": 128, "g": 130, "b": 95},
    "result_rgb": {"r": 125, "g": 128, "b": 92},
    "mixing_ratios": [0.6, 0.4],
    "accuracy": {
      "distance": 5.2,
      "level": "Excellent"
    },
    "success": true
  }
}
```

#### Response
```json
{
  "success": true,
  "message": "Mixing result saved successfully",
  "mixing_id": "mixing_uuid_123",
  "mixing_data": {
    "id": "mixing_uuid_123",
    "type": "mixing_result",
    "user_colors": [
      {"r": 0, "g": 119, "b": 190},
      {"r": 255, "g": 140, "b": 0}
    ],
    "target_rgb": {"r": 128, "g": 130, "b": 95},
    "result_rgb": {"r": 125, "g": 128, "b": 92},
    "mixing_ratios": [0.6, 0.4],
    "accuracy": {
      "distance": 5.2,
      "level": "Excellent"
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "success": true
  }
}
```

---

### 5. Get Mixing History
**GET** `/get-mixing-history/<user_id>`

Get user's mixing history.

#### Parameters
- `limit` (optional): Maximum number of results to return (default: 20)

#### Response
```json
{
  "success": true,
  "message": "Retrieved 1 mixing results from history",
  "user_id": "user_123",
  "mixing_history": [
    {
      "id": "mixing_uuid_123",
      "type": "mixing_result",
      "user_colors": [
        {"r": 0, "g": 119, "b": 190},
        {"r": 255, "g": 140, "b": 0}
      ],
      "target_rgb": {"r": 128, "g": 130, "b": 95},
      "result_rgb": {"r": 125, "g": 128, "b": 92},
      "mixing_ratios": [0.6, 0.4],
      "accuracy": {
        "distance": 5.2,
        "level": "Excellent"
      },
      "createdAt": "2024-01-01T00:00:00Z",
      "success": true
    }
  ],
  "total_results": 1
}
```

---

### 6. Save Mixed Color to Inventory
**POST** `/save-mixed-color`

Save a mixed color to user's inventory.

#### Request
```json
{
  "user_id": "user_123",
  "mixed_color_data": {
    "name": "Custom Pink",
    "rgb": {"r": 255, "g": 192, "b": 203},
    "hex": "#FFC0CB",
    "cmyk": {"c": 0, "m": 25, "y": 20, "k": 0},
    "source_colors": [
      {"r": 255, "g": 0, "b": 0},
      {"r": 255, "g": 255, "b": 255}
    ],
    "mixing_ratios": [0.2, 0.8],
    "target_rgb": {"r": 255, "g": 192, "b": 203},
    "accuracy": {
      "distance": 12.04,
      "level": "Good"
    },
    "tags": ["pink", "custom", "mixed"]
  }
}
```

#### Response
```json
{
  "success": true,
  "message": "Mixed color 'Custom Pink' saved successfully",
  "mixed_color_id": "mixed_color_uuid_123",
  "mixed_color_data": {
    "id": "mixed_color_uuid_123",
    "name": "Custom Pink",
    "type": "mixed_color",
    "rgb": {"r": 255, "g": 192, "b": 203},
    "hex": "#FFC0CB",
    "cmyk": {"c": 0, "m": 25, "y": 20, "k": 0},
    "source_colors": [
      {"r": 255, "g": 0, "b": 0},
      {"r": 255, "g": 255, "b": 255}
    ],
    "mixing_ratios": [0.2, 0.8],
    "target_rgb": {"r": 255, "g": 192, "b": 203},
    "accuracy": {
      "distance": 12.04,
      "level": "Good"
    },
    "addedAt": "Server Timestamp",
    "source": "paint_mixing",
    "tags": ["pink", "custom", "mixed"]
  }
}
```

---

### 7. Save Recipe to Inventory
**POST** `/save-recipe`

Save a paint mixing recipe to user's inventory.

#### Request
```json
{
  "user_id": "user_123",
  "recipe_data": {
    "name": "Pink Recipe",
    "source_colors": [
      {"r": 255, "g": 0, "b": 0},
      {"r": 255, "g": 255, "b": 255}
    ],
    "mixing_ratios": [0.2, 0.8],
    "target_rgb": {"r": 255, "g": 192, "b": 203},
    "target_cmyk": {"c": 0, "m": 25, "y": 20, "k": 0},
    "result_rgb": {"r": 254, "g": 204, "b": 204},
    "accuracy": {
      "distance": 12.04,
      "level": "Good"
    },
    "instructions": [
      "Mix 20% red paint",
      "Mix 80% white paint",
      "Stir thoroughly"
    ],
    "tags": ["pink", "recipe", "custom"]
  }
}
```

#### Response
```json
{
  "success": true,
  "message": "Recipe 'Pink Recipe' saved successfully",
  "recipe_id": "recipe_uuid_123",
  "recipe_data": {
    "id": "recipe_uuid_123",
    "name": "Pink Recipe",
    "type": "recipe",
    "source_colors": [
      {"r": 255, "g": 0, "b": 0},
      {"r": 255, "g": 255, "b": 255}
    ],
    "mixing_ratios": [0.2, 0.8],
    "target_rgb": {"r": 255, "g": 192, "b": 203},
    "target_cmyk": {"c": 0, "m": 25, "y": 20, "k": 0},
    "result_rgb": {"r": 254, "g": 204, "b": 204},
    "accuracy": {
      "distance": 12.04,
      "level": "Good"
    },
    "instructions": [
      "Mix 20% red paint",
      "Mix 80% white paint",
      "Stir thoroughly"
    ],
    "addedAt": "Server Timestamp",
    "source": "paint_mixing",
    "tags": ["pink", "recipe", "custom"]
  }
}
```

---

### 8. Additional CRUD Endpoints
**Note**: These endpoints require Firestore database connection to function.

- `GET /get-color/<user_id>/<color_id>` - Get specific color
- `PUT /update-color/<user_id>/<color_id>` - Update color
- `DELETE /delete-color/<user_id>/<color_id>` - Delete color
- `GET /get-mixing-result/<user_id>/<mixing_id>` - Get specific mixing result
- `DELETE /delete-mixing-result/<user_id>/<mixing_id>` - Delete mixing result

---

## Database Setup

### Firestore Structure
```
users/
  {user_id}/
    uid: "user_123"
    createdAt: timestamp
    lastActive: timestamp
    
    inventory/
      {color_id}/
        id, name, type, rgb, hex, cmyk, addedAt, source, tags
      {mixed_color_id}/
        id, name, type, rgb, hex, cmyk, source_colors, 
        mixing_ratios, target_rgb, accuracy, addedAt, source, tags
      {recipe_id}/
        id, name, type, source_colors, mixing_ratios, 
        target_rgb, target_cmyk, result_rgb, accuracy, 
        instructions, addedAt, source, tags
    
    mixing_history/
      {mixing_id}/
        id, type, user_colors, target_rgb, result_rgb, 
        mixing_ratios, accuracy, createdAt, success
```

### Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /inventory/{itemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /mixing_history/{mixingId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## Support
For issues or questions, please check the pipeline status endpoint first to ensure all components are operational.
