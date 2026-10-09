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

  // تصدير البيانات بالكامل كـ JSON نصي للنسخ الاحتياطي
  Future<String> exportBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '[]';
  }

  // استعادة البيانات من ملف النسخ الاحتياطي
  Future<bool> importBackupJson(String jsonString) async {
    try {
      // التحقق من صحة بنية الـ JSON
      jsonDecode(jsonString);
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      return false;
    }
  }
}
