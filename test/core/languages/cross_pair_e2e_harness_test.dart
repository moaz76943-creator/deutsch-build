import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/cross_pair_e2e_harness.dart';

void main() {
  group('100-Language CrossPairE2EHarness Tests', () {
    test('Executes end-to-end cross-pair transitions within sub-50ms latency', () async {
      final harness = CrossPairE2EHarness.fullPlatform();
      final result = await harness.runBenchmark();

      expect(result.totalPairsTested, equals(10));
      expect(result.successfulTransitions, equals(10));
      expect(result.allBidiTransitionsValid, isTrue);
      expect(result.averageLatencyMs, lessThan(50.0));
      expect(result.isPassed, isTrue);

      harness.dispatcher.dispose();
    });
  });
}
