import 'package:flutter/material.dart';

class AppTheme {
<<<<<<< HEAD
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.tertiary,
      surface: AppColors.lightSurface,
      onSurface: const Color(0xFF1C1B1F),
      background: AppColors.lightBackground,
      onBackground: const Color(0xFF1C1B1F),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1C1B1F),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48), // Accessibility: min touch target
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
=======
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B1F4D),
      fontFamily: 'Cairo',
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF38BDF8),
        secondary: Color(0xFFF39C6B),
        surface: Color(0xFF1E3A8A),
>>>>>>> origin/staging/v2-full-platform
      ),
    );
  }
}
