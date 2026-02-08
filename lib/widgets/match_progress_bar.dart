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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MatchProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isComplete) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // ME avatar + label
          _buildAvatarWithLabel(
            label: 'ME',
            isMe: true,
          ),
          const SizedBox(width: 12),

          // Dual progress bar
          Expanded(
            child: _buildDualProgressBar(),
          ),

          const SizedBox(width: 12),
          // THEM avatar + label
          _buildAvatarWithLabel(
            label: 'THEM',
            isMe: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithLabel({
    required String label,
    required bool isMe,
  }) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.mintGreen.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.mintGreen.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: isMe
                ? _buildMyAvatar()
                : _buildTheirAvatar(),
          ),
        ),
        const SizedBox(height: 6),
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.lightNavy,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.mintGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.mintGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyAvatar() {
    // Fully revealed avatar for ME
    return Container(
      color: AppTheme.lightNavy,
      child: const Center(
        child: Icon(
          Icons.person,
          color: AppTheme.mintGreen,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTheirAvatar() {
    // Blurred avatar for THEM based on reveal progress
    final blurAmount = widget.theirBlurLevel * 2.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: AppTheme.lightNavy,
          child: Center(
            child: Icon(
              Icons.person,
              color: AppTheme.slate.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
        ),
        if (blurAmount > 0)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkNavy.withValues(alpha: 0.3 + (widget.theirBlurLevel * 0.1)),
            ),
          ),
      ],
    );
  }

  Widget _buildDualProgressBar() {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: AppTheme.lightNavy,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppTheme.mintGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // MY progress (left to center)
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (widget.myProgress / 5) * 0.5, // Half width max
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.mintGreen.withValues(alpha: 0.7),
                      AppTheme.mintGreen,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mintGreen.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // THEIR progress (right to center)
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: (widget.theirProgress / 5) * 0.5, // Half width max
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.mintGreen,
                      AppTheme.mintGreen.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mintGreen.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Animated Heart icon at center
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => Transform.scale(
                scale: widget.isComplete ? _pulseAnimation.value : 1.0,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.isComplete
                      ? AppTheme.mintGreen
                      : AppTheme.darkNavy,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.mintGreen,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mintGreen.withValues(
                        alpha: widget.isComplete ? 0.6 : 0.3,
                      ),
                      blurRadius: widget.isComplete ? 12 : 8,
                      spreadRadius: widget.isComplete ? 4 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: widget.isComplete
                      ? AppTheme.darkNavy
                      : AppTheme.mintGreen,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
