abstract interface class LocalPreferencesStore {
  String? getString(String key);

  Future<bool> setString(String key, String value);
}
