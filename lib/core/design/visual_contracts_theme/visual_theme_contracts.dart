import 'package:flutter/material.dart';

enum VisualThemeMode { system, light, dark }

@immutable
final class VisualThemeBundle {
  const VisualThemeBundle({
    required this.light,
    required this.dark,
  });

  final ThemeData light;
  final ThemeData dark;

  ThemeData forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

@immutable
final class VisualThemeSnapshot {
  const VisualThemeSnapshot({
    required this.mode,
    required this.effectiveBrightness,
    required this.theme,
  });

  final VisualThemeMode mode;
  final Brightness effectiveBrightness;
  final ThemeData theme;
}
