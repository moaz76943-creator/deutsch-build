import 'learning_preferences.dart';
import 'storage_metrics.dart';

abstract interface class SettingsRepository {
  Future<LearningPreferences> loadPreferences();
  Future<void> savePreferences(LearningPreferences preferences);
  Future<StorageMetrics> loadStorageMetrics();
  Future<StorageMetrics> clearCache();
}

abstract interface class SettingsLocalDataSource {
  Future<String?> read();
  Future<void> write(String value);
  void evictMemoryCache();
}

abstract interface class LearningProgressResetter {
  Future<bool> resetLearningProgress();
}
