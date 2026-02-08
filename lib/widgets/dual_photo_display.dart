import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DualPhotoDisplay extends StatefulWidget {
  final int revealProgress; // 0-5 for THEM's reveal
  final bool isMyTurn;

  const DualPhotoDisplay({
    super.key,
    required this.revealProgress,
    this.isMyTurn = true,
  });

  @override
  State<DualPhotoDisplay> createState() => _DualPhotoDisplayState();
}

class _DualPhotoDisplayState extends State<DualPhotoDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  int _lastProgress = 0;

  @override
  void initState() {
    super.initState();
    _lastProgress = widget.revealProgress;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.06), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(DualPhotoDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealProgress > _lastProgress) {
      _scaleController.forward(from: 0);
      _lastProgress = widget.revealProgress;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get blurAmount => (5 - widget.revealProgress) * 3.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 20) / 2;
        final cardHeight = constraints.maxHeight;

        return Row(
          children: [
            // ME photo (left, tilted left)
            Expanded(
              child: Transform.rotate(
                angle: -5 * math.pi / 180,
                child: _buildPhotoCard(
                  isMe: true,
                  width: cardWidth,
                  height: cardHeight,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // THEM photo (right, tilted right)
            Expanded(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: Transform.rotate(
                  angle: 5 * math.pi / 180,
                  child: _buildPhotoCard(
                    isMe: false,
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoCard({
    required bool isMe,
    required double width,
    required double height,
  }) {
    final color = isMe ? AppTheme.crystalCyan : AppTheme.crystalPink;
    final isActive = isMe ? widget.isMyTurn : !widget.isMyTurn;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : color.withValues(alpha: 0.4),
          width: isActive ? 3 : 2,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          BoxShadow(
            color: AppTheme.pillShadow.withValues(alpha: 0.6),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo placeholder
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.2),
                    AppTheme.midPurple,
                    AppTheme.deepPurple,
                  ],
                ),
              ),
              child: _buildPhotoContent(isMe: isMe, color: color),
            ),

            // Blur overlay for THEM
            if (!isMe && blurAmount > 0)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: Container(
                  color: AppTheme.deepPurple.withValues(alpha: 0.15),
                ),
              ),

            // Reveal badge
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Center(
                child: _buildRevealBadge(isMe: isMe),
              ),
            ),

            // Lock overlay when fully blurred
            if (!isMe && widget.revealProgress == 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPurple.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.crystalPink.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: AppTheme.crystalPink,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoContent({required bool isMe, required Color color}) {
    // Placeholder - in production, use Image.network with errorBuilder
    return Center(
      child: Icon(
        Icons.person,
        size: 48,
        color: color.withValues(alpha: isMe ? 0.5 : 0.3),
      ),
    );
  }

  Widget _buildRevealBadge({required bool isMe}) {
    final percentage = isMe ? 100 : widget.revealProgress * 20;
    final isRevealed = percentage == 100;
    final color = isMe ? AppTheme.crystalCyan : AppTheme.crystalPink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.deepPurple.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRevealed ? color : AppTheme.softPurple,
          width: 1,
        ),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: isRevealed ? color : AppTheme.mutedText,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
