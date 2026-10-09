import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VocabularyRepository {
  static const String _key = 'vocabulary_items_v3';
  static const String _legacyKey = 'vocabulary_items_v2';

  Future<List<Map<String, dynamic>>> getVocabularyList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
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

  // تصدير البيانات بتنسيق Anki المتوافق (Tab-Separated Values: Front \t Back)
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

  Future<bool> importBackupJson(String jsonString) async {
    try {
      jsonDecode(jsonString);
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDatabaseHealthStats() async {
    final items = await getVocabularyList();
    int totalCount = items.length;
    
    Map<String, int> langCounts = {};
    for (var item in items) {
      String lang = item['languageCode'] ?? 'de';
      langCounts[lang] = (langCounts[lang] ?? 0) + 1;
    }

    final rawJson = await exportBackupJson();
    int sizeInBytes = utf8.encode(rawJson).length;

    return {
      'totalCount': totalCount,
      'langCounts': langCounts,
      'sizeInBytes': sizeInBytes,
      'status': 'مستقر ومجهز لتصدير Anki'
    };
  }
}
