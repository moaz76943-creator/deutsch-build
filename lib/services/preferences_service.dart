import 'package:shared_preferences/shared_preferences.dart';

/// Single adapter boundary for the shared_preferences plugin.
/// Application/UI code depends on this service instead of the plugin API.
class PreferencesService {
  final SharedPreferences _prefs;
  const PreferencesService._(this._prefs);

  static Future<PreferencesService> instance() async =>
      PreferencesService._(await SharedPreferences.getInstance());

  String? getString(String key) => _prefs.getString(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  bool getBool(String key) => _prefs.getBool(key) ?? false;
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<bool> remove(String key) => _prefs.remove(key);
}

extension PreferencesTextStorage on PreferencesService {
  String? readText(String storageKey) => getString(storageKey);

  List<String>? readTextList(String storageKey) => getStringList(storageKey);

  Future<bool> writeText(String storageKey, String value) =>
      setString(storageKey, value);

  Future<bool> writeTextList(String storageKey, List<String> value) =>
      setStringList(storageKey, value);

  Future<bool> deleteValue(String storageKey) => remove(storageKey);
}
