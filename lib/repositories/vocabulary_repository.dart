import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VocabularyRepository {
  static const String _storageKey = 'saved_vocabulary_list';

  // جلب الكلمات بشكل آمن مع التعامل مع الاستثناءات
  Future<List<Map<String, String>>> getVocabularyList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(_storageKey);
      if (storedData != null) {
        final List<dynamic> decoded = jsonDecode(storedData);
        return decoded.map((item) => Map<String, String>.from(item)).toList();
      }
    } catch (e) {
      // معالجة الأخطاء محلياً دون تعطل التطبيق
      print('Error loading vocabulary: $e');
    }
    
    // العودة لقائمة افتراضية آمنة في حال الفشل أو فراغ التخزين
    return [
      {"word": "die Herausforderung", "meaning": "التحدي / الصعوبة", "example": "Das ist eine große Herausforderung."},
      {"word": "nachhaltig", "meaning": "مستدام / دائم", "example": "Wir brauchen nachhaltige Lösungen."},
    ];
  }

  // حفظ الكلمات بشكل آمن ومحمي
  Future<bool> saveVocabularyList(List<Map<String, String>> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(list);
      return await prefs.setString(_storageKey, encoded);
    } catch (e) {
      print('Error saving vocabulary: $e');
      return false;
    }
  }
}
