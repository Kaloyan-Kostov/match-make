import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CrystalOrb extends StatefulWidget {
  final bool isComplete;
  final double size;

  const CrystalOrb({
    super.key,
    required this.isComplete,
    this.size = 56,
  });

  @override
  State<CrystalOrb> createState() => _CrystalOrbState();
}

class _CrystalOrbState extends State<CrystalOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Glow intensity animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isComplete) {
      _startCompleteAnimations();
    }
  }

  void _startCompleteAnimations() {
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  void _stopCompleteAnimations() {
    _pulseController.stop();
    _pulseController.reset();
    _glowController.stop();
    _glowController.reset();
  }

  @override
  void didUpdateWidget(CrystalOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _startCompleteAnimations();
    } else if (!widget.isComplete && oldWidget.isComplete) {
      _stopCompleteAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController, _glowController]),
      builder: (context, child) {
        final scale = widget.isComplete ? _pulseAnimation.value : 1.0;
        final glowIntensity = widget.isComplete ? _glowAnimation.value : 0.4;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: AppTheme.crystalCyan.withValues(alpha: glowIntensity * 0.8),
                  blurRadius: widget.isComplete ? 30 : 15,
                  spreadRadius: widget.isComplete ? 8 : 4,
                ),
                BoxShadow(
                  color: AppTheme.crystalPink.withValues(alpha: glowIntensity * 0.5),
                  blurRadius: widget.isComplete ? 40 : 20,
                  spreadRadius: widget.isComplete ? 12 : 6,
                ),
              ],
            ),
            child: CustomPaint(
              painter: CrystalOrbPainter(
                rotation: _rotateController.value * 2 * math.pi,
                isComplete: widget.isComplete,
                glowIntensity: glowIntensity,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CrystalOrbPainter extends CustomPainter {
  final double rotation;
  final bool isComplete;
  final double glowIntensity;

  CrystalOrbPainter({
    required this.rotation,
    required this.isComplete,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base orb gradient
    final baseGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: isComplete
          ? [
              AppTheme.crystalCyan.withValues(alpha: 0.9),
              AppTheme.crystalPink.withValues(alpha: 0.7),
              AppTheme.deepPurple.withValues(alpha: 0.9),
            ]
          : [
              AppTheme.midPurple,
              AppTheme.softPurple,
              AppTheme.deepPurple,
            ],
    );

    // Draw base orb
    final basePaint = Paint()
      ..shader = baseGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, basePaint);

    // Inner crystal facets
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final facetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = (isComplete ? AppTheme.crystalCyan : AppTheme.mutedText)
          .withValues(alpha: 0.6);

    // Draw hexagonal pattern
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final innerRadius = radius * 0.4;
      final outerRadius = radius * 0.85;

      canvas.drawLine(
        Offset(math.cos(angle) * innerRadius, math.sin(angle) * innerRadius),
        Offset(math.cos(angle) * outerRadius, math.sin(angle) * outerRadius),
        facetPaint,
      );
    }

    // Inner hexagon
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final r = radius * 0.4;
      final point = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        hexPath.moveTo(point.dx, point.dy);
      } else {
        hexPath.lineTo(point.dx, point.dy);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, facetPaint);

    canvas.restore();

    // Highlight/shine
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.5),
        radius: 0.5,
        colors: [
          Colors.white.withValues(alpha: isComplete ? 0.6 : 0.3),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.8, shinePaint);

    // Outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = (isComplete ? AppTheme.crystalCyan : AppTheme.softPurple)
          .withValues(alpha: 0.8);
    canvas.drawCircle(center, radius - 1, ringPaint);

    // Center symbol (puzzle piece icon)
    if (!isComplete) {
      _drawPuzzleLock(canvas, center, radius * 0.35);
    } else {
      _drawUnlockedSymbol(canvas, center, radius * 0.35);
    }
  }

  void _drawPuzzleLock(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = AppTheme.mutedText.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Lock body
    final lockRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, size * 0.2), width: size * 1.2, height: size),
      const Radius.circular(4),
    );
    canvas.drawRRect(lockRect, paint);

    // Lock shackle
    final shacklePath = Path()
      ..moveTo(center.dx - size * 0.35, center.dy - size * 0.3)
      ..quadraticBezierTo(
        center.dx - size * 0.35, center.dy - size * 0.8,
        center.dx, center.dy - size * 0.8,
      )
      ..quadraticBezierTo(
        center.dx + size * 0.35, center.dy - size * 0.8,
        center.dx + size * 0.35, center.dy - size * 0.3,
      );
    canvas.drawPath(shacklePath, paint);
  }

  void _drawUnlockedSymbol(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = AppTheme.crystalGold
      ..style = PaintingStyle.fill;

    // Star burst
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;
      final outerR = size * (i % 2 == 0 ? 1.0 : 0.5);
      final point = Offset(
        center.dx + math.cos(angle) * outerR,
        center.dy + math.sin(angle) * outerR,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CrystalOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.isComplete != isComplete ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
