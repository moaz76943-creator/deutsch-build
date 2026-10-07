import 'package:shared_preferences/shared_preferences.dart';

class ProgressStorageService {
  static const String _keyLangCode = 'user_selected_language';
  static const String _keyStreak = 'user_streak_days';
  static const String _keyPoints = 'user_total_points';
  static const String _keyAccuracy = 'user_accuracy_percent';
  static const String _keyFavorites = 'user_favorite_words';

  static Future<void> saveSelectedLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLangCode, langCode);
  }

  static Future<String> getSelectedLanguage({String defaultLang = 'de'}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLangCode) ?? defaultLang;
  }

  static Future<void> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyPoints) ?? 1450;
    await prefs.setInt(_keyPoints, current + points);
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'streak': prefs.getInt(_keyStreak) ?? 14,
      'points': prefs.getInt(_keyPoints) ?? 1450,
      'accuracy': prefs.getInt(_keyAccuracy) ?? 98,
      'langCode': prefs.getString(_keyLangCode) ?? 'de',
    };
  }

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  static Future<bool> toggleFavorite(String wordJsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList(_keyFavorites) ?? [];
    bool isAdded;
    if (favs.contains(wordJsonStr)) {
      favs.remove(wordJsonStr);
      isAdded = false;
    } else {
      favs.add(wordJsonStr);
      isAdded = true;
    }
    await prefs.setStringList(_keyFavorites, favs);
    return isAdded;
  }
}
