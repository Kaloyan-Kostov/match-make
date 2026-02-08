import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CrystalOrb extends StatefulWidget {
  final bool isComplete;
  final double size;

  const CrystalOrb({
    super.key,
    required this.isComplete,
    this.size = 52,
  });

  @override
  State<CrystalOrb> createState() => _CrystalOrbState();
}

class _CrystalOrbState extends State<CrystalOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isComplete) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CrystalOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isComplete && oldWidget.isComplete) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
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
                    const Color(0xFFFF5252), // Bright red
                    const Color(0xFFFF1744),
                  ]
                : [
                    AppTheme.crystalCyan.withValues(alpha: 0.8),
                    AppTheme.crystalPink.withValues(alpha: 0.8),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isComplete
                  ? const Color(0xFFFF5252).withValues(alpha: 0.6)
                  : AppTheme.crystalCyan.withValues(alpha: 0.4),
              blurRadius: widget.isComplete ? 20 : 12,
              spreadRadius: widget.isComplete ? 6 : 3,
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome,
          color: AppTheme.white,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}
