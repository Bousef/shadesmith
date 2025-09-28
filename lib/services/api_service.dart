import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/color_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.108.119.107:8080';
  
  // Scan RGB from images
  static Future<Map<String, dynamic>> scanRgbFromImages(List<File> imageFiles) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/scan-rgb-from-images'),
      );

      // Add files to request
      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to scan RGB: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error scanning RGB from images: $e');
    }
  }

  // RGB paint mixing - POST /rgb-paint-mixing (From API documentation)
  static Future<Map<String, dynamic>> rgbPaintMixing({
    required List<Map<String, int>> userColors,
    required Map<String, int> targetRgb,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rgb-paint-mixing'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_colors': userColors,
          'target_rgb': targetRgb,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to calculate paint mixing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating paint mixing: $e');
    }
  }

  // Complete paint mixing pipeline
  static Future<Map<String, dynamic>> completePaintMixing({
    required List<File> imageFiles,
    required Map<String, int> targetRgb,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/complete-paint-mixing'),
      );

      // Add files to request
      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      // Add target RGB as form data
      request.fields['target_rgb'] = json.encode(targetRgb);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to complete paint mixing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in complete paint mixing: $e');
    }
  }

  // RGB to CMYK conversion
  static Future<Map<String, dynamic>> rgbToCmyk({
    required int r,
    required int g,
    required int b,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rgb-to-cmyk'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'r': r,
          'g': g,
          'b': b,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to convert RGB to CMYK: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error converting RGB to CMYK: $e');
    }
  }

  // Multiple image conversion - POST /convert-multiple-images
  static Future<Map<String, dynamic>> convertMultipleImages(List<File> imageFiles) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/convert-multiple-images'),
      );

      // Add files to request
      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to convert images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error converting images: $e');
    }
  }

  // Generate random color - POST /generate-random-color
  static Future<Map<String, dynamic>> generateRandomColor() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-random-color'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate random color: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating random color: $e');
    }
  }

  // Generate multiple colors - POST /generate-multiple-colors
  static Future<Map<String, dynamic>> generateMultipleColors({required int count}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-multiple-colors'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'count': count}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate multiple colors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating multiple colors: $e');
    }
  }

  // Generate color palette - POST /generate-color-palette
  static Future<Map<String, dynamic>> generateColorPalette() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-color-palette'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate color palette: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating color palette: $e');
    }
  }

  // Check pipeline status - GET /pipeline-status
  static Future<Map<String, dynamic>> getPipelineStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pipeline-status'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get pipeline status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting pipeline status: $e');
    }
  }

  // Convert ColorModel to API format
  static Map<String, int> colorModelToApi(ColorModel color) {
    return {
      'r': color.red,
      'g': color.green,
      'b': color.blue,
    };
  }

  // Convert API format to ColorModel
  static ColorModel apiToColorModel(Map<String, dynamic> apiColor) {
    return ColorModel(
      red: apiColor['r'] ?? 0,
      green: apiColor['g'] ?? 0,
      blue: apiColor['b'] ?? 0,
    );
  }

  // Helper Methods for API Response Processing
  
  // Extract primary color from scan results
  static Map<String, dynamic>? extractPrimaryColor(Map<String, dynamic> scanResult) {
    try {
      if (scanResult['success'] == true) {
        final scannedResults = scanResult['scanned_results'] as List;
        
        for (final result in scannedResults) {
          if (result['success'] == true && result['primary_rgb'] != null) {
            final primaryRgb = result['primary_rgb'];
            return {
              'r': primaryRgb['r'],
              'g': primaryRgb['g'],
              'b': primaryRgb['b'],
              'pixel_fraction': primaryRgb['pixel_fraction'],
              'score': primaryRgb['score'],
            };
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Extract mixing ratios from paint mixing result
  static List<double>? extractMixingRatios(Map<String, dynamic> mixingResult) {
    try {
      if (mixingResult['success'] == true && mixingResult['closest_match'] != null) {
        final ratios = mixingResult['closest_match']['ratios'] as List;
        return ratios.map((ratio) => (ratio as num).toDouble()).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Extract accuracy information from paint mixing result
  static Map<String, dynamic>? extractAccuracyInfo(Map<String, dynamic> mixingResult) {
    try {
      if (mixingResult['success'] == true) {
        return {
          'distance': mixingResult['closest_match']?['distance'] ?? 0.0,
          'accuracy_level': mixingResult['accuracy_analysis']?['accuracy_level'] ?? 'Unknown',
          'description': mixingResult['accuracy_analysis']?['description'] ?? 'No description available',
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Extract generated colors from color generation results
  static List<Map<String, dynamic>>? extractGeneratedColors(Map<String, dynamic> generationResult) {
    try {
      if (generationResult['success'] == true) {
        if (generationResult['colors'] != null) {
          return List<Map<String, dynamic>>.from(generationResult['colors']);
        } else if (generationResult['color'] != null) {
          return [generationResult['color']];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
