import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowingOrb extends StatefulWidget {
  final bool isComplete;
  final double size;

  const GlowingOrb({
    super.key,
    required this.isComplete,
    this.size = 50,
  });

  @override
  State<GlowingOrb> createState() => _GlowingOrbState();
}

class _GlowingOrbState extends State<GlowingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        final scale = widget.isComplete ? _breatheAnimation.value * 1.1 : _breatheAnimation.value;
        final glowIntensity = widget.isComplete ? 1.0 : _glowAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isComplete
                    ? [
                        AppTheme.crystalGold,
                        AppTheme.crystalPink,
                        AppTheme.crystalCyan,
                      ]
                    : [
                        AppTheme.crystalCyan.withValues(alpha: 0.9),
                        AppTheme.crystalPink.withValues(alpha: 0.9),
                      ],
              ),
              boxShadow: [
                // Inner glow
                BoxShadow(
                  color: AppTheme.crystalCyan.withValues(alpha: glowIntensity * 0.6),
                  blurRadius: 15 * glowIntensity,
                  spreadRadius: 3 * glowIntensity,
                ),
                // Outer glow
                BoxShadow(
                  color: AppTheme.crystalPink.withValues(alpha: glowIntensity * 0.4),
                  blurRadius: 25 * glowIntensity,
                  spreadRadius: 8 * glowIntensity,
                ),
                if (widget.isComplete)
                  BoxShadow(
                    color: AppTheme.crystalGold.withValues(alpha: 0.5),
                    blurRadius: 35,
                    spreadRadius: 12,
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
