import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_auth_provider.dart';
import '../services/inventory_service.dart';
import '../services/recipe_service.dart';
import '../models/inventory_model.dart';
import '../models/recipe_model.dart';
import 'capture_screen.dart';
import 'color_pick_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _refreshKey = 0; // Add refresh key to force rebuild

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Refresh data when switching to inventory or logs tabs
      if (_tabController.index == 1 || _tabController.index == 2) {
        _refreshData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to refresh data
  void _refreshData() {
    setState(() {
      _refreshKey++;
    });
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
        color: Colors.black.withOpacity(0.4), // Much darker navbar
        borderRadius: BorderRadius.circular(0), // Square container
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.15), // Slightly darker indicator
          borderRadius: BorderRadius.circular(0), // Square indicator
        ),
        indicatorSize: TabBarIndicatorSize.tab, // Indicator matches tab size
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60, // Slightly dimmer unselected text
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
                const Icon(Icons.camera_alt, size: 18, color: Color(0xFFA855F7)), // Brighter purple
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
                const Icon(Icons.palette, size: 18, color: Color(0xFF9333EA)), // Brighter purple
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
                const Icon(Icons.history, size: 18, color: Color(0xFF7C3AED)), // Brighter purple
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
                const Icon(Icons.person, size: 18, color: Color(0xFF6D28D9)), // Brighter purple
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
          // Artistic Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.2),
                  Colors.pink.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.pink, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color Studio',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Capture your inspiration',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Artistic Capture Options
          Row(
            children: [
              Expanded(
                child: _buildArtisticCard(
                  icon: Icons.camera_alt,
                  title: 'Capture',
                  subtitle: 'Photo & Sample',
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _showCameraCapture(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildArtisticCard(
                  icon: Icons.colorize,
                  title: 'Color Pick',
                  subtitle: 'RGB & HEX',
                  gradient: LinearGradient(
                    colors: [Colors.pink.withOpacity(0.8), Colors.orange.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _showRGBInput(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Current Target with Artistic Design
          _buildArtisticTargetDisplay(),
          
          const SizedBox(height: 20),
          
          // Inspiration Gallery
          _buildInspirationGallery(),
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
              Text(
                'Color Inventory',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
          child: _buildInventoryPalette(),
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
            'Paint Mixing Recipes',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        
        // Logs List
        Expanded(
          child: _buildRecipesList(),
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

  Widget _buildArtisticCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 100,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtisticTargetDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
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
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to Mix',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a color to begin your artistic journey',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationGallery() {
    final inspirationColors = [
      {'name': 'Sunset', 'colors': [Colors.orange, Colors.pink, Colors.purple]},
      {'name': 'Ocean', 'colors': [Colors.blue, Colors.cyan, Colors.teal]},
      {'name': 'Forest', 'colors': [Colors.green, Colors.lightGreen, Colors.amber]},
      {'name': 'Fire', 'colors': [Colors.red, Colors.orange, Colors.yellow]},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Inspiration',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: inspirationColors.length,
            itemBuilder: (context, index) {
              final inspiration = inspirationColors[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: inspiration['colors'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (inspiration['colors'] as List<Color>).first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    inspiration['name'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.9),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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


  Widget _buildArtisticColorCard(Map<String, dynamic> colorData, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (colorData['color'] as Color).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                  gradient: LinearGradient(
                    colors: [
                      colorData['color'] as Color,
                      (colorData['color'] as Color).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (colorData['color'] as Color).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Color info overlay
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _colorToHex(colorData['color'] as Color),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Artistic decoration
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 10,
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    colorData['name'] as String,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'RGB: ${_colorToRGB(colorData['color'] as Color)}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showColorDetails(colorData),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple, Colors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
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

  Widget _buildColorCard(Map<String, dynamic> colorData, int index) {
    return _buildArtisticColorCard(colorData, index);
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

  // Navigation methods
  void _showCameraCapture() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CaptureScreen(),
      ),
    );
    // Refresh data when returning from capture screen
    _refreshData();
  }

  void _showRGBInput() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ColorPickScreen(),
      ),
    );
    // Refresh data when returning from color pick screen
    _refreshData();
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

  Widget _buildInventoryPalette() {
    return FutureBuilder<InventoryModel>(
      key: ValueKey('inventory_$_refreshKey'),
      future: InventoryService.getInventory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading inventory: ${snapshot.error}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          );
        }

        final inventory = snapshot.data ?? InventoryModel.defaultInventory();
        final availableColors = inventory.availableColors.where((color) => color.isAvailable).toList();

        if (availableColors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 60,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'No colors in inventory',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture or pick colors to get started',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final colorData = {
                'name': availableColors[index].name,
                'color': availableColors[index].color.toFlutterColor(),
              };
              return _buildColorCard(colorData, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecipesList() {
    return FutureBuilder<List<RecipeModel>>(
      key: ValueKey('recipes_$_refreshKey'),
      future: RecipeService.getAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading recipes: ${snapshot.error}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          );
        }

        final recipes = snapshot.data ?? [];

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 60,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'No recipes yet',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first paint mixing recipe',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort recipes by creation date (newest first)
        recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _buildRecipeCard(recipe);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Header
          Row(
            children: [
              // Target Color
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: recipe.targetColor.toFlutterColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target: ${recipe.targetColor.hex}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Created: ${_formatDate(recipe.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Accuracy Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: recipe.accuracy <= 10 
                    ? Colors.green.withOpacity(0.8)
                    : recipe.accuracy <= 30
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ΔE: ${recipe.accuracy.toStringAsFixed(1)}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Ingredients
          Text(
            'Ingredients:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          ...recipe.ingredients.map((ingredient) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Text(
              '• ${ingredient.name}: ${ingredient.percentage.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
