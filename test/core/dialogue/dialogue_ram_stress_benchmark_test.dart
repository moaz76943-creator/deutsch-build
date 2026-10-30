import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/dialogue_ram_stress_benchmark.dart';

void main() {
  group('DialogueRamStressBenchmark Tests', () {
    const benchmark = DialogueRamStressBenchmark();

    test('100-turn dialogue stress test strictly stays under 180MB RAM ceiling', () {
      final result = benchmark.execute100TurnStressTest();

      expect(result.totalSimulatedTurns, equals(100));
      expect(result.isWithinSovereignBudget, isTrue);
      expect(result.peakMemoryMb, lessThan(180.0));
      expect(result.peakMemoryMb, lessThan(125.0)); // Highly optimized sliding window
      expect(result.compactionsTriggered, greaterThan(80));
      expect(result.auditVerdict, equals('MEMORY_STRESS_PASSED_LEAK_FREE'));
    });

    test('Stress audit result serializes to diagnostic JSON metrics', () {
      final result = benchmark.execute100TurnStressTest();
      final json = result.toJson();

      expect(json['totalSimulatedTurns'], equals(100));
      expect(json.containsKey('peakMemoryMb'), isTrue);
      expect(json['isWithinSovereignBudget'], isTrue);
    });
  });
}
