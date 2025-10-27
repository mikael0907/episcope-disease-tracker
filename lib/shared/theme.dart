import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Common colors (used in both themes)
  static const primary = Color(0xFF3F3D56);
  static const secondary = Color(0xFFFACC15);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);

  // Light theme colors
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF1E293B);
  static const lightInputFill = Color(0xFFE2E8F0);

  // Dark theme colors
  static const darkBackground = Color(0xFF1E293B);
  static const darkSurface = Color(0xFF334155);
  static const darkText = Color(0xFFE5E7EB);
  static const darkInputFill = Color(0xFF334155);
}

class AppThemes {
  // Main font family
  static final _font = GoogleFonts.poppins();

  /// 🎨 Light Theme
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: _font.fontFamily,
    primaryColor: AppColors.primary,
    canvasColor: AppColors.lightSurface,
    cardColor: AppColors.lightSurface,
    hintColor: AppColors.lightInputFill,

    textTheme: TextTheme(
      bodyLarge: _font.copyWith(color: AppColors.lightText),
      bodyMedium: _font.copyWith(color: AppColors.lightText),
      titleLarge: _font.copyWith(
        color: AppColors.lightText,
        fontWeight: FontWeight.bold,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        textStyle: _font.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.lightSurface,
    ),
  );

  /// 🌙 Dark Theme
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: _font.fontFamily,
    primaryColor: AppColors.primary,
    canvasColor: AppColors.darkBackground,
    cardColor: AppColors.darkBackground,
    hintColor: AppColors.darkInputFill,

    textTheme: TextTheme(
      bodyLarge: _font.copyWith(color: AppColors.darkText),
      bodyMedium: _font.copyWith(color: AppColors.darkText),
      titleLarge: _font.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        textStyle: _font.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.darkSurface,
    ),
  );
}
