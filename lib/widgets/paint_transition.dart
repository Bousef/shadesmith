import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaintTransition extends StatefulWidget {
  final Widget child;
  final VoidCallback onTransitionComplete;
  final Duration duration;

  const PaintTransition({
    super.key,
    required this.child,
    required this.onTransitionComplete,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<PaintTransition> createState() => _PaintTransitionState();
}

class _PaintTransitionState extends State<PaintTransition>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _fluidController;
  late Animation<double> _splashSpread;
  late Animation<double> _screenCoverage;
  late Animation<double> _fadeOut;
  late Animation<double> _fluidMovement;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fluidController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Paint splatters spread out (0.0 to 0.6 of animation)
    _splashSpread = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Screen gets covered by paint (0.4 to 0.8 of animation)
    _screenCoverage = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
    ));

    // Fade out to next screen (0.7 to 1.0 of animation)
    _fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));

    // Fluid movement animation for dynamic splatter motion
    _fluidMovement = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fluidController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Start both controllers for fluid motion
    _mainController.forward();
    _fluidController.repeat(); // Repeat the fluid movement
    
    // Complete transition
    await Future.delayed(widget.duration);
    widget.onTransitionComplete();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _fluidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                      Color(0xFFE53E3E),
                      Color(0xFFECC94B),
                      Color(0xFF3182CE),

                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Paint splatters layer - fills entire screen with fluid motion
          AnimatedBuilder(
            animation: Listenable.merge([_splashSpread, _screenCoverage, _fluidMovement]),
            builder: (context, child) {
              return CustomPaint(
                painter: PaintSplatterPainter(
                  _splashSpread.value,
                  _screenCoverage.value,
                  _fluidMovement.value,
                  screenSize,
                ),
                size: screenSize,
              );
            },
          ),
          
          // Next screen content (fading in)
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - _fadeOut.value,
                child: widget.child,
              );
            },
          ),
        ],
      ),
    );
  }

}


class PaintSplatterPainter extends CustomPainter {
  final double splashValue;
  final double coverageValue;
  final double fluidValue;
  final Size screenSize;
  final math.Random random = math.Random(42);
  final List<Color> colors = [
    const Color(0xFF38A169), // Green
    const Color(0xFF3182CE), // Blue
    const Color(0xFFD69E2E), // Yellow
    const Color(0xFF805AD5), // Purple
    const Color(0xFFE53E3E), // More red for impact
    const Color(0xFFDD6B20), // More orange
  ];

  PaintSplatterPainter(this.splashValue, this.coverageValue, this.fluidValue, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (splashValue == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Three circular loading streaks
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) * 0.3;
    
    // Streak 1: Blue streak
    _drawCircularStreak(
      canvas, 
      centerX, centerY, 
      radius, 
      splashValue, 
      fluidValue, 
      const Color(0xFF3182CE), // Blue
      0.0, // Starting angle offset
      0
    );

    // Streak 2: Purple streak
    _drawCircularStreak(
      canvas, 
      centerX, centerY, 
      radius, 
      splashValue, 
      fluidValue, 
      const Color(0xFF805AD5), // Purple
      2.094, // 120 degrees offset
      1
    );

    // Streak 3: Orange streak
    _drawCircularStreak(
      canvas, 
      centerX, centerY, 
      radius, 
      splashValue, 
      fluidValue, 
      const Color(0xFFDD6B20), // Orange
      4.188, // 240 degrees offset
      2
    );

    // Add expanding circles for coverage effect
    if (coverageValue > 0.3) {
      _drawExpandingCircles(canvas, centerX, centerY, radius, coverageValue, fluidValue);
    }
  }

