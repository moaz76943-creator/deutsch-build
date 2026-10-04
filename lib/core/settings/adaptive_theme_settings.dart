import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AdaptiveThemeSettingsController extends ChangeNotifier {
  AdaptiveThemeSettingsController._({
    required SharedPreferences preferences,
    required ThemeMode initialMode,
  })  : _preferences = preferences,
        _mode = initialMode;

  static const String _storageKey = 'settings.theme_mode.v1';

  final SharedPreferences _preferences;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static Future<AdaptiveThemeSettingsController> load({
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final mode = ThemeMode.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => ThemeMode.system,
    );
    return AdaptiveThemeSettingsController._(
      preferences: prefs,
      initialMode: mode,
    );
  }

  void setMode(ThemeMode next) {
    if (_mode == next) return;
    _mode = next;
    notifyListeners();
    unawaited(_preferences.setString(_storageKey, next.name));
  }

  void followSystem() => setMode(ThemeMode.system);

  void toggle(Brightness platformBrightness) {
    final effective = switch (_mode) {
      ThemeMode.system => platformBrightness,
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
    };
    setMode(
      effective == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
