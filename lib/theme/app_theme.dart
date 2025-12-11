import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors based on the design
  static const Color background = Color(0xFF0F151F); // Deep dark blue/black
  static const Color surface = Color(0xFF1A212E); // Slightly lighter for cards/bars
  static const Color surfaceLight = Color(0xFF252D3D); // Even lighter for interactions
  static const Color primary = Color(0xFF2B85FF); // Bright Blue accent
  static const Color primaryDark = Color(0xFF0056D2);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAB2C0); // Muted grey for subtitles
  static const Color pdfRed = Color(0xFFFF4747);
  static const Color statusSyncedBg = Color(0xFF14293A);
  static const Color statusSyncedFg = Color(0xFF4CA6FF);
  static const Color statusOcrBg = Color(0xFF251A30);
  static const Color statusOcrFg = Color(0xFFB070FF);
  static const Color statusSecuredBg = Color(0xFF2A2215);
  static const Color statusSecuredFg = Color(0xFFFFB84C);
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
      ),
      // Customizing other components to match the "Surface" look
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.inter(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
