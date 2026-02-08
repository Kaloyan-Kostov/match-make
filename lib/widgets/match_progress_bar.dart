import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

class _MatchProgressBarState extends State<MatchProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartBeatController;
  late Animation<double> _heartBeatAnimation;

  @override
  void initState() {
    super.initState();
    _heartBeatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heartBeatAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _heartBeatController,
        curve: Curves.easeInOut,
      ),
    );

    // Start beating if already complete
    if (widget.isComplete) {
      _heartBeatController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MatchProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _heartBeatController.repeat(reverse: true);
    } else if (!widget.isComplete && oldWidget.isComplete) {
      _heartBeatController.stop();
      _heartBeatController.reset();
    }
  }

  @override
  void dispose() {
    _heartBeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Main progress row with avatars
          Row(
            children: [
              // ME avatar (far left)
              _buildAvatar(isMe: true),
              const SizedBox(width: 8),

              // Thick dual progress bar with heart
              Expanded(
                child: _buildLiquidProgressBar(),
              ),

              const SizedBox(width: 8),
              // THEM avatar (far right)
              _buildAvatar(isMe: false),
            ],
          ),
          const SizedBox(height: 8),
          // Labels below
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('ME'),
                _buildLabel('THEM'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isMe}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.warmBerry,
        border: Border.all(
          color: isMe ? AppTheme.coralPink : AppTheme.softPlum,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isMe ? AppTheme.coralPink : AppTheme.softPlum)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: isMe ? _buildMyAvatar() : _buildTheirAvatar(),
      ),
    );
  }

  Widget _buildMyAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.coralPink.withValues(alpha: 0.3),
            AppTheme.warmBerry,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: AppTheme.coralPink,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTheirAvatar() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.softPlum.withValues(alpha: 0.5),
                AppTheme.warmBerry,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              color: AppTheme.mutedText.withValues(alpha: 0.6),
              size: 28,
            ),
          ),
        ),
        // Blur overlay
        Container(
          decoration: BoxDecoration(
            color: AppTheme.deepPlum
                .withValues(alpha: 0.2 + (widget.theirBlurLevel * 0.12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.mutedText,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildLiquidProgressBar() {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.warmBerry,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.softPlum.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pillShadow.withValues(alpha: 0.5),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          // MY progress - liquid fill from left
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              widthFactor: (widget.myProgress / 5) * 0.45,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.coralPink.withValues(alpha: 0.8),
                      AppTheme.coralPink,
                      AppTheme.heartRed.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.coralPink.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // THEIR progress - liquid fill from right
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              widthFactor: (widget.theirProgress / 5) * 0.45,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.heartRed.withValues(alpha: 0.9),
                      AppTheme.coralPink,
                      AppTheme.coralPink.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.coralPink.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Big red pulsing heart in center
          Center(
            child: ScaleTransition(
              scale: _heartBeatAnimation,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isComplete
                      ? AppTheme.heartRed
                      : AppTheme.deepPlum,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.heartRed,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.heartRed.withValues(
                        alpha: widget.isComplete ? 0.6 : 0.3,
                      ),
                      blurRadius: widget.isComplete ? 16 : 8,
                      spreadRadius: widget.isComplete ? 4 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: widget.isComplete
                      ? AppTheme.cream
                      : AppTheme.heartRed,
                  size: 24,
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
