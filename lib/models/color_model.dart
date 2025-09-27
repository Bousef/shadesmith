import 'package:flutter/material.dart';

class ColorModel {
  final int red;
  final int green;
  final int blue;
  final double opacity;

  ColorModel({
    required this.red,
    required this.green,
    required this.blue,
    this.opacity = 1.0,
  });

  // Convert to HEX
  String get hex {
    return '#${red.toRadixString(16).padLeft(2, '0')}'
           '${green.toRadixString(16).padLeft(2, '0')}'
           '${blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  // Convert to RGB
  String get rgb => 'RGB($red, $green, $blue)';

  // Convert to HSL (simplified)
  Map<String, double> get hsl {
    final r = red / 255.0;
    final g = green / 255.0;
    final b = blue / 255.0;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final delta = max - min;

    double hue = 0;
    double saturation = 0;
    final lightness = (max + min) / 2;

    if (delta != 0) {
      saturation = lightness > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      if (max == r) {
        hue = ((g - b) / delta) % 6;
      } else if (max == g) {
        hue = (b - r) / delta + 2;
      } else {
        hue = (r - g) / delta + 4;
      }
      hue *= 60;
      if (hue < 0) hue += 360;
    }

    return {
      'hue': hue,
      'saturation': saturation * 100,
      'lightness': lightness * 100,
    };
  }

  // Factory constructor from Flutter Color
  factory ColorModel.fromFlutterColor(dynamic color) {
    return ColorModel(
      red: color.red,
      green: color.green,
      blue: color.blue,
      opacity: color.opacity,
    );
  }

  // Convert to Flutter Color
  dynamic toFlutterColor() {
    return Color.fromRGBO(red, green, blue, opacity);
  }
}

