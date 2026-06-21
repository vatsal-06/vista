import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary teal/green palette (from wireframes)
  static const Color primary = Color(0xFF1B7B6B);        // deep teal - logo, headers
  static const Color primaryLight = Color(0xFF2ABFAD);   // bright teal - START WALK button
  static const Color primaryPale = Color(0xFFB2DFDB);    // pale teal - ripple rings
  static const Color primaryMuted = Color(0xFF4DB6AC);   // medium teal - icons

  // Surface & background
  static const Color background = Color(0xFFF0F4F3);     // off-white with green tint
  static const Color surface = Color(0xFFFFFFFF);        // card white
  static const Color surfaceGrey = Color(0xFFF5F5F5);    // light grey for secondary items

  // Text
  static const Color textPrimary = Color(0xFF111111);    // near black
  static const Color textSecondary = Color(0xFF757575);  // medium grey
  static const Color textTertiary = Color(0xFFAAAAAA);   // light grey

  // Alert / SOS
  static const Color danger = Color(0xFFB71C1C);         // deep red
  static const Color dangerLight = Color(0xFFEF5350);    // medium red
  static const Color dangerPale = Color(0xFFFFCDD2);     // pale red
  static const Color warning = Color(0xFFC0392B);        // amber/warning triangle

  // Dark button (SPEAK on home)
  static const Color darkButton = Color(0xFF1A2332);

  // Misc
  static const Color divider = Color(0xFFE0E0E0);
  static const Color activeGreen = Color(0xFF4CAF50);
  static const Color locationPurple = Color(0xFF9E9EC8);
}

class AppTextStyles {
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle titleLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle titleMedium(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      );

  static TextStyle label(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 1.2,
      );

  static TextStyle buttonText(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
