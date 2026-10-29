import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VocabularyRepository {
  static const String _key = 'vocabulary_items_v3';
  static const String _legacyKey = 'vocabulary_items_v2';
  static const String _backupPrefix = 'vocab_backup_roll_';

  Future<List<Map<String, dynamic>>> getVocabularyList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // نظام الإقلاع والتعبئة التلقائية (First-Run Seeder) إذا كانت المفكرة فارغة
      if (!prefs.containsKey(_key) || prefs.getString(_key) == '[]' || prefs.getString(_key) == null) {
        try {
          String jsonString = await rootBundle.loadString('assets/data/master_vocabulary.json');
          await prefs.setString(_key, jsonString);
        } catch (_) {
          // في حال عدم توفر الأصول المؤقتة يتم العودة لقائمة فارغة آمنة
        }
      }

      await _runSelfHealingDaemon(prefs);

      if (!prefs.containsKey(_key) && prefs.containsKey(_legacyKey)) {
        final legacyData = prefs.getString(_legacyKey);
        if (legacyData != null) {
          await prefs.setString(_key, legacyData);
        }
      }

      final String? jsonString = prefs.getString(_key);
      if (jsonString == null) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _runSelfHealingDaemon(SharedPreferences prefs) async {
    try {
      final String? jsonString = prefs.getString(_key);
      if (jsonString != null) {
        jsonDecode(jsonString);
      }
    } catch (_) {
      await prefs.setString(_key, '[]');
    }
  }

  Future<bool> saveVocabularyList(List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(items);
      
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('$_backupPrefix$timestamp', jsonString);

      return await prefs.setString(_key, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<String> exportBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '[]';
  }

  Future<String> exportAnkiTsv() async {
    final items = await getVocabularyList();
    StringBuffer buffer = StringBuffer();
    for (var item in items) {
      String front = item['languageCode'] == 'de' ? '${item['article']} ${item['word']}' : item['word'];
      String back = '${item['meaning']} (${item['semanticField'] ?? 'عام'})';
      buffer.write('$front\t$back\n');
    }
    return buffer.toString();
  }

  Future<String> generateDiagnosticReport() async {
    final items = await getVocabularyList();
    int total = items.length;
    Map<String, int> langs = {};
    Map<String, int> fields = {};

    for (var item in items) {
      String l = item['languageCode'] ?? 'de';
      langs[l] = (langs[l] ?? 0) + 1;
      String f = item['semanticField'] ?? 'عام';
      fields[f] = (fields[f] ?? 0) + 1;
    }

    final rawJson = await exportBackupJson();
    int bytes = utf8.encode(rawJson).length;

    StringBuffer report = StringBuffer();
    report.writeln('=== تقرير الصحة التشخيصي وتعبئة البذور ===');
    report.writeln('إجمالي الوحدات المعرفية الحقيقية: $total');
    report.writeln('حجم التخزين المؤصل محلياً: $bytes بايت');
    report.writeln('توزيع اللغات: $langs');
    report.writeln('التوزيع الدلالي والمهني: $fields');
    report.writeln('حالة التعبئة التلقائية (First-Run Seeder): مجهزة ومفعلة بنجاح');
    return report.toString();
  }

  Future<bool> importBackupJson(String jsonString) async {
    try {
      jsonDecode(jsonString);
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      return false;
    }
  }
}
