import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Micro-SaaS Factory: Design System
/// 
/// To change the app's look in 30 seconds:
/// 1. Change [AppColors.primary] color
/// 2. Themes automatically adapt for dark/light mode

class AppColors {
  // ⚡ CHANGE THIS LINE FOR EACH NEW APP!
  static const Color primary = Color(0xFF2B85FF); // Blue for PDF Organizer
  
  // ─────────────────────────────────────────────────────────────────
  // Dark Mode Colors
  // ─────────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F151F);
  static const Color surfaceDark = Color(0xFF1A212E);
  static const Color surfaceLightDark = Color(0xFF252D3D);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFAAB2C0);
  
  // ─────────────────────────────────────────────────────────────────
  // Light Mode Colors
  // ─────────────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  
  // Derived from primary
  static Color get primaryDark => HSLColor.fromColor(primary)
      .withLightness(0.3)
      .toColor();
  
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
  
  // ─────────────────────────────────────────────────────────────────
  // Legacy accessors (for backward compatibility in widgets)
  // These now default to dark mode colors
  // ─────────────────────────────────────────────────────────────────
  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  // Note: surfaceLight conflicts, using surfaceLightDark
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
}

class AppTheme {
  // ─────────────────────────────────────────────────────────────────
  // 🌙 Dark Theme
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondaryDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(color: AppColors.textPrimaryDark, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.backgroundDark,
        elevation: 0,
      ),
    );
  }
  
  // ─────────────────────────────────────────────────────────────────
  // ☀️ Light Theme
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      textTheme: _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLightLight,
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondaryLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(color: AppColors.textPrimaryLight, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.backgroundLight,
        elevation: 0,
      ),
    );
  }
  
  // ─────────────────────────────────────────────────────────────────
  // Shared Text Theme Builder
  // ─────────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: primary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: secondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
