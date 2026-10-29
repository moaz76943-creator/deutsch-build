import '../../../services/preferences_service.dart';
import '../domain/settings_repository.dart';

final class PreferencesSettingsLocalDataSource
    implements SettingsLocalDataSource {
  PreferencesSettingsLocalDataSource(this._preferences);

  static const String storageKey = 'app_learning_preferences_v1';

  final PreferencesService _preferences;
  String? _memoryCache;
  bool _cacheLoaded = false;

  @override
  Future<String?> read() async {
    if (_cacheLoaded) return _memoryCache;
    _memoryCache = _preferences.readText(storageKey);
    _cacheLoaded = true;
    return _memoryCache;
  }

  @override
  Future<void> write(String value) async {
    final stored = await _preferences.writeText(storageKey, value);
    if (!stored) {
      throw StateError('app_settings_write_failed');
    }
    _memoryCache = value;
    _cacheLoaded = true;
  }

  @override
  void evictMemoryCache() {
    _memoryCache = null;
    _cacheLoaded = false;
  }
}
