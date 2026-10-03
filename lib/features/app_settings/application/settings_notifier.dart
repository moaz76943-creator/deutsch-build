import 'package:flutter/foundation.dart';

import '../domain/learning_preferences.dart';
import '../domain/settings_repository.dart';
import '../domain/storage_metrics.dart';

final class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier(this._repository, this._progressResetter);

  final SettingsRepository _repository;
  final LearningProgressResetter _progressResetter;

  LearningPreferences _preferences = const LearningPreferences();
  StorageMetrics _storageMetrics =
      const StorageMetrics(localDataBytes: 0);
  bool _initialized = false;
  bool _saving = false;
  bool _busy = false;
  String? _errorCode;

  LearningPreferences get preferences => _preferences;
  StorageMetrics get storageMetrics => _storageMetrics;
  bool get isInitialized => _initialized;
  bool get isSaving => _saving;
  bool get isBusy => _busy;
  bool get hasError => _errorCode != null;
  String? get errorCode => _errorCode;

  Future<void> initialize() async {
    if (_initialized) return;
    _busy = true;
    _errorCode = null;
    notifyListeners();
    try {
      _preferences = await _repository.loadPreferences();
      _storageMetrics = await _repository.loadStorageMetrics();
      _initialized = true;
    } on Object {
      _errorCode = 'settings_initialize_failed';
      _initialized = true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> setSpeechRatePreset(SpeechRatePreset preset) {
    return _persist(
      _preferences.copyWith(speechRatePreset: preset),
    );
  }

  Future<void> setTextScaleFactor(double value) {
    return _persist(
      _preferences.copyWith(textScaleFactor: value),
    );
  }

  Future<void> setShowAutomaticTranslation(bool value) {
    return _persist(
      _preferences.copyWith(showAutomaticTranslation: value),
    );
  }

  Future<bool> clearCache() async {
    _busy = true;
    _errorCode = null;
    notifyListeners();
    try {
      _storageMetrics = await _repository.clearCache();
      return true;
    } on Object {
      _errorCode = 'settings_cache_clear_failed';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> resetLearningProgress({
    required bool confirmed,
  }) async {
    if (!confirmed || _busy) return false;
    _busy = true;
    _errorCode = null;
    notifyListeners();
    try {
      final reset = await _progressResetter.resetLearningProgress();
      if (!reset) {
        _errorCode = 'learning_progress_reset_failed';
      }
      return reset;
    } on Object {
      _errorCode = 'learning_progress_reset_failed';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _persist(LearningPreferences next) async {
    if (_saving) return;
    final previous = _preferences;
    _preferences = next;
    _saving = true;
    _errorCode = null;
    notifyListeners();
    try {
      await _repository.savePreferences(next);
      _storageMetrics = await _repository.loadStorageMetrics();
    } catch (_) {
      _preferences = previous;
      _errorCode = 'settings_save_failed';
      notifyListeners();
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
