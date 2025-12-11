import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Micro-SaaS Factory: Design System
/// 
/// To change the app's look in 30 seconds:
/// 1. Change [AppColors.primary] color
/// 2. Optionally adjust [AppColors.background] for dark/light mode

class AppColors {
  // ⚡ CHANGE THIS LINE FOR EACH NEW APP!
  static const Color primary = Color(0xFF2B85FF); // Blue for PDF Organizer
  
  // Base colors
  static const Color background = Color(0xFF0F151F);
  static const Color surface = Color(0xFF1A212E);
  static const Color surfaceLight = Color(0xFF252D3D);
  
  // Derived from primary
  static Color get primaryDark => HSLColor.fromColor(primary)
      .withLightness(0.3)
      .toColor();
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAB2C0);
  
  // Status colors (PDF App specific - can be customized)
  static const Color pdfRed = Color(0xFFFF4747);
  static const Color statusSyncedBg = Color(0xFF14293A);
  static const Color statusSyncedFg = Color(0xFF4CA6FF);
  static const Color statusOcrBg = Color(0xFF251A30);
  static const Color statusOcrFg = Color(0xFFB070FF);
  static const Color statusSecuredBg = Color(0xFF2A2215);
  static const Color statusSecuredFg = Color(0xFFFFB84C);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4CA6FF), Color(0xFF0056D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
