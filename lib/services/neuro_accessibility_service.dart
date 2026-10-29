import 'preferences_service.dart';

class NeuroAccessibilityService {
  static const _keyEnabled = 'neuro_accessibility_enabled';

  final PreferencesService _prefs;

  NeuroAccessibilityService(this._prefs);

  bool get isEnabled => _prefs.getBool(_keyEnabled);

  Future<bool> setEnabled(bool value) => _prefs.setBool(_keyEnabled, value);
}
