import 'package:flutter/material.dart';

/// MiniMoni Color Palette
/// Based on the soft pink and white logo design
class AppColors {
  // Primary Colors (from logo)
  static const Color primaryPink = Color(0xFFFF9E9E);
  static const Color lightPink = Color(0xFFFFC4C4);
  static const Color softPink = Color(0xFFFFF0F0);
  static const Color veryLightPink = Color(0xFFFFF8F8);

  // Supporting Pastels
  static const Color pastelLavender = Color(0xFFE6E6FA);
  static const Color pastelBlue = Color(0xFFE0F6FF);
  static const Color pastelYellow = Color(0xFFFFFACD);
  static const Color pastelGreen = Color(0xFFE8F5E8);
  static const Color pastelPink = Color(0xFFFFE4E1);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textDisabled = Color(0xFFA0AEC0);

  // Functional Colors
  static const Color success = Color(0xFF68D391);
  static const Color warning = Color(0xFFFBD38D);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF63B3ED);
  static const Color accentOrange = Color(0xFFFFB347);

  // Background Colors
  static const Color backgroundGradientStart = Color(0xFFFFE4E6);
  static const Color backgroundGradientEnd = Color(0xFFFFF0F8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPink, lightPink],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softPink, veryLightPink],
  );
}
