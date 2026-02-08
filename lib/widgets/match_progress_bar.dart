import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glowing_orb.dart';

class MatchProgressBar extends StatelessWidget {
  final int myProgress; // 0-5
  final int theirProgress; // 0-5

  const MatchProgressBar({
    super.key,
    required this.myProgress,
    required this.theirProgress,
  });

  // Clamped to 0.0 - 0.5 (each side fills half)
  double get _myFill => (myProgress / 10.0).clamp(0.0, 0.5);
  double get _theirFill => (theirProgress / 10.0).clamp(0.0, 0.5);
  bool get isComplete => myProgress >= 5 && theirProgress >= 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // ME label
          _buildLabel('ME', AppTheme.crystalCyan),
          const SizedBox(width: 10),

          // Progress bar with orb
          Expanded(
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sleek thin bar
                  Container(
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.deepPurple,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.softPurple.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(
                        children: [
                          // MY fill (left to center) - Mint gradient
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              widthFactor: _myFill,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.crystalCyan.withValues(alpha: 0.7),
                                      AppTheme.crystalCyan,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // THEIR fill (right to center) - Pink gradient
                          Align(
                            alignment: Alignment.centerRight,
                            child: AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              widthFactor: _theirFill,
                              alignment: Alignment.centerRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.crystalPink,
                                      AppTheme.crystalPink.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Central MatchMake Star Orb
                  GlowingOrb(
                    isComplete: isComplete,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),
          // THEM label
          _buildLabel('THEM', AppTheme.crystalPink),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}

// Animated FractionallySizedBox for smooth progress
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final AlignmentGeometry alignment;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.alignment,
    required this.child,
    required super.duration,
    super.curve = Curves.linear,
  });

  @override
  ImplicitlyAnimatedWidgetState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final animatedWidth = _widthFactor?.evaluate(animation) ?? widget.widthFactor;

    // Ensure we don't render if width is 0 or negative
    if (animatedWidth <= 0) {
      return const SizedBox.shrink();
    }

    return FractionallySizedBox(
      widthFactor: animatedWidth.clamp(0.0, 1.0),
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}
