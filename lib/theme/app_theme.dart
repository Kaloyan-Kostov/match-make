import 'package:flutter/material.dart';

class AppTheme {
  // Core colors
  static const Color darkNavy = Color(0xFF0A192F);
  static const Color mintGreen = Color(0xFF64FFDA);
  static const Color lightNavy = Color(0xFF112240);
  static const Color slate = Color(0xFF8892B0);
  static const Color lightSlate = Color(0xFFA8B2D1);
  static const Color white = Color(0xFFE6F1FF);

  // Button colors
  static const Color buttonShadow = Color(0xFF051024);
  static const Color buttonHighlight = Color(0xFF1D3A5F);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkNavy,
      primaryColor: mintGreen,
      colorScheme: const ColorScheme.dark(
        primary: mintGreen,
        secondary: mintGreen,
        surface: lightNavy,
        onPrimary: darkNavy,
        onSecondary: darkNavy,
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
          color: lightSlate,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: slate,
          fontSize: 16,
        ),
        labelLarge: TextStyle(
          color: darkNavy,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
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
