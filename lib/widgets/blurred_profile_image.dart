import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BlurredProfileImage extends StatelessWidget {
  final int revealProgress; // 0-5 (0 = fully blurred, 5 = fully revealed)
  final String? imageUrl;

  const BlurredProfileImage({
    super.key,
    required this.revealProgress,
    this.imageUrl,
  });

  double get blurAmount {
    return (5 - revealProgress) * 4.0;
  }

  int get revealPercentage => revealProgress * 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: revealProgress == 5
              ? AppTheme.crystalCyan.withValues(alpha: 0.6)
              : AppTheme.softPurple.withValues(alpha: 0.5),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pillShadow.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
          if (revealProgress == 5)
            BoxShadow(
              color: AppTheme.crystalCyan.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 4,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder image
            _buildPlaceholderImage(),

            // Blur overlay
            if (blurAmount > 0)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: Container(
                  color: AppTheme.deepPurple.withValues(alpha: 0.2),
                ),
              ),

            // Reveal percentage indicator
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPurple.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: revealProgress == 5
                          ? AppTheme.crystalCyan
                          : AppTheme.softPurple,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        revealProgress == 5
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: revealProgress == 5
                            ? AppTheme.crystalCyan
                            : AppTheme.mutedText,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$revealPercentage%',
                        style: TextStyle(
                          color: revealProgress == 5
                              ? AppTheme.crystalCyan
                              : AppTheme.mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lock overlay when fully blurred
            if (revealProgress == 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPurple.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.crystalPink.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.crystalPink.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: AppTheme.crystalPink,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.softPurple,
            AppTheme.midPurple,
            AppTheme.deepPurple.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: AppTheme.mutedText.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
