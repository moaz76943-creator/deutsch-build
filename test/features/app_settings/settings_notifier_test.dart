import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/app_settings/application/settings_notifier.dart';
import 'package:deutsch_bilarabi/features/app_settings/domain/learning_preferences.dart';
import 'package:deutsch_bilarabi/features/app_settings/domain/settings_repository.dart';
import 'package:deutsch_bilarabi/features/app_settings/domain/storage_metrics.dart';

final class _MemorySettingsRepository implements SettingsRepository {
  LearningPreferences preferences = const LearningPreferences();
  StorageMetrics metrics = const StorageMetrics(localDataBytes: 0);
  bool failSave = false;

  @override
  Future<LearningPreferences> loadPreferences() async => preferences;

  @override
  Future<void> savePreferences(LearningPreferences preferences) async {
    if (failSave) throw StateError('save failed');
    this.preferences = preferences;
  }

  @override
  Future<StorageMetrics> loadStorageMetrics() async => metrics;

  @override
  Future<StorageMetrics> clearCache() async {
    metrics = StorageMetrics(
      localDataBytes: metrics.localDataBytes,
      lastCacheClearAt: DateTime.utc(2026, 10, 3, 18, 30),
    );
    return metrics;
  }
}

final class _MemoryProgressResetter implements LearningProgressResetter {
  int resetCalls = 0;
  bool result = true;

  @override
  Future<bool> resetLearningProgress() async {
    resetCalls += 1;
    return result;
  }
}

void main() {
  test('updates preferences immediately and persists them', () async {
    final repository = _MemorySettingsRepository();
    final resetter = _MemoryProgressResetter();
    final notifier = SettingsNotifier(repository, resetter);
    addTearDown(notifier.dispose);
    await notifier.initialize();

    await notifier.setSpeechRatePreset(SpeechRatePreset.slow);
    await notifier.setTextScaleFactor(1.18);
    await notifier.setShowAutomaticTranslation(false);

    expect(notifier.preferences.speechRate, 0.75);
    expect(notifier.preferences.textScaleFactor, 1.2);
    expect(notifier.preferences.showAutomaticTranslation, isFalse);
    expect(repository.preferences, notifier.preferences);
  });

  test('queued failed saves restore the last persisted snapshot', () async {
    final repository = _MemorySettingsRepository();
    final notifier = SettingsNotifier(
      repository,
      _MemoryProgressResetter(),
    );
    addTearDown(notifier.dispose);
    await notifier.initialize();
    repository.failSave = true;

    final first = notifier.setTextScaleFactor(1.15);
    final second = notifier.setTextScaleFactor(1.25);

    await expectLater(first, throwsStateError);
    await expectLater(second, throwsStateError);

    expect(notifier.preferences.textScaleFactor, 1.0);
    expect(notifier.hasError, isTrue);
  });

  test('failed save restores previous preferences and exposes an error', () async {
    final repository = _MemorySettingsRepository();
    final notifier = SettingsNotifier(
      repository,
      _MemoryProgressResetter(),
    );
    addTearDown(notifier.dispose);
    await notifier.initialize();
    repository.failSave = true;

    await expectLater(
      notifier.setTextScaleFactor(1.25),
      throwsStateError,
    );

    expect(notifier.preferences.textScaleFactor, 1.0);
    expect(notifier.hasError, isTrue);
  });

  test('clear cache refreshes storage metrics', () async {
    final repository = _MemorySettingsRepository();
    final notifier = SettingsNotifier(
      repository,
      _MemoryProgressResetter(),
    );
    addTearDown(notifier.dispose);
    await notifier.initialize();

    final cleared = await notifier.clearCache();

    expect(cleared, isTrue);
    expect(notifier.storageMetrics.lastCacheClearAt, isNotNull);
  });

  test('progress reset requires explicit confirmation', () async {
    final resetter = _MemoryProgressResetter();
    final notifier = SettingsNotifier(
      _MemorySettingsRepository(),
      resetter,
    );
    addTearDown(notifier.dispose);
    await notifier.initialize();

    expect(
      await notifier.resetLearningProgress(confirmed: false),
      isFalse,
    );
    expect(resetter.resetCalls, 0);

    expect(
      await notifier.resetLearningProgress(confirmed: true),
      isTrue,
    );
    expect(resetter.resetCalls, 1);
  });
}
