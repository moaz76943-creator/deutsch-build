import 'package:flutter/material.dart';

import 'visual_theme_contracts.dart';

class BrightnessModeController extends ChangeNotifier {
  BrightnessModeController({
    VisualThemeMode initialMode = VisualThemeMode.system,
  }) : _mode = initialMode;

  VisualThemeMode _mode;

  VisualThemeMode get mode => _mode;

  ThemeMode get themeMode => switch (_mode) {
        VisualThemeMode.system => ThemeMode.system,
        VisualThemeMode.light => ThemeMode.light,
        VisualThemeMode.dark => ThemeMode.dark,
      };

  Brightness effectiveBrightness(Brightness platformBrightness) =>
      switch (_mode) {
        VisualThemeMode.system => platformBrightness,
        VisualThemeMode.light => Brightness.light,
        VisualThemeMode.dark => Brightness.dark,
      };

  void selectMode(VisualThemeMode next) {
    if (_mode == next) return;
    _mode = next;
    notifyListeners();
  }

  void selectThemeMode(ThemeMode next) {
    selectMode(
      switch (next) {
        ThemeMode.system => VisualThemeMode.system,
        ThemeMode.light => VisualThemeMode.light,
        ThemeMode.dark => VisualThemeMode.dark,
      },
    );
  }

  void toggle(Brightness platformBrightness) {
    final effective = effectiveBrightness(platformBrightness);
    selectMode(
      effective == Brightness.dark
          ? VisualThemeMode.light
          : VisualThemeMode.dark,
    );
  }

  void followSystem() => selectMode(VisualThemeMode.system);
}
