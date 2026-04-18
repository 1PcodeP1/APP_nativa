import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF131313);
  static const Color primary = Color(0xFFf2ca50);
  static const Color primaryContainer = Color(0xFFd4af37);
  static const Color onPrimary = Color(0xFF3c2f00);
  static const Color onPrimaryContainer = Color(0xFF554300);
  
  static const Color secondary = Color(0xFFffb4ac);
  static const Color secondaryContainer = Color(0xFF960711);
  static const Color onSecondary = Color(0xFF690007);
  static const Color onSecondaryContainer = Color(0xFFff9f95);
  
  static const Color surface = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF3a3939);
  static const Color surfaceContainerLowest = Color(0xFF0e0e0e);
  static const Color surfaceContainerLow = Color(0xFF1c1b1b);
  static const Color surfaceContainer = Color(0xFF201f1f);
  static const Color surfaceContainerHigh = Color(0xFF2a2a2a);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  
  static const Color onSurface = Color(0xFFe5e2e1);
  static const Color onSurfaceVariant = Color(0xFFd0c5af);
  static const Color surfaceVariant = Color(0xFF353534);
  
  static const Color outline = Color(0xFF99907c);
  static const Color outlineVariant = Color(0xFF4d4635);
  
  static const Color tertiary = Color(0xFFbfcdff);
}

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.surface,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    tertiary: AppColors.tertiary,
    background: AppColors.background,
    onBackground: AppColors.onSurface,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.notoSerif(
      fontWeight: FontWeight.bold,
      fontSize: 56,
      letterSpacing: -0.25,
      color: AppColors.onSurface,
    ),
    headlineLarge: GoogleFonts.notoSerif(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: AppColors.onSurface,
    ),
    headlineMedium: GoogleFonts.notoSerif(
      fontWeight: FontWeight.normal,
      fontSize: 28,
      color: AppColors.onSurface,
    ),
    titleLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: AppColors.onSurface,
    ),
    titleMedium: GoogleFonts.manrope(
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: AppColors.onSurface,
    ),
    bodyLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: AppColors.onSurface,
    ),
    bodyMedium: GoogleFonts.manrope(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: AppColors.onSurface,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: AppColors.onPrimaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceContainerLowest,
    border: InputBorder.none,
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary, width: 1),
    ),
    enabledBorder: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceContainerHigh,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(2),
    ),
    margin: EdgeInsets.zero,
  ),
);
