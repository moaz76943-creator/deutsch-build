import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/neuro_accessibility_settings.dart';

void main() {
  test('NeuroAccessibilitySettings loads and updates preference', () async {
    SharedPreferences.setMockInitialValues({'neuro_accessibility_enabled': false});
    final prefs = await PreferencesService.instance();
    final settings = NeuroAccessibilitySettings(prefs);

    expect(settings.isEnabled, isFalse);

    await settings.setEnabled(true);
    expect(settings.isEnabled, isTrue);
    expect(prefs.getBool('neuro_accessibility_enabled'), isTrue);
  });
}
