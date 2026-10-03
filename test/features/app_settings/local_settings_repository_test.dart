import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/app_settings/data/local_settings_repository.dart';
import 'package:deutsch_bilarabi/features/app_settings/domain/learning_preferences.dart';
import 'package:deutsch_bilarabi/features/app_settings/domain/settings_repository.dart';

final class _MemorySettingsSource implements SettingsLocalDataSource {
  String? payload;
  bool failWrites = false;
  int evictions = 0;

  @override
  Future<String?> read() async => payload;

  @override
  Future<void> write(String value) async {
    if (failWrites) throw StateError('write failed');
    payload = value;
  }

  @override
  void evictMemoryCache() {
    evictions += 1;
  }
}

void main() {
  test('saves and restores learning preferences', () async {
    final source = _MemorySettingsSource();
    final repository = LocalSettingsRepository(source);
    const expected = LearningPreferences(
      speechRatePreset: SpeechRatePreset.slow,
      textScaleFactor: 1.2,
      showAutomaticTranslation: false,
    );

    await repository.savePreferences(expected);
    final restored = await repository.loadPreferences();

    expect(restored, expected);
    expect(jsonDecode(source.payload!)['schema_version'], 1);
  });

  test('malformed persisted values are normalized fail-safe', () async {
    final source = _MemorySettingsSource()
      ..payload = jsonEncode(<String, Object?>{
        'schema_version': 1,
        'speech_rate': -4,
        'text_scale_factor': 99,
        'show_automatic_translation': 'invalid',
      });
    final repository = LocalSettingsRepository(source);

    final restored = await repository.loadPreferences();

    expect(restored.speechRate, 0.75);
    expect(
      restored.textScaleFactor,
      LearningPreferences.maximumTextScale,
    );
    expect(restored.showAutomaticTranslation, isTrue);
  });

  test('clear cache records timestamp without discarding preferences', () async {
    final source = _MemorySettingsSource();
    final now = DateTime.utc(2026, 10, 3, 18, 30);
    final repository = LocalSettingsRepository(
      source,
      nowUtc: () => now,
    );
    const expected = LearningPreferences(
      textScaleFactor: 1.15,
      showAutomaticTranslation: false,
    );
    await repository.savePreferences(expected);

    final metrics = await repository.clearCache();
    final restored = await repository.loadPreferences();

    expect(source.evictions, 1);
    expect(metrics.lastCacheClearAt, now);
    expect(metrics.localDataBytes, greaterThan(0));
    expect(restored, expected);
  });

  test('storage metrics match persisted settings payload size', () async {
    final source = _MemorySettingsSource();
    final repository = LocalSettingsRepository(source);
    await repository.savePreferences(const LearningPreferences());

    final metrics = await repository.loadStorageMetrics();

    expect(metrics.localDataBytes, utf8.encode(source.payload!).length);
  });
}
