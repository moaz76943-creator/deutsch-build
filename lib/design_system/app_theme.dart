import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  /// Builds a Material 3 theme that prefers dynamic (Material You) colors
  /// when available, otherwise falls back to the brand seed.
  /// Enhanced for accessibility (TalkBack, contrast, font scaling), dark mode,
  /// surface hierarchy, and smoother animations.
  static ThemeData build({
    required Brightness brightness,
    ColorScheme? dynamicScheme,
  }) {
    final isDark = brightness == Brightness.dark;

    final ColorScheme baseScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: isDark ? AppColors.primaryDark : AppColors.primary,
          brightness: brightness,
        );

    // Explicit surface hierarchy for proper MD3 elevation and containers
    final ColorScheme colorScheme = baseScheme.copyWith(
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      secondary: isDark ? AppColors.secondaryDark : AppColors.secondary,
      tertiary: isDark ? AppColors.tertiaryDark : AppColors.tertiary,
      surface: isDark ? const Color(0xFF12151A) : const Color(0xFFFFFEFC),
      surfaceContainerLowest: isDark ? const Color(0xFF0B0E12) : const Color(0xFFFFFFFF),
      surfaceContainerLow: isDark ? const Color(0xFF1B1F25) : const Color(0xFFF8FAFC),
      surfaceContainer: isDark ? const Color(0xFF1F2329) : const Color(0xFFF1F5F9),
      surfaceContainerHigh: isDark ? const Color(0xFF292D33) : const Color(0xFFE2E8F0),
      surfaceContainerHighest: isDark ? const Color(0xFF33373D) : const Color(0xFFCBD5E1),
      onSurface: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      onSurfaceVariant: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
      outline: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      outlineVariant: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Cairo',
      fontFamilyFallback: AppTypography.fallbackFontFamilies,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _buildTextTheme(colorScheme),
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
          side: BorderSide(color: colorScheme.outline, width: 1.5),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      cardTheme: CardTheme(
        elevation: isDark ? 1 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surfaceContainer,
        surfaceTintColor: colorScheme.surfaceTint,
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        titleTextStyle: AppTypography.h2.copyWith(color: colorScheme.onSurface),
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: AppTypography.h2.copyWith(color: colorScheme.onSurface),
        contentTextStyle: AppTypography.body.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        modalElevation: 8,
        modalBackgroundColor: colorScheme.surfaceContainerHigh,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
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
      splashFactory: InkSparkle.splashFactory,
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
