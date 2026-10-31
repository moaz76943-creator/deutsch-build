import 'dart:async';

import 'package:flutter/foundation.dart';

import 'local_preferences_store.dart';

enum SpeechRatePreset {
  half(0.5, '0.5x'),
  threeQuarter(0.75, '0.75x'),
  normal(1.0, '1.0x');

  const SpeechRatePreset(this.multiplier, this.label);

  final double multiplier;
  final String label;

  double resolveEngineRate({
    double normalEngineRate = 0.46,
  }) =>
      (normalEngineRate * multiplier).clamp(0.1, 1.0).toDouble();
}

final class SpeechRateSettingsController extends ChangeNotifier {
  SpeechRateSettingsController._({
    required LocalPreferencesStore preferences,
    required SpeechRatePreset initialPreset,
  })  : _preferences = preferences,
        _preset = initialPreset;

  static const String _storageKey = 'settings.speech_rate.v1';

  final LocalPreferencesStore _preferences;
  SpeechRatePreset _preset;

  SpeechRatePreset get preset => _preset;
  double get speedMultiplier => _preset.multiplier;

  static Future<SpeechRateSettingsController> load({
    required LocalPreferencesStore preferences,
  }) async {
    final raw = preferences.getString(_storageKey);
    final preset = SpeechRatePreset.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => SpeechRatePreset.normal,
    );
    return SpeechRateSettingsController._(
      preferences: preferences,
      initialPreset: preset,
    );
  }

  void setPreset(SpeechRatePreset next) {
    if (_preset == next) return;
    _preset = next;
    notifyListeners();
    unawaited(_preferences.setString(_storageKey, next.name));
  }
}
