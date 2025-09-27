import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/artistic_background.dart';
import '../widgets/auth_form.dart';
import '../services/app_auth_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Artistic background
          const ArtisticBackground(),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo and title
                  _buildLogo(),
                  
                  const SizedBox(height: 60),
                  
                  // Google Sign In
                  _buildGoogleSignIn(),
                  
                  const SizedBox(height: 32),
                  
                  // Auth form
                  AuthForm(isSignUp: _isSignUp),
                  
                  const SizedBox(height: 32),
                  
                  // Toggle between sign in and sign up
                  _buildAuthToggle(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // ShadeSmith Logo
        ClipRect(
          child: Image.asset(
            'assets/images/ShadeSmithTransparentLogo.png',
            height: 120,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
        )
            .animate()
            .scale(
              duration: 800.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 600.ms),
        
        const SizedBox(height: 24),
        
        // App name
        Text(
          'ShadeSmith',
          style: GoogleFonts.playfairDisplay(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1,
          ),
        )
            .animate(delay: 200.ms)
            .slideY(
              begin: 0.3,
              duration: 600.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(duration: 600.ms),
        
        const SizedBox(height: 8),
        
        // Tagline
        Text(
          'AI-Powered Color Mixing',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        )
            .animate(delay: 400.ms)
            .slideY(
              begin: 0.3,
              duration: 600.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(duration: 600.ms),
      ],
    );
  }


  Widget _buildAuthToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : "Don't have an account?",
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSignUp = !_isSignUp;
            });
          },
          child: Text(
            _isSignUp ? 'Sign In' : 'Sign Up',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    )
        .animate(delay: 1000.ms)
        .slideY(
          begin: 0.3,
          duration: 600.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 600.ms);
  }

  Widget _buildGoogleSignIn() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Consumer<AppAuthProvider>(
          builder: (context, authProvider, child) {
            return InkWell(
              onTap: authProvider.isLoading ? null : () async {
                final success = await authProvider.signInWithGoogle();
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        authProvider.errorMessage ?? 'Google Sign-In failed',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    )
        .animate(delay: 1000.ms)
        .slideY(
          begin: 0.3,
          duration: 600.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 600.ms);
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: CustomPaint(
        painter: GoogleIconPainter(),
      ),
    );
  }
}

class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Create a more accurate Google "G" logo
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    
    // Draw the blue arc (top right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // -90 degrees
      1.57,  // 90 degrees
      false,
      paint..strokeWidth = 2,
    );
    
    // Draw the green arc (bottom right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,     // 0 degrees
      1.57,  // 90 degrees
      false,
      paint..strokeWidth = 2,
    );
    
    // Draw the yellow arc (bottom left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.57,  // 90 degrees
      1.57,  // 90 degrees
      false,
      paint..strokeWidth = 2,
    );
    
    // Draw the red arc (top left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14,  // 180 degrees
      1.57,  // 90 degrees
      false,
      paint..strokeWidth = 2,
    );
    
    // Draw the horizontal line (part of the G)
    paint.color = const Color(0xFF4285F4);
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx + radius * 0.3, center.dy),
      Offset(center.dx + radius * 0.8, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

