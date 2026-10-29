import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

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
    ),
    // Ensure good contrast and scaling support via theme
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: const Color(0xFF001B3D),
      secondary: AppColors.secondaryDark,
      onSecondary: const Color(0xFF003733),
      tertiary: AppColors.tertiaryDark,
      surface: AppColors.darkSurface,
      onSurface: const Color(0xFFE6E1E5),
      background: AppColors.darkBackground,
      onBackground: const Color(0xFFE6E1E5),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE6E1E5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static TextTheme get _textTheme => TextTheme(
    displayLarge: AppTypography.display.copyWith(fontSize: 32),
    displayMedium: AppTypography.display.copyWith(fontSize: 28),
    headlineLarge: AppTypography.h1.copyWith(fontSize: 24),
    headlineMedium: AppTypography.h1.copyWith(fontSize: 22),
    titleLarge: AppTypography.title,
    titleMedium: AppTypography.h2,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.body.copyWith(fontSize: 14),
    labelLarge: AppTypography.label.copyWith(fontSize: 14),
    labelMedium: AppTypography.label,
    labelSmall: AppTypography.caption,
  );

  /// Optional: Dynamic color support for Android 12+
  static ThemeData withDynamicColor(ColorScheme dynamicScheme, bool isDark) {
    final base = isDark ? darkTheme : lightTheme;
    return base.copyWith(
      colorScheme: dynamicScheme,
      scaffoldBackgroundColor: dynamicScheme.surface,
    );
  }
}
