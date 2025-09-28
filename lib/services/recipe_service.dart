import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_model.dart';
import '../models/recipe_model.dart';
import '../models/inventory_model.dart';

class RecipeService {
  static const String _recipesKey = 'user_recipes';
  
  // Save recipe to local storage
  static Future<void> saveRecipe(RecipeModel recipe) async {
    try {
      final recipes = await getAllRecipes();
      recipes.add(recipe);
      
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = json.encode(recipes.map((r) => _recipeToJson(r)).toList());
      await prefs.setString(_recipesKey, recipesJson);
    } catch (e) {
      print('Error saving recipe: $e');
      rethrow;
    }
  }

  // Get all saved recipes
  static Future<List<RecipeModel>> getAllRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getString(_recipesKey);
      
      if (recipesJson != null) {
        final recipesData = json.decode(recipesJson) as List;
        return recipesData.map((data) => _recipeFromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading recipes: $e');
      return [];
    }
  }

  // Delete recipe
  static Future<void> deleteRecipe(String recipeId) async {
    try {
      final recipes = await getAllRecipes();
      recipes.removeWhere((recipe) => recipe.id == recipeId);
      
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = json.encode(recipes.map((r) => _recipeToJson(r)).toList());
      await prefs.setString(_recipesKey, recipesJson);
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }

  // Clear all recipe data (for logout)
  static Future<void> clearRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recipesKey);
    } catch (e) {
      print('Error clearing recipes: $e');
    }
  }

  // Create recipe from API response
  static RecipeModel createRecipeFromApiResponse({
    required Map<String, dynamic> apiResponse,
    required ColorModel targetColor,
    List<Map<String, int>>? userColors, // Optional - can be extracted from response
    List<dynamic>? selectedColors, // Optional - selected colors with names from inventory
  }) {
    try {
      // Handle /rgb-paint-mixing API response structure (from API documentation)
      if (apiResponse.containsKey('closest_match') && apiResponse.containsKey('user_colors')) {
        final closestMatch = apiResponse['closest_match'];
        final ratios = closestMatch['ratios'] as List;
        final responseUserColors = apiResponse['user_colors'] as List;
        
        final ingredients = <ColorMix>[];
        
        for (int i = 0; i < responseUserColors.length && i < ratios.length; i++) {
          final colorData = responseUserColors[i];
          final ratio = (ratios[i] as num).toDouble();
          
          final colorModel = ColorModel(
            red: colorData['r'] as int,
            green: colorData['g'] as int,
            blue: colorData['b'] as int,
          );
          
          // Use actual color name from selected colors if available, otherwise use hex
          String colorName = colorModel.hex;
          if (selectedColors != null && i < selectedColors.length) {
            try {
              final selectedColor = selectedColors[i] as BaseColor;
              colorName = selectedColor.name;
            } catch (e) {
              // If casting fails, keep the hex name
              colorName = colorModel.hex;
            }
          }
          
          ingredients.add(ColorMix(
            color: colorModel,
            percentage: ratio * 100,
            name: colorName,
          ));
        }
        
        return RecipeModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          targetColor: targetColor,
          ingredients: ingredients,
          accuracy: (closestMatch['distance'] as num).toDouble(),
          createdAt: DateTime.now(),
        );
      }
      
      // Handle /rgbToRatio API response structure (fallback)
      else if (apiResponse.containsKey('closest_match') && userColors != null) {
        final closestMatch = apiResponse['closest_match'];
        final ratios = closestMatch['ratios'] as List;
        
        final ingredients = <ColorMix>[];
        
        for (int i = 0; i < userColors.length && i < ratios.length; i++) {
          final colorData = userColors[i];
          final ratio = (ratios[i] as num).toDouble();
          
          final colorModel = ColorModel(
            red: colorData['r'] as int,
            green: colorData['g'] as int,
            blue: colorData['b'] as int,
          );
          
          // Use actual color name from selected colors if available, otherwise use hex
          String colorName = colorModel.hex;
          if (selectedColors != null && i < selectedColors.length) {
            try {
              final selectedColor = selectedColors[i] as BaseColor;
              colorName = selectedColor.name;
            } catch (e) {
              // If casting fails, keep the hex name
              colorName = colorModel.hex;
            }
          }
          
          ingredients.add(ColorMix(
            color: colorModel,
            percentage: ratio * 100,
            name: colorName,
          ));
        }
        
        return RecipeModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          targetColor: targetColor,
          ingredients: ingredients,
          accuracy: (closestMatch['distance'] as num).toDouble(),
          createdAt: DateTime.now(),
        );
      }
      
      // Handle /complete-paint-mixing API response structure
      else if (apiResponse.containsKey('final_result')) {
        final finalResult = apiResponse['final_result'];
        final paintInstructions = finalResult['paint_mixing_instructions'];
        final instructions = paintInstructions['instructions'] as List;
        
        final ingredients = <ColorMix>[];
        
        for (final instruction in instructions) {
          ingredients.add(ColorMix(
            color: ColorModel(
              red: 128, // Default color since instruction doesn't contain RGB
              green: 128,
              blue: 128,
            ),
            percentage: (instruction['percentage'] as num).toDouble(),
            name: instruction['color'],
          ));
        }
        
        final accuracy = finalResult['accuracy'];
        
        return RecipeModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          targetColor: targetColor,
          ingredients: ingredients,
          accuracy: (accuracy['distance'] as num).toDouble(),
          createdAt: DateTime.now(),
        );
      }
      
      // Fallback for unknown response structure
      else {
        throw Exception('Unknown API response structure');
      }
    } catch (e) {
      print('Error creating recipe from API response: $e');
      rethrow;
    }
  }

  // Create recipe from inventory colors
  static RecipeModel createRecipeFromInventoryColors({
    required ColorModel targetColor,
    required List<BaseColor> selectedColors,
    required List<double> ratios,
  }) {
    try {
      final ingredients = <ColorMix>[];
      
      for (int i = 0; i < selectedColors.length && i < ratios.length; i++) {
        ingredients.add(ColorMix(
          color: selectedColors[i].color,
          percentage: ratios[i] * 100,
          name: selectedColors[i].name,
        ));
      }
      
      return RecipeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetColor: targetColor,
        ingredients: ingredients,
        accuracy: 0.0, // Will be calculated by API
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error creating recipe from inventory colors: $e');
      rethrow;
    }
  }

  // Get recipes by date range
  static Future<List<RecipeModel>> getRecipesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allRecipes = await getAllRecipes();
    return allRecipes.where((recipe) =>
        recipe.createdAt.isAfter(startDate) &&
        recipe.createdAt.isBefore(endDate)
    ).toList();
  }

  // Get recipes by target color similarity
  static Future<List<RecipeModel>> getRecipesByColorSimilarity(ColorModel targetColor) async {
    final allRecipes = await getAllRecipes();
    
    // Sort by color similarity
    allRecipes.sort((a, b) {
      final distanceA = _calculateColorDistance(targetColor, a.targetColor);
      final distanceB = _calculateColorDistance(targetColor, b.targetColor);
      return distanceA.compareTo(distanceB);
    });
    
    return allRecipes;
  }

  // Calculate color distance (simple Euclidean distance)
  static double _calculateColorDistance(ColorModel color1, ColorModel color2) {
    final rDiff = color1.red - color2.red;
    final gDiff = color1.green - color2.green;
    final bDiff = color1.blue - color2.blue;
    
    return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
  }

  // Convert RecipeModel to JSON
  static Map<String, dynamic> _recipeToJson(RecipeModel recipe) {
    return {
      'id': recipe.id,
      'targetColor': {
        'red': recipe.targetColor.red,
        'green': recipe.targetColor.green,
        'blue': recipe.targetColor.blue,
        'opacity': recipe.targetColor.opacity,
      },
      'ingredients': recipe.ingredients.map((ingredient) => {
        'color': {
          'red': ingredient.color.red,
          'green': ingredient.color.green,
          'blue': ingredient.color.blue,
          'opacity': ingredient.color.opacity,
        },
        'percentage': ingredient.percentage,
        'name': ingredient.name,
      }).toList(),
      'accuracy': recipe.accuracy,
      'createdAt': recipe.createdAt.toIso8601String(),
    };
  }

  // Convert JSON to RecipeModel
  static RecipeModel _recipeFromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      targetColor: ColorModel(
        red: json['targetColor']['red'],
        green: json['targetColor']['green'],
        blue: json['targetColor']['blue'],
        opacity: json['targetColor']['opacity'] ?? 1.0,
      ),
      ingredients: (json['ingredients'] as List).map((ingredient) => ColorMix(
        color: ColorModel(
          red: ingredient['color']['red'],
          green: ingredient['color']['green'],
          blue: ingredient['color']['blue'],
          opacity: ingredient['color']['opacity'] ?? 1.0,
        ),
        percentage: (ingredient['percentage'] as num).toDouble(),
        name: ingredient['name'],
      )).toList(),
      accuracy: (json['accuracy'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
