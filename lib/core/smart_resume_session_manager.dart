import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SmartResumeSessionManager {
  static const String _keyActiveSession = 'active_learning_session_state';

  static Future<void> saveCurrentProgress({
    required int taskIndex,
    required List<String> taskIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'lastIndex': taskIndex,
      'taskIds': taskIds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_keyActiveSession, json.encode(data));
  }

  static Future<Map<String, dynamic>?> getSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyActiveSession);
    if (raw == null) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveSession);
  }
}
