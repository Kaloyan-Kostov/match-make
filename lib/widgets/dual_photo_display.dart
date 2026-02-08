import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shatter_reveal_photo.dart';

class DualPhotoDisplay extends StatelessWidget {
  final int myProgress;
  final int theirProgress;
  final bool isMyTurn;

  const DualPhotoDisplay({
    super.key,
    required this.myProgress,
    required this.theirProgress,
    this.isMyTurn = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Photo card sizing - responsive to screen
        final photoWidth = (screenWidth - 48) / 2; // 48 = padding + gap
        final photoHeight = screenHeight * 0.85; // Leave room for avatars
        final avatarSize = screenWidth * 0.12; // Responsive avatar

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ME side (left)
            Expanded(
              child: _buildPhotoColumn(
                isMe: true,
                progress: 5, // ME is always fully revealed
                isActive: isMyTurn,
                tiltAngle: -5,
                photoWidth: photoWidth,
                photoHeight: photoHeight,
                avatarSize: avatarSize,
              ),
            ),

            const SizedBox(width: 12),

            // THEM side (right)
            Expanded(
              child: _buildPhotoColumn(
                isMe: false,
                progress: theirProgress,
                isActive: !isMyTurn,
                tiltAngle: 5,
                photoWidth: photoWidth,
                photoHeight: photoHeight,
                avatarSize: avatarSize,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoColumn({
    required bool isMe,
    required int progress,
    required bool isActive,
    required double tiltAngle,
    required double photoWidth,
    required double photoHeight,
    required double avatarSize,
  }) {
    return Column(
      children: [
        // Avatar with label
        _buildAvatarWithLabel(
          isMe: isMe,
          isActive: isActive,
          size: avatarSize,
        ),

        const SizedBox(height: 10),

        // Photo card
        Expanded(
          child: ShatterRevealPhoto(
            revealProgress: progress,
            isMe: isMe,
            isActive: isActive,
            tiltAngle: tiltAngle,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWithLabel({
    required bool isMe,
    required bool isActive,
    required double size,
  }) {
    final accentColor = isMe ? AppTheme.crystalCyan : AppTheme.crystalPink;

    return Column(
      children: [
        // Avatar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accentColor.withValues(alpha: 0.4),
                AppTheme.midPurple,
              ],
            ),
            border: Border.all(
              color: isActive
                  ? accentColor
                  : accentColor.withValues(alpha: 0.4),
              width: isActive ? 3 : 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.pillShadow.withValues(alpha: 0.5),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Center(
            child: Icon(
              Icons.person,
              color: isActive ? accentColor : AppTheme.mutedText,
              size: size * 0.5,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? accentColor.withValues(alpha: 0.2)
                : AppTheme.midPurple,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? accentColor.withValues(alpha: 0.5)
                  : AppTheme.softPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            isMe ? 'YOU' : 'THEM',
            style: TextStyle(
              color: isActive ? accentColor : AppTheme.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
