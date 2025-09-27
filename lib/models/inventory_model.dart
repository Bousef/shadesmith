import 'color_model.dart';

class InventoryModel {
  final List<BaseColor> availableColors;

  InventoryModel({required this.availableColors});

  // Default inventory with basic colors
  factory InventoryModel.defaultInventory() {
    return InventoryModel(
      availableColors: [
        BaseColor(
          id: 'white',
          name: 'White',
          color: ColorModel(red: 255, green: 255, blue: 255),
          isAvailable: true,
        ),
        BaseColor(
          id: 'black',
          name: 'Black',
          color: ColorModel(red: 0, green: 0, blue: 0),
          isAvailable: true,
        ),
        BaseColor(
          id: 'red',
          name: 'Red',
          color: ColorModel(red: 255, green: 0, blue: 0),
          isAvailable: true,
        ),
        BaseColor(
          id: 'blue',
          name: 'Blue',
          color: ColorModel(red: 0, green: 0, blue: 255),
          isAvailable: true,
        ),
        BaseColor(
          id: 'yellow',
          name: 'Yellow',
          color: ColorModel(red: 255, green: 255, blue: 0),
          isAvailable: true,
        ),
        BaseColor(
          id: 'green',
          name: 'Green',
          color: ColorModel(red: 0, green: 255, blue: 0),
          isAvailable: false,
        ),
        BaseColor(
          id: 'purple',
          name: 'Purple',
          color: ColorModel(red: 128, green: 0, blue: 128),
          isAvailable: false,
        ),
        BaseColor(
          id: 'orange',
          name: 'Orange',
          color: ColorModel(red: 255, green: 165, blue: 0),
          isAvailable: false,
        ),
      ],
    );
  }
}

class BaseColor {
  final String id;
  final String name;
  final ColorModel color;
  final bool isAvailable;

  BaseColor({
    required this.id,
    required this.name,
    required this.color,
    required this.isAvailable,
  });

  BaseColor copyWith({
    String? id,
    String? name,
    ColorModel? color,
    bool? isAvailable,
  }) {
    return BaseColor(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

