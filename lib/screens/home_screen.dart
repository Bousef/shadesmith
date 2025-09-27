import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              // Compact Header
              _buildCompactHeader(),
              
              // Tab Bar
              _buildTabBar(),
              
              // Main Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCaptureTab(),
                      _buildPalletsTab(),
                      _buildLogsTab(),
                      _buildProfileTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Logo
          ClipRect(
            child: Image.asset(
              'assets/images/ShadeSmithTransparentLogo.png',
              height: 50,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Welcome Text
          Expanded(
            child: Consumer<AppAuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      authProvider.user?.displayName?.split(' ').first ?? 'Artist',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(0), // Square container
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(0), // Square indicator
        ),
        indicatorSize: TabBarIndicatorSize.tab, // Indicator matches tab size
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: EdgeInsets.zero, // Remove label padding
        indicatorPadding: EdgeInsets.zero, // Remove indicator padding
        dividerHeight: 0, // Remove divider
        tabs: [
          Tab(
            height: 50, // Fixed height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 18),
                const SizedBox(height: 2),
                Text(
                  'Capture',
                  style: GoogleFonts.inter(fontSize: 10),
                ),
              ],
            ),
          ),
          Tab(
            height: 50, // Fixed height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.palette, size: 18),
                const SizedBox(height: 2),
                Text(
                  'Pallets',
                  style: GoogleFonts.inter(fontSize: 10),
                ),
              ],
            ),
          ),
          Tab(
            height: 50, // Fixed height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 18),
                const SizedBox(height: 2),
                Text(
                  'Logs',
                  style: GoogleFonts.inter(fontSize: 10),
                ),
              ],
            ),
          ),
          Tab(
            height: 50, // Fixed height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(height: 2),
                Text(
                  'Profile',
                  style: GoogleFonts.inter(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Color Selection',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Camera Capture
          _buildFeatureCard(
            icon: Icons.camera_alt,
            title: 'Capture with Camera',
            subtitle: 'Take a photo and select your target color',
            color: const Color(0xFF3182CE),
            onTap: () => _showCameraCapture(),
          ),
          
          const SizedBox(height: 12),
          
          // RGB Input
          _buildFeatureCard(
            icon: Icons.color_lens,
            title: 'Enter RGB Code',
            subtitle: 'Input a specific color code manually',
            color: const Color(0xFF805AD5),
            onTap: () => _showRGBInput(),
          ),
          
          const SizedBox(height: 20),
          
          // Current Target
          _buildTargetColorDisplay(),
        ],
      ),
    );
  }

  Widget _buildPalletsTab() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _showAddColorDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
        
        // Paint Palette Layout
        Expanded(
          child: _buildPaintPalette(),
        ),
      ],
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Color Formula Logs',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        
        // Logs List
        Expanded(
          child: _buildLogsList(),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Info
          Consumer<AppAuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/BlacksmithIcon.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.user?.displayName ?? 'Artist',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.user?.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                await context.read<AppAuthProvider>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetColorDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Target Color',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No target color selected',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaintPalette() {
    final mockColors = [
      {'name': 'Cadmium Red', 'color': const Color(0xFFDC2626)},
      {'name': 'Ultramarine Blue', 'color': const Color(0xFF2563EB)},
      {'name': 'Cadmium Yellow', 'color': const Color(0xFFEAB308)},
      {'name': 'Titanium White', 'color': const Color(0xFFF8FAFC)},
      {'name': 'Ivory Black', 'color': const Color(0xFF1F2937)},
      {'name': 'Burnt Sienna', 'color': const Color(0xFF92400E)},
      {'name': 'Viridian Green', 'color': const Color(0xFF059669)},
      {'name': 'Alizarin Crimson', 'color': const Color(0xFFDC2626)},
    ];

    return Column(
      children: [
        // Search Bar - Compact height
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showFilterDialog(),
                child: const Icon(Icons.filter_list, color: Colors.white70, size: 16),
              ),
            ],
          ),
        ),
        
        // Color Grid - Takes remaining space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: mockColors.length,
              itemBuilder: (context, index) {
                final colorData = mockColors[index];
                return _buildColorCard(colorData, index);
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildColorCard(Map<String, dynamic> colorData, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Color Swatch
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _selectColor(colorData),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Stack(
                  children: [
                    // Color info overlay
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _colorToHex(colorData['color'] as Color),
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Color Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    colorData['name'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'RGB: ${_colorToRGB(colorData['color'] as Color)}',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showColorDetails(colorData),
                        child: const Icon(Icons.more_vert, color: Colors.white70, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _colorToRGB(Color color) {
    return '${color.red}, ${color.green}, ${color.blue}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Colors'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Colors'),
              leading: Radio(value: 'all', groupValue: 'all', onChanged: (value) {}),
            ),
            ListTile(
              title: const Text('Primary Colors'),
              leading: Radio(value: 'primary', groupValue: 'all', onChanged: (value) {}),
            ),
            ListTile(
              title: const Text('Secondary Colors'),
              leading: Radio(value: 'secondary', groupValue: 'all', onChanged: (value) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showColorDetails(Map<String, dynamic> colorData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(colorData['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorData['color'] as Color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 1),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('HEX', _colorToHex(colorData['color'] as Color)),
            _buildDetailRow('RGB', _colorToRGB(colorData['color'] as Color)),
            _buildDetailRow('HSL', _colorToHSL(colorData['color'] as Color)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _selectColor(colorData);
            },
            child: const Text('Use Color'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.inter()),
        ],
      ),
    );
  }

  String _colorToHSL(Color color) {
    // Simple HSL conversion
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final delta = max - min;
    
    int h = 0;
    if (delta != 0) {
      if (max == r) {
        h = ((g - b) / delta % 6).round();
      } else if (max == g) {
        h = ((b - r) / delta + 2).round();
      } else {
        h = ((r - g) / delta + 4).round();
      }
    }
    
    final l = (max + min) / 2;
    final s = delta == 0 ? 0 : delta / (1 - (2 * l - 1).abs());
    
    return '${(h * 60).round()}, ${(s * 100).round()}%, ${(l * 100).round()}%';
  }

  void _selectColor(Map<String, dynamic> colorData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${colorData['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildLogsList() {
    final mockLogs = [
      {'name': 'Sunset Orange', 'date': '2024-01-15', 'color': const Color(0xFFEA580C)},
      {'name': 'Ocean Blue', 'date': '2024-01-14', 'color': const Color(0xFF0EA5E9)},
      {'name': 'Forest Green', 'date': '2024-01-13', 'color': const Color(0xFF16A34A)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: mockLogs.length,
        itemBuilder: (context, index) {
          final log = mockLogs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: log['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['name'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log['date'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _restoreColorToInventory(log),
                  icon: const Icon(Icons.restore, color: Colors.white70, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Mock methods
  void _showCameraCapture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera capture coming soon!')),
    );
  }

  void _showRGBInput() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter RGB Code'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'e.g., 255, 128, 64',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('RGB input coming soon!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddColorDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add color functionality coming soon!')),
    );
  }

  void _restoreColorToInventory(Map<String, dynamic> log) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restoring ${log['name']} to inventory...')),
    );
  }
}
