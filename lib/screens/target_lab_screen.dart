import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/color_model.dart';
import '../models/inventory_model.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/inventory_service.dart';
import '../services/recipe_service.dart';

class TargetLabScreen extends StatefulWidget {
  final ColorModel targetColor;

  const TargetLabScreen({
    super.key,
    required this.targetColor,
  });

  @override
  State<TargetLabScreen> createState() => _TargetLabScreenState();
}

class _TargetLabScreenState extends State<TargetLabScreen> {
  List<BaseColor> _availableColors = [];
  List<BaseColor> _selectedColors = [];
  bool _isLoading = false;
  RecipeModel? _generatedRecipe;
  Map<String, dynamic>? _mixingResult;

  @override
  void initState() {
    super.initState();
    _loadAvailableColors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6B46C1), // Purple
              Color(0xFF4C51BF), // Indigo
              Color(0xFF3182CE), // Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: _isLoading 
                    ? _buildLoadingState()
                    : _mixingResult != null
                      ? _buildRecipeResult()
                      : _buildColorSelection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Lab',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Mix colors to achieve your target',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Calculating paint mixing ratios...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Color Display
          _buildTargetColorDisplay(),
          
          const SizedBox(height: 24),
          
          // Selected Colors
          if (_selectedColors.isNotEmpty) _buildSelectedColors(),
          
          const SizedBox(height: 24),
          
          // Available Colors
          _buildAvailableColors(),
          
          const SizedBox(height: 24),
          
          // Mix Button
          if (_selectedColors.length == 3) _buildMixButton(),
        ],
      ),
    );
  }

  Widget _buildTargetColorDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Target Color',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.targetColor.toFlutterColor(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.targetColor.toFlutterColor().withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.targetColor.hex,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RGB(${widget.targetColor.red}, ${widget.targetColor.green}, ${widget.targetColor.blue})',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Colors (${_selectedColors.length}/3)',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedColors.length,
            itemBuilder: (context, index) {
              final color = _selectedColors[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: color.color.toFlutterColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        color.name,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeSelectedColor(index),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Colors',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = _selectedColors.contains(color);
              final canSelect = _selectedColors.length < 3;
              
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    _removeSelectedColor(_selectedColors.indexOf(color));
                  } else if (canSelect) {
                    _addSelectedColor(color);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.color.toFlutterColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.3),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          color.name,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMixButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _calculateMixing,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                const Icon(Icons.blender, size: 20),
            const SizedBox(width: 8),
            Text(
              'Calculate Paint Mixing',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeResult() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Header
          Row(
            children: [
              Icon(
                Icons.science,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Paint Mixing Recipe',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Accuracy Display
          _buildAccuracyDisplay(),
          
          const SizedBox(height: 16),
          
          // Ingredients List
          Expanded(
            child: ListView.builder(
              itemCount: _generatedRecipe!.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = _generatedRecipe!.ingredients[index];
                return _buildIngredientCard(ingredient, index);
              },
            ),
          ),
          
          // Action Buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Recipe',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyDisplay() {
    final accuracy = _mixingResult!['accuracy_analysis']['accuracy_level'] as String;
    final distance = _mixingResult!['accuracy_analysis']['distance'] as double;
    
    Color accuracyColor;
    IconData accuracyIcon;
    
    switch (accuracy) {
      case 'Excellent':
        accuracyColor = Colors.green;
        accuracyIcon = Icons.star;
        break;
      case 'Good':
        accuracyColor = Colors.blue;
        accuracyIcon = Icons.thumb_up;
        break;
      case 'Fair':
        accuracyColor = Colors.orange;
        accuracyIcon = Icons.warning;
        break;
      default:
        accuracyColor = Colors.red;
        accuracyIcon = Icons.error;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accuracyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accuracyColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            accuracyIcon,
            color: accuracyColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accuracy: $accuracy',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Color Distance: ${distance.toStringAsFixed(1)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(ColorMix ingredient, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Color Swatch
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ingredient.color.toFlutterColor(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Ingredient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RGB(${ingredient.color.red}, ${ingredient.color.green}, ${ingredient.color.blue})',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${ingredient.percentage.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAvailableColors() async {
    try {
      final colors = await InventoryService.getAvailableColors();
      setState(() {
        _availableColors = colors;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load available colors: $e');
    }
  }

  void _addSelectedColor(BaseColor color) {
    setState(() {
      _selectedColors.add(color);
    });
  }

  void _removeSelectedColor(int index) {
    setState(() {
      _selectedColors.removeAt(index);
    });
  }

  Future<void> _calculateMixing() async {
    if (_selectedColors.length != 3) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userColors = _selectedColors.map((color) => 
        ApiService.colorModelToApi(color.color)
      ).toList();
      
      final targetRgb = ApiService.colorModelToApi(widget.targetColor);
      
      final result = await ApiService.rgbPaintMixing(
        userColors: userColors,
        targetRgb: targetRgb,
      );
      
      if (result['success'] == true) {
        final recipe = RecipeService.createRecipeFromApiResponse(
          apiResponse: result,
          targetColor: widget.targetColor,
        );
        
        setState(() {
          _mixingResult = result;
          _generatedRecipe = recipe;
          _isLoading = false;
        });
      } else {
        throw Exception(result['error'] ?? 'Failed to calculate mixing ratios');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to calculate mixing: $e');
    }
  }

  Future<void> _saveRecipe() async {
    if (_generatedRecipe == null) return;

    try {
      await RecipeService.saveRecipe(_generatedRecipe!);
      _showSuccessSnackBar('Recipe saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to save recipe: $e');
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedColors.clear();
      _mixingResult = null;
      _generatedRecipe = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
