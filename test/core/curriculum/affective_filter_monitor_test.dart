import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/affective_filter_monitor.dart';

void main() {
  group('AffectiveFilterMonitor Unit Tests (N031)', () {
    const monitor = AffectiveFilterMonitor(highFilterThreshold: 0.60);

    test('Smooth and fast session keeps affective filter low and receptive', () {
      final state = monitor.evaluateSession(
        averageLatencySeconds: 2.1,
        backspaceCorrectionsCount: 1,
        consecutiveMistakes: 0,
        sessionDurationMinutes: 12,
      );

      expect(state.isHighFilter, isFalse);
      expect(state.filterScore, lessThan(0.30));
      expect(state.recommendedDifficultyMultiplier, equals(1.0));
      expect(state.cognitivePacingAction, contains('Optimal Receptivity'));
    });

    test('High latency, repeated mistakes, and fatigue trigger protective de-escalation', () {
      final state = monitor.evaluateSession(
        averageLatencySeconds: 7.5,
        backspaceCorrectionsCount: 8,
        consecutiveMistakes: 3,
        sessionDurationMinutes: 45,
      );

      expect(state.isHighFilter, isTrue);
      expect(state.filterScore, greaterThanOrEqualTo(0.60));
      expect(state.recommendedDifficultyMultiplier, lessThan(1.0));
      expect(state.cognitivePacingAction, contains('De-escalation'));
    });
  });
}