  void _drawIrregularSplatter(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final spikes = 6 + random.nextInt(4); // 6-9 spikes
    
    for (int i = 0; i < spikes; i++) {
      final angle = (i / spikes) * 2 * math.pi;
      final spikeLength = size * (0.6 + random.nextDouble() * 0.8);
      
      final spikeX = center.dx + math.cos(angle) * spikeLength;
      final spikeY = center.dy + math.sin(angle) * spikeLength;
      
      if (i == 0) {
        path.moveTo(spikeX, spikeY);
      } else {
        path.lineTo(spikeX, spikeY);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawFluidSplatter(Canvas canvas, Paint paint, Offset center, double size, double fluidValue, int index) {
    // Create organic liquid paint blob with multiple techniques
    final paintBlobs = _createLiquidPaintBlobs(center, size, fluidValue, index);
    
    for (final blob in paintBlobs) {
      _drawLiquidBlob(canvas, paint, blob);
    }
  }

  void _drawLiquidFlow(Canvas canvas, Paint paint, Offset center, double size, double fluidValue, int index) {
    // Create flowing liquid mass - single large amorphous shape
    _drawFlowingLiquidMass(canvas, paint, center, size, fluidValue, index);
  }

  void _drawPureLiquidSplatter(Canvas canvas, Paint paint, Offset center, double size, double fluidValue, int index) {
    // Create pure chaotic liquid paint with no structure
    _drawChaoticLiquidPaint(canvas, paint, center, size, fluidValue, index);
  }

  void _drawCircularStreak(Canvas canvas, double centerX, double centerY, double radius, double animationValue, double fluidValue, Color color, double angleOffset, int streakIndex) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Calculate rotation angle based on animation progress
    final baseRotation = fluidValue * 2 * math.pi; // Full rotation
    final currentAngle = angleOffset + baseRotation;
    
    // Streak length based on animation progress
    final streakLength = radius * 0.4 * animationValue;
    
    // Create streak path
    final path = Path();
    
    // Calculate streak start and end points
    final startAngle = currentAngle - streakLength / radius;
    final endAngle = currentAngle + streakLength / radius;
    
    // Inner and outer radius for streak thickness
    final innerRadius = radius * 0.8;
    final outerRadius = radius * 1.2;
    
    // Create streak arc
    path.moveTo(
      centerX + innerRadius * math.cos(startAngle),
      centerY + innerRadius * math.sin(startAngle),
    );
    
    path.lineTo(
      centerX + outerRadius * math.cos(startAngle),
      centerY + outerRadius * math.sin(startAngle),
    );
    
    path.arcTo(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: outerRadius),
      startAngle,
      endAngle - startAngle,
      false,
    );
    
    path.lineTo(
      centerX + innerRadius * math.cos(endAngle),
      centerY + innerRadius * math.sin(endAngle),
    );
    
    path.arcTo(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: innerRadius),
      endAngle,
      startAngle - endAngle,
      false,
    );
    
    path.close();
    
    // Draw streak with gradient-like effect
    final opacity = (0.7 + math.sin(fluidValue * math.pi * 4 + streakIndex) * 0.3).clamp(0.3, 1.0);
    paint.color = color.withOpacity(opacity * animationValue);
    
    canvas.drawPath(path, paint);
    
    // Add glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(opacity * 0.3 * animationValue)
      ..style = PaintingStyle.fill;
    
    // Draw outer glow
    final glowPath = Path();
    glowPath.moveTo(
      centerX + (innerRadius - 5) * math.cos(startAngle),
      centerY + (innerRadius - 5) * math.sin(startAngle),
    );
    glowPath.lineTo(
      centerX + (outerRadius + 5) * math.cos(startAngle),
      centerY + (outerRadius + 5) * math.sin(startAngle),
    );
    glowPath.arcTo(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: outerRadius + 5),
      startAngle,
      endAngle - startAngle,
      false,
    );
    glowPath.lineTo(
      centerX + (innerRadius - 5) * math.cos(endAngle),
      centerY + (innerRadius - 5) * math.sin(endAngle),
    );
    glowPath.arcTo(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: innerRadius - 5),
      endAngle,
      startAngle - endAngle,
      false,
    );
    glowPath.close();
    
    canvas.drawPath(glowPath, glowPaint);
  }

  void _drawExpandingCircles(Canvas canvas, double centerX, double centerY, double baseRadius, double animationValue, double fluidValue) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw multiple expanding circles
    for (int i = 0; i < 3; i++) {
      final circleRadius = baseRadius * (1.0 + animationValue * 2.0) + (i * 20.0);
      final opacity = (0.3 - i * 0.1) * animationValue;
      
      paint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(centerX, centerY),
        circleRadius,
        paint,
      );
    }
  }

  void _drawPaintDrip(Canvas canvas, Paint paint, Offset startPos, double maxLength, double animationValue, double fluidValue, int index) {
    final random = math.Random(index * 47);
    
    // Validate inputs
    if (animationValue <= 0 || maxLength <= 0) return;
    
    // Calculate drip length based on animation progress
    final dripLength = maxLength * animationValue;
    final endY = startPos.dy + dripLength;
    
    // Ensure we have a valid segment length
    if (dripLength < 10) return;
    
    // Create multiple drip segments for realistic paint flow
    final numSegments = 8 + random.nextInt(5); // 8-12 segments
    final segmentLength = dripLength / numSegments;
    
    for (int segment = 0; segment < numSegments; segment++) {
      final segmentStartY = startPos.dy + (segment * segmentLength);
      final segmentEndY = segmentStartY + segmentLength;
      
      // Add subtle sway to each segment
      final sway = math.sin(fluidValue * math.pi * 2 + segment * 0.5 + index * 0.3) * 8;
      final segmentX = startPos.dx + sway;
      
      // Vary drip width - wider at top, narrower at bottom
      final widthProgress = segment / numSegments.toDouble();
      final baseWidth = 4 + random.nextDouble() * 6;
      final segmentWidth = baseWidth * (1.0 - widthProgress * 0.7);
      
      // Ensure minimum width
      if (segmentWidth < 1.0) continue;
      
      // Draw drip segment
      _drawDripSegment(canvas, paint, Offset(segmentX, segmentStartY), Offset(segmentX, segmentEndY), segmentWidth, segment, index);
    }
    
    // Add drip tip at the end
    if (animationValue > 0.3 && endY > startPos.dy + 20) {
      final tipSway = math.sin(fluidValue * math.pi * 3 + index * 0.4) * 5;
      final tipX = startPos.dx + tipSway;
      final tipY = endY;
      final tipWidth = 2 + random.nextDouble() * 3;
      
      // Ensure minimum tip width
      if (tipWidth >= 1.0) {
        _drawDripTip(canvas, paint, Offset(tipX, tipY), tipWidth, index);
      }
    }
  }

  void _drawDripSegment(Canvas canvas, Paint paint, Offset start, Offset end, double width, int segment, int index) {
    final random = math.Random(index * 31 + segment);
    
    // Validate inputs
    if (width <= 0 || start.dy >= end.dy) return;
    
    // Create paint path for drip segment
    final path = Path();
    
    // Add slight curve to the drip segment
    final midY = (start.dy + end.dy) / 2;
    final curveOffset = (random.nextDouble() - 0.5) * width * 0.5;
    final midX = (start.dx + end.dx) / 2 + curveOffset;
    
    // Calculate points with bounds checking
    final leftStart = start.dx - width / 2;
    final rightStart = start.dx + width / 2;
    final leftEnd = end.dx - width / 2;
    final rightEnd = end.dx + width / 2;
    final leftMid = midX - width / 2;
    final rightMid = midX + width / 2;
    
    // Left side of drip
    path.moveTo(leftStart, start.dy);
    path.quadraticBezierTo(leftMid, midY, leftEnd, end.dy);
    
    // Right side of drip
    path.lineTo(rightEnd, end.dy);
    path.quadraticBezierTo(rightMid, midY, rightStart, start.dy);
    path.close();
    
    // Vary opacity slightly for each segment
    final opacity = (0.8 + random.nextDouble() * 0.4).clamp(0.1, 1.0);
    final segmentPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, segmentPaint);
  }

  void _drawDripTip(Canvas canvas, Paint paint, Offset position, double width, int index) {
    final random = math.Random(index * 29);
    
    // Validate inputs
    if (width <= 0) return;
    
    // Create paint droplet at tip
    final tipPath = Path();
    
    // Create teardrop shape
    final tipHeight = (width * 1.5).clamp(2.0, 20.0);
    final tipWidth = width.clamp(1.0, 10.0);
    
    // Calculate points with bounds checking
    final leftX = position.dx - tipWidth / 2;
    final rightX = position.dx + tipWidth / 2;
    final topY = position.dy - tipHeight;
    final leftQuarterX = position.dx - tipWidth / 4;
    final rightQuarterX = position.dx + tipWidth / 4;
    final quarterHeight = position.dy + tipHeight / 4;
    
    tipPath.moveTo(leftX, position.dy);
    tipPath.quadraticBezierTo(
      position.dx, topY,
      rightX, position.dy,
    );
    tipPath.quadraticBezierTo(
      rightQuarterX, quarterHeight,
      position.dx, position.dy,
    );
    tipPath.quadraticBezierTo(
      leftQuarterX, quarterHeight,
      leftX, position.dy,
    );
    tipPath.close();
    
    final opacity = (0.9 + random.nextDouble() * 0.2).clamp(0.1, 1.0);
    final tipPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(tipPath, tipPaint);
  }

  void _drawFlowingLiquidMass(Canvas canvas, Paint paint, Offset center, double size, double fluidValue, int index) {
    final path = Path();
    final random = math.Random(index * 37);
    
    // Create very organic, flowing shape with fewer points for more liquid appearance
    final points = <Offset>[];
    final numPoints = 6 + random.nextInt(4); // 6-9 points for amorphous shape
    
    for (int i = 0; i < numPoints; i++) {
      final angle = (i / numPoints.toDouble()) * 2 * math.pi;
      
      // Strong fluid distortion for liquid-like appearance
      final fluidDistortion = math.sin(fluidValue * math.pi * 2.5 + i * 0.7) * 0.6;
      final radiusVariation = 0.6 + random.nextDouble() * 0.8 + fluidDistortion;
      
      final radius = size * radiusVariation;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      points.add(Offset(x, y));
    }
    
    // Create very smooth, flowing curves for liquid appearance
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        final previous = points[i - 1];
        
        // Smooth curves with more fluid control points
        final cp1x = previous.dx + (current.dx - previous.dx) * 0.6;
        final cp1y = previous.dy + (current.dy - previous.dy) * 0.6;
        
        path.quadraticBezierTo(cp1x, cp1y, current.dx, current.dy);
      }
      
      // Close the path very smoothly
      final first = points[0];
      final last = points[points.length - 1];
      final cp1x = last.dx + (first.dx - last.dx) * 0.6;
      final cp1y = last.dy + (first.dy - last.dy) * 0.6;
      path.quadraticBezierTo(cp1x, cp1y, first.dx, first.dy);
    }
    
    canvas.drawPath(path, paint);
    
    // Add subtle liquid highlights for realism
    final highlightPaint = Paint()
      ..color = paint.color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path();
    final highlightCenter = Offset(
      center.dx - size * 0.25,
      center.dy - size * 0.25,
    );
    
    highlightPath.addOval(Rect.fromCenter(
      center: highlightCenter,
      width: size * 0.4,
      height: size * 0.3,
    ));
    
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawChaoticLiquidPaint(Canvas canvas, Paint paint, Offset center, double size, double fluidValue, int index) {
    final random = math.Random(index * 73);
    
    // Validate inputs
    if (size <= 0) return;
    
    // Create multiple chaotic paint blobs with no structure
    final numBlobs = 2 + random.nextInt(4); // 2-5 chaotic blobs
    
    for (int blobIndex = 0; blobIndex < numBlobs; blobIndex++) {
      // Random offset for each blob
      final offsetX = (random.nextDouble() - 0.5) * size * 0.8;
      final offsetY = (random.nextDouble() - 0.5) * size * 0.8;
      final blobCenter = Offset(center.dx + offsetX, center.dy + offsetY);
      
      // Random blob size with bounds
      final blobSize = (size * (0.3 + random.nextDouble() * 0.7)).clamp(5.0, 100.0);
      
      final path = Path();
      
      // Create completely chaotic shape with random points
      final numPoints = 5 + random.nextInt(6); // 5-10 random points
      final points = <Offset>[];
      
      for (int i = 0; i < numPoints; i++) {
        // Random angle and distance for each point
        final angle = random.nextDouble() * 2 * math.pi;
        final distance = blobSize * (0.4 + random.nextDouble() * 1.2);
        
        // Add chaotic fluid motion
        final chaosMotion = math.sin(fluidValue * math.pi * 3 + i * 1.5) * distance * 0.3;
        final x = blobCenter.dx + math.cos(angle) * distance + chaosMotion;
        final y = blobCenter.dy + math.sin(angle) * distance + chaosMotion * 0.5;
        
        points.add(Offset(x, y));
      }
      
      // Draw chaotic shape with random curves
      if (points.isNotEmpty && points.length >= 3) {
        path.moveTo(points[0].dx, points[0].dy);
        
        for (int i = 1; i < points.length; i++) {
          final current = points[i];
          final previous = points[i - 1];
          
          // Random control points for chaotic curves
          final cp1x = previous.dx + (current.dx - previous.dx) * (0.3 + random.nextDouble() * 0.7);
          final cp1y = previous.dy + (current.dy - previous.dy) * (0.3 + random.nextDouble() * 0.7);
          
          path.quadraticBezierTo(cp1x, cp1y, current.dx, current.dy);
        }
        
        // Close with random curve
        final first = points[0];
        final last = points[points.length - 1];
        final cp1x = last.dx + (first.dx - last.dx) * (0.3 + random.nextDouble() * 0.7);
        final cp1y = last.dy + (first.dy - last.dy) * (0.3 + random.nextDouble() * 0.7);
        path.quadraticBezierTo(cp1x, cp1y, first.dx, first.dy);
        
        // Draw the chaotic paint blob
        final opacity = (0.7 + random.nextDouble() * 0.3).clamp(0.1, 1.0);
        final blobPaint = Paint()
          ..color = paint.color.withOpacity(paint.color.opacity * opacity)
          ..style = PaintingStyle.fill;
        
        canvas.drawPath(path, blobPaint);
      }
    }
  }

  List<LiquidBlob> _createLiquidPaintBlobs(Offset center, double size, double fluidValue, int index) {
    final blobs = <LiquidBlob>[];
    final random = math.Random(index * 42); // Consistent randomness per splatter
    
    // Main central blob
    final mainBlob = LiquidBlob(
      center: center,
      baseRadius: size * (0.8 + random.nextDouble() * 0.4),
      fluidValue: fluidValue,
      index: index,
      isMainBlob: true,
    );
    blobs.add(mainBlob);
    
    // Create satellite droplets that flow outward
    final numDroplets = 3 + random.nextInt(5); // 3-7 droplets
    for (int i = 0; i < numDroplets; i++) {
      final angle = (i / numDroplets.toDouble()) * 2 * math.pi + fluidValue * math.pi * 0.5;
      final distance = size * (1.2 + random.nextDouble() * 1.5);
      
      // Add organic movement to droplet position
      final fluidOffset = math.sin(fluidValue * math.pi * 3 + i * 0.8) * size * 0.3;
      final dropletCenter = Offset(
        center.dx + math.cos(angle) * distance + fluidOffset,
        center.dy + math.sin(angle) * distance + fluidOffset * 0.6,
      );
      
      final droplet = LiquidBlob(
        center: dropletCenter,
        baseRadius: size * (0.3 + random.nextDouble() * 0.4),
        fluidValue: fluidValue,
        index: index + i + 100,
        isMainBlob: false,
      );
      blobs.add(droplet);
    }
    
    // Add tiny splatter droplets
    final numSplatters = 5 + random.nextInt(8); // 5-12 tiny splatters
    for (int i = 0; i < numSplatters; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = size * (1.8 + random.nextDouble() * 2.0);
      
      final splatterCenter = Offset(
        center.dx + math.cos(angle) * distance + math.sin(fluidValue * math.pi * 4 + i) * size * 0.2,
        center.dy + math.sin(angle) * distance + math.cos(fluidValue * math.pi * 4 + i) * size * 0.2,
      );
      
      final splatter = LiquidBlob(
        center: splatterCenter,
        baseRadius: size * (0.1 + random.nextDouble() * 0.2),
        fluidValue: fluidValue,
        index: index + i + 200,
        isMainBlob: false,
      );
      blobs.add(splatter);
    }
    
    return blobs;
  }

  void _drawLiquidBlob(Canvas canvas, Paint paint, LiquidBlob blob) {
    final path = Path();
    final random = math.Random(blob.index);
    
    // Create organic, irregular shape using multiple curves
    final points = <Offset>[];
    final numPoints = 8 + random.nextInt(8); // 8-15 points for organic shape
    
    for (int i = 0; i < numPoints; i++) {
      final angle = (i / numPoints.toDouble()) * 2 * math.pi;
      
      // Add organic distortion
      final distortion = math.sin(blob.fluidValue * math.pi * 2 + i * 0.5) * 0.3;
      final radiusVariation = 0.7 + random.nextDouble() * 0.6 + distortion;
      
      final radius = blob.baseRadius * radiusVariation;
      final x = blob.center.dx + math.cos(angle) * radius;
      final y = blob.center.dy + math.sin(angle) * radius;
      
      points.add(Offset(x, y));
    }
    
    // Create smooth curves between points for liquid-like appearance
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        final previous = points[i - 1];
        
        // Calculate control points for smooth curves
        final cp1x = previous.dx + (current.dx - previous.dx) * 0.5;
        final cp1y = previous.dy + (current.dy - previous.dy) * 0.5;
        
        path.quadraticBezierTo(cp1x, cp1y, current.dx, current.dy);
      }
      
      // Close the path smoothly
      final first = points[0];
      final last = points[points.length - 1];
      final cp1x = last.dx + (first.dx - last.dx) * 0.5;
      final cp1y = last.dy + (first.dy - last.dy) * 0.5;
      path.quadraticBezierTo(cp1x, cp1y, first.dx, first.dy);
    }
    
    canvas.drawPath(path, paint);
    
    // Add paint highlights for liquid effect
    if (blob.isMainBlob) {
      final highlightPaint = Paint()
        ..color = paint.color.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      final highlightPath = Path();
      final highlightCenter = Offset(
        blob.center.dx - blob.baseRadius * 0.3,
        blob.center.dy - blob.baseRadius * 0.3,
      );
      
      highlightPath.addOval(Rect.fromCenter(
        center: highlightCenter,
        width: blob.baseRadius * 0.6,
        height: blob.baseRadius * 0.4,
      ));
      
      canvas.drawPath(highlightPath, highlightPaint);
    }
  }

  void _drawPaintDrips(Canvas canvas, Paint paint, Size size, Offset center, double coverageValue, double fluidValue) {
    final dripCount = 8 + (coverageValue * 12).round(); // More drips as coverage increases
    
    for (int i = 0; i < dripCount; i++) {
      final random = math.Random(i * 37);
      final colorIndex = random.nextInt(colors.length);
      
      // Create vertical paint drips with organic variation
      final startX = center.dx + (random.nextDouble() - 0.5) * size.width * 0.6;
      final startY = center.dy + (random.nextDouble() - 0.5) * size.height * 0.4;
      final dripLength = 30 + random.nextDouble() * 80;
      
      // Add fluid motion to drip
      final dripOffset = math.sin(fluidValue * math.pi * 2 + i * 0.5) * 8;
      final currentX = startX + dripOffset;
      
      // Create organic drip shape
      final dripPath = Path();
      final dripWidth = 3 + random.nextDouble() * 6;
      
      // Start of drip (wider)
      dripPath.moveTo(currentX - dripWidth, startY);
      dripPath.lineTo(currentX + dripWidth, startY);
      
      // Middle of drip with organic curves
      final midY = startY + dripLength * 0.5;
      final midWidth = dripWidth * 0.7;
      final curveOffset = math.sin(fluidValue * math.pi * 3 + i * 0.3) * 5;
      
      dripPath.quadraticBezierTo(
        currentX + midWidth + curveOffset,
        midY,
        currentX + dripWidth * 0.3,
        startY + dripLength,
      );
      
      // End of drip (narrower, like a drop)
      dripPath.lineTo(currentX - dripWidth * 0.3, startY + dripLength);
      dripPath.quadraticBezierTo(
        currentX - midWidth - curveOffset,
        midY,
        currentX - dripWidth,
        startY,
      );
      
      dripPath.close();
      
      // Draw the drip with appropriate color and opacity
      final dripPaint = Paint()
        ..color = colors[colorIndex].withOpacity(0.6 * coverageValue)
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(dripPath, dripPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return splashValue != (oldDelegate as PaintSplatterPainter).splashValue ||
           coverageValue != oldDelegate.coverageValue ||
           fluidValue != oldDelegate.fluidValue;
  }
}

class LiquidBlob {
  final Offset center;
  final double baseRadius;
  final double fluidValue;
  final int index;
  final bool isMainBlob;

  LiquidBlob({
    required this.center,
    required this.baseRadius,
    required this.fluidValue,
    required this.index,
    required this.isMainBlob,
  });
}