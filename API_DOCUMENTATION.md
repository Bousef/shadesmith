# Shadesmith Multi-Agent Pipeline API Documentation

## Overview

The Shadesmith API provides a comprehensive multi-agent system for color analysis, image processing, and paint mixing calculations. The system consists of five specialized agents that work together to process images, calculate optimal paint mixing ratios, and generate random colors with descriptive names.

## Key Features

- **Enhanced Paint Mixing**: Uses realistic subtractive color theory where Blue + Yellow = Green
- **Multi-Agent Pipeline**: Orchestrated workflow for complex color analysis
- **Direct RGB Input**: Calculate mixing ratios without image uploads
- **Color Generation**: Generate random colors with creative descriptive names using AI
- **Google Cloud Vision**: Advanced RGB extraction from images

## Architecture

### Multi-Agent System
- **Image Converter Agent**: Converts images to PNG format and handles resizing
- **RGB Scanner Agent**: Extracts RGB values using Google Cloud Vision API
- **Calculations Agent**: Performs color calculations, conversions, and paint mixing ratios
- **Parent Agent**: Orchestrates the complete pipeline and returns comprehensive results
- **Color Generator Agent**: Generates random colors with descriptive names using Gemini AI

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
    "/rgb-paint-mixing",
    "/scan-rgb-from-images",
    "/convert-multiple-images",
    "/generate-random-color",
    "/generate-multiple-colors",
    "/generate-color-palette",
    "/pipeline-status"
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
    },
    "color_generator_agent": {
      "status": "active",
      "tools": 3,
      "description": "Generates random colors with descriptive names"
    }
  }
}
```

---

### 2. RGB Paint Mixing (Enhanced)
**POST** `/rgb-paint-mixing`

Calculate optimal paint mixing ratios using realistic subtractive color theory. This endpoint accepts RGB values directly without requiring image uploads.

#### Request
- **Content-Type**: `application/json`

```json
{
  "user_colors": [
    {"r": 255, "g": 255, "b": 255},
    {"r": 0, "g": 0, "b": 255},
    {"r": 255, "g": 255, "b": 0}
  ],
  "target_rgb": {"r": 0, "g": 255, "b": 0}
}
```

#### Example Request
```bash
curl -X POST http://localhost:8080/rgb-paint-mixing \
  -H "Content-Type: application/json" \
  -d '{
    "user_colors": [
      {"r": 255, "g": 0, "b": 0},
      {"r": 255, "g": 255, "b": 255}
    ],
    "target_rgb": {"r": 255, "g": 192, "b": 203}
  }'
```

#### Response
```json
{
  "success": true,
  "message": "Successfully calculated color mixing ratios using subtractive color theory",
  "target_rgb": {"r": 0, "g": 255, "b": 0},
  "target_cmyk": {"c": 100.0, "m": 0.0, "y": 100.0, "k": 0.0},
  "user_colors": [
    {"r": 255, "g": 255, "b": 255, "pixel_fraction": 1.0, "score": 1.0},
    {"r": 0, "g": 0, "b": 255, "pixel_fraction": 1.0, "score": 1.0},
    {"r": 255, "g": 255, "b": 0, "pixel_fraction": 1.0, "score": 1.0}
  ],
  "user_colors_count": 3,
  "closest_match": {
    "ratios": [0.5, 0.5],
    "mixed_rgb": {"r": 0, "g": 255, "b": 0},
    "mixed_cmyk": {"c": 100.0, "m": 0.0, "y": 100.0, "k": 0.0},
    "distance": 0.0
  },
  "accuracy_analysis": {
    "distance": 0.0,
    "accuracy_level": "Perfect",
    "description": "Target color achieved exactly with the calculated ratios"
  },
  "color_suggestions": {
    "achievable": true,
    "suggestions": []
  }
}
```

---

### 3. Multiple Image Conversion
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

### 4. RGB Scanning from Images
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
- **Google Generative AI (Gemini)**: Required for creative color naming
- **Python 3.8+**: Required for modern Python features

---

## Setup Instructions

1. **Install dependencies**:
   ```bash
   pip install flask pillow google-cloud-vision google-adk google-generativeai
   ```

2. **Set up Google Cloud Vision API**:
   - Enable the Vision API in your Google Cloud project
   - Set up authentication credentials

3. **Set up Gemini API**:
   - Get your Gemini API key from Google AI Studio
   - Set the `GEMINI_API_KEY` environment variable

4. **Run the Flask application**:
   ```bash
   python app.py
   ```

5. **Test the API**:
   ```bash
   curl http://localhost:8080/pipeline-status
   ```

---

## Support
For issues or questions, please check the pipeline status endpoint first to ensure all components are operational.
