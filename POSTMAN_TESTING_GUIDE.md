# Postman Testing Guide for Shadesmith API

## Setup Instructions

### 1. Import the Collection
1. Open Postman
2. Click **Import** button
3. Select the `Shadesmith_API_Postman_Collection.json` file
4. The collection will be imported with all endpoints pre-configured

### 2. Set Environment Variables
- The collection uses `{{base_url}}` variable set to `http://localhost:8080`
- You can modify this in the collection variables if needed

## Testing Each Endpoint

### 1. Pipeline Status (GET)
**Purpose**: Check if all agents are operational
- **Method**: GET
- **URL**: `http://localhost:8080/pipeline-status`
- **Expected Response**: Status of all 4 agents (image_converter, rgb_scanner, calculations, parent)

### 2. Project Info (GET)
**Purpose**: Get project information
- **Method**: GET
- **URL**: `http://localhost:8080/project-info`
- **Expected Response**: Project details and description

### 3. RGB to CMYK Conversion (POST)
**Purpose**: Convert RGB color to CMYK format
- **Method**: POST
- **URL**: `http://localhost:8080/rgb-to-cmyk`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "r": 255,
  "g": 192,
  "b": 203
}
```
- **Expected Response**: CMYK values for the input RGB

### 4. Paint Mixing Calculation (POST)
**Purpose**: Calculate optimal paint mixing ratios
- **Method**: POST
- **URL**: `http://localhost:8080/rgbToRatio`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "user_colors": [
    {"r": 255, "g": 0, "b": 0},
    {"r": 255, "g": 255, "b": 255}
  ],
  "target_rgb": {"r": 255, "g": 192, "b": 203}
}
```
- **Expected Response**: Mixing ratios and accuracy

### 5. Shade Percentage (POST)
**Purpose**: Calculate shade percentage
- **Method**: POST
- **URL**: `http://localhost:8080/shade-percentage`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "light_value": 128,
  "max_light": 255
}
```
- **Expected Response**: Shade percentage and brightness

### 6. Single Image Conversion (POST)
**Purpose**: Convert one image to PNG
- **Method**: POST
- **URL**: `http://localhost:8080/convert-to-png`
- **Body**: form-data
  - Key: `file`, Type: File, Value: Select an image file
- **Expected Response**: Conversion success and download URL

### 7. Multiple Image Conversion (POST)
**Purpose**: Convert multiple images to PNG
- **Method**: POST
- **URL**: `http://localhost:8080/convert-multiple-images`
- **Body**: form-data
  - Key: `files`, Type: File, Value: Select first image
  - Key: `files`, Type: File, Value: Select second image (optional)
  - Key: `files`, Type: File, Value: Select third image (optional)
- **Expected Response**: List of converted files

### 8. RGB Scanning (POST)
**Purpose**: Extract RGB values from images
- **Method**: POST
- **URL**: `http://localhost:8080/scan-rgb-from-images`
- **Body**: form-data
  - Key: `files`, Type: File, Value: Select image files
- **Expected Response**: RGB values extracted from each image

### 9. Complete Paint Mixing Pipeline (POST) ⭐
**Purpose**: Full pipeline test - most comprehensive endpoint
- **Method**: POST
- **URL**: `http://localhost:8080/complete-paint-mixing`
- **Body**: form-data
  - Key: `files`, Type: File, Value: Select first color image
  - Key: `files`, Type: File, Value: Select second color image
  - Key: `target_rgb`, Type: Text, Value: `{"r": 255, "g": 192, "b": 203}`
- **Expected Response**: Complete pipeline results with mixing instructions

### 10. Test Vision API (POST)
**Purpose**: Test Google Cloud Vision integration
- **Method**: POST
- **URL**: `http://localhost:8080/test-vision`
- **Body**: form-data
  - Key: `file`, Type: File, Value: Select an image
- **Expected Response**: Dominant colors detected by Vision API

### 11. List Files (GET)
**Purpose**: See all converted files
- **Method**: GET
- **URL**: `http://localhost:8080/list-files`
- **Expected Response**: List of available PNG files

## Test Scenarios

### Scenario 1: Basic Functionality Test
1. **Pipeline Status** → Should show all agents active
2. **RGB to CMYK** → Test with RGB(255, 192, 203)
3. **Paint Mixing** → Test with red + white → pink

### Scenario 2: Image Processing Test
1. **Single Image Conversion** → Upload any image file
2. **Multiple Image Conversion** → Upload 2-3 images
3. **RGB Scanning** → Upload color images
4. **List Files** → Check converted files

### Scenario 3: Complete Pipeline Test
1. **Complete Paint Mixing** → Upload red + white images, target pink
2. Verify all 4 agents executed successfully
3. Check mixing ratios and accuracy

### Scenario 4: Error Handling Test
1. **RGB to CMYK** → Send invalid JSON
2. **Image Conversion** → Upload non-image file
3. **Paint Mixing** → Send missing parameters

## Sample Test Images

### For Paint Mixing Tests:
- **Red Image**: Solid red color (RGB: 255, 0, 0)
- **White Image**: Solid white color (RGB: 255, 255, 255)
- **Blue Image**: Solid blue color (RGB: 0, 0, 255)

### Target Colors to Test:
- **Light Pink**: `{"r": 255, "g": 192, "b": 203}`
- **Orange**: `{"r": 255, "g": 165, "b": 0}`
- **Purple**: `{"r": 128, "g": 0, "b": 128}`
- **Green**: `{"r": 0, "g": 128, "b": 0}`

## Expected Response Formats

### Successful Response:
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {...}
}
```

### Error Response:
```json
{
  "error": "Error description",
  "status": 400
}
```

### Complete Pipeline Response:
```json
{
  "success": true,
  "agent_chain": ["image_converter_agent", "rgb_scanner_agent", "calculations_agent", "parent_agent"],
  "pipeline_steps": [...],
  "final_result": {
    "pipeline_summary": {...},
    "user_colors": [...],
    "target_color": {...},
    "resulting_color": {...},
    "mixing_ratios": [...],
    "accuracy": {...},
    "paint_mixing_instructions": {...}
  }
}
```

## Troubleshooting

### Common Issues:
1. **Connection Refused**: Ensure Flask app is running on port 8080
2. **File Upload Errors**: Check file size and format (max 3 images, common formats)
3. **Vision API Errors**: Ensure Google Cloud credentials are set up
4. **JSON Parse Errors**: Validate JSON format in request body

### Debug Steps:
1. Check Flask app logs in terminal
2. Verify all agents are loaded in pipeline status
3. Test with simple endpoints first (RGB to CMYK)
4. Use valid image files for upload tests

## Performance Notes
- **Image Processing**: May take 2-5 seconds per image
- **Vision API**: Depends on Google Cloud response time
- **Complete Pipeline**: Typically 5-15 seconds for 2-3 images
- **File Cleanup**: Automatic cleanup after 1 hour

## Tips for Effective Testing
1. **Start Simple**: Test basic endpoints first
2. **Use Real Images**: Test with actual color images, not just solid colors
3. **Test Edge Cases**: Try different color combinations
4. **Monitor Logs**: Watch Flask app output for debugging
5. **Save Responses**: Use Postman's save response feature for analysis
