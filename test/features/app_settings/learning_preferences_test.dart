import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/app_settings/domain/learning_preferences.dart';

void main() {
  test('defaults to normal speech, standard text, and visible translation', () {
    const preferences = LearningPreferences();

    expect(preferences.speechRate, 1.0);
    expect(preferences.textScaleFactor, 1.0);
    expect(preferences.showAutomaticTranslation, isTrue);
  });

  test('normalizes speech rate to slow or normal presets', () {
    final slow = LearningPreferences.normalized(speechRate: 0.72);
    final normal = LearningPreferences.normalized(speechRate: 0.93);

    expect(slow.speechRate, 0.75);
    expect(slow.speechRatePreset, SpeechRatePreset.slow);
    expect(normal.speechRate, 1.0);
    expect(normal.speechRatePreset, SpeechRatePreset.normal);
  });

  test('clamps and snaps text scale to supported five-percent steps', () {
    expect(
      LearningPreferences.normalized(textScaleFactor: 0.4).textScaleFactor,
      LearningPreferences.minimumTextScale,
    );
    expect(
      LearningPreferences.normalized(textScaleFactor: 9).textScaleFactor,
      LearningPreferences.maximumTextScale,
    );
    expect(
      LearningPreferences.normalized(textScaleFactor: 1.12).textScaleFactor,
      1.1,
    );
    expect(
      LearningPreferences.normalized(textScaleFactor: 1.14).textScaleFactor,
      1.15,
    );
  });

  test('copyWith preserves unrelated preferences', () {
    const original = LearningPreferences(
      speechRatePreset: SpeechRatePreset.slow,
      textScaleFactor: 1.2,
      showAutomaticTranslation: false,
    );

    final updated = original.copyWith(textScaleFactor: 0.95);

    expect(updated.speechRatePreset, SpeechRatePreset.slow);
    expect(updated.textScaleFactor, 0.95);
    expect(updated.showAutomaticTranslation, isFalse);
  });
}
