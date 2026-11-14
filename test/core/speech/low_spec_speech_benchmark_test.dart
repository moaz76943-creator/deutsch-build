import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/low_spec_speech_benchmark.dart';

void main() {
  group('LowSpecSpeechBenchmark Tests (Pillar 2 Gate)', () {
    const benchmark = LowSpecSpeechBenchmark();

    test('Demonstrates real-time factor RTF < 0.40 and low memory footprint', () {
      final report = benchmark.runBenchmark();

      expect(report.isCompliant, isTrue);
      expect(report.realTimeFactor, lessThan(0.40));
      expect(report.allocatedMemoryBytes, lessThan(40 * 1024 * 1024));
    });
  });
}
