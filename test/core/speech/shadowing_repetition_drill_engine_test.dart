import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/shadowing_repetition_drill_engine.dart';

void main() {
  group('ShadowingRepetitionDrillEngine Tests', () {
    const engine = ShadowingRepetitionDrillEngine();

    test('Awards high score when learner shadows near 400ms target offset', () {
      final report = engine.evaluateShadowing(
        referenceAudioDuration: const Duration(milliseconds: 2000),
        learnerSpokenDuration: const Duration(milliseconds: 2050),
        observedLatencyOffset: const Duration(milliseconds: 420),
      );

      expect(report.pacingSyncScore, greaterThanOrEqualTo(85.0));
      expect(report.durationRatio, closeTo(1.0, 0.05));
      expect(report.feedback, contains('رائع'));
    });

    test('Penalizes excessive latency lag between reference and echo', () {
      final report = engine.evaluateShadowing(
        referenceAudioDuration: const Duration(milliseconds: 2000),
        learnerSpokenDuration: const Duration(milliseconds: 1500),
        observedLatencyOffset: const Duration(milliseconds: 1200), // Too late
      );

      expect(report.pacingSyncScore, lessThan(60.0));
    });
  });
}
