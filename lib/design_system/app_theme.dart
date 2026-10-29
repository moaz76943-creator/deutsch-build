import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // Use fromSeed for harmonious MD3 color schemes while keeping brand colors
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.lightSurface,
      // MD3 surface containers for better hierarchy
      surfaceContainerLowest: AppColors.lightBackground,
      surfaceContainerLow: const Color(0xFFF7F2FA),
      surfaceContainer: AppColors.lightSurface,
      surfaceContainerHigh: const Color(0xFFECE6F0),
      surfaceContainerHighest: const Color(0xFFE6E0E9),
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1C1B1F),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48), // Accessibility: min 48dp touch target
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity, // Better for different screen sizes & accessibility
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(), // Smoother iOS-style on Android for polish
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    // Support for high contrast via system
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      tertiary: AppColors.tertiaryDark,
      surface: AppColors.darkSurface,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: const Color(0xFF1B1F25),
      surfaceContainer: const Color(0xFF1F2329),
      surfaceContainerHigh: const Color(0xFF252A31),
      surfaceContainerHighest: const Color(0xFF2B3038),
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE6E1E5),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
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
