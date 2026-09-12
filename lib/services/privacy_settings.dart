import 'preferences_service.dart';

/// Provider-neutral privacy preferences boundary.
///
/// UI and feature code receive this contract from the composition root rather
/// than reaching into global storage singletons.
abstract interface class PrivacySettingsStore {
  Future<bool> cloudAiEnabled();
  Future<bool> speechEnabled();
  Future<bool> setCloudAi(bool value);
  Future<bool> setSpeech(bool value);
}

final class LocalPrivacySettingsStore implements PrivacySettingsStore {
  const LocalPrivacySettingsStore(this._preferences);

  final PreferencesService _preferences;

  static const cloudKey = 'privacy_cloud_ai_v1';
  static const speechKey = 'privacy_speech_v1';

  @override
  Future<bool> cloudAiEnabled() async => _readBool(cloudKey);

  @override
  Future<bool> speechEnabled() async => _readBool(speechKey);

  @override
  Future<bool> setCloudAi(bool value) async => _writeBool(cloudKey, value);

  @override
  Future<bool> setSpeech(bool value) async => _writeBool(speechKey, value);

  Future<bool> _readBool(String key) async {
    try {
      return _preferences.getBool(key);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _writeBool(String key, bool value) async {
    try {
      return await _preferences.setBool(key, value);
    } catch (_) {
      return false;
    }
  }
}

/// Compatibility facade for staged callers outside the UI dependency graph.
/// New code should receive [PrivacySettingsStore] from composition.
final class PrivacySettings {
  PrivacySettings._();

  static Future<bool> cloudAiEnabled() async {
    try {
      return (await PreferencesService.instance()).getBool(
        LocalPrivacySettingsStore.cloudKey,
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> speechEnabled() async {
    try {
      return (await PreferencesService.instance()).getBool(
        LocalPrivacySettingsStore.speechKey,
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setCloudAi(bool value) async {
    try {
      return await (await PreferencesService.instance()).setBool(
        LocalPrivacySettingsStore.cloudKey,
        value,
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setSpeech(bool value) async {
    try {
      return await (await PreferencesService.instance()).setBool(
        LocalPrivacySettingsStore.speechKey,
        value,
      );
    } catch (_) {
      return false;
    }
  }
}
