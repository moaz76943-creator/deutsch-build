import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/continuous_speech_stress_audit.dart';

void main() {
  group('ContinuousSpeechStressAudit Tests', () {
    const audit = ContinuousSpeechStressAudit();

    test('Runs 50 continuous speech cycles without memory leaks', () {
      final report = audit.runAudit(cycles: 50);

      expect(report.completedCycles, equals(50));
      expect(report.hasLeakedBuffers, isFalse);
      expect(report.isPass, isTrue);
      expect(report.memoryDriftBytes, lessThan(3 * 1024 * 1024));
    });
  });
}
