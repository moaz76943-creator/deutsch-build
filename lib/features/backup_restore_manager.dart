import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class BackupRestoreManager {
  static const List<String> _trackedKeys = [
    'error_fingerprints',
    'user_xp_total',
    'user_streak_days',
    'user_last_session_epoch',
  ];

  static Future<String> createBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> backupData = {
      'app': 'Deutsch-BiArabi',
      'version': '2.0.0',
      'createdAt': DateTime.now().toIso8601String(),
      'data': {},
    };

    for (final key in _trackedKeys) {
      if (prefs.containsKey(key)) {
        backupData['data'][key] = prefs.get(key);
      }
    }

    return json.encode(backupData);
  }

  static Future<bool> restoreFromJson(String jsonContent) async {
    try {
      final Map<String, dynamic> parsed = json.decode(jsonContent);
      if (parsed['app'] != 'Deutsch-BiArabi' || !parsed.containsKey('data')) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = parsed['data'];

      for (final entry in data.entries) {
        if (entry.value is int) {
          await prefs.setInt(entry.key, entry.value);
        } else if (entry.value is String) {
          await prefs.setString(entry.key, entry.value);
        } else if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> exportBackupToFile(String targetPath) async {
    try {
      final jsonStr = await createBackupJson();
      final file = File(targetPath);
      await file.writeAsString(jsonStr);
      return true;
    } catch (_) {
      return false;
    }
  }
}
