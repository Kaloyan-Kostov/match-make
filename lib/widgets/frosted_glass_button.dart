import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FrostedGlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isTheirSelection;
  final int colorIndex;
  final double floatSpeed; // Different speeds for each button

  const FrostedGlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
    this.isTheirSelection = false,
    this.colorIndex = 0,
    this.floatSpeed = 1.0,
  });

  @override
  State<FrostedGlassButton> createState() => _FrostedGlassButtonState();
}

class _FrostedGlassButtonState extends State<FrostedGlassButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  Color get _pastelColor {
    final colors = AppTheme.pastelPalette;
    return colors[widget.colorIndex % colors.length];
  }

  Color get _glowColor {
    if (widget.isSelected) return AppTheme.crystalCyan;
    if (widget.isTheirSelection) return AppTheme.crystalPink;
    return _pastelColor;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 2 * math.pi),
      duration: Duration(milliseconds: (3000 / widget.floatSpeed).round()),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // Gentle floating motion
        final offset = math.sin(value) * 4;

        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) setState(() {});
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: _buildButton(),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: _buildSquircleBorder(),
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: _glowColor.withValues(alpha: widget.isSelected ? 0.6 : 0.3),
            blurRadius: widget.isSelected ? 20 : 12,
            spreadRadius: widget.isSelected ? 2 : 0,
          ),
          // Bottom shadow for depth
          BoxShadow(
            color: AppTheme.pillShadow.withValues(alpha: 0.5),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipPath(
        clipper: SquircleClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pastelColor.withValues(alpha: widget.isSelected ? 0.8 : 0.4),
                  _pastelColor.withValues(alpha: widget.isSelected ? 0.6 : 0.2),
                ],
              ),
              borderRadius: _buildSquircleBorder(),
              border: Border.all(
                color: widget.isSelected
                    ? AppTheme.crystalCyan
                    : _pastelColor.withValues(alpha: 0.6),
                width: widget.isSelected ? 2.5 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isSelected
                        ? AppTheme.white
                        : AppTheme.softWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    shadows: widget.isSelected
                        ? [
                            Shadow(
                              color: AppTheme.crystalCyan.withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (widget.isTheirSelection) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.crystalPink.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppTheme.crystalPink,
                    ),
                  ),
                ],
                if (widget.isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppTheme.crystalCyan,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius _buildSquircleBorder() {
    // Asymmetric "blob" style border radius
    return BorderRadius.only(
      topLeft: Radius.circular(24 + (widget.colorIndex % 3) * 4),
      topRight: Radius.circular(20 + ((widget.colorIndex + 1) % 3) * 4),
      bottomLeft: Radius.circular(18 + ((widget.colorIndex + 2) % 3) * 4),
      bottomRight: Radius.circular(26 + (widget.colorIndex % 2) * 4),
    );
  }
}

// Custom clipper for squircle/blob shape
class SquircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Organic blob-like shape using cubic bezier curves
    path.moveTo(w * 0.15, 0);
    path.cubicTo(w * 0.05, 0, 0, h * 0.1, 0, h * 0.2);
    path.lineTo(0, h * 0.8);
    path.cubicTo(0, h * 0.92, w * 0.08, h, w * 0.18, h);
    path.lineTo(w * 0.82, h);
    path.cubicTo(w * 0.94, h, w, h * 0.88, w, h * 0.75);
    path.lineTo(w, h * 0.22);
    path.cubicTo(w, h * 0.08, w * 0.92, 0, w * 0.8, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
