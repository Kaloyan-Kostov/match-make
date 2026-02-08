import 'package:flutter/material.dart';

class AppTheme {
  // Deep game background
  static const Color deepPurple = Color(0xFF1A0A2E);
  static const Color midPurple = Color(0xFF2D1B4E);
  static const Color softPurple = Color(0xFF3D2B5E);

  // Vibrant game accents
  static const Color crystalCyan = Color(0xFF00F5FF);
  static const Color crystalPink = Color(0xFFFF6BF3);
  static const Color crystalGold = Color(0xFFFFD700);
  static const Color electricBlue = Color(0xFF4D9FFF);

  // Pastel frosted colors
  static const Color frostedPink = Color(0xFFFFB3D9);
  static const Color frostedBlue = Color(0xFFB3E5FF);
  static const Color frostedPurple = Color(0xFFD9B3FF);
  static const Color frostedMint = Color(0xFFB3FFE0);
  static const Color frostedPeach = Color(0xFFFFD9B3);

  // Text colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF0E6FF);
  static const Color mutedText = Color(0xFFB8A8C8);

  // Glow colors
  static const Color glowCyan = Color(0xFF00F5FF);
  static const Color glowPink = Color(0xFFFF6BF3);

  // Legacy aliases
  static const Color deepPlum = deepPurple;
  static const Color warmBerry = midPurple;
  static const Color cream = white;
  static const Color heartRed = crystalPink;
  static const Color coralPink = crystalPink;
  static const Color softCream = softWhite;
  static const Color pillShadow = Color(0xFF0A0515);
  static const Color lightPlum = softPurple;
  static const Color softPlum = midPurple;

  // Pastel palette for buttons
  static const List<Color> pastelPalette = [
    frostedPink,
    frostedBlue,
    frostedPurple,
    frostedMint,
    frostedPeach,
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepPurple,
      primaryColor: crystalCyan,
      colorScheme: const ColorScheme.dark(
        primary: crystalCyan,
        secondary: crystalPink,
        surface: midPurple,
        onPrimary: deepPurple,
        onSecondary: deepPurple,
        onSurface: white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: softWhite,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: mutedText,
          fontSize: 16,
        ),
        labelLarge: TextStyle(
          color: deepPurple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deepPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
