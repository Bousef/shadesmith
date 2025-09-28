import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_model.dart';
import '../models/inventory_model.dart';

class InventoryService {
  static const String _inventoryKey = 'user_inventory';
  
  // Get user's inventory
  static Future<InventoryModel> getInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryJson = prefs.getString(_inventoryKey);
      
      if (inventoryJson != null) {
        final inventoryData = json.decode(inventoryJson);
        return _fromJson(inventoryData);
      } else {
        // Return default inventory if none exists
        return InventoryModel.defaultInventory();
      }
    } catch (e) {
      print('Error loading inventory: $e');
      return InventoryModel.defaultInventory();
    }
  }

  // Add color to inventory
  static Future<void> addColorToInventory({
    required String name,
    required ColorModel color,
    bool isAvailable = true,
  }) async {
    try {
      final inventory = await getInventory();
      final newColor = BaseColor(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        color: color,
        isAvailable: isAvailable,
      );
      
      final updatedColors = List<BaseColor>.from(inventory.availableColors);
      updatedColors.add(newColor);
      
      final updatedInventory = InventoryModel(availableColors: updatedColors);
      await _saveInventory(updatedInventory);
    } catch (e) {
      print('Error adding color to inventory: $e');
      rethrow;
    }
  }

  // Update color availability
  static Future<void> updateColorAvailability(String colorId, bool isAvailable) async {
    try {
      final inventory = await getInventory();
      final updatedColors = inventory.availableColors.map((color) {
        if (color.id == colorId) {
          return color.copyWith(isAvailable: isAvailable);
        }
        return color;
      }).toList();
      
      final updatedInventory = InventoryModel(availableColors: updatedColors);
      await _saveInventory(updatedInventory);
    } catch (e) {
      print('Error updating color availability: $e');
      rethrow;
    }
  }

  // Remove color from inventory
  static Future<void> removeColorFromInventory(String colorId) async {
    try {
      final inventory = await getInventory();
      final updatedColors = inventory.availableColors
          .where((color) => color.id != colorId)
          .toList();
      
      final updatedInventory = InventoryModel(availableColors: updatedColors);
      await _saveInventory(updatedInventory);
    } catch (e) {
      print('Error removing color from inventory: $e');
      rethrow;
    }
  }

  // Get available colors for mixing
  static Future<List<BaseColor>> getAvailableColors() async {
    final inventory = await getInventory();
    return inventory.availableColors.where((color) => color.isAvailable).toList();
  }

  // Check if color exists in inventory
  static Future<bool> colorExistsInInventory(ColorModel color) async {
    final inventory = await getInventory();
    return inventory.availableColors.any((baseColor) =>
        baseColor.color.red == color.red &&
        baseColor.color.green == color.green &&
        baseColor.color.blue == color.blue);
  }

  // Find closest color in inventory
  static Future<BaseColor?> findClosestColor(ColorModel targetColor) async {
    final inventory = await getInventory();
    BaseColor? closestColor;
    double minDistance = double.infinity;

    for (final color in inventory.availableColors) {
      final distance = _calculateColorDistance(targetColor, color.color);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = color;
      }
    }

    return closestColor;
  }

  // Calculate color distance (simple Euclidean distance)
  static double _calculateColorDistance(ColorModel color1, ColorModel color2) {
    final rDiff = color1.red - color2.red;
    final gDiff = color1.green - color2.green;
    final bDiff = color1.blue - color2.blue;
    
    return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
  }

  // Save inventory to local storage
  static Future<void> _saveInventory(InventoryModel inventory) async {
    final prefs = await SharedPreferences.getInstance();
    final inventoryJson = json.encode(_toJson(inventory));
    await prefs.setString(_inventoryKey, inventoryJson);
  }

  // Convert InventoryModel to JSON
  static Map<String, dynamic> _toJson(InventoryModel inventory) {
    return {
      'availableColors': inventory.availableColors.map((color) => {
        'id': color.id,
        'name': color.name,
        'color': {
          'red': color.color.red,
          'green': color.color.green,
          'blue': color.color.blue,
          'opacity': color.color.opacity,
        },
        'isAvailable': color.isAvailable,
      }).toList(),
    };
  }

  // Convert JSON to InventoryModel
  static InventoryModel _fromJson(Map<String, dynamic> json) {
    final colorsData = json['availableColors'] as List;
    final colors = colorsData.map((colorData) => BaseColor(
      id: colorData['id'],
      name: colorData['name'],
      color: ColorModel(
        red: colorData['color']['red'],
        green: colorData['color']['green'],
        blue: colorData['color']['blue'],
        opacity: colorData['color']['opacity'] ?? 1.0,
      ),
      isAvailable: colorData['isAvailable'],
    )).toList();

    return InventoryModel(availableColors: colors);
  }
}
