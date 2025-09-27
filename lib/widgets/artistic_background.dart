import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class ArtisticBackground extends StatelessWidget {
  const ArtisticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1B4B), // Deep purple
            Color(0xFF312E81), // Dark blue
            Color(0xFF4C1D95), // Purple
            Color(0xFF6B46C1), // Light purple
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Floating color orbs
          _buildFloatingOrb(
            color: const Color(0xFF9333EA).withOpacity(0.3),
            size: 120,
            left: 50,
            top: 100,
            delay: 0,
          ),
          _buildFloatingOrb(
            color: const Color(0xFFEC4899).withOpacity(0.2),
            size: 80,
            left: MediaQuery.of(context).size.width - 140,
            top: 200,
            delay: 1000,
          ),
          _buildFloatingOrb(
            color: const Color(0xFF06B6D4).withOpacity(0.25),
            size: 100,
            left: 80,
            top: 400,
            delay: 2000,
          ),
          _buildFloatingOrb(
            color: const Color(0xFF10B981).withOpacity(0.2),
            size: 60,
            left: MediaQuery.of(context).size.width - 160,
            top: 500,
            delay: 1500,
          ),
          
          // Geometric shapes
          _buildGeometricShape(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            size: 200,
            left: -50,
            top: 300,
          ),
          _buildGeometricShape(
            color: const Color(0xFFF59E0B).withOpacity(0.08),
            size: 150,
            left: MediaQuery.of(context).size.width - 120,
            top: 150,
          ),
          
          // Subtle pattern overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.8),
                radius: 1.5,
                colors: [
                  const Color(0xFF9333EA).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb({
    required Color color,
    required double size,
    required double left,
    required double top,
    required int delay,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.6),
              color.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 2000.ms, delay: delay.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 1500.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildGeometricShape({
    required Color color,
    required double size,
    required double left,
    required double top,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 3000.ms)
        .slideX(
          begin: -0.5,
          duration: 2000.ms,
          curve: Curves.easeInOut,
        );
  }
}

