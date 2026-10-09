import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VocabularyRepository {
  static const String _key = 'vocabulary_items_v2';

  Future<List<Map<String, dynamic>>> getVocabularyList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);
      if (jsonString == null) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveVocabularyList(List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(items);
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<String> exportBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '[]';
  }

  Future<bool> importBackupJson(String jsonString) async {
    try {
      jsonDecode(jsonString); // التحقق من سلامة بنية الـ JSON
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      return false;
    }
  }

  // حساب إحصاءات الصحة المحلية وحجم البيانات
  Future<Map<String, dynamic>> getDatabaseHealthStats() async {
    final items = await getVocabularyList();
    int totalCount = items.length;
    
    Map<String, int> langCounts = {};
    for (var item in items) {
      String lang = item['languageCode'] ?? 'de';
      langCounts[lang] = (langCounts[lang] ?? 0) + 1;
    }

    final rawJson = await exportBackupJson();
    int sizeInBytes = utfIdBytesLength(rawJson);

    return {
      'totalCount': totalCount,
      'langCounts': langCounts,
      'sizeInBytes': sizeInBytes,
      'status': 'سليم ومستقر 100%'
    };
  }

  int utfIdBytesLength(String str) {
    return utf8.encode(str).length;
  }
}
