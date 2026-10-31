import 'package:test/test.dart';
import 'package:deutsch_build/src/core/build/final_release_quality_gate.dart';

void main() {
  group('FinalReleaseQualityGate Tests', () {
    const gate = FinalReleaseQualityGate();

    test('All five sovereign subsystem pillars report 100% healthy', () {
      final audits = gate.evaluateAllSubsystems();

      expect(audits.length, equals(5));
      expect(audits.every((a) => a.isHealthy), isTrue);
      expect(gate.isProductionReady(), isTrue);
    });
  });
}
