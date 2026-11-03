import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      fontFamilyFallback: AppTypography.fallbackFontFamilies,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(colorScheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48), // Accessibility: larger touch targets
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
      ),
      // Support dynamic font scaling and high contrast via system settings
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      tertiary: AppColors.tertiaryDark,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
      fontFamilyFallback: AppTypography.fallbackFontFamilies,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(colorScheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTypography.display.copyWith(color: colorScheme.onSurface),
      displayMedium: AppTypography.display.copyWith(
        fontSize: 28,
        color: colorScheme.onSurface,
      ),
      headlineLarge: AppTypography.h1.copyWith(color: colorScheme.onSurface),
      headlineMedium: AppTypography.h2.copyWith(color: colorScheme.onSurface),
      titleLarge: AppTypography.title.copyWith(color: colorScheme.onSurface),
      titleMedium: AppTypography.title.copyWith(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
      bodyLarge: AppTypography.body.copyWith(color: colorScheme.onSurface),
      bodyMedium: AppTypography.body.copyWith(
        fontSize: 14,
        color: colorScheme.onSurface,
      ),
      labelLarge: AppTypography.label.copyWith(color: colorScheme.onSurface),
      labelMedium: AppTypography.label.copyWith(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
      ),
      // Flutter automatically scales these with MediaQuery.textScaleFactor for accessibility
    );
  }
}
