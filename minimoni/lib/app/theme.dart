import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

/// MiniMoni App Theme
/// Soft, gentle theme designed for baby care tracking
class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPink,
        primaryContainer: AppColors.softPink,
        secondary: AppColors.pastelLavender,
        secondaryContainer: AppColors.pastelBlue,
        surface: AppColors.white,
        surfaceContainer: AppColors.offWhite,
        surfaceContainerHighest: AppColors.lightGray,
        onPrimary: AppColors.white,
        onPrimaryContainer: AppColors.textDark,
        onSecondary: AppColors.textDark,
        onSecondaryContainer: AppColors.textDark,
        onSurface: AppColors.textDark,
        onSurfaceVariant: AppColors.textMedium,
        outline: AppColors.mediumGray,
        error: AppColors.error,
      ),

      // Typography with Google Fonts
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          height: 1.2,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.3,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.3,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.4,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
          height: 1.4,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
          height: 1.4,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.5,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
          height: 1.5,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
          height: 1.5,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          height: 1.6,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textMedium,
          height: 1.6,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textLight,
          height: 1.6,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
          height: 1.4,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
          height: 1.4,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
          height: 1.4,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark, size: 24),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: AppColors.primaryPink.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.primaryPink.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPink,
          side: const BorderSide(color: AppColors.primaryPink, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPink,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.nunito(color: AppColors.textLight, fontSize: 14),
        labelStyle: GoogleFonts.nunito(
          color: AppColors.textMedium,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryPink,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.offWhite,

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPink,
        primaryContainer: AppColors.softPink,
        secondary: AppColors.pastelLavender,
        secondaryContainer: AppColors.pastelBlue,
        surface: Color(0xFF0A0A0A), // Çok koyu gri
        surfaceContainer: Color(0xFF1A1A1A), // Koyu gri
        surfaceContainerHighest: Color(0xFF2A2A2A), // Orta koyu gri
        onPrimary: AppColors.white,
        onPrimaryContainer: AppColors.white,
        onSecondary: AppColors.white,
        onSecondaryContainer: AppColors.white,
        onSurface: AppColors.white,
        onSurfaceVariant: Color(0xFFCCCCCC), // Açık gri
        outline: Color(0xFF666666), // Orta gri
        error: AppColors.error,
        background: Color(0xFF000000), // Siyah
      ),

      // Typography with Google Fonts
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          height: 1.2,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          height: 1.3,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          height: 1.3,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          height: 1.4,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          height: 1.4,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          height: 1.4,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          height: 1.5,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          height: 1.5,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFCCCCCC), // Açık gri
          height: 1.5,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
          height: 1.6,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCCCCCC), // Açık gri
          height: 1.6,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF999999), // Orta gri
          height: 1.6,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          height: 1.4,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFCCCCCC), // Açık gri
          height: 1.4,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF999999), // Orta gri
          height: 1.4,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF0A0A0A), // Çok koyu gri
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white, size: 24),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: AppColors.primaryPink.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Color(0xFF1A1A1A), // Koyu gri
        surfaceTintColor: Colors.transparent,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.primaryPink.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPink,
          side: const BorderSide(color: AppColors.primaryPink, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPink,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1A1A1A), // Koyu gri
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF666666)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF666666)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.nunito(color: Color(0xFF999999), fontSize: 14),
        labelStyle: GoogleFonts.nunito(
          color: Color(0xFFCCCCCC),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A0A0A), // Çok koyu gri
        selectedItemColor: AppColors.primaryPink,
        unselectedItemColor: Color(0xFF999999), // Orta gri
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: Color(0xFF000000), // Siyah
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF666666), // Orta gri
        thickness: 1,
        space: 1,
      ),
    );
  }
}
