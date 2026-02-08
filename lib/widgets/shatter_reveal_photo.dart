import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShatterRevealPhoto extends StatefulWidget {
  final int revealProgress; // 0-5
  final bool isMe;
  final bool isActive; // Show glow when it's this player's turn
  final double tiltAngle; // Rotation in degrees
  final String? imageUrl;

  const ShatterRevealPhoto({
    super.key,
    required this.revealProgress,
    required this.isMe,
    this.isActive = false,
    this.tiltAngle = 0,
    this.imageUrl,
  });

  @override
  State<ShatterRevealPhoto> createState() => _ShatterRevealPhotoState();
}

class _ShatterRevealPhotoState extends State<ShatterRevealPhoto>
    with TickerProviderStateMixin {
  late AnimationController _shatterController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  List<ShatterParticle> _particles = [];
  int _lastProgress = 0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _lastProgress = widget.revealProgress;

    _shatterController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.95),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.08),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 0.98),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.98, end: 1.0),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(ShatterRevealPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger shatter effect when progress increases (for THEM's photo)
    if (!widget.isMe && widget.revealProgress > _lastProgress) {
      _triggerShatterEffect();
      _lastProgress = widget.revealProgress;
    }
  }

  void _triggerShatterEffect() {
    _generateParticles();
    _shatterController.forward(from: 0);
    _scaleController.forward(from: 0);
  }

  void _generateParticles() {
    final colors = [
      AppTheme.crystalCyan,
      AppTheme.white,
      AppTheme.frostedMint,
      AppTheme.crystalCyan.withValues(alpha: 0.7),
      AppTheme.white.withValues(alpha: 0.8),
    ];

    _particles = List.generate(50, (index) {
      // Particles emanate from center outward
      final angle = _random.nextDouble() * 2 * math.pi;
      final velocity = 80 + _random.nextDouble() * 120;
      final size = 2 + _random.nextDouble() * 6;

      return ShatterParticle(
        angle: angle,
        velocity: velocity,
        size: size,
        color: colors[_random.nextInt(colors.length)],
        rotationSpeed: _random.nextDouble() * 6 - 3,
        startDelay: _random.nextDouble() * 0.2,
      );
    });
  }

  @override
  void dispose() {
    _shatterController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  double get blurAmount {
    if (widget.isMe) return 0; // ME is always revealed
    return (5 - widget.revealProgress) * 4.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        return Transform.rotate(
          angle: widget.tiltAngle * math.pi / 180,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isMe ? 1.0 : _scaleAnimation.value,
                child: child,
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Active glow
                if (widget.isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isMe
                                    ? AppTheme.crystalCyan
                                    : AppTheme.crystalPink)
                                .withValues(alpha: 0.6),
                            blurRadius: 24,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Photo card
                Container(
                  width: maxWidth,
                  height: maxHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isMe
                          ? AppTheme.crystalCyan.withValues(alpha: 0.6)
                          : AppTheme.crystalPink.withValues(alpha: 0.6),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.pillShadow.withValues(alpha: 0.8),
                        offset: const Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Photo placeholder
                        _buildPhoto(),

                        // Blur overlay (for THEM only)
                        if (!widget.isMe && blurAmount > 0)
                          BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: blurAmount,
                              sigmaY: blurAmount,
                            ),
                            child: Container(
                              color: AppTheme.deepPurple.withValues(alpha: 0.2),
                            ),
                          ),

                        // Reveal percentage badge
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _buildRevealBadge(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Shatter particles overlay
                if (!widget.isMe)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shatterController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ShatterParticlePainter(
                            particles: _particles,
                            progress: _shatterController.value,
                            centerX: maxWidth / 2,
                            centerY: maxHeight / 2,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoto() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isMe
              ? [
                  AppTheme.crystalCyan.withValues(alpha: 0.3),
                  AppTheme.midPurple,
                  AppTheme.deepPurple,
                ]
              : [
                  AppTheme.crystalPink.withValues(alpha: 0.2),
                  AppTheme.softPurple,
                  AppTheme.midPurple,
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 50,
          color: widget.isMe
              ? AppTheme.crystalCyan.withValues(alpha: 0.5)
              : AppTheme.mutedText.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildRevealBadge() {
    final percentage = widget.isMe ? 100 : widget.revealProgress * 20;
    final isFullyRevealed = percentage == 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.deepPurple.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFullyRevealed
              ? AppTheme.crystalCyan
              : AppTheme.softPurple.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFullyRevealed ? Icons.visibility : Icons.visibility_off,
            size: 12,
            color: isFullyRevealed ? AppTheme.crystalCyan : AppTheme.mutedText,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              color: isFullyRevealed ? AppTheme.crystalCyan : AppTheme.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ShatterParticle {
  final double angle;
  final double velocity;
  final double size;
  final Color color;
  final double rotationSpeed;
  final double startDelay;

  ShatterParticle({
    required this.angle,
    required this.velocity,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.startDelay,
  });
}

class ShatterParticlePainter extends CustomPainter {
  final List<ShatterParticle> particles;
  final double progress;
  final double centerX;
  final double centerY;

  ShatterParticlePainter({
    required this.particles,
    required this.progress,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Apply start delay
      final adjustedProgress = ((progress - particle.startDelay) / (1 - particle.startDelay))
          .clamp(0.0, 1.0);

      if (adjustedProgress <= 0) continue;

      // Eased motion
      final easedProgress = Curves.easeOutCubic.transform(adjustedProgress);

      // Calculate position (emanating outward)
      final distance = particle.velocity * easedProgress;
      final x = centerX + math.cos(particle.angle) * distance;
      final y = centerY + math.sin(particle.angle) * distance;

      // Fade out
      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);

      // Scale down
      final scale = 1 - (adjustedProgress * 0.7);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotationSpeed * adjustedProgress * math.pi);
      canvas.scale(scale);

      // Draw as small rectangles (shattered glass shards)
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        const Radius.circular(1),
      );
      canvas.drawRRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ShatterParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
