import 'package:flutter/foundation.dart';

import '../domain/learning_preferences.dart';
import '../domain/storage_metrics.dart';

abstract interface class SettingsController implements Listenable {
  LearningPreferences get preferences;
  StorageMetrics get storageMetrics;
  bool get isInitialized;
  bool get isSaving;
  bool get isBusy;
  bool get hasError;
  String? get errorCode;

  Future<void> initialize();
  Future<void> setSpeechRatePreset(SpeechRatePreset preset);
  Future<void> setTextScaleFactor(double value);
  Future<void> setShowAutomaticTranslation(bool value);
  Future<bool> clearCache();
  Future<bool> resetLearningProgress({required bool confirmed});
  void dispose();
}

final class UnavailableSettingsController implements SettingsController {
  const UnavailableSettingsController();

  @override
  LearningPreferences get preferences => const LearningPreferences();

  @override
  StorageMetrics get storageMetrics =>
      const StorageMetrics(localDataBytes: 0);

  @override
  bool get isInitialized => true;

  @override
  bool get isSaving => false;

  @override
  bool get isBusy => false;

  @override
  bool get hasError => false;

  @override
  String? get errorCode => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> setSpeechRatePreset(SpeechRatePreset preset) async {}

  @override
  Future<void> setTextScaleFactor(double value) async {}

  @override
  Future<void> setShowAutomaticTranslation(bool value) async {}

  @override
  Future<bool> clearCache() async => false;

  @override
  Future<bool> resetLearningProgress({required bool confirmed}) async => false;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void dispose() {}
}
