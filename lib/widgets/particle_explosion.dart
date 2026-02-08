import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ParticleExplosion extends StatefulWidget {
  final bool trigger;
  final VoidCallback? onComplete;

  const ParticleExplosion({
    super.key,
    required this.trigger,
    this.onComplete,
  });

  @override
  State<ParticleExplosion> createState() => _ParticleExplosionState();
}

class _ParticleExplosionState extends State<ParticleExplosion>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final math.Random _random = math.Random();
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _generateParticles();
  }

  void _generateParticles() {
    final colors = [
      AppTheme.crystalCyan,
      AppTheme.crystalPink,
      AppTheme.crystalGold,
      AppTheme.frostedPink,
      AppTheme.frostedBlue,
      AppTheme.frostedPurple,
    ];

    _particles = List.generate(40, (index) {
      final angle = (index / 40) * 2 * math.pi + _random.nextDouble() * 0.5;
      final velocity = 100 + _random.nextDouble() * 150;
      final size = 4 + _random.nextDouble() * 8;

      return Particle(
        angle: angle,
        velocity: velocity,
        size: size,
        color: colors[_random.nextInt(colors.length)],
        rotationSpeed: _random.nextDouble() * 4 - 2,
        type: ParticleType.values[_random.nextInt(ParticleType.values.length)],
      );
    });
  }

  @override
  void didUpdateWidget(ParticleExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !_hasTriggered) {
      _hasTriggered = true;
      _generateParticles();
      _controller.forward(from: 0);
    } else if (!widget.trigger && _hasTriggered) {
      _hasTriggered = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

enum ParticleType { circle, star, diamond, spark }

class Particle {
  final double angle;
  final double velocity;
  final double size;
  final Color color;
  final double rotationSpeed;
  final ParticleType type;

  Particle({
    required this.angle,
    required this.velocity,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.type,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      // Eased progress for natural deceleration
      final easedProgress = Curves.easeOutCubic.transform(progress);

      // Calculate position
      final distance = particle.velocity * easedProgress;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance + (50 * progress * progress); // Gravity

      // Fade out
      final opacity = (1 - progress).clamp(0.0, 1.0);

      // Scale down
      final scale = (1 - progress * 0.5).clamp(0.3, 1.0);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotationSpeed * progress * math.pi * 2);
      canvas.scale(scale);

      switch (particle.type) {
        case ParticleType.circle:
          canvas.drawCircle(Offset.zero, particle.size, paint);
          break;
        case ParticleType.star:
          _drawStar(canvas, particle.size, paint);
          break;
        case ParticleType.diamond:
          _drawDiamond(canvas, particle.size, paint);
          break;
        case ParticleType.spark:
          _drawSpark(canvas, particle.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final point = Offset(math.cos(angle) * size, math.sin(angle) * size);
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
      ..moveTo(0, -size)
      ..lineTo(size * 0.6, 0)
      ..lineTo(0, size)
      ..lineTo(-size * 0.6, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSpark(Canvas canvas, double size, Paint paint) {
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-size, 0), Offset(size, 0), paint);
    canvas.drawLine(Offset(0, -size), Offset(0, size), paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
