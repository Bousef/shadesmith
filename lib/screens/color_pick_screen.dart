import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/color_model.dart';
import '../services/inventory_service.dart';
import 'target_lab_screen.dart';

class ColorPickScreen extends StatefulWidget {
  const ColorPickScreen({super.key});

  @override
  State<ColorPickScreen> createState() => _ColorPickScreenState();
}

class _ColorPickScreenState extends State<ColorPickScreen> {
  final TextEditingController _redController = TextEditingController();
  final TextEditingController _greenController = TextEditingController();
  final TextEditingController _blueController = TextEditingController();
  final TextEditingController _hexController = TextEditingController();
  
  ColorModel? _currentColor;
  bool _isValidColor = false;

  @override
  void initState() {
    super.initState();
    _redController.addListener(_updateColor);
    _greenController.addListener(_updateColor);
    _blueController.addListener(_updateColor);
    _hexController.addListener(_updateColorFromHex);
  }

  @override
  void dispose() {
    _redController.dispose();
    _greenController.dispose();
    _blueController.dispose();
    _hexController.dispose();
    super.dispose();
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Color Preview
                        _buildColorPreview(),
                        
                        const SizedBox(height: 24),
                        
                        // Input Fields
                        _buildInputFields(),
                        
                        const SizedBox(height: 24),
                        
                        // Quick Color Buttons
                        _buildQuickColorButtons(),
                        
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        if (_isValidColor) _buildActionButtons(),
                        
                        // Add some bottom padding for better scrolling
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
          Text(
            'Color Picker',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPreview() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: _currentColor?.toFlutterColor() ?? Colors.grey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_currentColor?.toFlutterColor() ?? Colors.grey).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentColor != null) ...[
            Text(
              _currentColor!.hex,
              style: GoogleFonts.inter(
                fontSize: 18,
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
            const SizedBox(height: 4),
            Text(
              'RGB(${_currentColor!.red}, ${_currentColor!.green}, ${_currentColor!.blue})',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ] else ...[
            Icon(
              Icons.color_lens,
              size: 40,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter RGB values',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RGB Values',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        
        // RGB Input Fields
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _redController,
                label: 'Red',
                maxValue: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _greenController,
                label: 'Green',
                maxValue: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _blueController,
                label: 'Blue',
                maxValue: 255,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // HEX Input Field
        Text(
          'HEX Value',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _hexController,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: '#FF0000',
            hintStyle: GoogleFonts.inter(
              color: Colors.white54,
            ),
            prefixIcon: const Icon(
              Icons.tag,
              color: Colors.white70,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required int maxValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.inter(
              color: Colors.white54,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickColorButtons() {
    final quickColors = [
      {'name': 'Red', 'color': const Color(0xFFFF0000)},
      {'name': 'Green', 'color': const Color(0xFF00FF00)},
      {'name': 'Blue', 'color': const Color(0xFF0000FF)},
      {'name': 'Yellow', 'color': const Color(0xFFFFFF00)},
      {'name': 'Cyan', 'color': const Color(0xFF00FFFF)},
      {'name': 'Magenta', 'color': const Color(0xFFFF00FF)},
      {'name': 'White', 'color': const Color(0xFFFFFFFF)},
      {'name': 'Black', 'color': const Color(0xFF000000)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Colors',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickColors.map((colorData) {
            return GestureDetector(
              onTap: () => _setQuickColor(colorData['color'] as Color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    (colorData['name'] as String)[0],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (colorData['color'] as Color).computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _addToInventory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Add to Inventory',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _makeTarget,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Make Target',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _updateColor() {
    final red = int.tryParse(_redController.text) ?? 0;
    final green = int.tryParse(_greenController.text) ?? 0;
    final blue = int.tryParse(_blueController.text) ?? 0;

    if (red >= 0 && red <= 255 && green >= 0 && green <= 255 && blue >= 0 && blue <= 255) {
      setState(() {
        _currentColor = ColorModel(red: red, green: green, blue: blue);
        _isValidColor = true;
      });
      
      // Update HEX field
      _hexController.text = _currentColor!.hex;
    } else {
      setState(() {
        _isValidColor = false;
      });
    }
  }

  void _updateColorFromHex() {
    final hexText = _hexController.text.replaceAll('#', '');
    if (hexText.length == 6) {
      try {
        final red = int.parse(hexText.substring(0, 2), radix: 16);
        final green = int.parse(hexText.substring(2, 4), radix: 16);
        final blue = int.parse(hexText.substring(4, 6), radix: 16);

        if (red >= 0 && red <= 255 && green >= 0 && green <= 255 && blue >= 0 && blue <= 255) {
          setState(() {
            _currentColor = ColorModel(red: red, green: green, blue: blue);
            _isValidColor = true;
          });

          // Update RGB fields
          _redController.text = red.toString();
          _greenController.text = green.toString();
          _blueController.text = blue.toString();
        }
      } catch (e) {
        setState(() {
          _isValidColor = false;
        });
      }
    } else {
      setState(() {
        _isValidColor = false;
      });
    }
  }

  void _setQuickColor(Color color) {
    setState(() {
      _currentColor = ColorModel.fromFlutterColor(color);
      _isValidColor = true;
    });

    _redController.text = color.red.toString();
    _greenController.text = color.green.toString();
    _blueController.text = color.blue.toString();
    _hexController.text = _currentColor!.hex;
  }

  Future<void> _addToInventory() async {
    if (_currentColor == null) return;

    try {
      await InventoryService.addColorToInventory(
        name: 'Custom Color',
        color: _currentColor!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Color added to inventory!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to main page after saving
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add color: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makeTarget() async {
    if (_currentColor == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TargetLabScreen(targetColor: _currentColor!),
      ),
    );
  }
}
