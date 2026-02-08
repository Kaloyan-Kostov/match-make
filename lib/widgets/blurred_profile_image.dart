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
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.mintGreen.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mintGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder image (gradient for now)
            _buildPlaceholderImage(),

            // Blur overlay
            if (blurAmount > 0)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: Container(
                  color: AppTheme.darkNavy.withValues(alpha: 0.1),
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
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.darkNavy.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.mintGreen.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        revealProgress == 5
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppTheme.mintGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$revealPercentage% Revealed',
                        style: const TextStyle(
                          color: AppTheme.mintGreen,
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.darkNavy.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.mintGreen.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppTheme.mintGreen,
                    size: 40,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    // Using a gradient as placeholder - replace with actual image later
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightNavy,
            AppTheme.darkNavy.withValues(alpha: 0.8),
            const Color(0xFF1A365D),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 120,
          color: AppTheme.slate.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
