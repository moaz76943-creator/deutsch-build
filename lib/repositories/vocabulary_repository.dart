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
      // اعتراض الأخطاء وضمان الاستقرار (Graceful Degradation)
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
}
