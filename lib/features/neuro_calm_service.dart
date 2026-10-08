import 'package:shared_preferences/shared_preferences.dart';

class NeuroCalmService {
  static const String _keyCalmMode = 'setting_calm_mode_enabled';

  static Future<bool> isCalmModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCalmMode) ?? false;
  }

  static Future<void> setCalmMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCalmMode, enabled);
  }
}
