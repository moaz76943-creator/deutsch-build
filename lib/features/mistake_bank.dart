import 'package:shared_preferences/shared_preferences.dart';

class MistakeBank {
  static const String _mistakesKey = 'user_mistakes_bank';

  static Future<void> addMistake(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_mistakesKey) ?? [];
    if (!list.contains(wordId)) {
      list.add(wordId);
      await prefs.setStringList(_mistakesKey, list);
    }
  }

  static Future<void> removeMistake(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_mistakesKey) ?? [];
    if (list.contains(wordId)) {
      list.remove(wordId);
      await prefs.setStringList(_mistakesKey, list);
    }
  }

  static Future<List<String>> getMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_mistakesKey) ?? [];
  }
}
