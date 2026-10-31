import 'package:shared_preferences/shared_preferences.dart';
import 'local_persistence_port.dart';

/// Adapter implementing the LocalPersistencePort using SharedPreferences.
/// This is the ONLY place that should import and use SharedPreferences directly.
/// All other code must go through the port for security, testability, and architecture compliance.
class SharedPreferencesAdapter implements LocalPersistencePort {
  final SharedPreferences _prefs;

  SharedPreferencesAdapter(this._prefs);

  static Future<SharedPreferencesAdapter> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesAdapter(prefs);
  }

  @override
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  @override
  Future<double?> getDouble(String key) async => _prefs.getDouble(key);

  @override
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  @override
  Future<List<String>?> getStringList(String key) async => _prefs.getStringList(key);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);

  @override
  Future<Set<String>> getKeys() async => _prefs.getKeys();

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);

  @override
  Future<bool> clear() => _prefs.clear();
}
