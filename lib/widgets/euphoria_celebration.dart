import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_theme.dart';

class EuphoriaCelebration extends StatefulWidget {
  final bool trigger;
  final VoidCallback? onComplete;

  const EuphoriaCelebration({
    super.key,
    required this.trigger,
    this.onComplete,
  });

  @override
  State<EuphoriaCelebration> createState() => _EuphoriaCelebrationState();
}

class _EuphoriaCelebrationState extends State<EuphoriaCelebration>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  bool _isActive = false;
  double _elapsed = 0;

  static const int particleCount = 60;
  static const double duration = 2.5; // seconds

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didUpdateWidget(EuphoriaCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    if (_isActive) return;
    _isActive = true;
    _elapsed = 0;
    _generateParticles();
    _ticker.start();
  }

  void _generateParticles() {
    _particles.clear();

    final colors = [
      AppTheme.crystalCyan,
      AppTheme.crystalPink,
      AppTheme.crystalGold,
      AppTheme.frostedMint,
      AppTheme.frostedPink,
      Colors.white,
    ];

    for (int i = 0; i < particleCount; i++) {
      // Particles emanate from center
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 150 + _random.nextDouble() * 250;
      final size = 4 + _random.nextDouble() * 10;

      _particles.add(Particle(
        x: 0,
        y: 0,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 100, // Slight upward bias
        size: size,
        color: colors[_random.nextInt(colors.length)],
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        type: ParticleType.values[_random.nextInt(ParticleType.values.length)],
        delay: _random.nextDouble() * 0.3,
      ));
    }
  }

  void _onTick(Duration elapsed) {
    final dt = elapsed.inMicroseconds / 1000000.0;

    if (_elapsed == 0) {
      _elapsed = dt;
      return;
    }

    final delta = dt - _elapsed;
    _elapsed = dt;

    // Physics update
    for (final p in _particles) {
      if (_elapsed < p.delay) continue;

      // Gravity
      p.vy += 400 * delta;

      // Drag
      p.vx *= 0.99;
      p.vy *= 0.99;

      // Position
      p.x += p.vx * delta;
      p.y += p.vy * delta;

      // Rotation
      p.rotation += p.rotationSpeed * delta;

      // Fade
      p.opacity = (1.0 - (_elapsed / duration)).clamp(0.0, 1.0);
    }

    setState(() {});

    if (_elapsed >= duration) {
      _ticker.stop();
      _isActive = false;
      _particles.clear();
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: ParticlePainter(particles: _particles),
      ),
    );
  }
}

enum ParticleType { star, circle, diamond, shimmer }

class Particle {
  double x, y;
  double vx, vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;
  ParticleType type;
  double delay;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.type,
    required this.delay,
    this.opacity = 1.0,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final p in particles) {
      if (p.opacity <= 0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(centerX + p.x, centerY + p.y);
      canvas.rotate(p.rotation);

      switch (p.type) {
        case ParticleType.star:
          _drawStar(canvas, p.size, paint);
          break;
        case ParticleType.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case ParticleType.diamond:
          _drawDiamond(canvas, p.size, paint);
          break;
        case ParticleType.shimmer:
          _drawShimmer(canvas, p.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final r = size / 2;
      final point = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, double size, Paint paint) {
    final path = Path()
      ..moveTo(0, -size / 2)
      ..lineTo(size / 3, 0)
      ..lineTo(0, size / 2)
      ..lineTo(-size / 3, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawShimmer(Canvas canvas, double size, Paint paint) {
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-size / 2, 0), Offset(size / 2, 0), paint);
    canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
