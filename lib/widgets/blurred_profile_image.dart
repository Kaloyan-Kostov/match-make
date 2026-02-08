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
    // 5 levels: 20, 16, 12, 8, 4, 0 (fully revealed)
    return (5 - revealProgress) * 4.0;
  }

  int get revealPercentage => revealProgress * 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.coralPink.withValues(alpha: 0.4),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pillShadow.withValues(alpha: 0.6),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
          BoxShadow(
            color: AppTheme.coralPink.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder image (warm gradient)
            _buildPlaceholderImage(),

            // Blur overlay
            if (blurAmount > 0)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: Container(
                  color: AppTheme.deepPlum.withValues(alpha: 0.15),
                ),
              ),

            // Reveal percentage indicator
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPlum.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.coralPink.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.pillShadow.withValues(alpha: 0.4),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        revealProgress == 5
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: revealProgress == 5
                            ? AppTheme.heartRed
                            : AppTheme.coralPink,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$revealPercentage% Revealed',
                        style: const TextStyle(
                          color: AppTheme.cream,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lock icon when fully blurred
            if (revealProgress == 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.deepPlum.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.coralPink.withValues(alpha: 0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.heartRed.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppTheme.coralPink,
                    size: 44,
                  ),
                ),
              ),

            // Sparkle effect when fully revealed
            if (revealProgress == 5)
              Positioned(
                top: 20,
                right: 20,
                child: Icon(
                  Icons.auto_awesome,
                  color: AppTheme.heartRed.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    // Warm gradient placeholder
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.softPlum,
            AppTheme.warmBerry,
            AppTheme.deepPlum.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 100,
          color: AppTheme.mutedText.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
