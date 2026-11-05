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
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      fontFamilyFallback: AppTypography.fallbackFontFamilies,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(colorScheme),
      // Smoother page transitions for better UX
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48), // Accessibility: larger touch targets (Google Play quality)
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 1,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
      ),
      // Support dynamic font scaling and high contrast via system settings
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Better dark mode enhancements already in darkTheme
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
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
      // Flutter automatically scales these with MediaQuery.textScaleFactor for accessibility (font scaling)
      // For TalkBack: ensure content descriptions on interactive elements in widgets
    );
  }
}
