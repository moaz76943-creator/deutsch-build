import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/pronunciation/domain/pronunciation_models.dart';
import 'package:deutsch_bilarabi/features/pronunciation/pronunciation_signal_evaluator.dart';

void main() {
  test('accepts usable local signal without inventing phoneme accuracy', () {
    const capture = PronunciationSignalCapture.available(
      PronunciationSignalFeatures(
        captureDurationMs: 1200,
        voicedDurationMs: 650,
        rms: .12,
        peak: .62,
        zeroCrossingRate: .08,
      ),
    );

    final feedback = PronunciationSignalEvaluator.evaluate(
      capture: capture,
      targetToken: 'fühlen',
    );

    expect(feedback.signalAvailable, isTrue);
    expect(feedback.signalUsable, isTrue);
    expect(feedback.phonemeAccuracyAvailable, isFalse);
    expect(feedback.timingScore, inInclusiveRange(0, 1));
  });

  test('fails closed when microphone signal is unavailable', () {
    final feedback = PronunciationSignalEvaluator.evaluate(
      capture: const PronunciationSignalCapture.unavailable(
        'microphone_permission_required',
      ),
      targetToken: 'Stadt',
    );

    expect(feedback.signalAvailable, isFalse);
    expect(feedback.signalUsable, isFalse);
    expect(feedback.phonemeAccuracyAvailable, isFalse);
  });
}
