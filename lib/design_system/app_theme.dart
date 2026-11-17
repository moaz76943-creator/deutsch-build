import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../core/ui/tokens/app_motion.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  /// Builds a Material 3 theme that prefers dynamic (Material You) colors
  /// when available, otherwise falls back to the brand seed.
  /// Enhanced for accessibility (TalkBack, contrast, font scaling), dark mode,
  /// smoother animations, and Google Play design quality.
  static ThemeData build({
    required Brightness brightness,
    ColorScheme? dynamicScheme,
  }) {
    final isDark = brightness == Brightness.dark;

    final ColorScheme baseScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: isDark ? AppColors.primaryDark : AppColors.primary,
          brightness: brightness,
          primary: isDark ? AppColors.primaryDark : AppColors.primary,
          secondary: isDark ? AppColors.secondaryDark : AppColors.secondary,
          tertiary: isDark ? AppColors.tertiaryDark : AppColors.tertiary,
        );

    // High-contrast adjustments for WCAG AA/AAA + TalkBack
    final ColorScheme colorScheme = baseScheme.copyWith(
      onSurface: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      onSurfaceVariant: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      surfaceContainerLowest: isDark ? const Color(0xFF0F1419) : const Color(0xFFFFFFFF),
      surfaceContainerLow: isDark ? const Color(0xFF1A1F25) : const Color(0xFFF8FAFC),
      surfaceContainer: isDark ? const Color(0xFF1E2329) : const Color(0xFFF1F5F9),
      surfaceContainerHigh: isDark ? const Color(0xFF252A31) : const Color(0xFFE2E8F0),
      surfaceContainerHighest: isDark ? const Color(0xFF2D333B) : const Color(0xFFCBD5E1),
      outline: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      outlineVariant: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Cairo',
      fontFamilyFallback: AppTypography.fallbackFontFamilies,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _buildTextTheme(colorScheme),
      // Accessibility: larger touch targets (min 48dp)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isDark ? 2 : 1,
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
          side: BorderSide(color: colorScheme.outline, width: 1.5),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.all(12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 1 : 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: colorScheme.surfaceTint,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        titleTextStyle: AppTypography.h2.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 3,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
      ),
      // Modern Material 3 motion system
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        },
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: colorScheme.onInverseSurface, fontSize: 13),
        waitDuration: AppMotion.fast,
        showDuration: const Duration(seconds: 4),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      // Respect system font scaling — no forced overrides
      // Reduced motion is handled at widget level via MediaQuery.disableAnimations
    );
  }

  static ThemeData get lightTheme => build(brightness: Brightness.light);
  static ThemeData get darkTheme => build(brightness: Brightness.dark);

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
