import 'package:flutter/material.dart';

class AppTheme {
  // Seed colors tuned for German learning (trust + energy) while staying MD3-friendly.
  static const Color _lightSeed = Color(0xFF365AA8);
  static const Color _darkSeed = Color(0xFFAFC6FF);

  static ThemeData get lightTheme => _buildTheme(Brightness.light, _lightSeed);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark, _darkSeed);

  static ThemeData _buildTheme(Brightness brightness, Color seed) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      // Dynamic contrast helpers for better a11y
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Cairo',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      // Accessibility: larger default touch targets + clear focus
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory, // Smoother MD3 ripples
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(), // Smoother shared-axis style
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: AppTypography.title.copyWith(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: AppTypography.label.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      cardTheme: CardTheme(
        elevation: isDark ? 1 : 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colorScheme.surfaceContainer,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return AppTypography.label.copyWith(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // Better dark mode contrast
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
    );
  }

  static TextTheme get _textTheme => const TextTheme(
    displayLarge: AppTypography.display,
    displayMedium: AppTypography.display,
    headlineLarge: AppTypography.h1,
    headlineMedium: AppTypography.h1,
    titleLarge: AppTypography.title,
    titleMedium: AppTypography.h2,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.body,
    labelLarge: AppTypography.label,
    labelMedium: AppTypography.label,
    labelSmall: AppTypography.caption,
  );

  /// Dynamic color (Material You) for Android 12+.
  /// Usage in MaterialApp: theme: AppTheme.withDynamic(dynamicLight, false), etc.
  static ThemeData withDynamic(ColorScheme dynamicScheme, bool isDark) {
    final base = isDark ? darkTheme : lightTheme;
    return base.copyWith(
      colorScheme: dynamicScheme,
      scaffoldBackgroundColor: dynamicScheme.surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: dynamicScheme.surface,
        foregroundColor: dynamicScheme.onSurface,
      ),
    );
  }
}
