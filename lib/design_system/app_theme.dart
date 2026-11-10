import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  /// Builds a Material 3 theme that prefers dynamic (Material You) colors
  /// when available, otherwise falls back to the brand seed.
  /// Enhanced for accessibility (TalkBack, contrast, font scaling), dark mode,
  /// and smoother animations.
  static ThemeData build({
    required Brightness brightness,
    ColorScheme? dynamicScheme,
  }) {
    final isDark = brightness == Brightness.dark;

    final ColorScheme colorScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: isDark ? AppColors.primaryDark : AppColors.primary,
          brightness: brightness,
          primary: isDark ? AppColors.primaryDark : AppColors.primary,
          secondary: isDark ? AppColors.secondaryDark : AppColors.secondary,
          tertiary: isDark ? AppColors.tertiaryDark : AppColors.tertiary,
          surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          background: isDark ? const Color(0xFF0B1F4D) : const Color(0xFFF8FAFC),
        );

    // Boost contrast for WCAG AA+ accessibility (TalkBack + low-vision users)
    final adjustedScheme = colorScheme.copyWith(
      onSurface: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      onSurfaceVariant: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
      surfaceContainerHighest: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      outline: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness, // Fixed: was always light
      fontFamily: 'Cairo',
      fontFamilyFallback: AppTypography.fallbackFontFamilies,
      colorScheme: adjustedScheme,
      scaffoldBackgroundColor: adjustedScheme.background,
      textTheme: _buildTextTheme(adjustedScheme),
      // Larger touch targets (min 48dp) for TalkBack and motor accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: adjustedScheme.outline, width: 1.5),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      cardTheme: CardTheme(
        elevation: isDark ? 2 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: adjustedScheme.surface,
        surfaceTintColor: adjustedScheme.surfaceTint,
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: adjustedScheme.surface,
        foregroundColor: adjustedScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: AppTypography.h2.copyWith(color: adjustedScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: adjustedScheme.secondaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: adjustedScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: adjustedScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: adjustedScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: adjustedScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: adjustedScheme.onSurfaceVariant),
      ),
      // Smoother page transitions for better perceived performance
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Respect system font scaling for accessibility (no textScaleFactor override)
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory, // Modern Material 3 ripple
    );
  }

  static ThemeData get lightTheme => build(brightness: Brightness.light);
  static ThemeData get darkTheme => build(brightness: Brightness.dark);

  /// Convenience wrapper that automatically picks dynamic colors when supported.
  static Widget withDynamicColor({
    required Widget Function(ThemeData light, ThemeData dark) builder,
  }) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final light = build(
          brightness: Brightness.light,
          dynamicScheme: lightDynamic,
        );
        final dark = build(
          brightness: Brightness.dark,
          dynamicScheme: darkDynamic,
        );
        return builder(light, dark);
      },
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
    );
  }
}
