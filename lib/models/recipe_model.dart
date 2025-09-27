import 'color_model.dart';

class RecipeModel {
  final String id;
  final ColorModel targetColor;
  final List<ColorMix> ingredients;
  final double accuracy; // ΔE value (lower is better)
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.targetColor,
    required this.ingredients,
    required this.accuracy,
    required this.createdAt,
  });

  // Mock factory for demo
  factory RecipeModel.mock(ColorModel targetColor) {
    return RecipeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      targetColor: targetColor,
      ingredients: [
        ColorMix(
          color: ColorModel(red: 255, green: 255, blue: 255), // White
          percentage: 45.0,
          name: 'White',
        ),
        ColorMix(
          color: ColorModel(red: 255, green: 200, blue: 0), // Yellow
          percentage: 30.0,
          name: 'Yellow',
        ),
        ColorMix(
          color: ColorModel(red: 255, green: 100, blue: 100), // Red
          percentage: 25.0,
          name: 'Red',
        ),
      ],
      accuracy: 2.3, // Good accuracy
      createdAt: DateTime.now(),
    );
  }
}

class ColorMix {
  final ColorModel color;
  final double percentage;
  final String name;

  ColorMix({
    required this.color,
    required this.percentage,
    required this.name,
  });
}

