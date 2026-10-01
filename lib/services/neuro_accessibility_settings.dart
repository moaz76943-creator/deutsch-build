import 'package:flutter/foundation.dart';

import 'preferences_service.dart';

class NeuroAccessibilitySettings extends ChangeNotifier {
  static const _keyEnabled = 'neuro_accessibility_enabled';

  final PreferencesService _prefs;
  bool _isEnabled = false;

  NeuroAccessibilitySettings(this._prefs) {
    _isEnabled = _prefs.getBool(_keyEnabled);
  }

  bool get isEnabled => _isEnabled;

  Future<void> setEnabled(bool value) async {
    if (_isEnabled == value) return;
    _isEnabled = value;
    await _prefs.setBool(_keyEnabled, value);
    notifyListeners();
  }
}
