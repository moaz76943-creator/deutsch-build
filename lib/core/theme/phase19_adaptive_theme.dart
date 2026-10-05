import 'package:flutter/material.dart';

abstract final class Phase19AdaptiveTheme {
  static const Color _seed = Color(0xFF176B5B);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(
          alpha: brightness == Brightness.dark ? 0.52 : 0.72,
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
