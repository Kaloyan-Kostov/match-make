import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'crystal_orb.dart';

class MatchProgressBar extends StatelessWidget {
  final int myProgress; // 0-5
  final int theirProgress; // 0-5

  const MatchProgressBar({
    super.key,
    required this.myProgress,
    required this.theirProgress,
  });

  bool get isComplete => myProgress >= 5 && theirProgress >= 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ME avatar + label
          _buildAvatarLabel(isMe: true),

          const SizedBox(width: 10),

          // Progress bar with central orb
          Expanded(
            child: SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress bar track
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.deepPurple,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.softPurple.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // MY progress fill (left to center)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            width: (myProgress / 5) * 0.45 * double.infinity,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.crystalCyan.withValues(alpha: 0.7),
                                  AppTheme.crystalCyan,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.crystalCyan.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // THEIR progress fill (right to center)
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            width: (theirProgress / 5) * 0.45 * double.infinity,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.crystalPink,
                                  AppTheme.crystalPink.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.crystalPink.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Central sparkle orb
                  CrystalOrb(
                    isComplete: isComplete,
                    size: 44,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // THEM avatar + label
          _buildAvatarLabel(isMe: false),
        ],
      ),
    );
  }

  Widget _buildAvatarLabel({required bool isMe}) {
    final color = isMe ? AppTheme.crystalCyan : AppTheme.crystalPink;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.3),
                AppTheme.midPurple,
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.7),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            color: color,
            size: 22,
          ),
        ),

        const SizedBox(height: 4),

        // Label with progress
        Text(
          isMe ? 'YOU' : 'THEM',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
