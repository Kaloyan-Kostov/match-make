import 'package:flutter/material.dart';

class AppTheme {
  // Warm plum/berry color palette
  static const Color deepPlum = Color(0xFF2D1B36);
  static const Color warmBerry = Color(0xFF3D2847);
  static const Color softPlum = Color(0xFF4A3255);
  static const Color lightPlum = Color(0xFF5C4168);

  // Accent colors
  static const Color heartRed = Color(0xFFFF5252); // Bright red for heart
  static const Color coralPink = Color(0xFFFF8A80);
  static const Color softPink = Color(0xFFFFAB91);

  // Text colors
  static const Color cream = Color(0xFFFFF8F0);
  static const Color softCream = Color(0xFFE8DED5);
  static const Color mutedText = Color(0xFFB8A8B8);

  // Button colors
  static const Color pillBackground = Color(0xFF4A3255);
  static const Color pillShadow = Color(0xFF1A0F1F);
  static const Color pillHighlight = Color(0xFF6B5278);

  // Legacy aliases for compatibility
  static const Color darkNavy = deepPlum;
  static const Color mintGreen = coralPink;
  static const Color lightNavy = warmBerry;
  static const Color slate = mutedText;
  static const Color lightSlate = softCream;
  static const Color white = cream;
  static const Color buttonShadow = pillShadow;
  static const Color buttonHighlight = pillHighlight;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepPlum,
      primaryColor: heartRed,
      colorScheme: const ColorScheme.dark(
        primary: heartRed,
        secondary: coralPink,
        surface: warmBerry,
        onPrimary: cream,
        onSecondary: deepPlum,
        onSurface: cream,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: cream,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: cream,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: softCream,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: mutedText,
          fontSize: 16,
        ),
        labelLarge: TextStyle(
          color: deepPlum,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deepPlum,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: cream,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
