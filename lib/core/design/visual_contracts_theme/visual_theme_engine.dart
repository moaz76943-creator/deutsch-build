import 'package:flutter/material.dart';

import 'brightness_mode_controller.dart';
import 'colors_typography_bridge.dart';
import 'visual_theme_contracts.dart';

final class VisualThemeEngine extends BrightnessModeController {
  VisualThemeEngine({
    required this.themes,
    VisualThemeMode initialMode = VisualThemeMode.system,
    this.colors = const VisualColorContracts(),
    this.typography = const VisualTypographyContracts(),
  }) : super(initialMode: initialMode);

  final VisualThemeBundle themes;
  final VisualColorContracts colors;
  final VisualTypographyContracts typography;

  VisualThemeSnapshot resolve(Brightness platformBrightness) {
    final brightness = effectiveBrightness(platformBrightness);
    return VisualThemeSnapshot(
      mode: mode,
      effectiveBrightness: brightness,
      theme: themes.forBrightness(brightness),
    );
  }
}
