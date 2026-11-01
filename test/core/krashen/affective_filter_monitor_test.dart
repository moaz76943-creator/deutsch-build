import 'package:test/test.dart';
import 'package:deutsch_build/src/core/krashen/affective_filter_monitor.dart';

void main() {
  group('AffectiveFilterMonitor Suite', () {
    const monitor = AffectiveFilterMonitor(sessionFatigueThresholdSeconds: 1200);

    test('Reports optimal low filter when latency is normal and zero errors occur', () {
      const metrics = InteractionMetrics(
        responseLatencyMs: 1100,
        expectedBaselineLatencyMs: 1200,
        hesitationFillerCount: 0,
        consecutiveErrorCount: 0,
        sessionDurationSeconds: 300,
      );

      final report = monitor.evaluateState(metrics);
      expect(report.isOptimalReception, isTrue);
      expect(report.recommendation, equals(PedagogicalIntervention.continueOptimalInput));
      expect(report.filterScore, closeTo(0.0, 0.05));
    });

    test('Detects high affective filter when consecutive errors and hesitation spike', () {
      const metrics = InteractionMetrics(
        responseLatencyMs: 3500,
        expectedBaselineLatencyMs: 1000,
        hesitationFillerCount: 3,
        consecutiveErrorCount: 3,
        sessionDurationSeconds: 600,
      );

      final report = monitor.evaluateState(metrics);
      expect(report.isInputObstructed, isTrue);
      expect(report.recommendation, equals(PedagogicalIntervention.offerPraiseAndEncouragement));
    });

    test('Detects cognitive fatigue after prolonged session duration', () {
      const metrics = InteractionMetrics(
        responseLatencyMs: 2000,
        expectedBaselineLatencyMs: 1200,
        hesitationFillerCount: 2,
        consecutiveErrorCount: 2,
        sessionDurationSeconds: 1500, // Exceeds threshold
      );

      final report = monitor.evaluateState(metrics);
      expect(report.isFatigueDetected, isTrue);
      expect(report.recommendation, equals(PedagogicalIntervention.suggestRestBreak));
    });
  });
}
