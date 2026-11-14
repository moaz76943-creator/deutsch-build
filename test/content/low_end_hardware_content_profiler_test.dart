import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/low_end_hardware_content_profiler.dart';

void main() {
  group('LowEndHardwareContentProfiler Unit Tests (L096)', () {
    const profiler = LowEndHardwareContentProfiler(maxMemoryCeilingMb: 45.0);

    test('Certifies content querying footprint within 45MB ceiling on budget devices', () {
      final report = profiler.evaluatePerformance(
        measuredMemoryMb: 28.5,
        queryLatencyMicros: 3500, // 3.5ms
      );

      expect(report.isWithinBudget, isTrue);
      expect(report.optimizationTier, equals('OPTIMAL_BALANCED'));
      expect(report.currentMemoryUsageMb, lessThan(45.0));
      expect(report.averageQueryLatencyMicros, lessThan(5000));
    });

    test('Flags over-budget memory spikes immediately', () {
      final report = profiler.evaluatePerformance(
        measuredMemoryMb: 52.0, // Over 45MB
        queryLatencyMicros: 12000,
      );

      expect(report.isWithinBudget, isFalse);
      expect(report.optimizationTier, equals('OVER_BUDGET_ACTION_REQUIRED'));
    });
  });
}
