import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupRestoreManager {
  static const List<String> _trackedKeys = [
    'user_custom_smart_notes',
    'srs_records',
    'user_favorite_words',
    'streak_count',
    'streak_last_active_date',
    'user_mistakes_bank',
  ];

  /// تصدير جميع بيانات المستخدم إلى نص JSON آمن
  static Future<String> exportBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> exportMap = {
      'app': 'Deutsch بالعربي',
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {},
    };

    for (final key in _trackedKeys) {
      if (prefs.containsKey(key)) {
        exportMap['data'][key] = prefs.get(key);
      }
    }

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  /// استيراد واستعادة بيانات المستخدم من JSON
  static Future<bool> restoreFromBackupJson(String jsonString) async {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic> || !decoded.containsKey('data')) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded['data']);

      for (final entry in data.entries) {
        final val = entry.value;
        if (val is String) {
          await prefs.setString(entry.key, val);
        } else if (val is int) {
          await prefs.setInt(entry.key, val);
        } else if (val is List) {
          await prefs.setStringList(entry.key, val.cast<String>());
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// نسخ النسخة الاحتياطية مباشرة إلى الحافظة
  static Future<void> copyBackupToClipboard() async {
    final jsonText = await exportBackupData();
    await Clipboard.setData(ClipboardData(text: jsonText));
    HapticFeedback.lightImpact();
  }
}
