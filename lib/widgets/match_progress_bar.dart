import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MatchProgressBar extends StatelessWidget {
  final int currentProgress; // 0-5 (number of correct answers)

  const MatchProgressBar({
    super.key,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // ME label
          _buildLabel('ME'),
          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: _buildProgressBar(),
          ),

          const SizedBox(width: 12),
          // THEM label
          _buildLabel('THEM'),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightNavy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.mintGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.mintGreen,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: AppTheme.lightNavy,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.mintGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Progress fill
          FractionallySizedBox(
            widthFactor: currentProgress / 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.mintGreen.withValues(alpha: 0.8),
                    AppTheme.mintGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mintGreen.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // Heart icon at center
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkNavy,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.mintGreen,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mintGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.mintGreen,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
