import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'crystal_orb.dart';
import 'particle_explosion.dart';

class MatchProgressBar extends StatefulWidget {
  final int myProgress; // 0-5 (my progress from left)
  final int theirProgress; // 0-5 (their progress from right)
  final String? myAvatarUrl;
  final String? theirAvatarUrl;
  final int theirBlurLevel; // 0-5 (5 = fully blurred)

  const MatchProgressBar({
    super.key,
    required this.myProgress,
    required this.theirProgress,
    this.myAvatarUrl,
    this.theirAvatarUrl,
    this.theirBlurLevel = 5,
  });

  bool get isComplete => myProgress >= 5 && theirProgress >= 5;

  @override
  State<MatchProgressBar> createState() => _MatchProgressBarState();
}

class _MatchProgressBarState extends State<MatchProgressBar> {
  bool _showExplosion = false;
  bool _hasExploded = false;

  @override
  void didUpdateWidget(MatchProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete && !_hasExploded) {
      setState(() {
        _showExplosion = true;
        _hasExploded = true;
      });
    } else if (!widget.isComplete && oldWidget.isComplete) {
      _hasExploded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Main progress row with avatars and crystal orb
          SizedBox(
            height: 70,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Progress bar background
                Positioned(
                  left: 50,
                  right: 50,
                  top: 25,
                  child: _buildProgressBar(),
                ),

                // ME avatar (far left)
                Positioned(
                  left: 0,
                  top: 8,
                  child: _buildAvatar(isMe: true),
                ),

                // THEM avatar (far right)
                Positioned(
                  right: 0,
                  top: 8,
                  child: _buildAvatar(isMe: false),
                ),

                // Crystal Orb in center
                Positioned.fill(
                  child: Center(
                    child: CrystalOrb(
                      isComplete: widget.isComplete,
                      size: 56,
                    ),
                  ),
                ),

                // Particle explosion overlay
                if (_showExplosion)
                  Positioned.fill(
                    child: ParticleExplosion(
                      trigger: _showExplosion,
                      onComplete: () {
                        if (mounted) {
                          setState(() => _showExplosion = false);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Labels below
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('YOU'),
                _buildLabel('MATCH'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isMe}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMe
              ? [AppTheme.crystalCyan.withValues(alpha: 0.3), AppTheme.midPurple]
              : [AppTheme.crystalPink.withValues(alpha: 0.3), AppTheme.midPurple],
        ),
        border: Border.all(
          color: isMe ? AppTheme.crystalCyan : AppTheme.crystalPink,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isMe ? AppTheme.crystalCyan : AppTheme.crystalPink)
                .withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                (isMe ? AppTheme.crystalCyan : AppTheme.crystalPink)
                    .withValues(alpha: 0.2),
                AppTheme.midPurple,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              color: isMe ? AppTheme.crystalCyan : AppTheme.mutedText,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.midPurple.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.softPurple.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.mutedText,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: AppTheme.deepPurple,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.softPurple.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pillShadow.withValues(alpha: 0.6),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          // MY progress - energy fill from left
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              widthFactor: (widget.myProgress / 5) * 0.42,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.crystalCyan.withValues(alpha: 0.6),
                      AppTheme.crystalCyan,
                      AppTheme.electricBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.crystalCyan.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // THEIR progress - energy fill from right
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              widthFactor: (widget.theirProgress / 5) * 0.42,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.electricBlue,
                      AppTheme.crystalPink,
                      AppTheme.crystalPink.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.crystalPink.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated version of FractionallySizedBox for smooth progress
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
  });

  @override
  AnimatedFractionallySizedBoxState createState() =>
      AnimatedFractionallySizedBoxState();
}

class AnimatedFractionallySizedBoxState
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
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}
